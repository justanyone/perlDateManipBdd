#!/usr/bin/env python3
"""Capture public year/day conversions twice in isolated processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/year-day-conversion-family'
MANIFEST = FAMILY / 'cases.json'
PROBE = ROOT / 'tools/probes/year-day-conversion-family/probe.pl'
RUNNER = Path(__file__).resolve()
PROFILE = ROOT / 'docs/automation/reference-profiles.json'
CONTRACT = ROOT / 'docs/research/contracts/calendar.json'
API_MAP = ROOT / 'docs/research/api/contract-map.json'
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


def observe(case):
    attempts = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='datemanip-year-day-') as cwd:
            result = subprocess.run(
                [PERL, str(PROBE), case['case_id']],
                cwd=cwd,
                env=ENVIRONMENT,
                text=True,
                capture_output=True,
                timeout=15,
                check=False,
            )
        attempts.append({'exit_code': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr})
    if attempts[0] != attempts[1]:
        raise RuntimeError(f"nonrepeatable case: {case['case_id']}")
    actual = attempts[0]
    if actual['exit_code'] or actual['stderr']:
        raise RuntimeError(f"probe process failed: {case['case_id']}: {actual}")
    observation = json.loads(actual['stdout'])
    observation['process_attempts'] = [
        {
            'exit_code': attempt['exit_code'],
            'stdout_sha256': hashlib.sha256(attempt['stdout'].encode()).hexdigest(),
            'stderr': attempt['stderr'],
            'stderr_sha256': hashlib.sha256(attempt['stderr'].encode()).hexdigest(),
        }
        for attempt in attempts
    ]
    observation['process_attempts_byte_equal'] = True
    return observation


with ThreadPoolExecutor(max_workers=4) as pool:
    observations = list(pool.map(observe, CASES))

source_paths = [
    'local/date-manip-7.00/lib/perl5/Date/Manip.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Date.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pod',
    'local/date-manip-7.00/lib/perl5/Date/Manip/Obj.pm',
    'local/date-manip-7.00/lib/perl5/Date/Manip/TZ.pm',
]
hashed = [MANIFEST, PROBE, RUNNER, PROFILE, CONTRACT, API_MAP, *[ROOT / path for path in source_paths]]
record = {
    'schema_version': 1,
    'status': 'reviewed reference evidence after literal and independent-calendar checks',
    'operation_ids': ['calendar.day-of-year', 'calendar.date-from-day-of-year'],
    'execution': {
        'command': 'python3 tools/probes/year-day-conversion-family/run.py',
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
print(json.dumps(record, indent=2, sort_keys=True))
