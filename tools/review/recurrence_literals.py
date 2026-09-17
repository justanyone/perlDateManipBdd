#!/usr/bin/env python3
"""Check recurrence draft table assertions against immutable recorded calls."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/recurrence-family/observations.json').read_text())
assert hashlib.sha256((ROOT / record['probe']).read_bytes()).hexdigest() == record['probe_sha256']
assert hashlib.sha256((ROOT / record['reference_profile_record']).read_bytes()).hexdigest() == record['reference_profile_sha256']
profile_record = json.loads((ROOT / record['reference_profile_record']).read_text())
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

def error_literal(text):
    if text == 'empty text':
        return ''
    match = re.fullmatch(r'text "(.*)"', text)
    assert match, f'untyped error literal: {text!r}'
    return match.group(1)

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
        if 'case' not in case:
            continue
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
            assert row['state']['error'] == error_literal(case['error'])
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

oo_profile = next(profile for profile in profile_record['profiles'] if profile['name'] == 'oo')
assert oo_profile['interface'] == 'Date::Manip::Date'
profile_config = dict(item.split('=', 1) for item in oo_profile['configuration'])
force_clock, force_zone = profile_config['ForceDate'].split(',', 1)
force_clock_match = re.fullmatch(r'(\d{4}-\d{2}-\d{2})-(\d{2}:\d{2}:\d{2})', force_clock)
assert force_clock_match
weekday_names = {
    '1': 'Monday', '2': 'Tuesday', '3': 'Wednesday', '4': 'Thursday',
    '5': 'Friday', '6': 'Saturday', '7': 'Sunday',
}
fixture = {
    'input language': profile_config['Language'],
    'time zone': force_zone,
    'reference clock': ' '.join(force_clock_match.groups()),
    'numeric date ordering': {'US': 'month then day'}[profile_config['DateFormat']],
    'omitted time': profile_config['DefaultTime'],
    'first day of week': weekday_names[profile_config['FirstDay']],
    'first week rule': {'jan4': 'week containing January 4'}[profile_config['Week1ofYear']],
    'working days': (f'{weekday_names[profile_config["WorkWeekBeg"]]} through '
                     f'{weekday_names[profile_config["WorkWeekEnd"]]}'),
    'working hours': f'{profile_config["WorkDayBeg"]} through {profile_config["WorkDayEnd"]}',
    'holidays and events': ('none' if profile_config['EraseHolidays'] == '1'
                            and profile_config['EraseEvents'] == '1' else 'configured'),
}
feature_dir = ROOT / 'spec/drafts/recurrence'
portable_names = (
    'lifecycle.feature',
    'grammar-and-boundaries.feature',
    'modifier-families.feature',
    'enumeration-and-compatibility.feature',
)
for filename in portable_names + ('perl-binding.feature',):
    text = (feature_dir / filename).read_text()
    assert 'Given the named recurrence fixture "utc-working-week-2040" has:' in text
    for setting, value in fixture.items():
        assert re.search(
            rf'^\s*\|\s*{re.escape(setting)}\s*\|\s*{re.escape(value)}\s*\|\s*$',
            text,
            re.MULTILINE,
        ), (filename, setting)

portable_text = '\n'.join((feature_dir / name).read_text() for name in portable_names)
binding_text = (feature_dir / 'perl-binding.feature').read_text()
grammar_text = (feature_dir / 'grammar-and-boundaries.feature').read_text()
probe_text = (ROOT / record['probe']).read_text()
assert "my $p = profile('oo');" in probe_text
diagnostic = "Can't use an undefined value as an ARRAY reference"
assert diagnostic not in portable_text
assert diagnostic in binding_text
assert binding_text.startswith(
    '@draft @recurrence @source-binding @perl-binding @reference-observed '
    '@excluded-from-portable-handoff\n'
)
assert '@RECUR-BIND-MAX-ATTEMPTS-DIAGNOSTIC @compatibility @disputed' in binding_text
assert 'Given public operation "recur.next-occurrence"' in binding_text
assert 'Then the public lookup call does not complete' in portable_text
assert 'And neither an event value nor a lookup-error value is returned' in portable_text

coverage = json.loads((ROOT / 'docs/research/recurrence-family/coverage.json').read_text())
feature_map = json.loads((ROOT / 'docs/research/recurrence-family/feature-map.json').read_text())
portability = json.loads((ROOT / 'docs/research/recurrence-family/portability-map.json').read_text())
coverage_cases = {case['case_id']: case for case in coverage['cases']}
mapped_cases = {case['case_id']: case for case in feature_map['portable_cases']}
assert len(coverage_cases) == len(mapped_cases) == 69
assert coverage_cases.keys() == mapped_cases.keys()
for case_id, source in coverage_cases.items():
    mapped = mapped_cases[case_id]
    assert mapped['public_operation_ids'] == source['contracts']
    assert mapped['contract_partitions'] == source['partitions']
    assert mapped['evidence_selector'] == source['reference_case']
    assert case_id in (ROOT / mapped['feature']).read_text()
assert feature_map['binding_cases'] == [{
    'binding_case_id': 'RECUR-BIND-MAX-ATTEMPTS-DIAGNOSTIC',
    'feature': 'spec/drafts/recurrence/perl-binding.feature',
    'portable_case_id': 'RECUR-MAX-ATTEMPTS-EXCEPTION',
    'public_operation_ids': ['recur.next-occurrence'],
    'evidence_selector': 'range-and-attempt-limits:attempt_next.exception',
    'classification': 'Perl binding compatibility diagnostic; excluded from portable handoff',
}]

assert portability['fixture']['fixture_id'] == 'utc-working-week-2040'
assert portability['fixture']['settings'] == fixture
assert portability['fixture']['defined_in'] == [
    f'spec/drafts/recurrence/{name}' for name in portable_names + ('perl-binding.feature',)
]
attempt = rows['range-and-attempt-limits']
attempt_input = attempt['input']
assert f'Given the maximum recurrence attempts setting is {attempt_input["max_recur_attempts"]}' in grammar_text
assert (
    f'And a recurrence with frequency text "{attempt_input["impossible_frequency"]}" '
    f'is anchored at "{attempt_input["requested_anchor"]}" in "{force_zone}"'
) in grammar_text
assert f'When I request the {attempt_input["operation"]} event' in grammar_text
portable_attempt = portability['impossible_february']['portable']
assert portable_attempt['case_id'] == 'RECUR-MAX-ATTEMPTS-EXCEPTION'
assert portable_attempt['public_operation_id'] == 'recur.next-occurrence'
assert portable_attempt['request'] == {
    'maximum_recurrence_attempts': 1,
    'frequency_text': attempt['input']['impossible_frequency'],
    'requested_anchor': attempt['input']['requested_anchor'] + ' Etc/UTC',
    'direction': attempt['input']['operation'],
}
assert portable_attempt['normalized_outcome'] == {
    'call_completion': 'interrupted before return',
    'event_return': 'no return value',
    'lookup_error_return': 'no return value',
}
assert attempt['attempt_next']['call_completed'] is False
assert 'date' not in attempt['attempt_next']
assert 'lookup_error' not in attempt['attempt_next']
assert diagnostic in attempt['attempt_next']['exception']
assert portable_attempt['evidence'] == {
    'selector': 'range-and-attempt-limits:attempt_next',
    'call_completed': False,
    'return_fields_present': False,
    'exception_present': True,
    'capture_interpretation': (
        'No event or lookup-error return field is emitted when the public call is interrupted. '
        'Historical null fields were unassigned probe placeholders, not returned absent values.'
    ),
}
assert portability['capture_schema_repair'] == {
    'case_id': 'range-and-attempt-limits',
    'field': 'attempt_next',
    'prior_representation': {
        'date': None,
        'lookup_error': None,
        'meaning': 'unassigned capture placeholders after interruption',
    },
    'current_representation': {
        'call_completed': False,
        'date_field': 'omitted',
        'lookup_error_field': 'omitted',
    },
    'fresh_independent_captures': 2,
    'fresh_captures_identical': True,
    'comparison': (
        'All fields in all 36 observations were identical after ignoring the probe hash and '
        'the corrected attempt_next completion/return-presence representation.'
    ),
}
binding_attempt = portability['impossible_february']['perl_binding']
assert binding_attempt['binding_case_id'] == 'RECUR-BIND-MAX-ATTEMPTS-DIAGNOSTIC'
assert binding_attempt['excluded_from_portable_handoff'] is True
assert binding_attempt['public_operation_id'] == 'recur.next-occurrence'
assert binding_attempt['diagnostic_contains'] == diagnostic

typed_rows = {case['case_id']: case for case in portability['modifier_boundary_rows']}
modifier_ids = {
    'PD0': 'RECUR-MOD-PD-ZERO',
    'PD8': 'RECUR-MOD-PD-EIGHT',
    'FD0': 'RECUR-MOD-FD-ZERO',
    'FW0': 'RECUR-MOD-FW-ZERO',
    'IW0': 'RECUR-MOD-IW-ZERO',
    'IW8': 'RECUR-MOD-IW-EIGHT',
}
assert typed_rows.keys() == set(modifier_ids.values())
for modifier, case_id in modifier_ids.items():
    source = boundaries[modifier]
    mapped = typed_rows[case_id]
    assert mapped['public_operation_ids'] == ['recur.set-modifiers', 'recur.occurrence-at-index']
    assert mapped['request'] == {
        'frequency_text': '0:0:0:1:0:0:0',
        'modifier_text': modifier,
        'requested_anchor': '2040-04-13 12:34:56 Etc/UTC',
        'index': 0,
    }
    expected_event = 'absent value'
    if source['nth_zero']['date'] is not None:
        raw = source['nth_zero']['date']
        expected_event = (
            f'civil date-time "{raw[:4]}-{raw[4:6]}-{raw[6:8]} '
            f'{raw[8:10]}:{raw[11:13]}:{raw[14:16]} Etc/UTC"'
        )
    lookup = source['nth_zero']['lookup_error']
    expected_lookup = f'number {lookup}' if isinstance(lookup, int) else f'text "{lookup}"'
    assert mapped['outcome'] == {
        'modifier_status': source['modifier_status'],
        'object_error_literal': ('empty text' if source['state']['error'] == ''
                                 else f'text "{source["state"]["error"]}"'),
        'event_literal': expected_event,
        'lookup_error_literal': expected_lookup,
    }

print(json.dumps({'draft_table_rows_checked': checked, 'repeatable_probe_cases': len(rows),
                  'original_portable_case_ids_checked': len(mapped_cases),
                  'binding_cases_checked': len(feature_map['binding_cases']),
                  'approved_specification_cases': 0}, indent=2))
