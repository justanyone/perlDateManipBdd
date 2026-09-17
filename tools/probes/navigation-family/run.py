#!/usr/bin/env python3
"""Run public previous/next observations twice in isolated processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CASES = ROOT / "docs/research/navigation-family/cases.json"
PROBE = ROOT / "tools/probes/navigation-family/probe.pl"
PROFILE = ROOT / "docs/automation/reference-profiles.json"
LIBRARY = ROOT / "local/date-manip-7.00/lib/perl5"
ENV = {"PATH": "/usr/bin:/bin", "PERL5LIB": str(LIBRARY), "TZ": "Etc/UTC",
       "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8", "PERL_HASH_SEED": "0",
       "PERL_PERTURB_KEYS": "0"}
MODULES = tuple(LIBRARY / name for name in (
    "Date/Manip/Base.pm", "Date/Manip/Date.pm", "Date/Manip/Date.pod",
    "Date/Manip/Obj.pm", "Date/Manip/TZ.pm", "Date/Manip/DM6.pm",
    "Date/Manip/DM6.pod", "Date/Manip/DM5.pm", "Date/Manip/DM5.pod"))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def invoke(case_id):
    with tempfile.TemporaryDirectory(prefix="date-manip-navigation-") as cwd:
        return subprocess.run(["perl", str(PROBE), case_id], cwd=cwd, env=ENV,
                              capture_output=True, text=True, timeout=15, check=False)


def observe(case):
    attempts = [invoke(case["case_id"]) for _ in range(2)]
    first = attempts[0]
    repeatable = all((x.returncode, x.stdout, x.stderr) ==
                     (first.returncode, first.stdout, first.stderr) for x in attempts[1:])
    decoded = None
    decode_error = None
    try:
        decoded = json.loads(first.stdout) if first.stdout else None
    except json.JSONDecodeError as exc:
        decode_error = str(exc)
    return {"case_id": case["case_id"], "repeatable": repeatable,
            "research_status": "repeatable" if repeatable and first.returncode == 0 else "disputed",
            "exit_status": first.returncode, "observation": decoded,
            "process_stderr": first.stderr, "json_decode_error": decode_error}


def main():
    fixture = json.loads(CASES.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(observe, fixture["cases"]))
    print(json.dumps({
        "schema_version": 1,
        "status": "repeatable research evidence; literals remain unapproved",
        "execution": {"command": "python3 tools/probes/navigation-family/run.py",
                      "repetitions": 2, "fresh_process_per_attempt": True,
                      "fresh_temporary_working_directory_per_attempt": True,
                      "timeout_seconds": 15, "parallel_workers": 4,
                      "environment": ENV},
        "fixture_sha256": digest(CASES),
        "sha256": {str(p.relative_to(ROOT)): digest(p) for p in (CASES, PROBE, PROFILE, Path(__file__).resolve())},
        "installed_module_sha256": {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(MODULES) | {Path(path) for row in rows for path in row["observation"]["loaded_modules"].values()})},
        "reference_assertions": fixture["reference"],
        "observations": rows,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
