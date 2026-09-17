#!/usr/bin/env python3
"""Review year/day evidence, exact feature rows, provenance, and calendar facts."""
import datetime as dt
from decimal import Decimal, ROUND_HALF_EVEN
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/year-day-conversion-family'
load = lambda name: json.loads((FAMILY / name).read_text())
manifest = load('cases.json')
evidence = load('observations.json')
bindings = load('bindings.json')
mapping = load('feature-map.json')
cases = manifest['cases']
observations = evidence['observations']
reference_profiles = {p['name']: p for p in json.loads((ROOT / 'docs/automation/reference-profiles.json').read_text())['profiles']}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compact(value):
    return json.dumps(value, separators=(',', ':'), ensure_ascii=False)


def table_after(relative, header, occurrence=0):
    lines = (ROOT / relative).read_text().splitlines()
    starts = []
    for index, line in enumerate(lines):
        if line.lstrip().startswith('|'):
            row = [cell.strip() for cell in line.strip().strip('|').split('|')]
            if row == header:
                starts.append(index)
    assert len(starts) > occurrence, (relative, header, starts)
    start = starts[occurrence]
    rows = []
    for line in lines[start + 1:]:
        if not line.lstrip().startswith('|'):
            break
        row = [cell.strip() for cell in line.strip().strip('|').split('|')]
        assert len(row) == len(header), (relative, line)
        rows.append(dict(zip(header, row)))
    assert rows
    return rows


assert manifest['schema_version'] == evidence['schema_version'] == bindings['schema_version'] == mapping['schema_version'] == 1
assert len(cases) == len(observations) == len(mapping['case_map']) == 40
case_ids = [case['case_id'] for case in cases]
assert len(set(case_ids)) == 40
assert [row['case_id'] for row in observations] == case_ids
assert [row['case_id'] for row in mapping['case_map']] == case_ids
assert {case['operation_id'] for case in cases} == set(manifest['operation_ids']) == set(evidence['operation_ids'])
assert {case['profile'] for case in cases} == {'base', 'dm6', 'dm5'}
assert sum(case['profile'] == 'base' for case in cases) == 23
assert sum(case['profile'] == 'dm6' for case in cases) == 9
assert sum(case['profile'] == 'dm5' for case in cases) == 8

for relative, expected in evidence['sha256'].items():
    assert digest(ROOT / relative) == expected, relative
for relative, expected in mapping['artifact_sha256'].items():
    assert digest(ROOT / relative) == expected, relative
execution = evidence['execution']
assert execution == {
    'command': 'python3 tools/probes/year-day-conversion-family/run.py',
    'environment': {
        'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8',
        'PATH': '/usr/bin:/bin',
        'PERL5LIB': str(ROOT / 'local/date-manip-7.00/lib/perl5'),
        'TZ': 'Etc/UTC',
    },
    'fresh_temporary_directory_per_repetition': True,
    'parallel_workers': 4,
    'perl': '/usr/bin/perl',
    'repetitions_per_case': 2,
    'timeout_seconds': 15,
}

profile_label = {'base': 'calendar service', 'dm6': 'current functional', 'dm5': 'legacy functional'}
dm5_warning = ('Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package '
               'starting in version 7.00 at (eval 42) line 1.\n')
by_id = {}


def same_json_value(actual, expected):
    if isinstance(actual, float) or isinstance(expected, float):
        return isinstance(actual, (int, float)) and isinstance(expected, (int, float)) and math.isclose(actual, expected, rel_tol=0, abs_tol=1e-12)
    if isinstance(expected, list):
        return isinstance(actual, list) and len(actual) == len(expected) and all(same_json_value(a, e) for a, e in zip(actual, expected))
    if isinstance(expected, dict):
        return isinstance(actual, dict) and actual.keys() == expected.keys() and all(same_json_value(actual[k], expected[k]) for k in expected)
    return actual == expected


