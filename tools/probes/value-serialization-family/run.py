#!/usr/bin/env python3
"""Capture each public Base split/join request twice in isolated processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CASES = ROOT / "docs/research/value-serialization-family/cases.json"
PROBE = ROOT / "tools/probes/value-serialization-family/probe.pl"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
MODULES = tuple(
    ROOT / "local/date-manip-7.00/lib/perl5" / name
    for name in (
        "Date/Manip/Base.pm", "Date/Manip/Date.pm", "Date/Manip/Obj.pm",
        "Date/Manip/TZ.pm", "Date/Manip/Zones.pm",
    )
)
ENV = {
    "PATH": "/usr/bin:/bin",
    "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
    "TZ": "Etc/UTC", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def observe(case):
    attempts = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix="value-serialization-") as work:
            result = subprocess.run(
                ["perl", str(PROBE), case["case_id"]], cwd=work, env=ENV,
                capture_output=True, text=True, timeout=15,
            )
        attempts.append({"exit_code": result.returncode,
                         "stdout": result.stdout, "stderr": result.stderr})
    if attempts[0] != attempts[1]:
        raise RuntimeError("nonrepeatable case: " + case["case_id"])
    if attempts[0]["exit_code"]:
        raise RuntimeError(case["case_id"] + ": " + repr(attempts[0]))
    return {
        "case_id": case["case_id"], "research_status": "repeatable",
        "observation": json.loads(attempts[0]["stdout"]),
        "process_stderr": attempts[0]["stderr"],
    }


if __name__ == "__main__":
    cases = json.loads(CASES.read_text())["cases"]
    fixture = json.loads(FIXTURE.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool:
        observations = list(pool.map(observe, cases))
    output = {
        "schema_version": 1,
        "status": "research observations; reviewed feature literals are frozen separately",
        "reference": fixture["reference"],
        "sha256": {str(p.relative_to(ROOT)): sha(p)
                   for p in (CASES, PROBE, FIXTURE, Path(__file__).resolve())},
        "installed_module_sha256": {str(p.relative_to(ROOT)): sha(p) for p in sorted({Path(path) for row in observations for path in row["observation"]["loaded_modules"].values()})},
        "execution": {
            "repetitions_per_case": 2, "timeout_seconds": 15,
            "parallel_workers": 4,
            "fresh_process_and_temporary_working_directory_per_attempt": True,
            "environment": ENV,
        },
        "observations": observations,
    }
    print(json.dumps(output, indent=2, sort_keys=True))
