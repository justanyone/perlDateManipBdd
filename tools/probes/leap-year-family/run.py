#!/usr/bin/env python3
"""Capture public leap-year behavior twice in fresh bounded processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
MANIFEST = ROOT / 'docs/research/leap-year-family/cases.json'
PROBE = ROOT / 'tools/probes/leap-year-family/probe.pl'
PROFILE = ROOT / 'docs/automation/reference-profiles.json'
CONTRACT = ROOT / 'docs/research/contracts/calendar.json'
RUNNER = Path(__file__).resolve()
PERL = '/usr/bin/perl'
ENVIRONMENT = {
    'PATH': '/usr/bin:/bin',
    'PERL5LIB': str(ROOT / 'local/date-manip-7.00/lib/perl5'),
    'TZ': 'Etc/UTC',
    'LANG': 'C.UTF-8',
    'LC_ALL': 'C.UTF-8',
}
CASES = json.loads(MANIFEST.read_text())['cases']


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(case_id):
    runs = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='datemanip-leap-year-') as cwd:
            completed = subprocess.run(
                [PERL, str(PROBE), case_id],
                cwd=cwd,
                env=ENVIRONMENT,
                text=True,
                capture_output=True,
                timeout=15,
                check=False,
            )
        runs.append({
            'exit_code': completed.returncode,
            'stdout': completed.stdout,
            'stderr': completed.stderr,
        })
    if runs[0] != runs[1]:
        raise RuntimeError(f'nonrepeatable observation: {case_id}')
    if runs[0]['exit_code'] != 0 or runs[0]['stderr']:
        raise RuntimeError(f'probe process failure: {case_id}: {runs[0]}')
    return json.loads(runs[0]['stdout'])


with ThreadPoolExecutor(max_workers=4) as pool:
    observations = list(pool.map(lambda row: execute(row['case_id']), CASES))

hashed = [MANIFEST, PROBE, PROFILE, CONTRACT, RUNNER]
for relative in (
    'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Config.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Date.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Misc.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Obj.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/TZ.pm',
):
    hashed.append(ROOT / relative)

record = {
    'schema_version': 1,
    'status': 'research evidence; literal and semantic review required',
    'operation_id': 'calendar.is-leap-year',
    'execution': {
        'command': 'python3 tools/probes/leap-year-family/run.py',
        'perl': PERL,
        'environment': ENVIRONMENT,
        'repetitions_per_case': 2,
        'fresh_temporary_directory_per_repetition': True,
        'timeout_seconds': 15,
        'parallel_workers': 4,
    },
    'sha256': {str(path.relative_to(ROOT)): sha256(path) for path in hashed},
    'observations': observations,
}
print(json.dumps(record, indent=2))
