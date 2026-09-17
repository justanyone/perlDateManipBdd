#!/usr/bin/env python3
"""Capture and repeat research observations without approving expected values."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
root=Path(__file__).resolve().parents[2]
inputs=root/'docs/research/inputs/calendar.json'
probe=root/'tools/probes/calendar-contracts.pl'
fixture=root/'docs/automation/reference-profiles.json'
cases=json.loads(inputs.read_text())['cases']
env={'PATH':os.environ['PATH'],'PERL5LIB':str(root/'local/date-manip-7.00/lib/perl5'),
     'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
from concurrent.futures import ThreadPoolExecutor

def observe(case):
    runs=[]
    with tempfile.TemporaryDirectory(prefix='datemanip-calendar-') as cwd:
        for _ in range(2):
            try:
                r=subprocess.run(['perl',str(probe),case['case_id']],env=env,cwd=cwd,capture_output=True,text=True,timeout=10)
                runs.append({'exit_code':r.returncode,'stdout':r.stdout,'stderr':r.stderr})
            except subprocess.TimeoutExpired:
                runs.append({'timeout':True})
    repeatable=runs[0]==runs[1]
    row={'case_id':case['case_id'],'repeatable':repeatable,'research_status':'repeatable' if repeatable else 'unstable'}
    if runs[0].get('exit_code')==0:
        row['observation']=json.loads(runs[0]['stdout']);row['stderr']=runs[0]['stderr']
    else:
        row['runs']=runs;row['research_status']='unresolved-process-failure'
    return row

with ThreadPoolExecutor(max_workers=4) as pool:
    rows=list(pool.map(observe,cases))
record={'schema_version':1,'status':'research evidence; not approved expectations',
        'command':'python3 tools/probes/run-calendar.py','repetitions':2,'timeout_seconds':10,'parallel_workers':4,
        'sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [inputs,probe,fixture,Path(__file__).resolve()]},
        'environment':env,'observations':rows}
print(json.dumps(record,indent=2))
