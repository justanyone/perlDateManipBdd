#!/usr/bin/env python3
"""Two isolated observations per original input-history request."""
from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/input-history"
CORPUS = FAMILY / "cases.json"
PROFILE = ROOT / "docs/automation/reference-profiles.json"
BINDINGS = FAMILY / "bindings.json"
PROBE = Path(__file__).with_name("probe.pl")
DATE_LIB = ROOT / "local/date-manip-7.00/lib/perl5"
ENV = {
    "PATH": "/usr/bin:/bin",
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "TZ": "Etc/UTC",
    "PERL5LIB": str(DATE_LIB),
}
REQUIRED_MODULES = {
    "Date/Manip/Date.pm",
    "Date/Manip/Obj.pm",
    "Date/Manip/TZ.pm",
    "Date/Manip/Zones.pm",
    "Date/Manip/TZ/etutc00.pm",
}
REFERENCE = {
    "release": "Date-Manip-7.00",
    "distribution_version": "7.00",
    "archive_sha256": "37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c",
    "archive_url": "https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_observation_fields(result: dict, case_id: str) -> None:
    observation = result["observation"]
    required = {
        "configuration_error", "configuration_call_executed", "construction_mode",
        "configured_zone", "input_scalar", "input_list", "package_version",
        "profile_expected", "profile_echo", "runtime", "loaded_module_paths",
        "tzdata", "tzcode", "value", "version",
    }
    missing = required - observation.keys()
    if missing:
        raise AssertionError(f"{case_id}: missing probe fields {sorted(missing)}")
    if observation["configuration_error"] or observation["version"] != "7.00" or observation["package_version"] != "7.00":
        raise AssertionError(f"{case_id}: unexpected configured reference version")
    if observation["configured_zone"] != "Etc/UTC":
        raise AssertionError(f"{case_id}: configured zone was not Etc/UTC")
    loaded = observation["loaded_module_paths"]
    missing_modules = REQUIRED_MODULES - loaded.keys()
    if missing_modules:
        raise AssertionError(f"{case_id}: missing loaded modules {sorted(missing_modules)}")
    for module, raw_path in loaded.items():
        path = Path(raw_path).resolve()
        if not path.is_file() or DATE_LIB not in path.parents:
            raise AssertionError(f"{case_id}: loaded module outside pinned library: {module}={raw_path}")


def observe(case: dict) -> dict:
    native_runs: list[bytes] = []
    process_runs: list[dict] = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix="dm-input-") as work:
            process = subprocess.run(
                ["/usr/bin/perl", str(PROBE), case["case_id"]], cwd=work,
                env=ENV, capture_output=True, timeout=15,
            )
        process_runs.append({
            "exit_code": process.returncode,
            "stderr": process.stderr.decode("utf-8", "surrogateescape"),
        })
        if process.returncode != 0 or process.stderr:
            raise AssertionError((case["case_id"], process.returncode, process.stderr))
        native_runs.append(process.stdout)
    if native_runs[0] != native_runs[1]:
        raise AssertionError(f"{case['case_id']}: isolated native payloads differ")
    result = json.loads(native_runs[0])
    if result["exception"] is not None or result["warnings"] or result["call_stdout"]:
        raise AssertionError(result)
    require_observation_fields(result, case["case_id"])
    result["native_payload_sha256"] = hashlib.sha256(native_runs[0]).hexdigest()
    result["process_runs"] = process_runs
    return result


def main() -> None:
    cases = json.loads(CORPUS.read_text())["cases"]
    profiles = json.loads(PROFILE.read_text())["profiles"]
    profile = next(value for value in profiles if value["name"] == "oo")
    with ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(observe, cases))
    first = results[0]["observation"]
    loaded_paths = first["loaded_module_paths"]
    for result in results[1:]:
        observation = result["observation"]
        if observation["runtime"] != first["runtime"]:
            raise AssertionError("runtime varies between cases")
        if observation["loaded_module_paths"] != loaded_paths:
            raise AssertionError("loaded module set varies between cases")
        if observation["profile_expected"] != profile["configuration"]:
            raise AssertionError("fixture profile differs between cases")
    module_hashes = {module: sha256(Path(path)) for module, path in sorted(loaded_paths.items())}
    files = [CORPUS, PROFILE, BINDINGS, PROBE, Path(__file__).resolve(), Path(__file__).with_name("review.py")]
    print(json.dumps({
        "schema_version": 2,
        "purpose": "research-only public-call reference evidence; not a portable fixture or BDD result",
        "export_status": "Keep with reference research. Do not include this Perl/profile record in a future implementation-only handoff.",
        "reference": REFERENCE,
        "repetitions": 2,
        "timeout_seconds": 15,
        "environment": ENV,
        "fixture_expectation": {"profile_name": "oo", "ordered_configuration": profile["configuration"]},
        "runtime": first["runtime"],
        "configured_zone": first["configured_zone"],
        "loaded_module_paths": loaded_paths,
        "loaded_module_sha256": module_hashes,
        "sha256": {str(path.relative_to(ROOT)): sha256(path) for path in files},
        "observations": results,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