for case, observed, mapped in zip(cases, observations, mapping['case_map']):
    by_id[case['case_id']] = observed
    for field in ('case_id', 'operation_id', 'profile', 'group', 'classification', 'argument_spec', 'request'):
        assert same_json_value(observed[field], case[field]), (case['case_id'], field)
    assert mapped['profile'] == case['profile']
    assert mapped['classification'] == case['classification']
    assert (ROOT / mapped['feature']).is_file()
    assert observed['distribution_version'] == '7.00'
    assert observed['perl_version'] == 'v5.40.1'
    assert observed['perl_archname'] == 'x86_64-linux-gnu-thread-multi'
    fixture = reference_profiles['oo' if case['profile'] == 'base' else case['profile']]
    assert observed['fixture_profile'] == fixture
    requested = list(fixture['configuration'])
    if 'yy_to_yyyy' in case:
        requested.append('YYtoYYYY=' + case['yy_to_yyyy'])
    assert observed['requested_configuration'] == requested
    assert observed['process_attempts_byte_equal'] is True
    assert len(observed['process_attempts']) == 2
    assert observed['process_attempts'][0] == observed['process_attempts'][1]
    process = observed['process_attempts'][0]
    assert process['exit_code'] == 0 and process['stderr'] == ''
    assert process['stderr_sha256'] == hashlib.sha256(b'').hexdigest()
    assert len(process['stdout_sha256']) == 64
    load_call = observed['module_load']
    assert load_call['call_completed'] and load_call['exception'] is None and load_call['stdout'] == ''
    assert load_call['warnings'] == ([dm5_warning] if case['profile'] == 'dm5' else [])
    config = observed['configuration']
    assert config['call_completed'] and config['exception'] is None and config['stdout'] == '' and config['warnings'] == []
    expected_config = '' if case['profile'] == 'dm6' else None
    assert config['return'] == expected_config
    assert config['return_type'] == ('scalar' if case['profile'] == 'dm6' else 'undefined')
    version = observed['version']
    assert version['call_completed'] and version['warnings'] == [] and version['exception'] is None and version['stdout'] == ''
    assert version['return'] == ('5.66' if case['profile'] == 'dm5' else '7.00')
    if case['profile'] == 'base':
        assert observed['constructor']['return'] == 'Date::Manip::Date'
        assert observed['zone_service']['return'] == 'Date::Manip::TZ'
        assert observed['tzdata']['return'] == 'tzdata2026c'
        assert observed['tzcode']['return'] == 'tzcode2026c'
        assert observed['base_service']['return'] == 'Date::Manip::Base'
    for context in ('scalar', 'list'):
        sequence = observed[context]
        call = sequence['call']
        assert call['context'] == context
        assert call['call_completed'] is True
        assert 'return' in call and 'return_type' in call
        assert call['exception'] is None and call['stdout'] == ''
        if context == 'list':
            assert call['return_count'] == len(call['return'])
            assert call['return_element_types'] == [
                'undefined' if value is None else ('ARRAY' if isinstance(value, list) else 'scalar')
                for value in call['return']
            ]
        if case['profile'] == 'base':
            for observer in ('error_before', 'error_after'):
                error = sequence[observer]
                assert error['call_completed'] and error['return'] == '' and error['return_type'] == 'scalar'
                assert error['warnings'] == [] and error['exception'] is None and error['stdout'] == ''
        else:
            assert set(sequence) == {'call'}

# If a future observation is interrupted, it must not invent a native return.
for observed in observations:
    for key in ('configuration', 'version', 'constructor', 'zone_service', 'tzdata', 'tzcode', 'base_service'):
        if key in observed and not observed[key]['call_completed']:
            assert 'return' not in observed[key] and 'return_type' not in observed[key]
    for context in ('scalar', 'list'):
        call = observed[context]['call']
        if not call['call_completed']:
            assert 'return' not in call and 'return_type' not in call

# Canonical public binding inventory, including every setup and observer call.
canonical = json.loads((ROOT / 'docs/research/api/contract-map.json').read_text())
canonical_ids = {operation['id'] for operation in canonical['operations']}
assert set(bindings['primary_operation_ids']) <= canonical_ids
assert {row['operation_id'] for row in bindings['supporting_public_calls']} <= canonical_ids
assert {(row['module'], row['callable']) for row in bindings['bindings']} == {
    ('Date::Manip::Base', 'day_of_year'),
    ('Date::Manip::DM6', 'Date_DayOfYear'),
    ('Date::Manip::DM5', 'Date_DayOfYear'),
    ('Date::Manip::DM6', 'Date_NthDayOfYear'),
    ('Date::Manip::DM5', 'Date_NthDayOfYear'),
}
contract = json.loads((ROOT / 'docs/research/contracts/calendar.json').read_text())
contract_ops = {operation['operation_id']: operation for operation in contract['operations']}
assert set(manifest['operation_ids']) <= set(contract_ops)
partition_ids = {partition['id'] for op in manifest['operation_ids'] for partition in contract_ops[op]['partitions']}
assert {row['partition_id'] for row in mapping['partition_evidence']} == partition_ids
for row in mapping['partition_evidence']:
    assert row['status'] != 'complete'
    assert set(row['case_ids']) <= set(case_ids)

