#!/usr/bin/env python3
"""Run every zones/business reference case twice in independent processes."""
from __future__ import annotations

import json
import hashlib
import tempfile
import os
from pathlib import Path
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = Path(__file__).resolve().parents[3]
PROBE = ROOT / 'tools/probes/zones-business-family/probe.pl'
FIXTURE = ROOT / 'tools/probes/zones-business-family/fixture.conf'
FIXTURE_DM5 = ROOT / 'tools/probes/zones-business-family/fixture-dm5.conf'
LIBRARY = ROOT / 'local/date-manip-7.00/lib/perl5'

def environment() -> dict[str, str]:
    return {
        'PATH': os.environ['PATH'], 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8',
        'TZ': 'Etc/UTC', 'PERL5LIB': str(LIBRARY), 'ZB_FIXTURE': str(FIXTURE),
        'ZB_FIXTURE_DM5': str(FIXTURE_DM5),
    }

def call(case_id: str) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix='date-zones-') as work:
        completed = subprocess.run(['perl', str(PROBE), case_id], cwd=work, env=environment(),
                                   text=True, capture_output=True, timeout=15, check=False)
    if completed.returncode:
        raise RuntimeError(f'{case_id}: exit {completed.returncode}: {completed.stderr}')
    record = json.loads(completed.stdout)
    record['process_stderr'] = completed.stderr
    return record

def twice(case_id: str) -> dict[str, object]:
    first, second = call(case_id), call(case_id)
    if first != second:
        raise RuntimeError(f'{case_id}: repeated fresh-process results differ')
    first['research_status'] = 'repeatable'
    return first

def main() -> None:
    listed = subprocess.run(['perl', str(PROBE), '--list'], cwd=ROOT, env=environment(),
                            text=True, capture_output=True, check=True).stdout.splitlines()
    with ThreadPoolExecutor(max_workers=4) as executor:
        records = list(executor.map(twice, listed))
    print(json.dumps({
        'schema_version': 1,
        'status': 'research-only; every case is repeatable but awaits coordinator review',
        'execution': {'command': 'python3 tools/probes/zones-business-family/run.py',
                      'separate_process_per_case': True, 'repetitions': 2,
                      'timeout_seconds': 15, 'maximum_parallel_processes': 4,
                      'environment': {'TZ': 'Etc/UTC', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8',
                                      'PERL5LIB': str(LIBRARY)}},
        'sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                   for p in (PROBE, FIXTURE, FIXTURE_DM5, Path(__file__).resolve())},
        'observations': records,
    }, sort_keys=True, indent=2))

if __name__ == '__main__':
    main()
