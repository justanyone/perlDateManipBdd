#!/usr/bin/env python3
"""Repeat isolated public holiday-list requests with retained provenance."""
import hashlib
import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
MANIFEST = ROOT / 'docs/research/holiday-list-family/cases.json'
LIB = ROOT / 'local/date-manip-7.00/lib/perl5'
ENV = {'PATH': '/usr/bin:/bin', 'PERL5LIB': str(LIB), 'TZ': 'Etc/UTC',
       'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8', 'PERL_HASH_SEED': '0', 'PERL_PERTURB_KEYS': '0'}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def observe(case):
    attempts = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='holiday-list-') as cwd:
            process = subprocess.run(['/usr/bin/perl', str(HERE / 'probe.pl'), case['case_id']],
                                     env=ENV, cwd=cwd, capture_output=True, timeout=20)
        if process.returncode or process.stderr:
            raise RuntimeError((case['case_id'], process.returncode, process.stderr.decode()))
        attempts.append(process.stdout)
    assert attempts[0] == attempts[1], case['case_id']
    result = json.loads(attempts[0])
    result['process_attempts'] = [{'exit_code': 0, 'stdout_sha256': sha(raw),
                                   'stderr_sha256': sha(b'')} for raw in attempts]
    return result


cases = json.loads(MANIFEST.read_text())['cases']
with ThreadPoolExecutor(max_workers=4) as pool:
    observations = list(pool.map(observe, cases))
loaded = {}
for row in observations:
    for name, raw in row['loaded'].items():
        path = Path(raw).resolve()
        assert path == LIB / name
        loaded[str(path.relative_to(ROOT))] = sha(path.read_bytes())
files = [MANIFEST, HERE / 'probe.pl', HERE / 'fixture.conf', HERE / 'leap-fixture.conf',
         HERE / 'empty-fixture.conf', Path(__file__).resolve(),
         ROOT / 'docs/automation/reference-profiles.json', LIB / 'Date/Manip/Date.pod',
         LIB / 'Date/Manip/Holidays.pod']
print(json.dumps({'status': 'repeated research observations, not reviewed or BDD execution',
                  'execution': {'environment': ENV, 'fresh_process_and_directory': True,
                                'repetitions': 2, 'timeout_seconds': 20, 'workers': 4},
                  'observations': observations,
                  'source_sha256': {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in files},
                  'loaded_sha256': loaded}, indent=2, sort_keys=True))
