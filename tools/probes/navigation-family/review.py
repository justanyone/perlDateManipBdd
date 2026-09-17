#!/usr/bin/env python3
"""Check navigation research against concrete draft rows; does not run BDD steps."""
import hashlib
import json
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/navigation-family'
data = json.loads((FAMILY / 'observations.json').read_text())
cases = json.loads((FAMILY / 'cases.json').read_text())['cases']
mapping = json.loads((FAMILY / 'coverage-map.json').read_text())
canonical = {x['id'] for x in json.loads((ROOT / 'docs/research/api/contract-map.json').read_text())['operations']}
for path, digest in (data['sha256'] | data['installed_module_sha256']).items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
assert len(cases) == len(data['observations']) == len(mapping['cases']) == 87

def typed(value):
    if value is None: return 'null'
    if isinstance(value, list): return 'list ' + arguments(value)
    if isinstance(value, str): return 'text ' + json.dumps(value)
    return 'number ' + str(value)

def arguments(values): return '[' + ', '.join(map(typed, values)) + ']'

def civil(value):
    assert re.fullmatch(r'\d{10}:\d{2}:\d{2}', value), value
    return value[:4] + '-' + value[4:6] + '-' + value[6:8] + ' ' + value[8:]

features = {str(p.relative_to(ROOT)): p.read_text() for p in (ROOT / 'spec/drafts/navigation').glob('*.feature')}
tables = {}
for path, text in features.items():
    header = None
    for line in text.splitlines():
        if not line.strip().startswith('|'):
            header = None; continue
        cells = [x.strip() for x in line.strip().strip('|').split('|')]
        if header is None: header = cells; continue
        assert len(cells) == len(header)
        row = dict(zip(header, cells))
        assert row['case'] not in tables
        tables[row['case']] = row

for case, record, mapped in zip(cases, data['observations'], mapping['cases']):
    cid = case['case_id']; obs = record['observation']; raw = obs['raw_return']; call = raw['call']
    assert cid == record['case_id'] == mapped['case_id']
    assert record['repeatable'] and record['exit_status'] == 0 and record['process_stderr'] == ''
    assert record['json_decode_error'] is None and obs['exception'] is None and obs['call_stdout'] == ''
    assert obs['request'] == case
    assert obs['operation_id'] == mapped['operation_id']
    assert set(obs['contract_ids']) <= canonical
    for path in obs['loaded_modules'].values():
        assert str(Path(path).relative_to(ROOT)) in data['installed_module_sha256']
    expected_warnings = 2 if 'OMITTED-CURR' in cid else (1 if case['profile'] == 'dm5' else 0)
    assert len(obs['warnings']) == expected_warnings
    if case['profile'] == 'dm5':
        assert obs['warnings'][0].startswith('Date::Manip::DM5 is deprecated')
    text = features[mapped['feature']]
    assert text.count(cid) == 1
    if cid in tables:
        row = tables[cid]
        assert row['direction'] == ('previous' if case['direction'] == 'prev' else 'next')
        assert row['exact arguments'] == arguments(case['arguments'])
        if 'initial receiver' in row: assert row['initial receiver'] == case['receiver']['text']
        if 'input text' in row: assert row['input text'] == case['receiver']['text']
        if 'profile' in row: assert row['profile'] == {'dm6':'current','dm5':'compatibility'}[case['profile']]
    else:
        block = next(block for block in text.split('  Scenario:') if cid in block)
        assert arguments(case['arguments']) in block and case['receiver']['text'] in block
        assert civil(raw['after']['scalar']['value']) in block
        row = {}
    if case['profile'] != 'oo':
        assert raw['setup']['distribution_version'] == '7.00'
        assert raw['setup']['backend_version'] == ('5.66' if case['profile'] == 'dm5' else '7.00')
        assert raw['setup']['configuration_exception'] is None
        if call['exception']:
            assert not call['call_completed'] and 'value' not in call and 'value_type' not in call
            assert call['exception'].startswith(row['exact exception prefix'])
        else:
            assert call['call_completed'] and call['value_type'] == 'scalar'
            if 'result' in row:
                assert row['result'] == (civil(call['value']) if call['value'] else 'empty text')
            elif 'OMITTED-CURR' in cid:
                assert civil(call['value']) == '2040-11-30 18:15:00'
            else: assert call['value'] == ''
    else:
        assert raw['setup']['version']['value'] == '7.00'
        assert call['exception'] is None
        state = raw['after']
        if 'wall result' in row:
            assert call['value'] == 0 and call['error_after'] == ''
            assert civil(state['scalar']['value']) == row['wall result']
            assert civil(state['gmt']['value']) == row['GMT result']
            assert state['list']['value'] == [int(x) for x in re.findall(r'\d+', row['wall result'])]
        elif 'call error' in row:
            assert call['value'] == 1 and call['error_after'] == ('' if row['call error'] == 'empty' else row['call error'])
        elif 'DST-GAP' in cid:
            assert call['value'] == 0 and call['error_after'] == '[set] Invalid date/timezone'
        else: assert call['value'] == 0 and call['error_after'] == ''
        if call['error_after'] or case['receiver']['state'] != 'valid':
            assert state['scalar']['value'] == '' and state['list']['value'] == []
            cleared = raw['after_error_clear']
            assert cleared['clear']['value'] is None and cleared['clear']['error_after'] == ''
            expected = '2040112318:15:00' if case['receiver']['state'] == 'valid' and 'DST-GAP' not in cid else ''
            assert cleared['state']['scalar']['value'] == expected
            assert cleared['state']['gmt']['value'] == expected
print('87 navigation requests, mapped literals, exception completion, mutation outcomes and module hashes verified')

# Portable observer vocabulary must not reintroduce source calling conventions.
object_text = features['spec/drafts/navigation/object-navigation.feature']
background = object_text.split('  Scenario:')[0]
assert 'scalar' not in background and 'list context' not in background
functional_text = features['spec/drafts/navigation/functional-navigation.feature']
for block in functional_text.split('  Scenario:'):
    if block.lstrip().startswith(('Functional profiles navigate', 'Invalid source and weekday', 'Extra clock components')):
        assert 'deprecation' not in block and 'defined scalar' not in block
for observer in mapping['portable_observers'].values():
    assert observer['operation_id'] in canonical
