#!/usr/bin/env python3
"""Verify additional authored calendar literals and independent epoch/week facts."""
import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
evidence = json.loads((ROOT / 'docs/research/observations/calendar.json').read_text())
mapping = json.loads((ROOT / 'docs/research/calendar-additional-feature-map.json').read_text())
for path, digest in evidence['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
rows = {r['case_id']: r['observation'] for r in evidence['observations']}
features = '\n'.join((ROOT / 'spec/drafts' / name).read_text()
                     for name in ('epoch.feature', 'calendar-positions.feature'))
for case in mapping['cases']:
    assert features.count(case['case_id']) == 1, case['case_id']
    observed = rows[case['reference_case']]
    expected = case['expected']
    kind = case['assertion_kind']
    if kind == 'stored-instant':
        assert observed['raw_return'] == {'scalar': expected['status']}
        assert observed['object_error'] == expected['error']
        assert observed['date_after'] == '%04d%02d%02d%02d:%02d:%02d' % tuple(expected['date_time'])
    else:
        assert observed['raw_return'] == {kind: expected}
    request = case['request']
    operation = case['operation_id']
    if operation.startswith('epoch.'):
        if 'date_time' in request:
            assert int(dt.datetime(*request['date_time'], tzinfo=dt.timezone.utc).timestamp()) == expected
        else:
            fields = expected['date_time'] if kind == 'stored-instant' else expected
            assert int(dt.datetime(*fields, tzinfo=dt.timezone.utc).timestamp()) == request['seconds']
    elif operation == 'calendar.week-year-start':
        assert list(dt.date.fromisocalendar(request['year'], 1, 1).timetuple()[:3]) == expected
    elif operation == 'calendar.weeks-in-year':
        assert dt.date(request['year'], 12, 28).isocalendar().week == expected
    elif operation == 'calendar.nth-weekday' and expected is not None:
        assert dt.date(*expected).isoweekday() == request['weekday']
print(json.dumps({'candidate_cases_checked': len(mapping['cases']),
                  'independent_epoch_and_week_facts_checked': True,
                  'approved_specification_cases': 0}, indent=2))
