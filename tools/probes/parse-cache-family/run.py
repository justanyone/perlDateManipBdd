#!/usr/bin/env python3
"""Run isolated Date::Manip parse/value sequence observations."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CORPUS = ROOT / "docs/research/parse-cache-family/cases.json"
PROBE = ROOT / "tools/probes/parse-cache-family/probe.pl"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
ENV = {
    "PATH": "/usr/bin:/bin",
    "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
    "TZ": "Etc/UTC",
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
}


def observe(case):
    runs = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix="parse-cache-research-") as work:
            result = subprocess.run(
                ["perl", str(PROBE), case["case_id"]], cwd=work, env=ENV,
                capture_output=True, text=True, timeout=15,
            )
        runs.append({"exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr})
    if runs[0] != runs[1]:
        raise RuntimeError("nonrepeatable case: " + case["case_id"])
    if runs[0]["exit_code"]:
        raise RuntimeError(runs[0])
    return {
        "case_id": case["case_id"],
        "research_status": "repeatable",
        "observation": json.loads(runs[0]["stdout"]),
        "process_stderr": runs[0]["stderr"],
    }


if __name__ == "__main__":
    cases = json.loads(CORPUS.read_text())["cases"]
    fixture = json.loads(FIXTURE.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(observe, cases))
    print(json.dumps({
        "schema_version": 2,
        "status": "research observations with explicit call completion; feature literals manually reviewed, disputed compatibility behavior",
        "sequence_result_rule": (
            "result and result_type exist only when call_completed is true; "
            "an interrupted call records its exception and has no return fields"
        ),
        "reference": fixture["reference"],
        "sha256": {
            str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in (CORPUS, PROBE, FIXTURE, Path(__file__).resolve(),
                         ROOT / "local/date-manip-7.00/lib/perl5/Date/Manip/Date.pm",
                         ROOT / "local/date-manip-7.00/lib/perl5/Date/Manip/Obj.pm")
        },
        "execution": {
            "repetitions": 2, "timeout_seconds": 15, "parallel_workers": 4,
            "fresh_temporary_working_directory_per_case": True, "environment": ENV,
        },
        "observations": rows,
    }, indent=2))
