#!/usr/bin/env python3
"""Run every rendering observation twice in fresh Date::Manip processes."""
import hashlib,json,os,subprocess,tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
root=Path(__file__).resolve().parents[3]
cases_path=root/'docs/research/rendering-family/cases.json'; probe=root/'tools/probes/rendering-family/rendering-family.pl'; profiles=root/'docs/automation/reference-profiles.json'
cases=json.loads(cases_path.read_text())['cases']
env={'PATH':os.environ['PATH'],'PERL5LIB':str(root/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
def observe(case):
  runs=[]
  with tempfile.TemporaryDirectory(prefix='datemanip-rendering-') as cwd:
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
record={'schema_version':1,'status':'research evidence; no expected value is approved','command':'python3 tools/probes/rendering-family/run-rendering-family.py','repetitions':2,'timeout_seconds':15,'parallel_workers':4,'environment':env,'sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [cases_path,probe,profiles,Path(__file__).resolve()]},'observations':rows}
print(json.dumps(record,indent=2))
