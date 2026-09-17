#!/usr/bin/env python3
"""Run each public Date set probe twice in fresh clean processes."""
import concurrent.futures
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
FIXTURE_PATH = ROOT / "docs/research/date-set-family/cases.json"
FIXTURE_BYTES = FIXTURE_PATH.read_bytes()
FIXTURE_SHA256 = hashlib.sha256(FIXTURE_BYTES).hexdigest()
FIXTURES = json.loads(FIXTURE_BYTES.decode("utf-8"))
PROBE = ROOT / "tools/probes/date-set-family/probe.pl"
PERL = shutil.which("perl") or "perl"
ENV = {
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "TZ": "Etc/UTC",
    "PERL_HASH_SEED": "0",
    "PERL_PERTURB_KEYS": "0",
    "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
    "PATH": os.environ.get("PATH", ""),
}


def invoke(case_id):
    with tempfile.TemporaryDirectory(prefix="date-manip-date-set-") as cwd:
        return subprocess.run(
            [PERL, str(PROBE), case_id],
            cwd=cwd,
            env=ENV,
            text=True,
            encoding="utf-8",
            capture_output=True,
            timeout=15,
            check=False,
        )


def run_case(case):
    attempts = [invoke(case["case_id"]) for _ in range(2)]
    first = attempts[0]
    repeatable = all(
        attempt.returncode == first.returncode
        and attempt.stdout == first.stdout
        and attempt.stderr == first.stderr
        for attempt in attempts[1:]
    )
    observation = None
    decode_error = None
    if first.stdout:
        try:
            observation = json.loads(first.stdout)
        except json.JSONDecodeError as exc:
            decode_error = str(exc)
    fixture_matches = observation is not None and observation.get("fixture_sha256") == FIXTURE_SHA256
    return {
        "case_id": case["case_id"],
        "repeatable": repeatable,
        "research_status": "repeatable" if repeatable and first.returncode == 0 and fixture_matches else "disputed",
        "exit_status": first.returncode,
        "fixture_hash_matches": fixture_matches,
        "observation": observation,
        "stderr": first.stderr,
        "json_decode_error": decode_error,
    }


def main():
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(run_case, FIXTURES["cases"]))
    module_dir = ROOT / "local/date-manip-7.00/lib/perl5/Date/Manip"
    print(json.dumps({
        "schema_version": 1,
        "status": "research evidence; no expected value is approved",
        "command": "python3 tools/probes/date-set-family/run.py",
        "repetitions": 2,
        "timeout_seconds": 15,
        "parallel_workers": 4,
        "clean_environment_keys": sorted(ENV),
        "fresh_temporary_working_directory_per_attempt": True,
        "fixture_file": "docs/research/date-set-family/cases.json",
        "fixture_sha256": FIXTURE_SHA256,
        "sha256": {
            str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in [PROBE, pathlib.Path(__file__).resolve(), FIXTURE_PATH,
                         module_dir / "Date.pod",
                         module_dir / "Date.pm", module_dir / "Obj.pm",
                         module_dir / "Base.pm", module_dir / "TZ.pm"]
        },
        "reference_assertions": FIXTURES["reference"],
        "observations": rows,
    }, ensure_ascii=False, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()
