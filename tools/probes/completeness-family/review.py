#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];family=ROOT/'docs/research/completeness-family'
cases=json.loads((family/'cases.json').read_text());data=json.loads((family/'observations.json').read_text())
for f,h in data['sha256'].items():assert hashlib.sha256((ROOT/f).read_bytes()).hexdigest()==h,f
feature=(ROOT/'spec/drafts/completeness/supplied-fields.feature').read_text()
rows={r['result']['case']['case_id']:r for r in data['rows']};count=0
for line in feature.splitlines():
 if not line.strip().startswith('| COMP-'):continue
 cid,setup,text,status,error,values=[c.strip() for c in line.strip().strip('|').split('|')]
 r=rows[cid];d=r['result'];o=d['observation'];count+=1
 assert r['repeatable'] and r['exit']==0 and r['stderr']==''
 assert d['case']['parse_text']==json.loads(text)
 assert d['case']['parse_requested']==(setup=='full parsing')
 assert o.get('parse_status')==json.loads(status) and o['error_after_setup']==json.loads(error)
 assert [q['value'] for q in d['queries']]==json.loads(values)
 assert [q['request'] for q in d['queries']]==cases['selectors']
 assert d['configuration']==cases['configuration']
 assert o['zone']=='Etc/UTC' and o['version']=='7.00' and o['tzdata']=='tzdata2026c' and o['tzcode']=='tzcode2026c'
 for q in d['queries']:
  assert q['error_before']==q['error_after']==json.loads(error)
  assert bool(q['defined'])==(q['value'] is not None)
  assert len(q['warnings'])==int(q['value'] is None)
  if q['warnings']:assert '[complete] Object must contain a valid date' in q['warnings'][0]
 assert d['exception'] is None and d['stdout']=='' and d['warnings']==[]
assert count==len(rows)==11
print('11 setup cases,132 exact completeness results,36 warning channels and provenance checked')
