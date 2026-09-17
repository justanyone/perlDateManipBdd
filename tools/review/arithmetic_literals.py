#!/usr/bin/env python3
"""Targeted arithmetic draft checks; no reference calls or automatic approval."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/arithmetic-family/observations.json').read_text())
mapping = json.loads((ROOT / 'docs/research/arithmetic-family/feature-map.json').read_text())
source_cases = {}
for name in ('cases.json', 'extended-cases.json', 'edge-cases.json'):
    for case in json.loads(
        (ROOT / 'docs/research/arithmetic-family' / name).read_text()
    )['cases']:
        assert case['case_id'] not in source_cases
        source_cases[case['case_id']] = case
for path, digest in record['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
rows = {r['case_id']: r['observation'] for r in record['observations']}
assert len(rows) == 107
assert set(rows) == set(source_cases)
assert all(r['repeatable'] and r['stderr'] == '' for r in record['observations'])
assert all(r['exception'] is None and r['call_stdout'] == '' for r in rows.values())

def normalized(value):
    if isinstance(value, str) and len(value) == 16 and value[:8].isdigit() and value[10] == ':':
        return value[:4] + '-' + value[4:6] + '-' + value[6:8] + ' ' + value[8:]
    return value

checked = 0
seen = set()
outline_rows = {}
feature_texts = {
    path.name: path.read_text()
    for path in (ROOT / 'spec/drafts/arithmetic').glob('*.feature')
}
for name, text in feature_texts.items():
    header = None
    for line in text.splitlines():
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
        outline_rows[cid] = case
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
profile = mapping['portable_profile']

def two_column_table(block):
    pairs = []
    for line in block.splitlines():
        if not line.strip().startswith('|'):
            continue
        cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
        assert len(cells) == 2
        pairs.append(cells)
    return dict(pairs[1:])

for name, text in feature_texts.items():
    assert 'named fixed profile' not in text and 'named fixed reference profile' not in text
    setting_block, tail = text.split(
        '    And interval normalization uses these relationships:', 1
    )
    relation_block = tail.split('\n    And interval field records', 1)[0]
    relation_block = relation_block.split('\n  @', 1)[0]
    assert two_column_table(setting_block) == profile['settings'], name
    assert two_column_table(relation_block) == profile[
        'interval_normalization_relationships'
    ], name

reference_profiles = {
    row['name']: row
    for row in json.loads(
        (ROOT / 'docs/automation/reference-profiles.json').read_text()
    )['profiles']
}
for profile_name in ('oo', 'dm6', 'dm5'):
    configured = reference_profiles[profile_name]['configuration']
    config_values = dict(item.split('=', 1) for item in configured)
    observed_profiles = {
        tuple(observation['profile_configuration'])
        for observation in rows.values()
        if observation['profile'] == profile_name
    }
    assert observed_profiles == {tuple(configured)}, profile_name
    joined = '\n'.join(configured)
    assert 'Language=English' in joined and 'DateFormat=US' in joined
    assert 'FirstDay=1' in joined
    assert 'WorkWeekBeg=1' in joined and 'WorkWeekEnd=5' in joined
    assert 'WorkDayBeg=09:00' in joined and 'WorkDayEnd=17:00' in joined
    assert 'WorkDay24Hr=0' in joined and 'EraseHolidays=1' in joined
    assert int(config_values['WorkWeekEnd']) - int(config_values['WorkWeekBeg']) + 1 == 5
    work_start = int(config_values['WorkDayBeg'].split(':', 1)[0])
    work_end = int(config_values['WorkDayEnd'].split(':', 1)[0])
    assert work_end - work_start == 8
    if profile_name == 'dm5':
        assert 'ForceDate=2040-02-28-10:20:30' in joined
        assert 'TZ=Etc/UTC' in joined and 'Jan1Week1=0' in joined
        assert 'TodayIsMidnight=1' in joined
    else:
        assert 'ForceDate=2040-02-28-10:20:30,Etc/UTC' in joined
        assert 'Encoding=ASCII' in joined and 'Week1ofYear=jan4' in joined
        assert 'DefaultTime=midnight' in joined and 'EraseEvents=1' in joined

range_case = source_cases['DELTA-FORMAT-ALL-RANGES']
range_observation = rows['DELTA-FORMAT-ALL-RANGES']['raw_return']
assert range_case['request']['initial'] == '1:2:3:4:5:6:7'
conversions = dict(zip(
    range_case['request']['patterns'],
    map(int, range_observation['list']),
))
second = conversions['%smm'] // 6
hour = conversions['%shh'] // 5
day = conversions['%sdd'] // 4
week = conversions['%sww'] // 3
year = conversions['%syy']
month = conversions['%sMM'] // 2
assert second == 60
assert hour == 60 * second
assert day == 24 * hour
assert week == 7 * day
assert year == 12 * month
assert year * 10_000 == 3_652_425 * day
assert profile['interval_normalization_relationships'] == {
    'minute': '60 seconds',
    'hour': '60 minutes',
    'standard day': '24 hours',
    'standard week': '7 days',
    'year for year-month normalization': '12 months',
    'year for estimated conversion': '365.2425 days',
    'configured business day': '8 hours',
    'configured business week': '5 days',
}

repairs = mapping['portable_repairs']
for cid in ('DELTA-FORMAT-DM6', 'DELTA-FORMAT-DM5'):
    repair = repairs[cid]
    text = feature_texts[Path(repair['feature']).name]
    block = text.split('  Scenario: ' + repair['scenario'], 1)[1].split('\n  @', 1)[0]
    assert 'scalar' not in block and 'list result' not in block
    assert 'use render-each-pattern' in block and 'use render-joined-patterns' in block
    interval, delta_type, precision, *patterns = source_cases[cid]['request']['args']
    profile_text = 'current' if cid.endswith('DM6') else 'legacy'
    request_tail = (
        f'with interval {json.dumps(interval)}, type {json.dumps(delta_type)}, '
        f'decimal places {precision}, and patterns {json.dumps(patterns[0])} and '
        f'{json.dumps(patterns[1])} in the {profile_text} compatibility profile'
    )
    assert f'When I use render-each-pattern {request_tail}' in block
    assert f'When I use render-joined-patterns {request_tail}' in block
    observed = rows[cid]['raw_return']
    operations = {item['operation']: item for item in repair['portable_operations']}
    assert operations['render-each-pattern']['expected'] == observed['list']
    assert operations['render-each-pattern']['evidence_carrier'] == 'raw_return.list'
    assert operations['render-each-pattern']['research_binding_context'] == 'Perl list context'
    assert operations['render-joined-patterns']['expected'] == observed['scalar']
    assert operations['render-joined-patterns']['evidence_carrier'] == 'raw_return.scalar'
    assert operations['render-joined-patterns']['research_binding_context'] == 'Perl scalar context'
    list_literal = ' and '.join(json.dumps(value) for value in observed['list'])
    assert f'Then the ordered rendered texts are {list_literal}' in block
    assert f'Then the joined rendered text is {json.dumps(observed["scalar"])}' in block

def typed_literal(value):
    return 'empty text' if value == '' else 'text ' + json.dumps(value)

grammar_repairs = repairs['delta_grammar_rows']
assert len(grammar_repairs) == 20
for cid, repair in grammar_repairs.items():
    row = outline_rows[cid]
    observed = rows[cid]['raw_return']
    request = source_cases[cid]['request']
    assert set(request) == {'text'}
    assert row['text'] == repair['input_text'] == request['text']
    assert repair['options_literal'] == 'default options'
    grammar_text = feature_texts['delta-grammar-and-format-matrix.feature']
    assert 'When I parse interval text "<text>" with default options' in grammar_text
    assert row['status'] == str(observed['status'])
    assert row['fields'] == repair['serialized_interval_literal'] == typed_literal(
        observed['after']['value_scalar']
    )
    assert row['error'] == repair['error_literal'] == typed_literal(
        observed['after']['error']
    )
    assert row['fields'] and row['error']

invalid_repair = repairs['BUSINESS-INVALID-OBJECT']
edge_text = feature_texts['arithmetic-dst-business-edges.feature']
portable_block = edge_text.split(
    '  Scenario: ' + invalid_repair['portable_scenario'], 1
)[1].split('\n\n', 1)[0]
binding_marker = (
    '  @source-binding @perl-binding @reference-binding '
    '@excluded-from-portable-handoff\n  Scenario: '
    + invalid_repair['binding_scenario']
)
assert binding_marker in edge_text
binding_block = edge_text.split(binding_marker, 1)[1]
assert 'warning' not in portable_block
assert 'the answer is absent' in portable_block
assert 'the error remains "[parse] Invalid date string"' in portable_block
assert 'same invalid state without a stored-value query' in portable_block
warning = rows['BUSINESS-INVALID-OBJECT']['warnings']
assert rows['BUSINESS-INVALID-OBJECT']['raw_return']['before'] == rows[
    'BUSINESS-INVALID-OBJECT'
]['raw_return']['after']
assert rows['BUSINESS-INVALID-OBJECT']['raw_return']['before'][
    'value_read_performed'
] is False
assert len(warning) == 1
assert invalid_repair['native_warning_contains'] in warning[0]
assert invalid_repair['native_warning_contains'] in binding_block
print(json.dumps({'repeatable_cases': len(rows), 'calculation_table_literals_checked': checked,
                  'unique_outline_rows': len(seen), 'invalid_state_channels_checked': 3,
                  'typed_delta_grammar_rows_checked': len(grammar_repairs),
                  'named_pattern_operations_checked': 4,
                  'binding_warning_splits_checked': 1,
                  'approved_specification_cases': 0}, indent=2))
