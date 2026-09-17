#!/usr/bin/env python3
"""Run each original configuration probe twice in isolated processes."""
import concurrent.futures, hashlib, json, os, pathlib, subprocess, sys, tempfile
ROOT=pathlib.Path(__file__).resolve().parents[3]
CASES=json.loads((ROOT/'docs/research/configuration-family/cases.json').read_text())['cases']
ENV={'PATH':os.environ['PATH'],'PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
def one(c):
 out=[]
 for _ in range(2):
  with tempfile.TemporaryDirectory(prefix='datemanip-config-') as work:
   p=subprocess.run(['perl',str(ROOT/'tools/probes/configuration-family/probe.pl'),c['case_id']],cwd=work,env=ENV,text=True,capture_output=True,timeout=15)
  out.append((p.stdout,p.stderr,p.returncode))
 same=out[0]==out[1]
 return {'case_id':c['case_id'],'repeatable':same,'research_status':'repeatable' if same else 'disputed','observation':json.loads(out[0][0]) if out[0][0] else None,'stderr':out[0][1],'returncode':out[0][2]}
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex: rows=list(ex.map(one,CASES))
files=['docs/research/configuration-family/cases.json','tools/probes/configuration-family/probe.pl','tools/probes/configuration-family/run.py','docs/automation/reference-profiles.json']
print(json.dumps({'schema_version':1,'status':'research evidence; no expected value is approved','command':'python3 tools/probes/configuration-family/run.py','repetitions':2,'timeout_seconds':15,'parallel_workers':4,'sha256':{x:hashlib.sha256((ROOT/x).read_bytes()).hexdigest() for x in files},'observations':rows},sort_keys=True,indent=2))
