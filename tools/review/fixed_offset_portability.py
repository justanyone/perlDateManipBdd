#!/usr/bin/env python3
"""Check portable names and exact requests without changing capture provenance."""
import json
from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parents[2]
runpy.run_path(str(ROOT / 'tools/probes/fixed-offset-family/review.py'), run_name='__main__')
family = ROOT / 'docs/research/fixed-offset-family'
mapping = json.loads((family / 'feature-map.json').read_text())
selected = json.loads((family / 'selected-observations.json').read_text())
feature = (ROOT / mapping['feature']).read_text()
assert 'scalar' not in feature and '<utc_text>' in feature
assert 'Then the parsed-zone text is "2040022912:34:56"' in feature
assert 'And the UTC text is "<utc_text>"' in feature
assert 'When I parse the civil time "2040-02-29 12:34:56 <offset>"' in feature
assert mapping['portable_observers']['parsed-zone text']['evidence'] == 'public_result.parsed_scalar'
assert mapping['portable_observers']['UTC text']['evidence'] == 'public_result.gmt_scalar'
by_id = {row['example_id']: row for row in selected['observations']}
for item in mapping['examples']:
    row = by_id[item['example_id']]
    assert row['input_text'] == '2040-02-29 12:34:56 ' + item['input_offset']
    if item['outcome'] != 'success':
        assert 'When I parse the civil time "' + row['input_text'] + '"' in feature
        assert 'Then the parse error is "[parse] Unable to determine timezone"' in feature
print('7 portable requests and named text observers verified')
