#!/usr/bin/env python3
"""Run every original arithmetic/delta probe twice in separate reference processes."""
import hashlib,json,os,subprocess,tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
root=Path(__file__).resolve().parents[3]
inputs=root/'docs/research/arithmetic-family/cases.json'; additions=root/'docs/research/arithmetic-family/extended-cases.json'; edges=root/'docs/research/arithmetic-family/edge-cases.json'; probe=root/'tools/probes/arithmetic-family/arithmetic-family.pl'; fixture=root/'docs/automation/reference-profiles.json'
cases=json.loads(inputs.read_text())['cases'] + json.loads(additions.read_text())['cases'] + json.loads(edges.read_text())['cases']
env={'PATH':os.environ['PATH'],'PERL5LIB':str(root/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
def observe(case):
  runs=[]
  with tempfile.TemporaryDirectory(prefix='datemanip-arithmetic-') as cwd:
    for _ in range(2):
      try:
        p=subprocess.run(['perl',str(probe),case['case_id']],cwd=cwd,env=env,capture_output=True,text=True,timeout=15)
        runs.append({'exit_code':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
      except subprocess.TimeoutExpired: runs.append({'timeout':True})
  row={'case_id':case['case_id'],'repeatable':runs[0]==runs[1],'research_status':'repeatable' if runs[0]==runs[1] else 'unstable'}
  if runs[0].get('exit_code')==0: row.update(observation=json.loads(runs[0]['stdout']),stderr=runs[0]['stderr'])
  else: row.update(runs=runs,research_status='unresolved-process-failure')
  return row
with ThreadPoolExecutor(max_workers=4) as pool: rows=list(pool.map(observe,cases))
record={'schema_version':1,'status':'research evidence; no expected value is approved','command':'python3 tools/probes/arithmetic-family/run-arithmetic-family.py','repetitions':2,'timeout_seconds':15,'parallel_workers':4,'environment':env,'sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [inputs,additions,edges,probe,fixture,Path(__file__).resolve()]},'observations':rows}
print(json.dumps(record,indent=2))
