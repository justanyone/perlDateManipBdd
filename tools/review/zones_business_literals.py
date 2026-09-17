#!/usr/bin/env python3
"""Check selected literal zone/business assertions against unchanged saved evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
evidence = json.loads((ROOT / 'docs/research/zones-business-family/observations.json').read_text())
for path, digest in evidence['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
rows = {r['case_id']: r for r in evidence['observations']}
assert len(rows) == 33
for row in rows.values():
    assert row['exception'] == row['process_stderr'] == ''
    assert row['research_status'] == 'repeatable'

all_day = 'All-Day Office Event'
briefing = 'One-Hour Briefing'
review = 'Two-Hour Review'
expected_changes = [
    ['2040030100:00:00', all_day],
    ['2040030110:00:00', all_day, briefing],
    ['2040030111:00:00', all_day],
    ['2040030113:00:00', all_day, review],
    ['2040030115:00:00', all_day],
]
assert rows['ZB-EVENTS-OO-DAY']['result']['events'] == expected_changes
assert rows['ZB-EVENTS-OO-RANGE']['result']['events'] == expected_changes[1:4]
expected_functional = []
for timestamp, *names in expected_changes:
    expected_functional.extend([timestamp, names])
assert rows['ZB-EVENTS-DM6-DATES']['result']['events'] == expected_functional
assert rows['ZB-EVENTS-OO-INSTANT']['result']['events'] == [
    ['2040030100:00:00', '2040030123:59:59', all_day],
    ['2040030110:00:00', '2040030110:59:59', briefing],
]
assert rows['ZB-BUSINESS-HOLIDAYS-DM6']['result']['business_day'] == 0
erased = rows['ZB-LEGACY-ERASE-HOLIDAYS']['result']
assert erased['before'] == 'Audit Day' and erased['after'] is None
assert erased['business_day_after'] == 1
text = (ROOT / 'spec/drafts/zones-business/zones-business.feature').read_text()
assert 'five timestamped active-name sets' not in text
assert 'three timestamped active-name sets' not in text
assert 'holiday label at "2040-03-01 10:00:00" is absent' in text
print(json.dumps({'repeatable_cases': len(rows), 'event_assertions_checked': 4,
                  'missing_call_and_absent_label_checked': True,
                  'approved_specification_cases': 0}, indent=2))
