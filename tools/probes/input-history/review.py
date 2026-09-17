#!/usr/bin/env python3
"""Review input-history literal correspondence; not a BDD execution result."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
family=ROOT/'docs/research/input-history'
load=lambda name:json.loads((family/name).read_text())
data=load('observations.json');cases=load('cases.json')['cases'];mapping=load('feature-map.json')
for f,h in data['sha256'].items():assert hashlib.sha256((ROOT/f).read_bytes()).hexdigest()==h,f
text=(ROOT/mapping['feature']).read_text()
blocks=re.split(r'  Scenario: Read remembered source text for ',text)[1:]
assert len(blocks)==len(cases)==len(data['observations'])==16
for block,case,row,mapped in zip(blocks,cases,data['observations'],mapping['cases']):
 cid=case['case_id'];assert block.splitlines()[0]==row['case_id']==mapped['case_id']==cid
 assert row['request']==case and row['warnings']==[] and row['exception'] is None and row['call_stdout']==''
 o=row['observation']
 assert o['configuration_error']=='' and o['version']=='7.00'
 assert o['tzdata']=='tzdata2026c' and o['tzcode']=='tzcode2026c'
 assert o['input_list']==[o['input_scalar']]
 assert o['error_before_input']==o['error_after_scalar']==o['error_after_list']
 def values(prefix):
  return [json.loads(line.strip()[len(prefix):]) for line in block.splitlines() if line.strip().startswith(prefix)]
 assert values('Then the action return is ')==[a['result'] for a in o['actions']]
 assert values('And the immediate error is ')==[a['error'] for a in o['actions']]
 assert values('Then the result is ')==[o['input_scalar']]
 assert values('Then the collection is ')==[o['input_list']]
 assert values('And the error is ')==[o['error_before_input'],o['error_after_list'],o['error_after_value']]
 assert [json.loads(line.split(' with arguments ',1)[1]) for line in block.splitlines() if ' with arguments ' in line]==[a['arguments'] for a in case['actions']]
 native=o['value'];normalized=f'{native[:4]}-{native[4:6]}-{native[6:8]} {native[8:]}' if native else ''
 assert values('Then the date-value text is ')==[normalized]
print('16 input-history scenarios match exact request, result, error and carrier channels; provenance checked')
