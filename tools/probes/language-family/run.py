#!/usr/bin/env python3
"""Observe each public language selector twice in isolated reference processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT=Path(__file__).resolve().parents[3]
INVENTORY=ROOT/'docs/research/language-family/selector-inventory.json'
FIXTURE=ROOT/'docs/research/language-family/cases.json'
PROBE=ROOT/'tools/probes/language-family/selectors.pl'
LIB=ROOT/'local/date-manip-7.00/lib/perl5'
ENV={'PATH':os.environ['PATH'],'PERL5LIB':str(LIB),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}

def observe(selector):
    attempts=[]
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='language-selector-') as work:
            r=subprocess.run(['perl',str(PROBE),selector],cwd=work,env=ENV,
                             capture_output=True,text=True,timeout=15)
        attempts.append((r.returncode,r.stdout,r.stderr))
    assert attempts[0]==attempts[1],selector
    assert attempts[0][0]==0,(selector,attempts[0])
    return {'selector':selector,'repeatable':True,'exit_status':r.returncode,
            'observation':json.loads(r.stdout),'stderr':r.stderr}

if __name__=='__main__':
    selectors=[s for row in json.loads(INVENTORY.read_text())['languages']
               for s in [row['canonical'],*row['aliases']]]
    with ThreadPoolExecutor(max_workers=4) as pool:
        observations=list(pool.map(observe,selectors))
    print(json.dumps({'schema_version':2,'status':'research; not approved portable expectations',
        'repetitions':2,'parallel_workers':4,'timeout_seconds':15,
        'fresh_temporary_working_directory_per_attempt':True,'environment':ENV,
        'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in [INVENTORY,FIXTURE,PROBE,Path(__file__).resolve(),
                            *[LIB/'Date/Manip'/name for name in ('Base.pm','Date.pm','Obj.pm')]]},
        'observations':observations},ensure_ascii=False,indent=2)+'\n')
