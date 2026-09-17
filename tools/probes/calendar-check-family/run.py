#!/usr/bin/env python3
"""Run calendar check/check_time observations twice per isolated case."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CASES = ROOT / "docs/research/calendar-check-family/cases.json"
PROBE = ROOT / "tools/probes/calendar-check-family/probe.pl"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
MODULE_ROOT = ROOT / "local/date-manip-7.00/lib/perl5"
MODULES = tuple(sorted((MODULE_ROOT / "Date/Manip").rglob("*.pm")))
RESEARCH_SOURCES = (
    MODULE_ROOT / "Date/Manip/Base.pm",
    MODULE_ROOT / "Date/Manip/Base.pod",
    ROOT / "docs/research/contracts/calendar.json",
)
ENV = {
    "PATH": "/usr/bin:/bin", "PERL5LIB": str(MODULE_ROOT),
    "TZ": "Etc/UTC", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
    "PERL_HASH_SEED": "0", "PERL_PERTURB_KEYS": "0",
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def observe(case):
    attempts = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix="calendar-check-") as work:
            proc = subprocess.run(
                ["perl", str(PROBE), case["case_id"]], cwd=work, env=ENV,
                capture_output=True, timeout=15,
            )
        attempts.append({"exit_code": proc.returncode,
                         "stdout": proc.stdout, "stderr": proc.stderr})
    if attempts[0] != attempts[1]:
        raise RuntimeError("nonrepeatable case: " + case["case_id"])
    if attempts[0]["exit_code"]:
        raise RuntimeError(case["case_id"] + ": " + repr(attempts[0]))
    return {
        "case_id": case["case_id"], "research_status": "repeatable",
        "observation": json.loads(attempts[0]["stdout"].decode("utf-8")),
        "process_stderr_hex": attempts[0]["stderr"].hex(),
    }


if __name__ == "__main__":
    manifest = json.loads(CASES.read_text())
    fixture = json.loads(FIXTURE.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(observe, manifest["cases"]))
    result = {
        "schema_version": 1,
        "status": "research observations; reviewed feature literals are frozen separately",
        "reference": fixture["reference"],
        "sha256": {str(p.relative_to(ROOT)): sha(p)
                   for p in (CASES, PROBE, FIXTURE, Path(__file__).resolve())},
        "installed_module_sha256": {
            str(p.relative_to(ROOT)): sha(p) for p in MODULES
        },
        "research_source_sha256": {
            str(p.relative_to(ROOT)): sha(p) for p in RESEARCH_SOURCES
        },
        "execution": {
            "repetitions_per_case": 2, "parallel_workers": 4,
            "timeout_seconds": 15,
            "fresh_process_and_temporary_working_directory_per_attempt": True,
            "environment": ENV,
        },
        "observations": rows,
    }
    print(json.dumps(result, indent=2, sort_keys=True, ensure_ascii=False))
