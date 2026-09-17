#!/usr/bin/env python3
"""Run the canonical language corpus twice in clean, fresh processes."""
import concurrent.futures
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
FIXTURE_PATH = ROOT / "docs/research/language-family/cases.json"
FIXTURE_BYTES = FIXTURE_PATH.read_bytes()
FIXTURE_SHA256 = hashlib.sha256(FIXTURE_BYTES).hexdigest()
FIXTURES = json.loads(FIXTURE_BYTES.decode("utf-8"))
PERL = shutil.which("perl") or "perl"
PROBE = ROOT / "tools/probes/language-family/probe.pl"
ENV = {
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "TZ": "Etc/UTC",
    "PERL_HASH_SEED": "0",
    "PERL_PERTURB_KEYS": "0",
    "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
    "PATH": os.environ.get("PATH", ""),
}


def invoke(profile, mode, language_id):
    with tempfile.TemporaryDirectory(prefix="date-manip-language-") as cwd:
        return subprocess.run(
            [PERL, str(PROBE), profile, mode, language_id],
            cwd=cwd,
            env=ENV,
            text=True,
            encoding="utf-8",
            capture_output=True,
            timeout=15,
            check=False,
        )


def run_case(case):
    profile, mode, language_id = case
    attempts = [invoke(profile, mode, language_id) for _ in range(2)]
    first = attempts[0]
    same = all(
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
        "case_id": "-".join(case),
        "repeatable": same,
        "research_status": "repeatable" if same and first.returncode == 0 and fixture_matches else "disputed",
        "exit_status": first.returncode,
        "observation": observation,
        "stderr": first.stderr,
        "json_decode_error": decode_error,
        "fixture_hash_matches": fixture_matches,
    }


def corpus(profile):
    modes = ["ascii", "utf8"] if profile == "dm6" else ["legacy-default", "legacy-international"]
    cases = [(profile, mode, language["id"]) for language in FIXTURES["languages"] for mode in modes]
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(run_case, cases))
    return {
        "schema_version": 1,
        "status": "research evidence; no expected value is approved",
        "command": f"python3 tools/probes/language-family/run-corpus.py {profile}",
        "profile": profile,
        "repetitions": 2,
        "timeout_seconds": 15,
        "parallel_workers": 4,
        "clean_environment_keys": sorted(ENV),
        "fresh_temporary_working_directory_per_attempt": True,
        "fixture_file": "docs/research/language-family/cases.json",
        "fixture_sha256": FIXTURE_SHA256,
        "sha256": {
            str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path):
                hashlib.sha256(path.read_bytes()).hexdigest()
            for path in [PROBE, pathlib.Path(__file__).resolve(), FIXTURE_PATH,
                         ROOT / "local/date-manip-7.00/lib/perl5/Date/Manip/Date.pm",
                         ROOT / "local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm",
                         pathlib.Path("/tmp/Date-Manip-7.00.tar.gz")]
        },
        "reference_assertions": FIXTURES["reference_assertions"],
        "observations": rows,
    }


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("profile", choices=("dm6", "dm5"))
    args = parser.parse_args()
    print(json.dumps(corpus(args.profile), ensure_ascii=False, sort_keys=True, indent=2))
