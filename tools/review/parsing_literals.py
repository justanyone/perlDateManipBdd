#!/usr/bin/env python3
"""Check authored literals against saved evidence, without calling Date::Manip.

This verifies evidence correspondence and civil-date validity, not complete
grammar semantics. It cannot promote drafts to approved specification.
"""
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/parsing-family/observations.json').read_text())
mapping = json.loads((ROOT / 'docs/research/parsing-family/feature-map.json').read_text())
for path, digest in record['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
observations = {row['case_id']: row for row in record['observations']}
assert len(observations) == len(record['observations'])
seen = set()
successes = 0
for case in mapping['cases']:
    case_id = case['case_id']
    assert case_id not in seen
    seen.add(case_id)
    row = observations[case['reference_case']]
    assert row['research_status'] == 'repeatable'
    assert row['process_stderr'] == ''
    observed = row['observation']
    assert observed['exception'] is None
    assert observed['call_stdout'] == ''
    assert observed['request']['text'] == case['text']
    raw = observed.get('value')
    normalized = raw[:4] + '-' + raw[4:6] + '-' + raw[6:8] + ' ' + raw[8:] if raw else None
    assert normalized == case['expected'], (case_id, normalized, case['expected'])
    if observed['profile'] == 'oo':
        assert observed['error_after_configuration'] == ''
        assert (observed['status'] == 0) == (case['expected'] is not None)
        if case['expected'] is not None:
            assert observed['error_after_parse'] == observed['error_after_value_read'] == ''
    if case['expected'] is not None:
        datetime.datetime.strptime(case['expected'], '%Y-%m-%d %H:%M:%S')
        successes += 1
for case_id in mapping['configuration_exceptions']:
    row = observations[case_id]['observation']
    assert row['exception_stage'] == 'configuration'
    assert 'Unknown configuration variable Format_MMMYYYY' in row['exception']
    assert 'value' not in row and 'status' not in row
assert seen | set(mapping['configuration_exceptions']) == set(observations)
# Bind all authored table rows to their own request/profile and expected result.
by_id = {case['case_id']: case for case in mapping['cases']}
feature = '\n'.join(path.read_text() for path in sorted((ROOT / 'spec/drafts/parsing').glob('*.feature')))
assert 'When I interpret empty text as a date' in feature
feature_ids = set()
header = None
empty_rows = 0
for line in feature.splitlines():
    if not line.lstrip().startswith('|'):
        header = None
        continue
    cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
    if header is None:
        header = cells
        continue
    assert len(cells) == len(header) and all(cells)
    if 'case' not in header:
        continue
    row = dict(zip(header, cells))
    case_id = row['case']
    assert case_id not in feature_ids
    feature_ids.add(case_id)
    case = by_id[case_id]
    assert row['profile'] == case['profile']
    assert row['month-year mode'] == case['month_year_mode']
    if 'text' in row:
        assert row['text'] == case['text']
    else:
        assert case_id.startswith('PARSE-INVALID-EMPTY-') and case['text'] == ''
        empty_rows += 1
    if case['expected'] is not None:
        assert row['expected date-time'] == case['expected']
    else:
        assert 'expected date-time' not in row
assert empty_rows == 3 and feature_ids == set(by_id)
# Independent calendar facts behind the original ordinal and week-date examples.
assert datetime.date(2040, 1, 1) + datetime.timedelta(days=59) == datetime.date(2040, 2, 29)
assert datetime.date.fromisocalendar(2040, 9, 3) == datetime.date(2040, 2, 29)
assert datetime.date.fromisocalendar(2040, 9, 1) == datetime.date(2040, 2, 27)
print(json.dumps({'candidate_literals_checked': len(seen), 'valid_civil_results': successes,
                  'feature_request_rows_checked': len(feature_ids), 'explicit_empty_inputs': empty_rows,
                  'configuration_exceptions': len(mapping['configuration_exceptions']),
                  'approved_specification_cases': 0}, indent=2))
