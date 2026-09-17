#!/usr/bin/env python3
"""Check draft partial-parsing evidence; this is not an executable BDD runner."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / 'docs/research/partial-parsing-edges'
load = lambda name: json.loads((FAMILY / name).read_text())
cases = {c['case_id']: c for c in load('cases.json')['cases']}
evidence = load('observations.json')
rows = {r['case_id']: r for r in evidence['observations']}
assert len(cases) == len(rows) == 52 and cases.keys() == rows.keys()
for group in ('sha256', 'installed_module_sha256'):
    for path, digest in evidence[group].items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
mapping = load('feature-map.json')
seen = []
for path, ids in mapping['portable_features'].items():
    text = (ROOT / path).read_text()
    found = re.findall(r'PPE-(?:DATE|TIME|PREFIX)-[A-Z0-9-]+', text)
    assert sorted(found) == sorted(ids), path
    seen.extend(found)
assert len(seen) == len(set(seen)) == 52 and set(seen) == set(cases)
failures = successes = 0
for cid, row in rows.items():
    o = row['observation']; case = cases[cid]
    assert row['research_status'] == 'repeatable' and row['process_stderr'] == ''
    assert o['request'] == case and o['exception'] is None and o['call_stdout'] == ''
    assert o['observed_distribution_version'] == '7.00'
    assert o['observed_backend_version'] == ('5.66' if case.get('profile') == 'dm5' else '7.00')
    calls = o.get('calls', [o]) if case['kind'] != 'prefix' else []
    for call in calls:
        assert call['configuration_error'] == '' and call['initialization_status'] == 0
        if call['status']:
            failures += 1
            assert call['value_while_error'] == '' and call['value_while_error_type'] == 'text'
            assert call['error_clear_return'] is None and call['error_clear_return_type'] == 'absent'
            assert call['error_after_clear'] == ''
            full = call.get('method') == 'parse'
            assert call['error_after_value_while_error'] == ('[value] Object does not contain a date' if full else call['error_after_call'])
            assert call['error_after_value_after_clear'] == ('[value] Object does not contain a date' if full else '')
            initial = call['initial_request'][:19].replace('-', '').replace(' ', '')
            assert call['value_after_error_clear'] == ('' if full else initial)
        elif case['kind'] == 'oo':
            successes += 1
            for name in ('parsed', 'gmt'):
                fields = call[name + '_fields']
                y, m, d, h, minute, sec = fields
                assert call[name + '_value'] == f'{y:04}{m:02}{d:02}{h:02}:{minute:02}:{sec:02}'
                assert call['error_after_' + name + '_scalar'] == call['error_after_' + name + '_list'] == ''
    if case['kind'] == 'prefix':
        assert o['carrier_before'] == case['value']
        if case['carrier'] == 'token-array':
            assert o['consumed_count'] == len(o['carrier_before']) - len(o['carrier_after'])
        else:
            assert o['carrier_after'] == o['carrier_before'] and o['value'] == ''
# Compare explicit outline columns with the frozen native channels.
table_rows = 0
for path in mapping['portable_features']:
    header = None
    for line in (ROOT / path).read_text().splitlines():
        if not line.strip().startswith('|'):
            header = None
            continue
        cells = [c.strip().replace(r'\|', '|') for c in re.split(r'(?<!\\)\|', line.strip())[1:-1]]
        if header is None:
            header = cells
            continue
        row = dict(zip(header, cells))
        cid = row.get('case')
        if cid not in cases:
            continue
        table_rows += 1
        case = cases[cid]; observation = rows[cid]['observation']
        for column, key in [('text', 'text'), ('date', 'text'), ('initial', 'initial')]:
            if column in row:
                assert row[column] == case[key], (cid, column)
        for column, key in [('result', 'parsed_value'), ('gmt', 'gmt_value')]:
            if column in row:
                native = observation.get(key, observation.get('value'))
                assert row[column][:19].replace('-', '').replace(' ', '') == native, (cid, column)
        if 'zone' in row:
            assert row['zone'] == observation['zone_render'], cid
        if 'local zone' in row:
            assert row['local zone'] == observation['observed_context_zone'], cid
        if 'consumed' in row:
            assert int(row['consumed']) == observation['consumed_count'], cid
        if 'tokens' in row:
            assert json.loads(row['tokens']) == case['value'], cid
assert table_rows == 48

assert failures == 14 and successes == 24
for cid, count in [('PPE-DATE-GATE-NOHOLIDAYS', 12), ('PPE-PREFIX-DM6-UNDEFINED-TOKEN', 2), ('PPE-PREFIX-DM5-UNDEFINED-TOKEN', 3)]:
    assert len(rows[cid]['observation']['warnings']) == count
binding = mapping['binding_only_feature']; text = (ROOT / binding['path']).read_text()
assert '@excluded-from-portable-handoff' in text
for assertion in binding['assertions']:
    assert text.count(assertion['assertion_id']) == 1
    assert assertion['source_case_id'] in rows
print('52 mapped cases; 11 hashes; 14 failure lifecycles; 24 scalar/list successes; 3 binding assertions checked')
