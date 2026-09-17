#!/usr/bin/env python3
"""Run every public week-number edge request twice in fresh processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib, json, subprocess, tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/week-rules-edges'; CASES=FAMILY/'cases.json'
PROBE=Path(__file__).with_name('probe.pl'); FIXTURE=ROOT/'docs/automation/reference-profiles.json'
LIB=ROOT/'local/date-manip-7.00/lib/perl5'
ARTIFACTS=(CASES,PROBE,FIXTURE,Path(__file__).resolve(),
           Path(__file__).with_name('make_cases.py'),Path(__file__).with_name('make_artifacts.py'),
           Path(__file__).with_name('review.py'),FAMILY/'bindings.json',FAMILY/'feature-map.json',
           FAMILY/'coverage-map.json',ROOT/'spec/drafts/week-rules-edges/base-edge-requests.feature',
           ROOT/'spec/drafts/week-rules-edges/legacy-overrides.feature',
           ROOT/'spec/drafts/week-rules-edges/perl-binding.feature')
ENV={'PATH':'/usr/bin:/bin','PERL5LIB':str(LIB),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','PERL_HASH_SEED':'0','PERL_PERTURB_KEYS':'0'}
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def observe(case):
    attempts=[]
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='week-rules-edges-') as cwd:
            proc=subprocess.run(['/usr/bin/perl',str(PROBE),case['case_id']],cwd=cwd,env=ENV,capture_output=True,timeout=20)
        attempts.append({'exit_code':proc.returncode,'stdout':proc.stdout,'stderr':proc.stderr})
    if attempts[0]!=attempts[1]: raise RuntimeError('nonrepeatable '+case['case_id'])
    if attempts[0]['exit_code']: raise RuntimeError(case['case_id']+': '+repr(attempts[0]))
    return {'case_id':case['case_id'],'research_status':'repeatable',
            'observation':json.loads(attempts[0]['stdout']),
            'process_stderr_hex':attempts[0]['stderr'].hex()}
if __name__=='__main__':
    manifest=json.loads(CASES.read_text()); fixture=json.loads(FIXTURE.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool: rows=list(pool.map(observe,manifest['cases']))
    loaded=sorted({name for row in rows for name in row['observation']['loaded_date_manip_module_files']})
    installed={str((LIB/name).relative_to(ROOT)):sha(LIB/name) for name in loaded}
    out={'schema_version':2,
         'status':'repeatable public reference observations; not BDD execution or semantic approval',
         'reference':fixture['reference'],
         'sha256':{str(path.relative_to(ROOT)):sha(path) for path in ARTIFACTS},
         'installed_module_sha256':installed,
         'execution':{'repetitions_per_case':2,'parallel_workers':4,'timeout_seconds':20,
                      'fresh_process_and_temporary_working_directory_per_attempt':True,
                      'environment':ENV},'observations':rows}
    print(json.dumps(out,indent=2,sort_keys=True,ensure_ascii=False))