# Exact native carrier table.
binding_path = 'spec/drafts/year-day-conversions/perl-binding.feature'
carrier_header = ['case', 'profile', 'callable', 'arguments', 'scalar', 'list',
                  'scalar warnings', 'list warnings', 'errors']
carrier_rows = table_after(binding_path, carrier_header)
assert [row['case'] for row in carrier_rows] == case_ids


def native(call, context):
    if not call['call_completed']:
        return 'no return'
    if context == 'scalar':
        if call['return_type'] == 'undefined':
            return 'undefined'
        if call['return_type'] == 'ARRAY':
            return 'array reference ' + compact(call['return'])
        return 'scalar ' + compact(call['return'])
    return 'list ' + compact(call['return'])


for case, observed, row in zip(cases, observations, carrier_rows):
    scalar = observed['scalar']['call']
    listed = observed['list']['call']
    expected = {
        'case': case['case_id'],
        'profile': profile_label[case['profile']],
        'callable': observed['callable'],
        'arguments': compact(case['argument_spec']),
        'scalar': native(scalar, 'scalar'),
        'list': native(listed, 'list'),
        'scalar warnings': str(len(scalar['warnings'])),
        'list warnings': str(len(listed['warnings'])),
        'errors': 'empty before/after' if case['profile'] == 'base' else 'no observer',
    }
    assert row == expected, case['case_id']

setup = table_after(binding_path, ['profile', 'constructor result', 'configuration result', 'version',
                                   'zone metadata', 'service result', 'module-load warnings'])
assert setup == [
    {'profile':'calendar service','constructor result':'Date::Manip::Date','configuration result':'undefined',
     'version':'7.00','zone metadata':'tzdata2026c and tzcode2026c','service result':'Date::Manip::Base','module-load warnings':'0'},
    {'profile':'current functional','constructor result':'not requested','configuration result':'defined empty text',
     'version':'7.00','zone metadata':'not exposed by this binding','service result':'not requested','module-load warnings':'0'},
    {'profile':'legacy functional','constructor result':'not requested','configuration result':'undefined',
     'version':'5.66','zone metadata':'not exposed by this binding','service result':'not requested','module-load warnings':'1'},
]
warning_rows = table_after(binding_path, ['case', 'count', 'first warning'])
for row in warning_rows:
    observed = by_id[row['case']]
    for context in ('scalar', 'list'):
        warnings = observed[context]['call']['warnings']
        assert len(warnings) == int(row['count'])
        assert warnings[0].startswith(row['first warning'])
assert dm5_warning.rstrip('\n') in (ROOT / binding_path).read_text()

# Portable forward rows and independent Gregorian facts.
forward_path = 'spec/drafts/year-day-conversions/forward.feature'
forward_rows = table_after(forward_path, ['case', 'profile', 'civil fields', 'ordinal'])
fraction_rows = table_after(forward_path, ['case', 'civil fields', 'ordinal'])
assert len(forward_rows) == 8 and len(fraction_rows) == 2
for row in forward_rows + fraction_rows:
    observed = by_id[row['case']]
    fields = json.loads(row['civil fields'])
    date = dt.date(*fields[:3])
    expected = Decimal(date.timetuple().tm_yday)
    if len(fields) == 6:
        expected += (Decimal(fields[3]) * 3600 + Decimal(fields[4]) * 60 + Decimal(str(fields[5]))) / Decimal(86400)
    actual = Decimal(str(observed['scalar']['call']['return']))
    assert abs(actual - expected) < Decimal('0.0000000000001'), row['case']
    assert Decimal(row['ordinal']) == actual
    if row in fraction_rows:
        rounded = actual.quantize(Decimal('0.000000000001'), rounding=ROUND_HALF_EVEN)
        assert format(rounded, 'f').rstrip('0').rstrip('.') == row['ordinal']
    assert observed['list']['call']['return'] == [observed['scalar']['call']['return']]
    if 'profile' in row:
        assert row['profile'] == profile_label[observed['profile']]

