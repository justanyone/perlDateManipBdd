#!/usr/bin/env python3
import concurrent.futures,json,os,pathlib,subprocess
R=pathlib.Path(__file__).resolve().parents[3]; x=json.loads((R/'docs/research/language-family/selector-inventory.json').read_text());ids=[z for l in x['languages'] for z in [l['canonical'],*l['aliases']]];E={**os.environ,'PERL5LIB':str(R/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}
def f(i):
 a=[subprocess.run(['perl',str(R/'tools/probes/language-family/selectors.pl'),i],cwd='/tmp',env=E,text=True,capture_output=True,timeout=15)for _ in range(2)];return {'selector':i,'repeatable':a[0].stdout==a[1].stdout and a[0].stderr==a[1].stderr,'observation':json.loads(a[0].stdout),'stderr':a[0].stderr}
with concurrent.futures.ThreadPoolExecutor(max_workers=4)as q:print(json.dumps({'repetitions':2,'timeout_seconds':15,'parallel_workers':4,'observations':list(q.map(f,ids))},sort_keys=True,indent=2))
