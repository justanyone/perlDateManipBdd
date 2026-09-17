#!/usr/bin/env python3
"""Check public parse-cache research and selected literal sequences without SUT calls."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / 'docs/research/parse-cache-family'
x = json.loads((FAMILY/'observations.json').read_text())
cases = {c['case_id']: c for c in json.loads((FAMILY/'cases.json').read_text())['cases']}
rows = {r['case_id']:r for r in x['observations']}
mapping = json.loads((FAMILY/'feature-map.json').read_text())['features']
ids = [i for group in mapping.values() for i in group]
assert len(ids) == len(set(ids)) == len(cases) == len(rows) == 30
assert set(ids) == set(cases) == set(rows)
for path, digest in x['sha256'].items():
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == digest, path
public = {o['id'] for o in json.loads((ROOT/'docs/research/api/contract-map.json').read_text())['operations']}
for binding in json.loads((FAMILY/'bindings.json').read_text())['bindings']:
    assert binding['operation_id'] in public
for path, expected in mapping.items():
    text = (ROOT/path).read_text()
    found = set(re.findall(r'PC-[A-Z-]+',text))
    assert found == set(expected), (path, found ^ set(expected))
interrupted_calls=[]
completed_absent_calls=[]
for case, row in rows.items():
    assert row['research_status']=='repeatable' and row['process_stderr']==''
    o=row['observation']; assert o['exception'] is None and o['call_stdout']==''
    assert o['configuration_status'] is None and o['configuration_error']==''
    assert o['distribution_version']=='7.00' and o['tzdata']=='tzdata2026c'
    assert o['request']==cases[case]
    sequence=o['sequence']; assert sequence[0]['result']==0 and sequence[0]['error_after']==''
    assert sequence[0]['call_completed'] is True and sequence[0]['action_exception'] is None
    assert len(sequence)==len(cases[case]['actions'])+1
    for action, step in zip(cases[case]['actions'], sequence[1:]):
        assert [step['action'],*step['arguments']]==action
        if step['call_completed']:
            assert step['action_exception'] is None
            assert 'result' in step and 'result_type' in step
            if step['result'] is None: completed_absent_calls.append((case,step['index']))
        else:
            assert step['action_exception']
            assert 'result' not in step and 'result_type' not in step
            interrupted_calls.append((case,step['index']))
        if step['action']=='clear_error':
            assert step['call_completed'] is True
            assert step['result'] is None and step['result_type']=='absent'
            assert step['error_after']==''
    assert sum((s['warnings'] for s in sequence[1:]),[])==o['warnings']
assert interrupted_calls==[
    ('PC-PARSE-FAIL-LOCAL-OBSERVER',3),
    ('PC-PARSE-FAIL-GMT-OBSERVER',3),
]
assert len(completed_absent_calls)==8

def sequence(case):
    return rows[case]['observation']['sequence']

def values_after_parse(case):
    steps=sequence(case)
    index=next(i for i,s in enumerate(steps) if s['action'] in ('parse','parse_date','parse_time'))
    assert steps[index]['result']==0 and steps[index]['error_after']==''
    return [s for s in steps[index+1:] if s['action']=='value']

stale_checks=0
for kind, current in [('DATE','2040022907:08:09'),('TIME','2039123116:05:09')]:
    for suffix in ('PRISTINE','PRE-PARSED'):
        values=values_after_parse(f'PC-{kind}-{suffix}')
        assert len(values)==3 and all(s['result']==current for s in values)
    for carrier in ('LOCAL','GMT'):
        for context in ('SCALAR','LIST'):
            values=values_after_parse(f'PC-{kind}-PRE-{carrier}-{context}')
            for step in values:
                selected, mode=step['arguments']
                if selected==carrier.lower():
                    assert step['result']==('2039123112:08:09' if mode=='scalar' else [2039,12,31,12,8,9])
                    stale_checks+=1
                elif mode=='scalar':
                    assert step['result']==current
                assert step['error_before']==step['error_after']==''
for case in ('PC-PARSE-PRISTINE','PC-PARSE-PRE-LOCAL','PC-PARSE-PRE-GMT','PC-PARSE-PRE-BOTH-LIST'):
    for step in values_after_parse(case):
        carrier,mode=step['arguments']
        expected='2040022916:05:09' if carrier=='parsed' else '2040022921:05:09'
        assert step['result']==(expected if mode=='scalar' else [2040,2,29,21,5,9])
for carrier in ('LOCAL','GMT'):
    steps=sequence(f'PC-PARSE-FAIL-{carrier}-OBSERVER')
    failures=[s for s in steps if s.get('action_exception')]
    assert len(failures)==1
    step=failures[0]
    assert step['arguments']==[carrier.lower(),'scalar']
    assert step['call_completed'] is False
    assert 'result' not in step and 'result_type' not in step
    assert 'undefined' in step['action_exception']
    assert len(step['warnings'])==8 and step['error_before']==step['error_after']==''
    assert steps[-1]['result']=='2040030214:10:11'
print(json.dumps({'mapped_sequences':30,'stale_value_literals_checked':stale_checks,
                  'exception_sequences_checked':2,'interrupted_calls_without_return':2,
                  'completed_absent_returns':len(completed_absent_calls),
                  'approved_specification_cases':0},indent=2))
