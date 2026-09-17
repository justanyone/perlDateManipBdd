#!/usr/bin/env python3
"""Review leap-year literals against evidence and independent Gregorian facts."""
import calendar
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/leap-year-family'
FEATURES = ROOT / 'spec/drafts/leap-years'
manifest_record = json.loads((FAMILY / 'cases.json').read_text())
evidence = json.loads((FAMILY / 'observations.json').read_text())
feature_map = json.loads((FAMILY / 'feature-map.json').read_text())
profiles = json.loads((ROOT / 'docs/automation/reference-profiles.json').read_text())
manifest = {row['case_id']: row for row in manifest_record['cases']}
observed = {row['case_id']: row for row in evidence['observations']}

assert evidence['operation_id'] == manifest_record['operation_id'] == 'calendar.is-leap-year'
assert len(manifest) == len(observed) == 84
assert list(manifest) == list(observed)
assert evidence['execution'] == {
    'command': 'python3 tools/probes/leap-year-family/run.py',
    'perl': '/usr/bin/perl',
    'environment': {
        'PATH': '/usr/bin:/bin',
        'PERL5LIB': str(ROOT / 'local/date-manip-7.00/lib/perl5'),
        'TZ': 'Etc/UTC', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8',
    },
    'repetitions_per_case': 2,
    'fresh_temporary_directory_per_repetition': True,
    'timeout_seconds': 15,
    'parallel_workers': 4,
}
for relative, digest in evidence['sha256'].items():
    assert hashlib.sha256((ROOT / relative).read_bytes()).hexdigest() == digest, relative


def tables(path):
    blocks = []
    current = []
    for line in path.read_text().splitlines() + ['']:
        if line.strip().startswith('|'):
            current.append([cell.strip() for cell in line.strip().strip('|').split('|')])
        elif current:
            header, *rows = current
            assert len(header) == len(set(header)), (path, header)
            assert all(len(row) == len(header) for row in rows), (path, header)
            if 'case' in header:
                indices = [header.index(key) for key in ('case', 'context') if key in header]
                assert len({tuple(row[i] for i in indices) for row in rows}) == len(rows), path
            blocks.append((header, [dict(zip(header, row)) for row in rows]))
            current = []
    return blocks


def table(path, required):
    matches = [(head, rows) for head, rows in tables(path) if set(required) <= set(head)]
    assert len(matches) == 1, (path, required, len(matches))
    return matches[0][1]


def exact_table(path, header):
    matches = [rows for head, rows in tables(path) if head == list(header)]
    assert len(matches) == 1, (path, header, len(matches))
    return matches[0]


profile_by_name = {row['name']: row for row in profiles['profiles']}
oo_config = dict(item.split('=', 1) for item in profile_by_name['oo']['configuration'])
dm5_config = dict(item.split('=', 1) for item in profile_by_name['dm5']['configuration'])
assert oo_config['ForceDate'] == '2040-02-28-10:20:30,Etc/UTC'
assert dm5_config['ForceDate'] == '2040-02-28-10:20:30' and dm5_config['TZ'] == 'Etc/UTC'
assert oo_config['Language'] == dm5_config['Language'] == 'English'
dm5_source = (ROOT / 'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm').read_text()
misc_pod = (ROOT / 'local/date-manip-7.00/lib/perl5/Date/Manip/Misc.pod').read_text()
assert '$Cnf{"YYtoYYYY"}=89;' in dm5_source
assert re.search(r'back to the year 0001\s+AD and forward to the year 9999 AD', misc_pod)
expected_fixture = {
    'calendar': 'proleptic Gregorian',
    'supported year interval': '0001 through 9999',
    'fixed reference clock': '2040-02-28 10:20:30 in Etc/UTC',
    'input language': 'English',
    'default short-year window': 'reference year minus 89 through plus 10',
}
for path in sorted(FEATURES.glob('*.feature')):
    fixture_rows = table(path, {'setting', 'value'})
    assert {row['setting']: row['value'] for row in fixture_rows} == expected_fixture, path

portable_names = ('gregorian-cycle.feature', 'short-year-compatibility.feature', 'invalid-and-outside.feature')
portable_text = '\n'.join((FEATURES / name).read_text() for name in portable_names)
binding_text = (FEATURES / 'perl-binding.feature').read_text()
assert ' at /home/' not in portable_text
assert 'Invalid year (' not in portable_text
assert binding_text.startswith(
    '@draft @leap-year @source-binding @perl-binding @reference-observed '
    '@excluded-from-portable-handoff\n'
)


def assert_completed(call, expected):
    assert call['call_completed'] is True
    assert call['exception'] is None and call['stdout'] == ''
    assert call['return'] == expected


