#!/usr/bin/env python3
"""Compare uninstrumented and call-traced research probes; never a conformance run."""
from concurrent.futures import ThreadPoolExecutor
import csv
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
HOOK = ROOT / 'tools/research-coverage/trace-calls.pl'
INVENTORY = ROOT / 'docs/planning/perl-api-inventory.csv'
CASES = [
    ('calendar', 'tools/probes/calendar-contracts.pl', 'CAL-calendar.is-leap-year-leap-2000-base-scalar'),
    ('calendar', 'tools/probes/calendar-contracts.pl', 'CAL-calendar.is-leap-year-leap-2000-dm6-scalar'),
    ('calendar', 'tools/probes/calendar-contracts.pl', 'CAL-calendar.is-leap-year-leap-2000-dm5-scalar'),
    ('parse', 'tools/probes/parsing-family/probe.pl', 'PARSE-ISO-DATE-COMPLETE-02-DEFAULT-OO'),
    ('parse', 'tools/probes/parsing-family/probe.pl', 'PARSE-INVALID-INVALID-LEAP-OO'),
    ('recurrence', 'tools/probes/recurrence-family/probe.pl', 'modifier-pd'),
    ('recurrence', 'tools/probes/recurrence-family/probe.pl', 'typed-setter-equivalence'),
    ('arithmetic', 'tools/probes/arithmetic-family/arithmetic-family.pl', 'ARITH-OO-DATE-DATE-EXACT'),
]
ENV = {'PATH': os.environ['PATH'], 'PERL5LIB': str(ROOT / 'local/date-manip-7.00/lib/perl5'),
       'TZ': 'Etc/UTC', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8'}

def run(case):
    family, probe, case_id = case
    command = ['perl', str(ROOT / probe), case_id]
    attempts = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='datemanip-call-trace-') as work:
            plain = subprocess.run(command, cwd=work, env=ENV, capture_output=True, timeout=15)
            target = Path(work) / 'calls.json'
            tracing_env = {**ENV, 'PERL5DB': "require '" + str(HOOK) + "';",
                           'DATEMANIP_TRACE_FILE': str(target)}
            traced = subprocess.run([command[0], '-d', *command[1:]], cwd=work,
                                    env=tracing_env, capture_output=True, timeout=15)
            equivalent = (plain.returncode, plain.stdout, plain.stderr) == (traced.returncode, traced.stdout, traced.stderr)
            calls = json.loads(target.read_text())['calls'] if target.exists() else {}
            attempts.append({'channels_identical': equivalent, 'plain_exit': plain.returncode,
                'traced_exit': traced.returncode, 'plain_stdout_sha256': hashlib.sha256(plain.stdout).hexdigest(),
                'traced_stdout_sha256': hashlib.sha256(traced.stdout).hexdigest(),
                'plain_stderr': plain.stderr.decode(), 'traced_stderr': traced.stderr.decode(), 'calls': calls})
    repeatable = attempts[0] == attempts[1]
    return {'family': family, 'probe': probe, 'case_id': case_id,
            'repeatable': repeatable, 'accepted_trace': repeatable and attempts[0]['channels_identical']
            and attempts[0]['plain_exit'] == 0, **attempts[0]}

if __name__ == '__main__':
    with ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(run, CASES))
    declarations = list(csv.DictReader(INVENTORY.open()))
    observed_names = set().union(*(set(r['calls']) for r in results if r['accepted_trace']))
    observed = [r for r in declarations if r['module'] + '::' + r['callable'] in observed_names]
    missing = [r for r in declarations if r['module'] + '::' + r['callable'] not in observed_names]
    files = {HOOK, INVENTORY, Path(__file__).resolve(), ROOT / 'docs/automation/reference-profiles.json'}
    files.update(ROOT / c[1] for c in CASES)
    files.update(ROOT / p for p in ('docs/research/inputs/calendar.json',
        'docs/research/parsing-family/cases.json', 'docs/research/arithmetic-family/cases.json',
        'docs/research/arithmetic-family/extended-cases.json', 'docs/research/arithmetic-family/edge-cases.json'))
    print(json.dumps({'schema_version': 1, 'status': 'research call-coverage pilot; not full coverage or BDD verification',
        'limitations': ['Subroutine entries only; no branch or statement coverage.',
                       'Fixture/setup calls are included and are not behavioral assertions.',
                       'Only channel-identical repeatable runs contribute to covered declarations.',
                       'Anonymous calls and source-side tooling need separate accounting.'],
        'sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)},
        'probes': results, 'declaration_counts': {'total': len(declarations), 'observed': len(observed), 'unobserved': len(missing)},
        'observed_declarations': [{'module': r['module'], 'callable': r['callable']} for r in observed],
        'unobserved_declarations': [{'module': r['module'], 'callable': r['callable'], 'disposition': r['disposition']} for r in missing],
        }, indent=2))
