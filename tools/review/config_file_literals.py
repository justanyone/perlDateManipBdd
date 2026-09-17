#!/usr/bin/env python3
"""Check original file bodies, settings and literal results against saved research."""
import hashlib,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[2];F=R/'docs/research/config-files-family'
doc=json.loads((F/'observations.json').read_text());cases={c['case_id']:c for c in json.loads((F/'cases.json').read_text())['cases']}
observed={r['case_id']:r for r in doc['observations']};mapping=json.loads((F/'feature-map.json').read_text());expected={r['case_id']:r for r in mapping['cases']}
assert len(cases)==len(observed)==len(expected)==36
for path,digest in doc['sha256'].items():assert hashlib.sha256((R/path).read_bytes()).hexdigest()==digest,path
text=(R/mapping['feature']).read_text();seen=[]
for block in text.split('  Scenario Outline: ')[1:]:
 before,examples=block.split('    Examples:')
 files={name:json.loads(body) for name,body in re.findall(r'And file "([^"]+)" contains.*?\n      """\n      (.*?)\n      """',before,re.S)}
 settings=[]
 for line in before.splitlines():
  if line.strip().startswith('|'):
   cells=[s.strip() for s in line.strip().strip('|').split('|')]
   if cells[0]!='setting':settings.append([cells[0],'' if cells[1]=='[empty text]' else cells[1]])
 result=re.search(r'Then the parsed civil date-time is "([^"]+)"',block).group(1)
 for line in examples.splitlines():
  if not line.strip().startswith('| CF-'):continue
  case,profile,query,setting=[s.strip() for s in line.strip().strip('|').split('|')];seen.append(case)
  c=cases[case];wrapper=observed[case];o=wrapper['observation'];e=expected[case]
  assert c['files']==files and c['settings']==settings,case
  assert o['request']==c and c['parse_text']=='04/05/2040'
  assert wrapper['repeatable'] and wrapper['process_stderr']=='' and o['exception'] is None
  assert o['backend_version']=='7.00' and o['later_warnings']==[] and o['call_stdout']==''
  assert result==e['result'] and o['value']==result.replace('-','').replace(' ',''),case
  assert bool(o['configuration_exception'])==bool(e['configuration_exception']),case
  assert len(o['configuration_warnings'])==int(bool(e['configuration_warning'])),case
  if e['configuration_exception']:assert 'not an assignment' in o['configuration_exception']
  if c['profile']=='oo':
   assert query=='requested' and o['date_order']==setting,case
   assert o['setup_return'] is None and o['setup_error']==''
   assert o['parse_status']==0 and o['parse_error']==o['error_after_value']==''
  else:assert query=='not requested' and o['setup_return']==''
assert len(seen)==len(set(seen))==36 and set(seen)==set(cases)
print(json.dumps({'file_configuration_requests_checked':36,'approved_specification_cases':0},indent=2))