cycle_expected = [year for year in range(2000, 2400) if calendar.isleap(year)]
assert len(cycle_expected) == 97
cycle_feature = FEATURES / 'gregorian-cycle.feature'
cycle_year_rows = exact_table(cycle_feature, ['year'])
assert [int(row['year']) for row in cycle_year_rows] == cycle_expected
cycle_case_rows = exact_table(cycle_feature, ['case', 'profile'])
cycle_case_rows = {row['case']: row for row in cycle_case_rows}
assert set(cycle_case_rows) == {cid for cid, row in manifest.items() if row['group'] == 'complete-cycle'}
for case_id in cycle_case_rows:
    row = observed[case_id]
    assert len(row['years']) == 400
    assert cycle_case_rows[case_id]['profile'] == row['profile']
    got_leaps = []
    for item in row['years']:
        expected = int(calendar.isleap(item['year']))
        assert_completed(item['scalar'], expected)
        assert_completed(item['list'], [expected])
        assert item['list']['return_count'] == 1
        assert not item['scalar']['warnings'] and not item['list']['warnings']
        if expected:
            got_leaps.append(item['year'])
    assert got_leaps == cycle_expected

boundary_rows = exact_table(cycle_feature, ['case', 'profile', 'year', 'classification'])
boundary_rows = {row['case']: row for row in boundary_rows}
assert set(boundary_rows) == {cid for cid, row in manifest.items() if row['group'] == 'valid-boundary'}
for case_id, feature in boundary_rows.items():
    request = manifest[case_id]
    year = int(request['input']['value'])
    expected = int(calendar.isleap(year))
    assert feature == {
        'case': case_id,
        'profile': request['profile'],
        'year': request['input']['value'],
        'classification': 'leap' if expected else 'common',
    }
    row = observed[case_id]
    assert_completed(row['scalar'], expected)
    assert_completed(row['list'], [expected])

short_feature = FEATURES / 'short-year-compatibility.feature'
default_rows = {row['case']: row for row in table(short_feature, {'case', 'profile', 'year', 'flag'})}
configured_rows = {row['case']: row for row in table(short_feature, {'case', 'profile', 'setting', 'flag'})}
assert set(default_rows) == {cid for cid, row in manifest.items() if row['group'] == 'short-year-default'}
assert set(configured_rows) == {cid for cid, row in manifest.items() if row['group'] == 'short-year-configuration'}
for case_id, feature in default_rows.items():
    request, row = manifest[case_id], observed[case_id]
    assert feature == {'case': case_id, 'profile': request['profile'],
                       'year': request['input']['value'], 'flag': str(row['scalar']['return'])}
for case_id, feature in configured_rows.items():
    request, row = manifest[case_id], observed[case_id]
    assert feature == {'case': case_id, 'profile': request['profile'],
                       'setting': request['yy_to_yyyy'], 'flag': str(row['scalar']['return'])}

# Independently resolve the documented fixed-2040 short-year windows. Base and
# DM6 observations use the supplied numeric value directly; DM5 applies these
# configured four-digit interpretations before classification.
dm5_short_year = {
    None: {'00': 2000, '40': 2040},
    'C': {'00': 2000},
    'C19': {'00': 1900},
    'C20': {'00': 2000},
    'C2000': {'00': 2000},
    '0': {'00': 2100},
    '99': {'00': 2000},
}
for case_id in set(default_rows) | set(configured_rows):
    request, row = manifest[case_id], observed[case_id]
    text_year = request['input']['value']
    if request['profile'] == 'dm5':
        interpreted = dm5_short_year[request.get('yy_to_yyyy')][text_year]
    else:
        interpreted = int(text_year)
    expected = int(interpreted % 4 == 0 and (interpreted % 100 != 0 or interpreted % 400 == 0))
    assert_completed(row['scalar'], expected)
    assert_completed(row['list'], [expected])

input_phrases = {
    'LY-EDGE-OMITTED': 'omitted argument',
    'LY-EDGE-UNDEFINED': 'explicit absent value',
    'LY-EDGE-EMPTY': 'empty text',
    'LY-EDGE-SPACE': 'text containing one space',
    'LY-EDGE-NONNUMERIC4': 'text "abcd"',
    'LY-EDGE-NONNUMERIC3': 'text "abc"',
    'LY-EDGE-FRACTION': 'number 2000.5',
    'LY-EDGE-ZERO': 'number 0',
    'LY-EDGE-NEGATIVE4': 'number -4',
    'LY-EDGE-NEGATIVE400': 'number -400',
    'LY-EDGE-NEGATIVE100': 'number -100',
    'LY-EDGE-OUTSIDE10000': 'number 10000',
}
invalid_feature = FEATURES / 'invalid-and-outside.feature'
invalid_rows = {row['case']: row for row in table(invalid_feature, {'case', 'profile', 'request', 'outcome'})}
assert set(invalid_rows) == {cid for cid, row in manifest.items() if row['group'] == 'invalid-or-outside'}
for case_id, feature in invalid_rows.items():
    request, row = manifest[case_id], observed[case_id]
    prefix = case_id.rsplit('-', 1)[0]
    call = row['scalar']
    outcome = ('call interrupted with no return' if not call['call_completed']
               else f'numeric flag {call["return"]}')
    assert feature == {'case': case_id, 'profile': request['profile'],
                       'request': input_phrases[prefix], 'outcome': outcome}


