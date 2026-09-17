#!/usr/bin/env python3
"""Review partial-parser draft literals against frozen research; no reference calls."""
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[2]
FAMILY=ROOT/'docs/research/partial-parsing-family'
document=json.loads((FAMILY/'observations.json').read_text())
cases={c['case_id']:c for c in json.loads((FAMILY/'cases.json').read_text())['cases']}
rows={r['case_id']:r for r in document['observations']}
assert len(rows)==len(cases)==71
for path,digest in {**document['sha256'],**document['installed_module_sha256']}.items():
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==digest,path
failures=0
for case,row in rows.items():
    assert row['research_status']=='repeatable' and row['process_stderr']==''
    o=row['observation'];assert o['request']==cases[case] and o['exception'] is None
    assert o['observed_distribution_version']=='7.00'
    assert o['observed_backend_version']==('5.66' if o['profile']=='dm5' else '7.00')
    if o['profile']=='oo':
        assert o['value_read_context']=='scalar'
        if o['status']:
            failures+=1
            assert o['value_after_call']=='' and o['value_after_call_type']=='text',case
            assert o['error_after_call']==o['error_after_value_read']
            assert o['error_clear_return'] is None and o['error_clear_return_type']=='absent'
            assert o['error_after_clear']==o['error_after_retained_value_read']==''
            assert o['value_after_error_clear']=='2039123107:08:09'
    elif cases[case]['carrier']=='token-array':
        assert o['carrier_before']==cases[case]['value']
        assert o['remaining_tokens']==o['carrier_after']
        assert o['consumed_count']==len(o['carrier_before'])-len(o['carrier_after'])
assert failures==10

def civil(value):
    match=re.fullmatch(r'(\d{4})(\d{2})(\d{2})(\d{2}:\d{2}:\d{2})',value)
    assert match,value
    y,m,d,t=match.groups();return f'{y}-{m}-{d} {t} Etc/UTC'

text=(ROOT/'spec/drafts/partial-parsing/date-and-time-parts.feature').read_text()
header=None;checked=0
for line in text.splitlines():
    if not line.strip().startswith('|'):continue
    cells=[v.strip() for v in line.strip().strip('|').split('|')]
    if cells[0]=='case':header=cells;continue
    r=dict(zip(header,cells));case=r['case'];c=cases[case];o=rows[case]['observation']
    assert r['text'].replace('[empty text]','')==c['text'],case
    if 'gates' in r:assert ([] if r['gates']=='none' else [r['gates']])==c['options'],case
    if 'initial' in r:assert r['initial'].removesuffix(' Etc/UTC')==c['initial'],case
    if 'form' in r:assert r['form']==c['form'],case
    if 'result' in r:
        assert o['status']==0 and civil(o['value_after_call'])==r['result'],case
    else:
        assert o['status']==1 and o['error_after_call']==r['error'],case
    checked+=1
assert checked==51
for case,expected in [('PP-DATE-10','2040022907:08:09'),('PP-TIME-DEFAULT','2040022816:05:09')]:
    assert rows[case]['observation']['value_after_call']==expected
for backend in ('DM6','DM5'):
    o=rows[f'PP-PREFIX-{backend}-ARRAY-LONGEST']['observation']
    assert o['value']=='2040030100:00:00' and o['remaining_tokens']==['--verbose'] and o['consumed_count']==3
    o=rows[f'PP-PREFIX-{backend}-UNSUPPORTED']['observation']
    assert o['value']=='' and o['call_stdout']=='ERROR:  Invalid arguments to ParseDate.\n'
assert rows['PP-PREFIX-DM6-ARRAY-EMPTY']['observation']['value']==''
assert rows['PP-PREFIX-DM5-ARRAY-EMPTY']['observation']['value'] is None
mentioned=[]
for path in (ROOT/'spec/drafts/partial-parsing').glob('*.feature'):
    mentioned+=re.findall(r'PP-[A-Z0-9-]+',path.read_text())
assert len(mentioned)==len(set(mentioned))==71 and set(mentioned)==set(cases)
print(json.dumps({'mapped_requests':71,'date_time_outline_literals_checked':checked,
                  'native_failure_carriers_checked':failures,'approved_specification_cases':0},indent=2))
