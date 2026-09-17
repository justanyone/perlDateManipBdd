#!/usr/bin/env python3
"""Check recurrence draft table assertions against immutable recorded calls."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/recurrence-family/observations.json').read_text())
assert hashlib.sha256((ROOT / record['probe']).read_bytes()).hexdigest() == record['probe_sha256']
assert hashlib.sha256((ROOT / record['reference_profile_record']).read_bytes()).hexdigest() == record['reference_profile_sha256']
rows = {r['case_id']: r for r in record['observations']}
assert len(rows) == 36
assert all(r['research_status'] == 'repeatable' and r['process_stderr'] == '' for r in rows.values())
shapes = {r['frequency_text']: r for r in rows['frequency-numeric-and-written-shapes']['shapes']}
invalid = {r['frequency_text']: r for r in rows['frequency-invalid-and-recovery']['invalid_frequency_rows']}
setters = {(r['field'], r['carrier']): r for r in rows['typed-setter-equivalence']['setter_rows']}
invalid_setters = {r['field']: r for r in rows['frequency-invalid-and-recovery']['invalid_date_fields']}
modifiers = rows['modifier-boundaries-order-and-recovery']
boundaries = {r['modifier']: r for r in modifiers['modifier_boundaries']}
orders = {', '.join(r['order']): r for r in modifiers['modifier_order']}
fields = {'lower bound': ('start', 'start'), 'upper bound': ('end', 'end'), 'requested anchor': ('basedate', 'base')}

def compact(text):
    return None if text == 'absent' else text[:10].replace('-', '') + text[11:]

checked = 0
for filename in ('grammar-and-boundaries.feature', 'modifier-families.feature'):
    header = None
    for line in (ROOT / 'spec/drafts/recurrence' / filename).read_text().splitlines():
        if not line.strip().startswith('|'):
            header = None
            continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if header is None:
            header = cells
            continue
        case = dict(zip(header, cells))
        cid = case['case']
        if cid.startswith('RECUR-GRAMMAR-'):
            row = shapes[case['text']]
            assert row['frequency_status'] == 0
            assert row['state']['frequency'] == case['stored']
            assert row.get('base_input') == (None if case['anchor'] == 'absent' else case['anchor'])
            assert row['nth_zero']['date'] == compact(case['event'])
            assert row['nth_zero']['lookup_error'] == 0
        elif cid.startswith('RECUR-FREQ-INVALID-'):
            row = invalid[case['text']]
            assert row['status'] == 1 and row['state']['frequency'] == ''
            assert row['state']['error'] == case['error']
        elif cid.startswith('RECUR-SETTER-'):
            method, key = fields[case['field']]
            if cid.endswith('-INVALID'):
                row = invalid_setters[method]
                assert row['status'] == 1 and row['state'][key] is None
                assert row['state']['error'] == case['error']
            else:
                carrier = 'text' if case['carrier'] == 'date text' else 'typed-date'
                row = setters[(method, carrier)]
                assert row['input'] == case['input'] and row['setter_status'] == 0
                assert row['state'][key] == compact(case['stored'])
        elif cid.startswith('RECUR-MOD-ORDER-'):
            row = orders[case['modifiers']]
            assert row['nth_zero']['date'] == compact(case['event'])
            assert row['nth_zero']['lookup_error'] == 0
        elif 'status' in case and 'modifier' in case:
            row = boundaries[case['modifier']]
            assert row['modifier_status'] == int(case['status'])
            assert row['state']['error'] == case['error']
            assert row['nth_zero']['date'] == compact(case['event'])
            assert str(row['nth_zero']['lookup_error']) == case['lookup']
        elif 'modifier' in case:
            row = rows['modifier-' + case['modifier'].rstrip('1234567890').lower()]
            assert row['input']['base'] == case['anchor']
            expected = compact(case['event']) if 'event' in case else None
            assert row['nth'][0]['date'] == expected
            assert row['nth'][0]['lookup_error'] == 0
        else:
            raise AssertionError(cid)
        checked += 1
assert modifiers['append_nth_zero']['date'] == '2040041712:34:56'
assert modifiers['recovery_nth_zero']['lookup_error'] == 'Invalid recurrence'
assert modifiers['full_recovery_nth_zero']['date'] == '2040041212:34:56'
assert modifiers['state_after_full_recovery']['error'] == ''
print(json.dumps({'draft_table_rows_checked': checked, 'repeatable_probe_cases': len(rows),
                  'approved_specification_cases': 0}, indent=2))
