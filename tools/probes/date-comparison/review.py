#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];F=ROOT/'docs/research/date-comparison'
load=lambda n:json.loads((F/n).read_text())
data=load('observations.json');cases=load('cases.json')['cases'];mapping=load('feature-map.json')
for f,h in data['sha256'].items():assert hashlib.sha256((ROOT/f).read_bytes()).hexdigest()==h,f
rows={r['result']['case']['case_id']:r for r in data['rows']};seen=[];header=None
for line in (ROOT/mapping['feature']).read_text().splitlines():
 if not line.strip().startswith('|'):
  header=None;continue
 cells=[s.strip() for s in line.strip().strip('|').split('|')]
 if header is None:header=cells;continue
 row=dict(zip(header,cells));cid=row['case'];seen.append(cid);r=rows[cid];d=r['result'];c=d['case'];o=d['observation']
 assert r['repeatable'] and r['exit']==0 and r['stderr']==''
 assert json.loads(row['left'])==c['left'] and json.loads(row['right'])==c['right']
 assert json.loads(row['result'])==o['result'] and o['result_defined']==int(o['result'] is not None)
 assert d['exception'] is None and d['stdout']==''
 assert o['version']==('5.66' if c['profile']=='dm5' else '7.00')
 if c['profile']=='oo':
  assert json.loads(row['statuses'])==[o['parse_left'],o['parse_right']]
  assert json.loads(row['errors'])==o['errors_before']==o['errors_after']
 elif c['profile']=='base':assert o['error_before']==o['error_after']==''
 assert len(d['warnings'])==(1 if c['profile']=='dm5' or (c['profile']=='oo' and o['result'] is None) else 0)
assert len(seen)==len(set(seen))==len(cases)==49
assert set(seen)=={r['case_id'] for r in mapping['cases']}
print('49 comparison request/result rows, public error channels and pinned provenance verified')
