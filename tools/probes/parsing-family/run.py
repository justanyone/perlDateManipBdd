#!/usr/bin/env python3
"""Capture repeatable research observations without deriving expected values."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CORPUS = ROOT / 'docs/research/parsing-family/cases.json'
PROBE = ROOT / 'tools/probes/parsing-family/probe.pl'
FIXTURE = ROOT / 'docs/automation/reference-profiles.json'
ENV = {'PATH': os.environ['PATH'], 'PERL5LIB': str(ROOT / 'local/date-manip-7.00/lib/perl5'),
       'TZ': 'Etc/UTC', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8'}

def observe(case):
    results = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='date-parse-research-') as work:
            result = subprocess.run(['perl', str(PROBE), case['case_id']], cwd=work,
                                    env=ENV, capture_output=True, text=True, timeout=15)
        results.append({'exit_code': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr})
    if results[0] != results[1]:
        raise RuntimeError('Nonrepeatable case: ' + case['case_id'])
    if results[0]['exit_code']:
        raise RuntimeError(results[0])
    return {'case_id': case['case_id'], 'research_status': 'repeatable',
            'observation': json.loads(results[0]['stdout']), 'process_stderr': results[0]['stderr']}

if __name__ == '__main__':
    cases = json.loads(CORPUS.read_text())['cases']
    with ThreadPoolExecutor(max_workers=4) as pool:
        rows = list(pool.map(observe, cases))
    print(json.dumps({'schema_version': 1, 'status': 'research observations; semantic review pending',
        'sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                   for p in (CORPUS, PROBE, FIXTURE, Path(__file__).resolve())},
        'execution': {'repetitions': 2, 'timeout_seconds': 15, 'parallel_workers': 4, 'environment': ENV},
        'observations': rows}, indent=2))
