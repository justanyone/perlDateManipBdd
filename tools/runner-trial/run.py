#!/usr/bin/env python3
"""Exercise the development runner, including required negative results."""
import json,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
ENV={'PATH':'/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','TZ':'Etc/UTC',
     'PERL5LIB':str(ROOT/'local/bdd-runner/lib/perl5'),'ANSI_COLORS_DISABLED':'1'}
command=['perl',str(ROOT/'local/bdd-runner/bin/pherkin'),'--strict','-o','JSON']
features=str(Path(__file__).with_name('features'))
results=[]
for name,tags,success in [('positive','not @deliberate-failure and not @undefined-step',True),('failure','@deliberate-failure',False),('undefined','@undefined-step',False),('outline','@outline',True)]:
 with tempfile.TemporaryDirectory(prefix='dm-bdd-trial-') as work:
  p=subprocess.run(command+['--tags',tags,features],cwd=work,env=ENV,capture_output=True,text=True,timeout=60)
 report=json.loads(p.stdout) if p.stdout.strip().startswith('[') else None
 scenarios=[e for f in (report or []) for e in f.get('elements',[]) if e.get('type')=='scenario']
 statuses=[step['result']['status'] for e in scenarios for step in e.get('steps',[])]
 if success:
  assert len(scenarios)==(3 if name=='outline' else 5),(name,len(scenarios),p.stdout,p.stderr)
  assert statuses and all(status=='passed' for status in statuses),(name,statuses)
 else:
  assert len(scenarios)==1 and ('failed' in statuses if name=='failure' else 'skipped' in statuses),(name,statuses,p.stdout,p.stderr)
 results.append({'scenario_count':len(scenarios),'step_statuses':statuses,'trial':name,'expected_success':success,'exit_code':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
print(json.dumps(results,indent=2))
if any((r['exit_code']==0)!=r['expected_success'] for r in results):
 raise SystemExit('runner trial did not match expected pass/fail statuses')
