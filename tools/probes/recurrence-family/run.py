#!/usr/bin/env python3
"""Run bounded, original recurrence probes twice in isolated reference processes."""
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[3]
probe = root / 'tools/probes/recurrence-family/probe.pl'
modifier_cases = [
    'pd', 'pt', 'nd', 'nt', 'wd', 'fd', 'bd', 'fw', 'bw', 'cwd',
    'cwn', 'cwp', 'nwd', 'pwd', 'dwd', 'ibd', 'nbd', 'iw', 'nw', 'easter',
]
cases = [f'modifier-{name}' for name in modifier_cases] + [
    'create-and-empty-read', 'create-from-date-context', 'parse-serialized-and-recovery',
    'field-read-replace', 'nth-missing-and-indexes', 'navigation-and-bounds',
    'dates-temporary-range-and-empty-filter',
    'frequency-numeric-and-written-shapes', 'frequency-invalid-and-recovery',
    'typed-setter-equivalence', 'range-and-attempt-limits',
    'modifier-boundaries-order-and-recovery',
    'functional-dm5-description', 'functional-dm6-description',
    'functional-dm5-endpoint', 'functional-dm6-endpoint',
]
env = {
    'PATH': '/usr/bin:/bin',
    'PERL5LIB': str(root / 'local/date-manip-7.00/lib/perl5'),
    'TZ': 'Etc/UTC', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8',
}
rows = []
with tempfile.TemporaryDirectory(prefix='datemanip-recur-family-') as work:
    for case in cases:
        command = ['perl', str(probe), case]
        first = subprocess.run(command, env=env, cwd=work, text=True, capture_output=True, timeout=15, check=True)
        second = subprocess.run(command, env=env, cwd=work, text=True, capture_output=True, timeout=15, check=True)
        if (first.stdout, first.stderr) != (second.stdout, second.stderr):
            raise RuntimeError(f'nonrepeatable observation: {case}')
        row = json.loads(first.stdout)
        row.update(process_stderr=first.stderr, research_status='repeatable')
        rows.append(row)

print(json.dumps({
    'schema_version': 1,
    'status': 'research-only; semantic review pending',
    'reference_profile_record': 'docs/automation/reference-profiles.json',
    'reference_profile_sha256': hashlib.sha256((root / 'docs/automation/reference-profiles.json').read_bytes()).hexdigest(),
    'probe': 'tools/probes/recurrence-family/probe.pl',
    'probe_sha256': hashlib.sha256(probe.read_bytes()).hexdigest(),
    'execution': {
        'command': 'python3 tools/probes/recurrence-family/run.py',
        'separate_process_per_case': True, 'repetitions': 2, 'timeout_seconds': 15, 'environment': env,
    },
    'observations': rows,
}, indent=2))
