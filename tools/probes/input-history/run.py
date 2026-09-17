#!/usr/bin/env python3
"""Two isolated observations per original input-history request."""
import hashlib,json,subprocess,tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
CORPUS=ROOT/'docs/research/input-history/cases.json'
PROBE=Path(__file__).with_name('probe.pl')
ENV={'PATH':'/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','TZ':'Etc/UTC','PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5')}
def observe(case):
 runs=[]
 for _ in range(2):
  with tempfile.TemporaryDirectory(prefix='dm-input-') as work:
   p=subprocess.run(['perl',str(PROBE),case['case_id']],cwd=work,env=ENV,capture_output=True,timeout=15)
  assert p.returncode==0 and p.stderr==b'',(case['case_id'],p.stderr)
  runs.append(p.stdout)
 assert runs[0]==runs[1],case['case_id']
 result=json.loads(runs[0]);assert result['exception'] is None and result['warnings']==[] and result['call_stdout']=='',result
 return result
if __name__=='__main__':
 cases=json.loads(CORPUS.read_text())['cases']
 with ThreadPoolExecutor(max_workers=4) as pool: results=list(pool.map(observe,cases))
 files=[CORPUS,PROBE,Path(__file__).resolve(),ROOT/'docs/automation/reference-profiles.json']
 files+=list((ROOT/'local/date-manip-7.00/lib/perl5/Date/Manip').glob('*.pm'))
 print(json.dumps({'schema_version':1,'repetitions':2,'timeout_seconds':15,'environment':ENV,'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},'observations':results},indent=2))
