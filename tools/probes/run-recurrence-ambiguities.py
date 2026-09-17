#!/usr/bin/env python3
"""Repeat original research probes; never promote results to approved expectations."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

root=Path(__file__).resolve().parents[2]
probe=root/'tools/probes/recurrence-ambiguities.pl'
cases=[f'weekday-{n}' for n in range(1,8)]+[
    'modifier-uppercase-string','modifier-uppercase-list','modifier-lowercase-list',
    'modifier-clears-anchor','endpoint-dm5','endpoint-dm6','anchor-positional-text','anchor-positional-value','anchor-setter']
env={'PATH':os.environ['PATH'],'PERL5LIB':str(root/'local/date-manip-7.00/lib/perl5'),
     'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
rows=[]
with tempfile.TemporaryDirectory(prefix='datemanip-recur-') as cwd:
    for case in cases:
        a=subprocess.run(['perl',str(probe),case],env=env,cwd=cwd,text=True,capture_output=True,timeout=15,check=True)
        b=subprocess.run(['perl',str(probe),case],env=env,cwd=cwd,text=True,capture_output=True,timeout=15,check=True)
        if (a.stdout,a.stderr)!=(b.stdout,b.stderr):
            raise RuntimeError('Nonrepeatable observation: '+case)
        row=json.loads(a.stdout)
        row.update(process_stderr=a.stderr,research_status='repeatable')
        rows.append(row)
record={'schema_version':1,'status':'research-only; semantic review pending',
        'reference_profile_record':'docs/automation/reference-profiles.json',
        'reference_profile_sha256':hashlib.sha256((root/'docs/automation/reference-profiles.json').read_bytes()).hexdigest(),
        'probe':'tools/probes/recurrence-ambiguities.pl',
        'probe_sha256':hashlib.sha256(probe.read_bytes()).hexdigest(),
        'execution':{'command':'python3 tools/probes/run-recurrence-ambiguities.py',
                     'separate_process_per_case':True,'repetitions':2,'timeout_seconds':15,'environment':env},
        'observations':rows}
# Output goes to stdout. Replacing reviewed evidence requires an explicit review.
print(json.dumps(record,indent=2))
