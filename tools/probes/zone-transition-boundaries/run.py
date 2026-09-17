#!/usr/bin/env python3
"""Run each public transition-boundary observation twice in isolation."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import datetime as dt
import sys
import zoneinfo
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CORPUS = ROOT / "docs/research/zone-transition-boundaries/cases.json"
PROBE = ROOT / "tools/probes/zone-transition-boundaries/probe.pl"
REVIEW = ROOT / "tools/probes/zone-transition-boundaries/review.py"
BINDINGS = ROOT / "docs/research/zone-transition-boundaries/bindings.json"
FEATURE_MAP = ROOT / "docs/research/zone-transition-boundaries/feature-map.json"
PROFILE = ROOT / "docs/automation/reference-profiles.json"
LIBRARY = ROOT / "local/date-manip-7.00/lib/perl5"
MODULES = tuple(LIBRARY / name for name in (
    "Date/Manip/Base.pm", "Date/Manip/Date.pm", "Date/Manip/Obj.pm",
    "Date/Manip/TZ.pm", "Date/Manip/Zones.pm",
    "Date/Manip/TZ/amnew_00.pm", "Date/Manip/TZ/aulord00.pm",
    "Date/Manip/TZ/etutc00.pm", "Date/Manip/TZ/eulond00.pm",
    "Date/Manip/TZ/paapia00.pm",
))
ENV = {
    "PATH": "/usr/bin:/bin",
    "PERL5LIB": str(LIBRARY),
    "TZ": "Etc/UTC",
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def call(case_id: str) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="zone-transition-boundary-") as work:
        result = subprocess.run(
            ["perl", str(PROBE), case_id], cwd=work, env=ENV,
            capture_output=True, text=True, timeout=15, check=False,
        )
    return {"exit_code": result.returncode, "stdout": result.stdout,
            "stderr": result.stderr}


def observe(case: dict[str, object]) -> dict[str, object]:
    first = call(str(case["case_id"]))
    second = call(str(case["case_id"]))
    if first != second:
        raise RuntimeError(f"nonrepeatable case: {case['case_id']}")
    if first["exit_code"]:
        raise RuntimeError(f"failed case {case['case_id']}: {first}")
    observation = json.loads(str(first["stdout"]))
    if observation["exception"]:
        raise RuntimeError(f"probe exception {case['case_id']}: {observation}")
    return {
        "case_id": case["case_id"],
        "research_status": "repeatable",
        "observation": observation,
        "process_attempts": [
            {"exit_code": first["exit_code"], "stderr": first["stderr"]},
            {"exit_code": second["exit_code"], "stderr": second["stderr"]},
        ],
    }


def one_runner_pass(cases: list[dict[str, object]]) -> list[dict[str, object]]:
    with ThreadPoolExecutor(max_workers=4) as pool:
        return list(pool.map(observe, cases))


def zoneinfo_provenance(cases: list[dict[str, object]]) -> dict[str, object]:
    version_file = Path("/usr/share/zoneinfo/tzdata.zi")
    version_line = next((line for line in version_file.read_text().splitlines() if line.startswith("# version ")), "")
    checked = 0
    for case in cases:
        zone = zoneinfo.ZoneInfo(str(case["zone"]))
        for fields, expected in zip(case["utc_points"], case["independent_expected_local"]):
            instant = dt.datetime(*fields, tzinfo=dt.timezone.utc).astimezone(zone)
            actual = instant.strftime("%Y-%m-%d %H:%M:%S %Z %z")
            if actual != expected:
                raise RuntimeError(f"zoneinfo mismatch {case['case_id']}: {actual!r} != {expected!r}")
            checked += 1
    return {
        "python_version": sys.version.split()[0],
        "zoneinfo_tzpath": list(zoneinfo.TZPATH),
        "tzdata_zi_path": str(version_file),
        "tzdata_zi_sha256": digest(version_file),
        "tzdata_zi_version_line": version_line,
        "comparison": "Python standard-library zoneinfo UTC conversion against each stored independent_expected_local literal",
        "checked_utc_instants": checked,
    }


def main() -> None:
    cases = json.loads(CORPUS.read_text())["cases"]
    profile = json.loads(PROFILE.read_text())
    observations = one_runner_pass(cases)
    repeat = one_runner_pass(cases)
    first_payload = json.dumps(observations, sort_keys=True, separators=(",", ":"))
    second_payload = json.dumps(repeat, sort_keys=True, separators=(",", ":"))
    if first_payload != second_payload:
        raise RuntimeError("whole runner passes differ")
    result = {
        "schema_version": 2,
        "status": "research observations; feature literals manually reviewed, not an approved specification",
        "reference": profile["reference"],
        "execution": {
            "command": "python3 tools/probes/zone-transition-boundaries/run.py",
            "repetitions": 2,
            "whole_runner_repetitions": 2,
            "whole_runner_payload_sha256": hashlib.sha256(first_payload.encode()).hexdigest(),
            "whole_runner_payloads_identical": True,
            "separate_process_per_attempt": True,
            "fresh_temporary_working_directory_per_attempt": True,
            "timeout_seconds": 15,
            "parallel_workers": 4,
            "environment": ENV,
        },
        "sha256": {str(path.relative_to(ROOT)): digest(path)
                   for path in (CORPUS, BINDINGS, FEATURE_MAP, PROBE, PROFILE, REVIEW, Path(__file__).resolve())},
        "installed_module_sha256": {
            str(path.relative_to(ROOT)): digest(path) for path in MODULES
        },
        "independent_zoneinfo": zoneinfo_provenance(cases),
        "observations": observations,
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
