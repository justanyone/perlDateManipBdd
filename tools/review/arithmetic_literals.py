#!/usr/bin/env python3
"""Targeted arithmetic draft checks; no reference calls or automatic approval."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/arithmetic-family/observations.json').read_text())
mapping = json.loads((ROOT / 'docs/research/arithmetic-family/feature-map.json').read_text())
for path, digest in record['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
rows = {r['case_id']: r['observation'] for r in record['observations']}
assert len(rows) == 107
assert all(r['repeatable'] and r['stderr'] == '' for r in record['observations'])
assert all(r['exception'] is None and r['call_stdout'] == '' for r in rows.values())

def normalized(value):
    if isinstance(value, str) and len(value) == 16 and value[:8].isdigit() and value[10] == ':':
        return value[:4] + '-' + value[4:6] + '-' + value[6:8] + ' ' + value[8:]
    return value

checked = 0
seen = set()
for path in (ROOT / 'spec/drafts/arithmetic').glob('*.feature'):
    header = None
    for line in path.read_text().splitlines():
        if not line.strip().startswith('|'):
            header = None
            continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if header is None:
            header = cells
            continue
        if 'case' not in header:
            continue
        case = dict(zip(header, cells))
        cid = case['case']
        assert cid not in seen, cid
        seen.add(cid)
        reference = mapping.get('feature_aliases', {}).get(cid, cid)
        if reference not in rows:
            continue
        result = rows[reference]['raw_return']
        if isinstance(result, dict) and 'value' in result and 'result' in case:
            assert normalized(result['value']) == case['result'], cid
            checked += 1
gap = rows['ARITH-DST-SPRING-AT-GAP']['raw_return']
assert gap['left_status'] == 1
assert gap['left_before']['error'] == '[parse] Invalid date in timezone'
assert gap['left_before']['value_read_performed'] is False
assert gap['answer_error_before_value'] == '[calc] Date object invalid'
assert gap['value'] == '' and gap['error'] == '[value] Object does not contain a date'
invalid = rows['BUSINESS-INVALID-OBJECT']['raw_return']
assert invalid['return'] is None
assert invalid['before']['error'] == invalid['after']['error'] == '[parse] Invalid date string'
assert invalid['before']['value_read_performed'] is False
assert invalid['after']['value_read_performed'] is False
rejected = rows['DELTA-PARSE-INVALID-ORDER']['raw_return']
assert rejected['status'] == 1 and rejected['after']['value_list'] == []
assert rejected['after']['value_scalar'] == ''
print(json.dumps({'repeatable_cases': len(rows), 'calculation_table_literals_checked': checked,
                  'unique_outline_rows': len(seen), 'invalid_state_channels_checked': 3,
                  'approved_specification_cases': 0}, indent=2))
