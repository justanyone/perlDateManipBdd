#!/usr/bin/env python3
"""Verify every configuration draft row against the saved public evidence."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
FAMILY=ROOT/'docs/research/configuration-family'; FEATURES=ROOT/'spec/drafts/configuration'
load=lambda path:json.loads(path.read_text())
compact=lambda value:json.dumps(value,ensure_ascii=False,separators=(',',':'))
record=load(FAMILY/'observations.json'); manifest=load(FAMILY/'cases.json')
feature_map=load(FAMILY/'feature-map.json'); bindings=load(FAMILY/'bindings.json')
profiles_doc=load(ROOT/'docs/automation/reference-profiles.json')
cases=manifest['cases']; observations={row['case_id']:row for row in record['observations']}
profiles={profile['name']:profile for profile in profiles_doc['profiles']}
PROFILE={'oo':'current-object','dm5':'legacy-functional'}

def typed(value):
    if value is None:return {'type':'absent'}
    if isinstance(value,bool):return {'type':'boolean','value':value}
    if isinstance(value,(int,float)):return {'type':'number','value':value}
    return {'type':'text','value':value}
def typed_text(value):return 'empty text' if value=='' else 'text '+json.dumps(value,ensure_ascii=False)
def split_table_line(line):
    value=line.strip();assert value.startswith('|') and value.endswith('|'),line
    value=value[1:-1];cells=[];current=[];index=0
    while index<len(value):
        char=value[index]
        if char=='\\':
            assert index+1<len(value),line
            following=value[index+1];current.append('\n' if following=='n' else following);index+=2;continue
        if char=='|':cells.append(''.join(current).strip());current=[]
        else:current.append(char)
        index+=1
    cells.append(''.join(current).strip());return cells
def read_tables(path):
    tables=[];header=None;rows=[]
    for line in path.read_text().splitlines()+['']:
        if not line.strip().startswith('|'):
            if header is not None:tables.append((header,rows));header=None;rows=[]
            continue
        cells=split_table_line(line)
        assert all(cell!='' for cell in cells),(path,line)
        if header is None:header=cells
        else:
            assert len(cells)==len(header),(path,cells)
            rows.append(dict(zip(header,cells)))
    return tables
assert split_table_line(r'| left \| value | one \\ slash |')==['left | value','one \\ slash']

assert len(cases)==len(observations)==40
assert [row['case_id'] for row in record['observations']]==[case['case_id'] for case in cases]
for path,digest in record['sha256'].items():assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==digest,path
for case in cases:
    row=observations[case['case_id']];obs=row['observation']
    assert row['repeatable'] and row['research_status']=='repeatable'
    assert row['returncode']==0 and row['stderr']=='' and obs['exception'] is None
    assert obs['case_id']==case['case_id'] and obs['profile']==case['profile']
    assert obs['operation_id']==case['operation_id'] and obs['contract_ids']==case['contract_ids']
    assert obs['partition_ids']==case['partition_ids'] and obs['request']==case['request']
    assert obs['distribution_version']=='7.00' and obs['call_stdout']==''

DIAGNOSTIC={
 'CFG-DM6-CONFIGFILE-MISSING':'missing-file diagnostic for text "/tmp/date-manip-no-such-config"',
 'CFG-DM6-ENCODING-INVALID':'invalid-setting diagnostic containing text "invalid: Encoding: not-an-encoding"',
 'CFG-DM6-WEEK1-INVALID':'invalid-setting diagnostic containing text "invalid: Week1ofYear: dow9"',
 'CFG-DM6-WORKDAY-INVALID':'invalid-setting diagnostic containing text "WorkDayBeg not before WorkDayEnd"',
 'CFG-DM6-TZ-INVALID':'invalid-zone diagnostic containing text "invalid zone in SetDate"',
 'CFG-DM6-YYTOYYYY':'invalid-setting diagnostic containing text "invalid: YYtoYYYY: c##"',
 'CFG-DM6-JAN1WEEK1':'deprecated-setting diagnostic'}
WARNING_FRAGMENT={
 'CFG-DM6-CONFIGFILE-MISSING':"file doesn't exist: /tmp/date-manip-no-such-config",
 'CFG-DM6-ENCODING-INVALID':'invalid: Encoding: not-an-encoding',
 'CFG-DM6-WEEK1-INVALID':'invalid: Week1ofYear: dow9',
 'CFG-DM6-WORKDAY-INVALID':'WorkDayBeg not before WorkDayEnd',
 'CFG-DM6-TZ-INVALID':'invalid zone in SetDate',
 'CFG-DM6-YYTOYYYY':'invalid: YYtoYYYY: c##'}
def config_request(case):
    request=case['request']
    return {'settings':[{'name':name,'value':typed(value)} for name,value in request['settings']],
            **({'read_names':request['read']} if request.get('read') is not None else {})}
def config_result(case,obs):
    raw=obs['raw_return']
    if case['profile']=='dm5':return {'initializer_result':typed(raw['initializer_return'])}
    return {'apply_result':typed(raw['return']),
            'stored':[{'name':name,'value':typed(value)} for name,value in raw['queried']]}
def config_diagnostic(case):
    return 'no request diagnostic' if case['profile']=='dm5' else DIAGNOSTIC.get(case['case_id'],'no diagnostic')
def lifecycle_request(case):
    request=case['request'];op=case['operation_id']
    if op=='config.read-settings':return {'operation':'read ordered configuration collection','preload':[{'name':n,'value':typed(v)} for n,v in request['settings']],'names':request['names']}
    if op=='error.read-state':return {'operation':'parse then clear error','input':typed(request['bad_text']),'clear_request':typed(request['clear'])}
    if op=='object.kind-check':return {'operation':'read value kinds','value_kinds':['date','duration','recurrence'],'predicate_order':['is date value','is duration value','is recurrence value']}
    if op=='context.create':return {'operation':'derive configuration context','initial_text':{'type':'omitted'},'numeric_date_order':typed('non-US')}
    return {'operation':'read calendar context service availability','value_kinds':['date','duration']}
def lifecycle_result(case,obs):
    raw=obs['raw_return'];op=case['operation_id']
    if op=='config.read-settings':return {'ordered_values':[typed(v) for v in raw['list']],'error':typed(raw['error'])}
    if op=='error.read-state':return {'initial_error':typed(raw['before']),'status':typed(raw['status']),'parse_error':typed(raw['after']),'clear_result':typed(raw['clear_return']),'final_error':typed(raw['post_clear'])}
    if op=='object.kind-check':
        predicate_names=['is_date_value','is_duration_value','is_recurrence_value']
        return {'date':dict(zip(predicate_names,[bool(v) for v in raw['date']])),
                'duration':dict(zip(predicate_names,[bool(v) for v in raw['delta']])),
                'recurrence':dict(zip(predicate_names,[bool(v) for v in raw['recur']]))}
    if op=='context.create':return {'source_numeric_date_order':typed(raw['source']),'derived_numeric_date_order':typed(raw['derived']),'derived_kind':'date value'}
    assert raw=={'date':'Date::Manip::Base','delta':'Date::Manip::Base'}
    return {'date_value':{'calendar_context_service_available':True},
            'duration_value':{'calendar_context_service_available':True}}

config_path=FEATURES/'configuration.feature';lifecycle_path=FEATURES/'object-lifecycle.feature';binding_path=FEATURES/'perl-binding.feature'
assert {path.name for path in FEATURES.glob('*.feature')}=={config_path.name,lifecycle_path.name,binding_path.name}
config_tables=read_tables(config_path);lifecycle_tables=read_tables(lifecycle_path);binding_tables=read_tables(binding_path)
profile_header=['profile','setting','typed value'];config_header=['case','profile','request','result','diagnostic']
lifecycle_header=['case','profile','request','result'];binding_header=['binding case','native profile','request','native warnings']
assert [header for header,_ in config_tables]==[profile_header,config_header]
assert [header for header,_ in lifecycle_tables]==[profile_header,lifecycle_header]
assert [header for header,_ in binding_tables]==[binding_header]

def expected_profile_rows(names):
    result=[]
    for name in names:
        for item in profiles[name]['configuration']:
            setting,value=item.split('=',1)
            result.append({'profile':PROFILE[name],'setting':setting,'typed value':typed_text(value)})
    return result
assert config_tables[0][1]==expected_profile_rows(['oo','dm5'])
assert lifecycle_tables[0][1]==expected_profile_rows(['oo'])

config_cases=[case for case in cases if case['operation_id']=='config.apply-settings']
lifecycle_cases=[case for case in cases if case['operation_id']!='config.apply-settings']
config_rows=config_tables[1][1];lifecycle_rows=lifecycle_tables[1][1]
assert len(config_rows)==35 and len(lifecycle_rows)==5
assert len({row['case'] for row in config_rows})==35 and len({row['case'] for row in lifecycle_rows})==5
assert [row['case'] for row in config_rows]==[case['case_id'] for case in config_cases]
assert [row['case'] for row in lifecycle_rows]==[case['case_id'] for case in lifecycle_cases]
for case,row in zip(config_cases,config_rows):
    obs=observations[case['case_id']]['observation']
    assert row=={'case':case['case_id'],'profile':PROFILE[case['profile']],
                 'request':compact(config_request(case)),'result':compact(config_result(case,obs)),
                 'diagnostic':config_diagnostic(case)},case['case_id']
    warnings=obs['warnings']
    if case['profile']=='dm5':
        assert len(warnings)==1 and 'Date::Manip::DM5 is deprecated' in warnings[0]
    elif case['case_id']=='CFG-DM6-JAN1WEEK1':
        assert len(warnings)==1 and 'jan1week1 Date::Manip config variable is deprecated' in warnings[0]
    elif case['case_id'] in WARNING_FRAGMENT:
        assert WARNING_FRAGMENT[case['case_id']] in ''.join(warnings)
    else:assert warnings==[],case['case_id']
for case,row in zip(lifecycle_cases,lifecycle_rows):
    obs=observations[case['case_id']]['observation']
    assert row=={'case':case['case_id'],'profile':'current-object',
                 'request':compact(lifecycle_request(case)),'result':compact(lifecycle_result(case,obs))},case['case_id']

portable_ids=[row['case'] for row in config_rows+lifecycle_rows]
assert len(portable_ids)==len(set(portable_ids))==40 and set(portable_ids)==set(observations)
jan_case=next(case for case in cases if case['case_id']=='CFG-DM6-JAN1WEEK1')
jan_obs=observations[jan_case['case_id']]['observation'];binding_row=binding_tables[0][1]
assert binding_row==[{'binding case':jan_case['case_id'],'native profile':'oo',
                      'request':compact(jan_case['request']),'native warnings':compact(jan_obs['warnings'])}]
portable_text=config_path.read_text()+lifecycle_path.read_text()
assert 'Date::Manip' not in portable_text and 'native profile' not in portable_text
for path in (config_path,lifecycle_path):
    text=path.read_text()
    assert 'weekday numbers 1 through 7 mean Monday through Sunday' in text
    assert 'US numeric date order means month, day, then year' in text
    assert 'current-object FirstDay 1 starts each week on Monday' in text
    assert 'current-object Week1ofYear jan4 means week one contains January 4' in text
    assert 'current-object DefaultTime midnight supplies 00:00:00 when a date omits its time' in text
assert 'legacy-functional Jan1Week1 0 means week one contains January 4' in config_path.read_text()
assert 'shared calendar context' not in portable_text.lower()
binding_text=binding_path.read_text()
for tag in ('@source-binding','@perl-binding','@excluded-from-portable-handoff'):assert tag in binding_text
assert 'deprecated-setting diagnostic' in portable_text
assert jan_obs['warnings'][0] not in portable_text and jan_obs['warnings'][0].splitlines()[0] in binding_text

expected_map=[]
for case in cases:
    obs=observations[case['case_id']]['observation'];is_config=case['operation_id']=='config.apply-settings'
    expected_map.append({'case_id':case['case_id'],'operation_id':case['operation_id'],'profile':PROFILE[case['profile']],
      'feature':'spec/drafts/configuration/configuration.feature' if is_config else 'spec/drafts/configuration/object-lifecycle.feature',
      'request':config_request(case) if is_config else lifecycle_request(case),
      'result':config_result(case,obs) if is_config else lifecycle_result(case,obs),
      **({'diagnostic':config_diagnostic(case)} if is_config else {})})
expected_binding_feature={'path':'spec/drafts/configuration/perl-binding.feature',
 'tags':['source-binding','perl-binding','excluded-from-portable-handoff'],
 'assertions':[{'case_id':jan_case['case_id'],'native_profile':'oo','request':jan_case['request'],'warnings':jan_obs['warnings']}]}
assert feature_map=={'schema_version':2,
 'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','case_map':expected_map,
 'binding_only_feature':expected_binding_feature}
assert bindings=={'schema_version':2,
 'status':'research-only source binding map; excluded from portable implementation handoff',
 'reference':'Date-Manip 7.00','bindings':[
  {'profile':'oo','portable_profile':'current-object','module':'Date::Manip::Date',
   'public_calls':['config','get_config','err','parse','new_config','new_delta','new_recur','is_date','is_delta','is_recur','base']},
  {'profile':'dm5','portable_profile':'legacy-functional','module':'Date::Manip::DM5',
   'public_calls':['Date_Init']}],
 'native_diagnostic_assertion':{'case_id':jan_case['case_id'],'feature':'spec/drafts/configuration/perl-binding.feature'},
 'return_fidelity':'Empty text, absent return, omitted input, number, boolean, and ordered collection are distinct in portable records. Native warnings remain separate.'}
print(json.dumps({'portable_rows_checked':40,'binding_rows_checked':1,'profile_rows_checked':49,
                  'repeatable_cases':40,'approved_specification_cases':0},indent=2))
