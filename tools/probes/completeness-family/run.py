#!/usr/bin/env python3
import hashlib,json,subprocess,tempfile
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
ROOT=Path(__file__).resolve().parents[3]
CORPUS=ROOT/'docs/research/completeness-family/cases.json'
PROBE=Path(__file__).with_name('probe.pl')
ENV={'PATH':'/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','TZ':'Etc/UTC','PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5')}
def observe(case):
 attempts=[]
 for _ in range(2):
  with tempfile.TemporaryDirectory(prefix='dm-completeness-') as work:
   p=subprocess.run(['perl',str(PROBE),case['case_id']],cwd=work,env=ENV,capture_output=True,text=True,timeout=15)
  attempts.append({'exit':p.returncode,'stderr':p.stderr,'stdout':p.stdout})
 assert attempts[0]==attempts[1] and attempts[0]['exit']==0 and attempts[0]['stderr']=='',attempts
 row=json.loads(attempts[0]['stdout']);assert row['exception'] is None and row['warnings']==[] and row['stdout']=='',row
 return {'repeatable':True,'exit':0,'stderr':'','result':row}
if __name__=='__main__':
 with ThreadPoolExecutor(max_workers=4) as pool:rows=list(pool.map(observe,json.loads(CORPUS.read_text())['cases']))
 files={CORPUS,PROBE,Path(__file__).resolve()}
 for row in rows:files.update(Path(p) for p in row['result']['loaded'].values())
 print(json.dumps({'repetitions':2,'timeout_seconds':15,'workers':4,'fresh_cwd':True,'environment':ENV,'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)},'rows':rows},indent=2))
