#!/usr/bin/env python3
"""Capture repeated isolated public week-count edge requests."""
import hashlib
import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
PROBE = Path(__file__).with_name('probe.pl')
MANIFEST = ROOT / 'docs/research/week-count-edges/cases.json'
PROFILE = ROOT / 'docs/automation/reference-profiles.json'
LIB = ROOT / 'local/date-manip-7.00/lib/perl5'
RESEARCH_SOURCES = (
    LIB / 'Date/Manip/Base.pm', LIB / 'Date/Manip/Base.pod',
    LIB / 'Date/Manip/Obj.pm', ROOT / 'docs/research/contracts/calendar.json',
)
ENV = {'PATH': '/usr/bin:/bin', 'PERL5LIB': str(LIB), 'TZ': 'Etc/UTC',
       'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8', 'PERL_HASH_SEED': '0', 'PERL_PERTURB_KEYS': '0'}


def observe(case):
    outputs = []
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='week-count-edge-') as cwd:
            result = subprocess.run(['/usr/bin/perl', str(PROBE), case['case_id']], env=ENV,
                                    cwd=cwd, capture_output=True, timeout=20, check=True)
        assert result.stderr == b''
        outputs.append(result.stdout)
    assert outputs[0] == outputs[1], case['case_id']
    return json.loads(outputs[0])


cases = json.loads(MANIFEST.read_text())['cases']
with ThreadPoolExecutor(max_workers=4) as pool:
    observations = list(pool.map(observe, cases))
loaded = {}
for row in observations:
    for name, raw in row['loaded'].items():
        path = Path(raw).resolve()
        assert path == LIB / name
        loaded[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
files = [MANIFEST, PROFILE, PROBE, Path(__file__).resolve()]
print(json.dumps({'status': 'repeatable research only', 'repetitions': 2,
                  'fresh_process_and_workdir': True, 'timeout_seconds': 20, 'workers': 4,
                  'environment': ENV, 'observations': observations,
                  'source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
                  'research_source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in RESEARCH_SOURCES},
                  'loaded_sha256': loaded}, indent=2, sort_keys=True))
