#!/usr/bin/env python3
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,os,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
CASE=ROOT/'docs/research/config-files-family/cases.json'
PROBE=ROOT/'tools/probes/config-files-family/probe.pl'
FIXTURE=ROOT/'docs/automation/reference-profiles.json'
LIB=ROOT/'local/date-manip-7.00/lib/perl5'
ENV={'PATH':os.environ['PATH'],'PERL5LIB':str(LIB),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
def observe(case):
 runs=[]
 for _ in range(2):
  with tempfile.TemporaryDirectory(prefix='config-files-') as work:
   for name,content in case['files'].items():
    assert Path(name).name==name
    (Path(work)/name).write_bytes(content.encode('utf-8'))
   r=subprocess.run(['perl',str(PROBE),case['case_id']],cwd=work,env=ENV,capture_output=True,text=True,timeout=15)
   runs.append((r.returncode,r.stdout,r.stderr))
 assert runs[0]==runs[1],case['case_id']
 assert r.returncode==0,(case['case_id'],r.stderr)
 return {'case_id':case['case_id'],'repeatable':True,'process_stderr':r.stderr,'observation':json.loads(r.stdout)}
if __name__=='__main__':
 with ThreadPoolExecutor(max_workers=4) as pool:rows=list(pool.map(observe,json.loads(CASE.read_text())['cases']))
 files=[CASE,PROBE,FIXTURE,Path(__file__).resolve(),*[LIB/'Date/Manip'/f for f in ['Date.pm','DM6.pm','Base.pm','TZ_Base.pm','Obj.pm']]]
 print(json.dumps({'schema_version':1,'status':'unreviewed research, not frozen test expectations','repetitions':2,'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},'observations':rows},indent=2))
