#!/usr/bin/env python3
"""Check explicit-pattern draft literals against saved research, without SUT calls."""
import datetime
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / 'docs/research/pattern-parsing-family'
document = json.loads((FAMILY / 'observations.json').read_text())
inputs = json.loads((FAMILY / 'cases.json').read_text())['cases']
mapping = json.loads((FAMILY / 'feature-map.json').read_text())
feature = (ROOT / mapping['feature']).read_text()
observations = {row['case_id']: row for row in document['observations']}
requests = {row['case_id']: row for row in inputs}
assert len(observations) == len(requests) == len(inputs) == 65
mapped = [case for group in mapping['groups'] for case in group['case_ids']]
assert len(mapped) == len(set(mapped)) == 65 and set(mapped) == set(requests)
for name, digest in document['provenance']['tool_sha256'].items():
    path = FAMILY / name if name == 'cases.json' else ROOT / 'tools/probes/pattern-parsing-family' / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, path
for name, digest in document['provenance']['installed_module_sha256'].items():
    path = ROOT / 'local/date-manip-7.00/lib/perl5/Date/Manip' / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, path
    assert document['provenance']['review_source_sha256'][name] == digest

def raw(case, interface):
    return observations[case]['routes'][interface]['observation']['raw_return']

for case, row in observations.items():
    assert row['repeatable'], case
    for interface, route in row['routes'].items():
        assert route['repeatable'] and route['process_stderr'] == '', (case, interface)
        record = route['observation']
        assert record['distribution_version'] == '7.00'
        assert record['timezone_data'] == {'tzdata': 'tzdata2026c', 'tzcode': 'tzcode2026c'}
        for key in ('pattern', 'text', 'kind'):
            assert record[key] == requests[case][key], (case, key)
    result = raw(case, 'oo')
    if 'scalar' in result:
        assert result['scalar']['status'] == result['list']['status'], case
        assert result['scalar']['value'] == result['list']['value'], case
        for carrier in ('scalar', 'list'):
            assert result[carrier]['call_stdout'] == '' and result[carrier]['warnings'] == [], case

def civil(text):
    """Presentation-only conversion; no date arithmetic or reference evaluation."""
    match = re.fullmatch(r'(\d{4})(\d{2})(\d{2})(\d{2}:\d{2}:\d{2})', text)
    assert match, text
    year, month, day, clock = match.groups()
    return f'{year}-{month}-{day} {clock} UTC'

checked = 0
for line in feature.splitlines():
    if not line.strip().startswith('|'):
        continue
    cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
    if len(cells) != 5 or cells[0] not in requests:
        continue
    case, directive, pattern, text, expected = cells
    request = requests[case]
    assert directive == request['directive'] and pattern == request['pattern'], case
    assert text.replace('{TAB}', '\t').replace('{LF}', '\n') == request['text'], case
    for carrier in ('scalar', 'list'):
        result = raw(case, 'oo')[carrier]
        assert result['status'] == 0 and result['exception'] is None, case
        assert civil(result['value']) == expected, case
    result = raw(case, 'dm6')
    assert result['exception'] is None and civil(result['value']) == expected, case
    checked += 1
assert checked == 50

# Literal statuses are distinct from the error getter and from the facade's text.
failures = {
    'PTN-30': (1, '[parse_format] Day of week invalid'),
    'PTN-31': (1, '[parse_format] Day of week invalid'),
    'PTN-55': ('Time not fully specified', ''),
    'PTN-56': (1, ''),
    'PTN-57': ('Year specified multiple times', ''),
    'PTN-58': ('Date not fully specified', ''),
    'PTN-60': (1, ''),
    'PTN-63': (1, ''),
}
for case, (status, error) in failures.items():
    for carrier in ('scalar', 'list'):
        result = raw(case, 'oo')[carrier]
        assert result['status'] == status and result['parse_error'] == error, case
        assert result['value'] is None and result['exception'] is None, case
    assert raw(case, 'dm6')['value'] == '', case
    assert raw(case, 'dm6')['exception'] is None, case

for line in feature.splitlines():
    if not line.strip().startswith('|'):
        continue
    cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
    if cells[0] in {'PTN-55', 'PTN-56', 'PTN-57', 'PTN-58', 'PTN-60', 'PTN-63'}:
        case, pattern, text, outcome = cells
        assert pattern == requests[case]['pattern'], case
        assert text.replace('{LF}', '\n') == requests[case]['text'], case
        status = failures[case][0]
        assert outcome == (f'pattern error "{status}"' if isinstance(status, str)
                           else 'valid pattern with no match, status 1'), case
    elif cells[0] in {'PTN-53', 'PTN-54'}:
        case, pattern, captures = cells
        assert pattern == requests[case]['pattern'], case
        # The feature uses record notation with identifier keys, not Perl syntax.
        quoted = re.sub(r'([A-Za-z][A-Za-z0-9_]*):', r'"\1":', captures)
        assert json.loads(quoted) == raw(case, 'oo')['list']['named_captures'], case

for case, expected in {
    'PTN-53': {'Label': 'id=', 'd': '29', 'm': '02', 'y': '2040'},
    'PTN-54': {'d': '29', 'm': '02', 'y': '2040'},
}.items():
    assert raw(case, 'oo')['list']['named_captures'] == expected, case
for interface in ('oo', 'dm6'):
    result = raw('PTN-59', interface)
    results = [result['scalar'], result['list']] if interface == 'oo' else [result]
    for result in results:
        assert result['value'] is None and 'Unmatched (' in result['exception']

for case in ('PTN-64', 'PTN-65'):
    assert raw(case, 'oo')['scalar']['value'] == '1970010100:03:41'
    assert raw(case, 'dm6')['value'] == '1970010100:03:41'
assert raw('PTN-61', 'dm6')['sequence']['steps'][-1]['value'] == ''
assert raw('PTN-61', 'oo')['sequence']['steps'][-1]['status'] == 1
for interface in ('oo', 'dm6'):
    assert raw('PTN-62', interface)['sequence']['steps'][-1]['value'] == '2040022900:00:00'

# These independent calendar facts support the literal values, not parser grammar.
utc = datetime.timezone.utc
assert int(datetime.datetime(2040, 2, 29, 16, 5, 9, tzinfo=utc).timestamp()) == 2214144309
assert datetime.date(2040, 2, 29).isocalendar() == (2040, 9, 3)
assert datetime.datetime.fromtimestamp(221, utc).isoformat() == '1970-01-01T00:03:41+00:00'
print(json.dumps({'mapped_requests': len(mapped), 'successful_table_literals_checked': checked,
                  'approved_specification_cases': 0}, indent=2))
