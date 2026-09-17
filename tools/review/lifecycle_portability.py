#!/usr/bin/env python3
"""Check typed lifecycle tables against the unchanged native evidence."""
import json
from pathlib import Path
import re
import runpy

ROOT = Path(__file__).resolve().parents[2]
runpy.run_path(str(ROOT / 'tools/probes/object-lifecycle-family/review.py'))
evidence = json.loads((ROOT / 'docs/research/object-lifecycle-family/observations.json').read_text())
raw = {row['case_id']: row['observation']['raw_return'] for row in evidence['observations']}
text = (ROOT / 'spec/drafts/object-lifecycle/value-state-and-errors.feature').read_text()
assert not re.search(r'\bscalar\b|\blist context\b|\bundefined\b', text, re.I)
tables = []
current = []
for line in text.splitlines() + ['']:
    if line.lstrip().startswith('|'):
        cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
        assert all(cells), line
        current.append(cells)
    elif current:
        tables.append(current)
        current = []
assert len(tables) == 3
selectors = {'omitted': 'omitted', 'empty text': 'empty',
             'unrecognized text OTHER': 'other', 'local': 'local', 'gmt': 'gmt'}
count = 0
for table, case_id, first_column in (
    (tables[1], 'OBJ-009-DATE-VALUE-CONTEXTS', 'selector'),
    (tables[2], 'OBJ-011-DELTA-VALUE-CONTEXTS', 'state'),
):
    header, *rows = table
    seen = set()
    for cells in rows:
        assert len(cells) == len(header)
        row = dict(zip(header, cells))
        key = selectors[row[first_column]] if first_column == 'selector' else row[first_column]
        assert key not in seen
        seen.add(key)
        observed = raw[case_id][key]
        expected_text = observed['scalar']['value']
        if first_column == 'selector':
            expected_text = expected_text[:4]+'-'+expected_text[4:6]+'-'+expected_text[6:8]+' '+expected_text[8:]
        assert row.get('normalized civil date-time', row.get('serialized text')) == expected_text
        assert row['ordered fields'] == ', '.join(map(str, observed['list']['value']))
        assert int(row['field count']) == observed['list']['count']
        assert row['error'] == 'empty text'
        for context in ('scalar', 'list'):
            assert observed[context]['error_before'] == observed[context]['error_after'] == ''
            assert observed[context]['exception'] is None
        count += 1
    assert seen == set(raw[case_id]) - {'dependent_calls_executed'}
print(f'{count} typed lifecycle rows verified against frozen text, fields, counts, and errors')
