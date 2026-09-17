#!/usr/bin/env python3
"""Check the configuration draft's table literals against saved research evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
record = json.loads((ROOT / 'docs/research/configuration-family/observations.json').read_text())
for path, digest in record['sha256'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
observations = {row['case_id']: row for row in record['observations']}
assert len(observations) == 40
for row in observations.values():
    assert row['repeatable'] and row['returncode'] == 0 and row['stderr'] == ''
    assert row['observation']['exception'] is None

header = None
checked = 0
feature = ROOT / 'spec/drafts/configuration/configuration.feature'
for line in feature.read_text().splitlines():
    if not line.strip().startswith('|'):
        header = None
        continue
    cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
    if header is None:
        header = cells
        continue
    assert len(cells) == len(header)
    case = dict(zip(header, cells))
    observation = observations[case['case_id']]['observation']
    result = observation['raw_return']
    if 'stored' in case:
        queried = result['queried']
        expected = case['stored'].split(' then ') if len(queried) > 1 else [case['stored']]
        assert [str(v) for _, v in queried] == expected, case['case_id']
        if 'read_name' in case:
            assert queried[0][0] == case['read_name']
    else:
        assert observation['profile'] == 'dm5' and result['initializer_return'] is None
    if 'diagnostic' in case:
        assert case['diagnostic'] in ''.join(observation['warnings']), case['case_id']
    checked += 1
derived = observations['CFG-CONTEXT-DERIVE']['observation']['raw_return']
assert derived['source'] == 'US' and derived['derived'] == 'non-US'
reset = observations['CFG-DM6-DEFAULTS']['observation']
assert reset['request']['settings'] == [['DateFormat', 'non-US'], ['Defaults', 'x']]
assert reset['raw_return']['queried'] == [['dateformat', 'US']]
print(json.dumps({'table_cases_checked': checked, 'repeatable_cases': 40,
                  'corrected_derivation_and_reset_checked': True,
                  'approved_specification_cases': 0}, indent=2))
