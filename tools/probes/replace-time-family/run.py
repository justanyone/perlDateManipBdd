#!/usr/bin/env python3
"""Two fresh-process Date_SetTime observations from the pinned reference."""
from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/replace-time-family"
CORPUS = FAMILY / "cases.json"
BINDINGS = FAMILY / "bindings.json"
PROFILES = ROOT / "docs/automation/reference-profiles.json"
PROBE = Path(__file__).with_name("probe.pl")
REVIEW = Path(__file__).with_name("review.py")
FEATURE = ROOT / "spec/drafts/replace-time/replace-time.feature"
PORTABLE_FEATURE = ROOT / "spec/drafts/replace-time/replace-time-portable.feature"
PORTABLE_MAP = FAMILY / "portable-case-map.json"
DATE_LIB = ROOT / "local/date-manip-7.00/lib/perl5"
ENV = {"PATH":"/usr/bin:/bin", "LANG":"C.UTF-8", "LC_ALL":"C.UTF-8", "TZ":"Etc/UTC", "PERL5LIB":str(DATE_LIB)}
REFERENCE = {
    "release":"Date-Manip-7.00", "distribution_version":"7.00",
    "archive_sha256":"37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c",
    "archive_url":"https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz",
}

def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def module_hashes(paths: dict[str, str]) -> dict[str, str]:
    result = {}
    for module, raw in sorted(paths.items()):
        path = Path(raw).resolve()
        if not path.is_file() or DATE_LIB not in path.parents:
            raise AssertionError(f"module outside pinned dependency: {module}={raw}")
        result[module] = digest(path)
    return result

def observe(case: dict) -> dict:
    raw_runs, process_runs = [], []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix="dm-replace-time-") as cwd:
            run = subprocess.run(["/usr/bin/perl", str(PROBE), case["case_id"]], cwd=cwd, env=ENV,
                                 capture_output=True, timeout=15)
        process_runs.append({"exit_code":run.returncode, "stderr":run.stderr.decode("utf-8", "surrogateescape")})
        if run.returncode or run.stderr:
            raise AssertionError((case["case_id"], run.returncode, run.stderr))
        raw_runs.append(run.stdout)
    if raw_runs[0] != raw_runs[1]:
        raise AssertionError(f"{case['case_id']}: native payload differs across fresh processes")
    result = json.loads(raw_runs[0])
    required = {"case_id", "request", "operation_id", "public_symbol", "profile_expected",
                "fixture_expected_distribution_version", "fixture_expected_backend_version",
                "observed_distribution_version", "observed_backend_version", "configured_zone",
                "configuration_return", "runtime", "loaded_binding_file", "loaded_module_paths",
                "scalar_context", "list_context", "warnings", "call_stdout", "exception", "exception_stage"}
    missing = required - result.keys()
    if missing: raise AssertionError(f"{case['case_id']}: missing fields {sorted(missing)}")
    if result["exception"] is not None or result["call_stdout"]:
        raise AssertionError(f"{case['case_id']}: setup exception or unexpected stdout")
    if result["request"] != case or result["operation_id"] != "date.replace-time":
        raise AssertionError(f"{case['case_id']}: request identity mismatch")
    if result["configured_zone"].lower() not in {"utc", "etc/utc"}: raise AssertionError(f"{case['case_id']}: zone drift")
    if result["observed_distribution_version"] != "7.00": raise AssertionError(f"{case['case_id']}: wrong release")
    result["native_payload_sha256"] = hashlib.sha256(raw_runs[0]).hexdigest()
    result["process_runs"] = process_runs
    return result

def main() -> None:
    cases = json.loads(CORPUS.read_text())["cases"]
    with ThreadPoolExecutor(max_workers=4) as pool:
        observations = list(pool.map(observe, cases))
    by_backend = {}
    for observation in observations:
        backend = observation["request"]["backend"]
        current = observation["loaded_module_paths"]
        if backend in by_backend and current != by_backend[backend]:
            raise AssertionError(f"{backend}: module set changed by case")
        by_backend[backend] = current
    artifact_files = [CORPUS, BINDINGS, PROFILES, PROBE, Path(__file__).resolve(), REVIEW, FEATURE, PORTABLE_FEATURE, PORTABLE_MAP]
    print(json.dumps({
        "schema_version": 1,
        "purpose":"fresh-process public Date_SetTime reference observations; not an executable BDD result",
        "export_status":"Reference-only evidence; exclude Perl binding, profile, and native diagnostic records from a future independent implementation handoff.",
        "reference":REFERENCE, "repetitions":2, "timeout_seconds":15, "environment":ENV,
        "runtime":observations[0]["runtime"],
        "loaded_module_sha256_by_backend":{backend:module_hashes(paths) for backend, paths in sorted(by_backend.items())},
        "sha256":{str(path.relative_to(ROOT)):digest(path) for path in artifact_files},
        "observations":observations,
    }, indent=2, sort_keys=True))

if __name__ == "__main__": main()
