#!/usr/bin/env python3
"""Review native table literals and evidence provenance without reference calls."""
import datetime
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/rendering-family/observations.json').read_text())
cases = json.loads((ROOT / 'docs/research/rendering-family/cases.json').read_text())['cases']
mapping = json.loads((ROOT / 'docs/research/rendering-family/feature-map.json').read_text())
for path, digest in record['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
observed = {r['case_id']: r['observation'] for r in record['observations']}
inputs = {c['case_id']: c for c in cases}
assert len(observed) == len(inputs) == 24
for case_id, row in observed.items():
    assert row['exception'] is None and row['call_stdout'] == '', case_id
    expected_configuration = '' if row['profile'] == 'dm6' else None
    assert row['raw_return']['configuration_diagnostic'] == expected_configuration, case_id
    assert row['request']['patterns'] == inputs[case_id]['patterns']
    if row['profile'].startswith('oo'):
        assert row['raw_return']['parse_status'] == 0
        assert row['raw_return']['error_state'] == ''

def decode_cell(text):
    prefix = 'one leading ASCII space followed by '
    return ' ' + text[len(prefix):] if text.startswith(prefix) else text

table_checks = [
    ('native-rendering.feature', ['RENDER-NATIVE-BASICS', 'RENDER-NATIVE-COMPOSITES']),
    ('compatibility-rendering.feature', ['RENDER-DM5-NATIVE-BASICS', 'RENDER-DM5-NATIVE-COMPOSITES']),
]
checked_fields = 0
for filename, evidence_ids in table_checks:
    text = (ROOT / 'spec/drafts/rendering' / filename).read_text()
    rows = [[decode_cell(c.strip()) for c in line.strip().strip('|').split('|')]
            for line in text.splitlines() if line.strip().startswith('|')]
    assert len(rows) == len(evidence_ids) * 2
    for i, case_id in enumerate(evidence_ids):
        assert rows[2*i] == inputs[case_id]['patterns'], case_id
        assert rows[2*i+1] == observed[case_id]['raw_return']['list_texts'], case_id
        checked_fields += len(rows[2*i+1])
tags = []
for feature in (ROOT / 'spec/drafts/rendering').glob('*.feature'):
    text = feature.read_text()
    assert 'evidence row' not in text and 'catalogue order' not in text
    tags.extend(re.findall(r'@(RENDER-[A-Z0-9-]+)', text))
assert len(tags) == len(set(tags)) == len(inputs)
assert set(tags) == {tag for row in mapping['feature_cases'] for tag in row['tags']}
for row in mapping['feature_cases']:
    for evidence in row['evidence']:
        count = len(inputs[evidence['case_id']]['patterns'])
        assert evidence['pattern_indexes'] == list(range(1, count+1))
# Independent UTC epoch and ISO-week facts for the baseline.
utc = datetime.timezone.utc
assert int(datetime.datetime(2040, 2, 29, 16, 5, 9, tzinfo=utc).timestamp()) == 2214144309
assert datetime.date(2040, 2, 29).isocalendar() == (2040, 9, 3)
assert datetime.date(2040, 1, 1).isocalendar() == (2039, 52, 7)
print(json.dumps({'native_table_literals_checked': checked_fields,
                  'evidence_cases_and_tags_checked': len(tags),
                  'approved_specification_cases': 0}, indent=2))
