#!/usr/bin/env python3
"""Capture each public weekday request twice in isolated processes."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/weekday-family'
CASES=FAMILY/'cases.json'
PROBE=Path(__file__).with_name('probe.pl')
LIB=ROOT/'local/date-manip-7.00/lib/perl5'
FIXTURE=ROOT/'docs/automation/reference-profiles.json'
ARTIFACTS=(CASES,PROBE,Path(__file__).resolve(),Path(__file__).with_name('make_cases.py'),
 FIXTURE,ROOT/'docs/research/contracts/calendar.json',ROOT/'docs/planning/perl-api-inventory.csv')
REVIEWED_SOURCES=tuple(ROOT/path for path in (
 'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm',
 'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pod',
 'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pm',
 'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pod',
 'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm',
 'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pod'))
ENV={'PATH':'/usr/bin:/bin','PERL5LIB':str(LIB),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8',
     'PERL_HASH_SEED':'0','PERL_PERTURB_KEYS':'0'}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def rel(path):return str(path.relative_to(ROOT))
def observe(case):
    attempts=[]
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='weekday-family-') as cwd:
            proc=subprocess.run(['/usr/bin/perl',str(PROBE),case['case_id']],cwd=cwd,env=ENV,
                                capture_output=True,timeout=20)
        attempts.append({'exit_code':proc.returncode,'stdout':proc.stdout,'stderr':proc.stderr})
    if attempts[0]!=attempts[1]:raise RuntimeError('nonrepeatable '+case['case_id'])
    if attempts[0]['exit_code']:
        raise RuntimeError(case['case_id']+': '+repr(attempts[0]))
    return {'case_id':case['case_id'],'research_status':'repeatable',
            'observation':json.loads(attempts[0]['stdout']),
            'process_stderr_hex':attempts[0]['stderr'].hex()}
if __name__=='__main__':
    manifest=json.loads(CASES.read_text());fixture=json.loads(FIXTURE.read_text())
    with ThreadPoolExecutor(max_workers=4) as pool:
        rows=list(pool.map(observe,manifest['cases']))
    loaded=sorted({name for row in rows for name in row['observation']['loaded_date_manip_module_files']})
    installed={rel(LIB/name):sha(LIB/name) for name in loaded}
    out={'schema_version':1,
      'status':'repeatable public reference observations; not BDD execution or semantic approval',
      'reference':fixture['reference'],
      'artifact_sha256':{rel(path):sha(path) for path in ARTIFACTS},
      'reviewed_source_sha256':{rel(path):sha(path) for path in REVIEWED_SOURCES},
      'installed_module_sha256':installed,
      'execution':{'repetitions_per_case':2,'parallel_workers':4,'timeout_seconds':20,
        'fresh_process_and_temporary_working_directory_per_attempt':True,'environment':ENV},
      'observations':rows}
    print(json.dumps(out,indent=2,sort_keys=True,ensure_ascii=False))
