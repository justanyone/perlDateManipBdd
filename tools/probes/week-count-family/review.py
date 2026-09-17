#!/usr/bin/env python3
"""Verify week-count domains, frozen rows, native carriers, and independent facts."""
import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/week-count-family'
load = lambda name: json.loads((FAMILY / name).read_text())
manifest, evidence, mapping = load('cases.json'), load('observations.json'), load('feature-map.json')
for path, expected in (evidence['sha256'] | evidence['loaded_sha256']).items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == expected, path
assert evidence['repetitions'] == 2
assert evidence['observation']['version'] == '7.00'
assert evidence['environment']['PATH'] == '/usr/bin:/bin'
years = manifest['years']
assert len(years) == 14
types = {(y % 4 == 0 and (y % 100 != 0 or y % 400 == 0), dt.date(y,1,1).isoweekday()) for y in years}
assert types == {(leap, day) for leap in (False, True) for day in range(1,8)}
expected_settings = {(f,r) for f in range(1,8) for r in [*[f'jan{i}' for i in range(1,8)], *[f'dow{i}' for i in range(1,8)],'firstday']}
assert {(c['first_day'],c['rule']) for c in manifest['cases']} == expected_settings
assert len(manifest['cases']) == 105

def start(year, first, rule):
    date = dt.date(year,1,1)
    if rule.startswith('jan'):
        date = dt.date(year,1,int(rule[3:]))
    else:
        desired = first if rule == 'firstday' else int(rule[3:])
        date += dt.timedelta(days=(desired-date.isoweekday()) % 7)
    return date-dt.timedelta(days=(date.isoweekday()-first) % 7)

def rows(path, header):
    text = path.read_text()
    assert 'ordered input years are '+json.dumps(years,separators=(',',':')) in text
    table = [[c.strip() for c in line.strip().strip('|').split('|')]
             for line in text.splitlines() if line.lstrip().startswith('|')]
    assert table[0] == header and len(table) == 106
    assert all(len(row) == len(header) for row in table)
    result = [dict(zip(header,row)) for row in table[1:]]
    assert len({r['case'] for r in result}) == 105
    return result

portable = rows(ROOT / mapping['portable_feature'], ['case','first weekday','rule','counts'])
native = rows(ROOT / mapping['binding_feature'], ['case','first weekday','rule','counts','lists'])
observations = evidence['observation']['observations']
assert len(observations) == len(portable) == len(native) == 105
assert mapping['case_ids'] == [c['case_id'] for c in manifest['cases']]
for case, observed, p, n in zip(manifest['cases'],observations,portable,native):
    assert observed['request'] == case and observed['warnings'] == []
    assert [r['year'] for r in observed['results']] == years
    counts = []
    for row in observed['results']:
        y = row['year']
        count = (start(y+1,case['first_day'],case['rule'])-start(y,case['first_day'],case['rule'])).days//7
        assert row['first'] == row['repeated'] == count and row['listed'] == [count]
        counts.append(count)
    expected = {'case':case['case_id'],'first weekday':str(case['first_day']),'rule':case['rule'],
                'counts':json.dumps(counts,separators=(',',':'))}
    assert p == expected
    assert n == expected | {'lists':json.dumps([[v] for v in counts],separators=(',',':'))}
canonical = json.loads((ROOT / 'docs/research/api/contract-map.json').read_text())
assert mapping['operation_id'] in {o['id'] for o in canonical['operations']}
assert '@excluded-from-portable-handoff' in (ROOT / mapping['binding_feature']).read_text().splitlines()[0]
print('1470 independent week counts, repeated reads, 105 portable rows and105 native rows verified; invalid domains remain open')
