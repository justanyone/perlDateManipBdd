#!/usr/bin/env python3
"""Run every explicit-pattern request twice per interface in clean processes."""
import concurrent.futures
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/pattern-parsing-family"
MANIFEST = FAMILY / "cases.json"
PROBE = ROOT / "tools/probes/pattern-parsing-family/probe.pl"
LIBRARY = ROOT / "local/date-manip-7.00/lib/perl5"
TIMEOUT = 15
WORKERS = 4


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def clean_environment():
    return {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "TZ": "Etc/UTC",
        "PERL5LIB": str(LIBRARY),
    }


def run_once(case_id, interface):
    with tempfile.TemporaryDirectory(prefix="date-manip-pattern-") as work_dir:
        return subprocess.run(
            ["perl", str(PROBE), interface, case_id], cwd=work_dir,
            env=clean_environment(), text=True, capture_output=True,
            timeout=TIMEOUT, check=False,
        )


def observe_case(case):
    routes = {}
    repeatable = True
    for interface in ("oo", "dm6"):
        attempts = [run_once(case["case_id"], interface) for _ in range(2)]
        same = all(
            (a.returncode, a.stdout, a.stderr)
            == (attempts[0].returncode, attempts[0].stdout, attempts[0].stderr)
            for a in attempts[1:]
        )
        repeatable = repeatable and same
        if attempts[0].returncode != 0:
            raise RuntimeError(
                f"{case['case_id']} {interface} exited {attempts[0].returncode}: {attempts[0].stderr}"
            )
        routes[interface] = {
            "repeatable": same,
            "process_stderr": attempts[0].stderr,
            "observation": json.loads(attempts[0].stdout),
        }
    return {
        "case_id": case["case_id"],
        "research_status": "repeatable" if repeatable else "disputed",
        "repeatable": repeatable,
        "routes": routes,
    }


def main():
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as executor:
        observations = list(executor.map(observe_case, manifest["cases"]))
    source_date = pathlib.Path("/tmp/Date-Manip-7.00/lib/Date/Manip/Date.pm")
    source_dm6 = pathlib.Path("/tmp/Date-Manip-7.00/lib/Date/Manip/DM6.pm")
    document = {
        "schema_version": 3,
        "status": "repeatable reference evidence with manually cross-checked draft literals; not approved for promotion",
        "command": "python3 tools/probes/pattern-parsing-family/run.py",
        "execution": {
            "repetitions_per_interface": 2,
            "timeout_seconds": TIMEOUT,
            "parallel_workers": WORKERS,
            "process_isolation": "Every OO and DM6 attempt ran in its own clean Perl process and private temporary working directory.",
            "environment": {k: clean_environment()[k] for k in ("LANG", "LC_ALL", "TZ")},
        },
        "provenance": {
            "release": "Date-Manip-7.00",
            "distribution_version": "7.00",
            "archive_sha256": "37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c",
            "tool_sha256": {
                "cases.json": sha256(MANIFEST), "probe.pl": sha256(PROBE),
                "run.py": sha256(pathlib.Path(__file__).resolve()),
            },
            "installed_module_sha256": {
                "Date.pm": sha256(LIBRARY / "Date/Manip/Date.pm"),
                "DM6.pm": sha256(LIBRARY / "Date/Manip/DM6.pm"),
            },
            "review_source_sha256": {
                "Date.pm": sha256(source_date) if source_date.exists() else None,
                "DM6.pm": sha256(source_dm6) if source_dm6.exists() else None,
            },
        },
        "observations": observations,
    }
    json.dump(document, sys.stdout, sort_keys=True, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
