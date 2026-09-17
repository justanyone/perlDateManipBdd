#!/usr/bin/env python3
"""Capture two isolated public week-count matrices with exact provenance."""
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
PROBE = Path(__file__).with_name('probe.pl')
MANIFEST = ROOT / 'docs/research/week-count-family/cases.json'
LIB = ROOT / 'local/date-manip-7.00/lib/perl5'
env = {'PATH':'/usr/bin:/bin', 'PERL5LIB':str(LIB), 'TZ':'Etc/UTC',
       'LANG':'C.UTF-8', 'LC_ALL':'C.UTF-8', 'PERL_HASH_SEED':'0', 'PERL_PERTURB_KEYS':'0'}
runs = []
for _ in range(2):
    with tempfile.TemporaryDirectory(prefix='week-count-') as cwd:
        result = subprocess.run(['/usr/bin/perl', str(PROBE)], cwd=cwd, env=env,
                                capture_output=True, timeout=30, check=True)
    assert result.stderr == b''
    runs.append(result.stdout)
assert runs[0] == runs[1]
data = json.loads(runs[0])
files = [MANIFEST, PROBE, Path(__file__).resolve()]
loaded = {}
for name, path in data['loaded'].items():
    path = Path(path).resolve()
    assert path == LIB / name
    loaded[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
print(json.dumps({'status':'repeatable research; no BDD execution or completeness claim',
                  'repetitions':2, 'environment':env,
                  'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
                  'loaded_sha256':loaded, 'observation':data}, indent=2, sort_keys=True))