# Portable inverse rows and independent Gregorian conversion.
inverse_path = 'spec/drafts/year-day-conversions/inverse.feature'
integral_rows = table_after(inverse_path, ['case', 'profile', 'year', 'ordinal', 'fields'], 0)
inverse_fraction_rows = table_after(inverse_path, ['case', 'profile', 'year', 'ordinal', 'fields'], 1)
assert len(integral_rows) == 8 and len(inverse_fraction_rows) == 6
for row in integral_rows + inverse_fraction_rows:
    observed = by_id[row['case']]
    year = int(row['year'])
    ordinal = Decimal(row['ordinal'])
    whole = int(ordinal)
    date = dt.date(year, 1, 1) + dt.timedelta(days=whole - 1)
    remainder = ordinal - whole
    seconds = remainder * Decimal(86400)
    hour = int(seconds // Decimal(3600))
    seconds -= Decimal(hour * 3600)
    minute = int(seconds // Decimal(60))
    seconds -= Decimal(minute * 60)
    expected_fields = [date.year, date.month, date.day]
    if remainder or observed['profile'] != 'base':
        second = int(seconds) if seconds == int(seconds) else float(seconds)
        expected_fields += [hour, minute, second]
    feature_fields = json.loads(row['fields'])
    assert len(feature_fields) == len(expected_fields)
    for actual, expected in zip(feature_fields, expected_fields):
        if isinstance(expected, float):
            assert math.isclose(actual, expected, abs_tol=0.005)
        else:
            assert actual == expected
    native = observed['scalar']['call']['return'] if observed['profile'] == 'base' else observed['list']['call']['return']
    assert len(native) == len(expected_fields)
    assert [Decimal(str(value)) for value in native] == [Decimal(str(value)) for value in feature_fields], row['case']
    for actual, expected in zip(native, expected_fields):
        if isinstance(expected, float):
            assert math.isclose(float(actual), expected, abs_tol=0.005)
        else:
            assert actual == expected
    assert row['profile'] == profile_label[observed['profile']]
assert '[2040,2,29,12,0,0.50]' in (ROOT / inverse_path).read_text()
assert 'rounded to 12 decimal places with ties to even and trailing zeros removed' in (ROOT / forward_path).read_text()
for filename in ('forward.feature', 'inverse.feature', 'compatibility.feature'):
    text = (ROOT / 'spec/drafts/year-day-conversions' / filename).read_text()
    assert 'three civil fields are ordered year, month, day' in text
    assert 'six civil fields are ordered year, month, day, hour, minute, second' in text

# Exact disputed rows; these are evidence, not independent Gregorian approval.
compat_path = 'spec/drafts/year-day-conversions/compatibility.feature'
short_rows = table_after(compat_path, ['case', 'profile', 'ordinal'])
assert short_rows == [
    {'case':'YDC-FWD-DM6-SHORT-C19','profile':'current functional','ordinal':'61'},
    {'case':'YDC-FWD-DM5-SHORT-C19','profile':'legacy functional','ordinal':'60'},
]
out_rows = table_after(compat_path, ['case', 'profile', 'year', 'ordinal', 'fields'])
for row in out_rows:
    observed = by_id[row['case']]
    native = observed['scalar']['call']['return'] if observed['profile'] == 'base' else observed['list']['call']['return']
    assert json.loads(row['fields']) == native
    assert int(row['year']) == observed['request']['year']
    assert int(row['ordinal']) == observed['request']['ordinal']
    assert row['profile'] == profile_label[observed['profile']]
compat_text = (ROOT / compat_path).read_text()
assert 'civil fields [2039,2,29]' in compat_text and 'observed numeric ordinal is exactly 60' in compat_text
assert 'year and ordinal both omitted' in compat_text and '[2040,1,1,0,0,0]' in compat_text
dm5_bound = by_id['YDC-EDGE-DM5-COMMON-366']
assert dm5_bound['scalar']['call']['return_type'] == 'undefined'
assert dm5_bound['list']['call']['return'] == []
assert 'result is an absent civil date value' in (ROOT / inverse_path).read_text()

primary_feature_ids = set()
for relative in ('forward.feature', 'inverse.feature', 'compatibility.feature'):
    for line in (ROOT / 'spec/drafts/year-day-conversions' / relative).read_text().splitlines():
        if '| YDC-' in line:
            primary_feature_ids.add(line.split('|')[1].strip())
primary_feature_ids |= {'YDC-FWD-BASE-INVALID-CIVIL', 'YDC-EDGE-DM5-COMMON-366', 'YDC-EDGE-DM5-OMITTED'}
assert primary_feature_ids == {case['case_id'] for case in cases if case['classification'] != 'binding-only'}
assert '@excluded-from-portable-handoff' in (ROOT / binding_path).read_text().splitlines()[0]
assert '@disputed' in (ROOT / compat_path).read_text().splitlines()[0]

print('40 cases, 80 conversion calls, exact setup/error/channel records, 34 portable-or-disputed mappings, independent Gregorian facts, hashes, and four feature files verified')