def binding_request(case):
    input_value = case['input']
    if input_value['shape'] == 'omitted':
        text = 'omitted argument'
    elif input_value['shape'] == 'undefined':
        text = 'explicit undefined scalar'
    elif input_value['shape'] == 'text':
        text = 'text ' + json.dumps(input_value['value'])
    else:
        text = 'number ' + str(input_value['value'])
    if 'yy_to_yyyy' in case:
        text += ' with YYtoYYYY ' + case['yy_to_yyyy']
    return text


carrier_rows = {row['case']: row for row in table(
    FEATURES / 'perl-binding.feature',
    {'case', 'profile', 'request', 'scalar completion', 'scalar return', 'list completion', 'list return'},
)}
assert set(carrier_rows) == set(manifest) - set(cycle_case_rows)
for case_id, feature in carrier_rows.items():
    request, row = manifest[case_id], observed[case_id]
    scalar, listed = row['scalar'], row['list']
    if scalar['call_completed']:
        scalar_completion, scalar_return = 'completed', f'number {scalar["return"]}'
        list_completion, list_return = 'completed', f'one-element list [{listed["return"][0]}]'
        assert listed['return_count'] == 1 and listed['return'][0] == scalar['return']
    else:
        scalar_completion = list_completion = 'interrupted'
        scalar_return = list_return = 'no return'
        assert 'return' not in scalar and 'return' not in listed
    assert feature == {
        'case': case_id, 'profile': request['profile'], 'request': binding_request(request),
        'scalar completion': scalar_completion, 'scalar return': scalar_return,
        'list completion': list_completion, 'list return': list_return,
    }

exception_rows = table(FEATURES / 'perl-binding.feature', {'case', 'request', 'context', 'diagnostic'})
expected_exceptions = []
for case_id, row in observed.items():
    for context in ('scalar', 'list'):
        call = row.get(context)
        if call and not call['call_completed']:
            expected_exceptions.append({
                'case': case_id, 'request': binding_request(manifest[case_id]),
                'context': context, 'diagnostic': call['exception'].splitlines()[0],
            })
assert exception_rows == expected_exceptions

warning_rows = table(FEATURES / 'perl-binding.feature',
                     {'case', 'profile', 'request', 'context', 'count', 'warning'})
expected_warnings = []
for case_id, row in observed.items():
    for context in ('scalar', 'list'):
        call = row.get(context)
        if not call or not call['warnings']:
            continue
        assert len(set(call['warnings'])) == 1
        expected_warnings.append({
            'case': case_id, 'profile': row['profile'],
            'request': binding_request(manifest[case_id]), 'context': context,
            'count': str(len(call['warnings'])),
            'warning': call['warnings'][0].split(' at /home/')[0],
        })
assert warning_rows == expected_warnings

dm5_deprecation = ('Date::Manip::DM5 is deprecated and will be removed from the Date::Manip '
                   'package starting in version 7.00 at (eval 42) line 1.\n')
assert dm5_deprecation.rstrip() in binding_text
for row in observed.values():
    expected = [dm5_deprecation] if row['profile'] == 'dm5' else []
    assert row['module_load']['warnings'] == expected
    assert row['configuration']['call_completed'] is True
    assert row['configuration']['exception'] is None
    assert row['configuration']['warnings'] == []
    assert row['configuration']['stdout'] == ''
    assert row['loaded_module_path'] == str(ROOT / f'local/date-manip-7.00/lib/perl5/{row["module"].replace("::", "/")}.pm')

mapped = {row['case_id']: row for row in feature_map['cases']}
assert set(mapped) == set(manifest)
binding_names = {
    'base': 'Date::Manip::Base.leapyear',
    'dm6': 'Date::Manip::DM6.Date_LeapYear',
    'dm5': 'Date::Manip::DM5.Date_LeapYear',
}
for case_id, case in manifest.items():
    row = mapped[case_id]
    assert row['operation_id'] == 'calendar.is-leap-year'
    assert row['public_binding'] == binding_names[case['profile']]
    assert row['request'] == case['input'] and row['evidence_selector'] == case_id
    assert case_id in (ROOT / row['portable_feature']).read_text()
    assert case_id in (ROOT / row['binding_feature']).read_text()

print(json.dumps({
    'operation_id': 'calendar.is-leap-year',
    'manifest_cases_checked': len(manifest),
    'cycle_year_calls_checked': 3 * 400,
    'native_context_calls_checked': 2 * (3 * 400 + len(manifest) - 3),
    'independent_valid_year_facts_checked': 400 + 7,
    'independent_short_year_interpretations_checked': len(default_rows) + len(configured_rows),
    'portable_approved_cases': 0,
}, indent=2))
