#!/usr/bin/env python3
"""Independently verify all valid week-rule matrix literals and provenance."""
from __future__ import annotations
import calendar
import datetime as dt
import hashlib, json, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/week-rules-family'
MANIFEST=json.loads((FAMILY/'matrix-manifest.json').read_text())
FEATURE=ROOT/'spec/drafts/week-rules/week-rules.feature'
COVERAGE=json.loads((FAMILY/'coverage-map.json').read_text())

def digest(path:Path)->str:return hashlib.sha256(path.read_bytes()).hexdigest()
def week_start(year:int,first_day:int,rule:str)->dt.date:
    jan1=dt.date(year,1,1); first0=first_day-1
    if rule.startswith('jan'): target=dt.date(year,1,int(rule[3:]))
    elif rule.startswith('dow'):
        wanted=int(rule[3:])-1; target=jan1+dt.timedelta((wanted-jan1.weekday())%7)
    elif rule=='firstday': target=jan1+dt.timedelta((first0-jan1.weekday())%7)
    else: raise AssertionError(rule)
    return target-dt.timedelta((target.weekday()-first0)%7)
def forward(year:int,month:int,day:int,first_day:int,rule:str)->list[int]:
    value=dt.date(year,month,day); start=week_start(year,first_day,rule)
    if value<start:
        prior=week_start(year-1,first_day,rule); return [year-1,(value-prior).days//7+1]
    following=week_start(year+1,first_day,rule)
    if value>=following:return [year+1,(value-following).days//7+1]
    return [year,(value-start).days//7+1]
def rows(path:Path)->dict[str,dict[str,str]]:
    result={}; header=None
    for line in path.read_text().splitlines():
        if not line.strip().startswith('|'):header=None;continue
        cells=[cell.strip() for cell in line.strip().strip('|').split('|')]
        if header is None:header=cells;continue
        if len(cells)!=len(header):raise AssertionError(f'malformed feature row {line}')
        row=dict(zip(header,cells)); key=row.get('case')
        if key:
            if key in result:raise AssertionError(f'duplicate feature row {key}')
            result[key]=row
    return result
def compact_forward(record:list[dict])->str:return json.dumps([[row['year'],row['forward']] for row in record],separators=(',',':'))
def compact_inverse(record:list[dict])->str:return json.dumps([[row['year'],row['inverse']] for row in record],separators=(',',':'))
def main()->None:
    if len(sys.argv)!=2:raise SystemExit('usage: review.py RESULT.json')
    result=json.loads(Path(sys.argv[1]).read_text()); obs=result['observation']
    for relative,expected in result['sha256'].items():
        if digest(ROOT/relative)!=expected:raise AssertionError(f'artifact hash {relative}')
    for module,expected in result['loaded_module_sha256'].items():
        path=Path(obs['loaded_module_paths'][module])
        if not path.is_file() or digest(path)!=expected:raise AssertionError(f'module hash {module}')
    if obs['exception'] is not None or obs['warnings'] or obs['call_stdout'] or result['process_runs'] != [{'exit_code':0,'stderr':''}]*2:raise AssertionError('unexpected native channel')
    if obs['operation_id']!='calendar.week-number' or obs['distribution_version']!='7.00':raise AssertionError('wrong operation/version')
    configs=obs['configurations']; expected_configs=MANIFEST['configurations']
    if len(configs)!=105 or [x['case_id'] for x in configs] != [x['case_id'] for x in expected_configs]:raise AssertionError('config domain incomplete')
    table=rows(FEATURE); wanted_feature={x['case_id'] for x in expected_configs}|{f'{x}-INVERSE' for x in MANIFEST['selected_inverse_configurations']}
    if set(table)!=wanted_feature:raise AssertionError('feature literal rows incomplete')
    partitions={row['partition_id']:row for row in COVERAGE['partition_map']}
    config_ids=[row['case_id'] for row in expected_configs]
    if (COVERAGE['operation_id']!='calendar.week-number' or partitions['calendar.week-number.p1']['case_ids'] != [f'{value}-INVERSE' for value in MANIFEST['selected_inverse_configurations']]
            or partitions['calendar.week-number.p2']['case_ids'] != config_ids or partitions['calendar.week-number.p3']['case_ids'] != config_ids
            or partitions['calendar.week-number.p4']['status'] != 'remaining' or partitions['calendar.week-number.p5']['status'] != 'remaining'):
        raise AssertionError('canonical partition map differs')
    dates=MANIFEST['date_order']; years=MANIFEST['years']; selected=set(MANIFEST['selected_inverse_configurations'])
    rules = [f'jan{i}' for i in range(1,8)] + [f'dow{i}' for i in range(1,8)] + ['firstday']
    assert {(row['first_day'],row['week1_of_year']) for row in expected_configs} == {(day,rule) for day in range(1,8) for rule in rules}
    assert {(calendar.isleap(row['year']),dt.date(row['year'],1,1).isoweekday()) for row in years} == {(leap,day) for leap in [False,True] for day in range(1,8)}
    assert [(row['month'],row['day']) for row in dates] == [(1,day) for day in range(1,8)] + [(12,day) for day in range(25,32)]
    assert 'Given the calendar years in request order are ' + str([row['year'] for row in years]) in FEATURE.read_text()

    for config,request in zip(configs,expected_configs):
        cid=request['case_id']; first=request['first_day']; rule=request['week1_of_year']
        if config['first_day']!=first or config['week1_of_year']!=rule or config['configuration_return']!={'defined':False,'type':'absent','value':None}:raise AssertionError(f'{cid}: configuration mismatch')
        if len(config['years'])!=14:raise AssertionError(f'{cid}: year types missing')
        for actual,year in zip(config['years'],years):
            if actual['year']!=year['year'] or len(actual['forward'])!=14:raise AssertionError(f'{cid}: date matrix missing')
            independent=[forward(year['year'],date['month'],date['day'],first,rule) for date in dates]
            if actual['forward']!=independent:raise AssertionError(f'{cid}/{year["year"]}: independent forward mismatch')
            if cid in selected:
                expected_inverse=[[week,week_start(year['year'],first,rule).year if week==1 else (week_start(year['year'],first,rule)+dt.timedelta(7)).year, (week_start(year['year'],first,rule)+dt.timedelta(7*(week-1))).month, (week_start(year['year'],first,rule)+dt.timedelta(7*(week-1))).day] for week in MANIFEST['inverse_weeks']]
                if actual.get('inverse')!=expected_inverse:raise AssertionError(f'{cid}/{year["year"]}: inverse mismatch')
            elif 'inverse' in actual:raise AssertionError(f'{cid}: unselected inverse')
        literal=table[cid]
        if literal['first day']!=str(first) or literal['week-one rule']!=rule or literal['forward matrix']!=compact_forward(config['years']):raise AssertionError(f'{cid}: feature forward literal mismatch')
        if cid in selected:
            inverse_literal=table[f'{cid}-INVERSE']
            if inverse_literal['first day']!=str(first) or inverse_literal['week-one rule']!=rule or inverse_literal['inverse matrix']!=compact_inverse(config['years']):raise AssertionError(f'{cid}: feature inverse literal mismatch')
    print('reviewed 105 valid configurations, 14 Gregorian year types, 20,580 forward pairs, and 196 selected inverse results')
if __name__=='__main__':main()
