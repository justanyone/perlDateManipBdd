#!/usr/bin/env python3
"""Strictly review every weekday observation, map, and Gherkin row."""
import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/weekday-family';FEATURES=ROOT/'spec/drafts/weekdays'
load=lambda path:json.loads(path.read_text())
compact=lambda value:json.dumps(value,ensure_ascii=False,separators=(',',':'))
manifest=load(FAMILY/'cases.json');evidence=load(FAMILY/'observations.json')
feature_map=load(FAMILY/'feature-map.json');bindings=load(FAMILY/'bindings.json');source_review=load(FAMILY/'source-review.json')
coverage_map=load(FAMILY/'coverage-map.json')
reference_profiles={p['name']:p for p in load(ROOT/'docs/automation/reference-profiles.json')['profiles']}
cases=manifest['cases'];rows=evidence['observations'];observations={row['case_id']:row['observation'] for row in rows}
PROFILE={'base':'calendar-service','dm6':'current-functional','dm5':'legacy-functional'}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def typed(value):
    if value is None:return {'type':'absent'}
    if isinstance(value,bool):return {'type':'boolean','value':value}
    if isinstance(value,(int,float)):return {'type':'number','value':value}
    if value=='':return {'type':'empty-text'}
    return {'type':'text','value':value}
def civil_date(value):return {'year':value[0],'month':value[1],'day':value[2]}
def field_order(case):return ['year','month','day'] if case['profile']=='base' else ['month','day','year']
def portable_request(case):
    source=case['portable_request'];category=case['category']
    if category=='weekday':return {'civil_dates':[civil_date(v) for v in source['civil_dates']]}
    if category=='gregorian-year-type':return {'year_type':source['year_type'],'january_1_weekday':source['january_1_weekday'],'civil_dates':[civil_date(v) for v in source['civil_dates']]}
    if category=='gregorian-control':return {'control':source['control'],'civil_dates':[civil_date(v) for v in source['civil_dates']]}
    if category=='invalid-field':return {'shape':'three named date fields','fields':{name:typed(value) for name,value in zip(['year','month','day'],source['civil_date_fields'])}}
    if category in ('missing-field','extra-field'):return {'shape':'positional fields','field_order':field_order(case),'provided':[typed(v) for v in source['provided_fields']]}
    if category=='invalid-carrier':return {'shape':source['carrier']+' date carrier'}
    if category=='extra-method-argument':return {'shape':'date collection plus an extra argument','date_fields':{name:typed(value) for name,value in zip(['year','month','day'],source['civil_date_fields'])},'extra_argument':typed('ignored')}
    if category=='short-year':return {'shape':'short-year positional fields','field_order':['month','day','year'],'provided':[typed(source['month']),typed(source['day']),typed(source['short_year'])],'short_year_rule':typed(source['short_year_rule'])}
    raise AssertionError(category)
def portable_result(case,obs):
    calls=[]
    for invocation in obs['invocations']:
        scalar=invocation['scalar'];listed=invocation['list']
        if scalar['call_completed']:
            calls.append({'status':'completed','weekday':scalar['return'],'diagnostic':'arithmetic-input diagnostic' if scalar['warnings'] else 'none'})
        else:calls.append({'status':'failed','diagnostic':'invalid-input failure'})
    return {'calls':calls}
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
    tables=[];header=None;table_rows=[]
    for line in path.read_text().splitlines()+['']:
        if not line.strip().startswith('|'):
            if header is not None:tables.append((header,table_rows));header=None;table_rows=[]
            continue
        cells=split_table_line(line);assert all(value!='' for value in cells),(path,line)
        if header is None:header=cells
        else:
            assert len(cells)==len(header),(path,cells)
            table_rows.append(dict(zip(header,cells)))
    return tables
assert split_table_line(r'| left \| value | one \\ slash |')==['left | value','one \\ slash']

assert len(cases)==len(rows)==len(observations)==190
assert [c['case_id'] for c in cases]==[r['case_id'] for r in rows]
assert len({c['case_id'] for c in cases})==190
for path,digest in evidence['artifact_sha256'].items():assert sha(ROOT/path)==digest,path
for path,digest in evidence['reviewed_source_sha256'].items():assert sha(ROOT/path)==digest,path
for path,digest in evidence['installed_module_sha256'].items():assert sha(ROOT/path)==digest,path
assert evidence['execution']=={'repetitions_per_case':2,'parallel_workers':4,'timeout_seconds':20,
 'fresh_process_and_temporary_working_directory_per_attempt':True,
 'environment':{'PATH':'/usr/bin:/bin','PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','PERL_HASH_SEED':'0','PERL_PERTURB_KEYS':'0'}}

independent_calls=0;completed=0;failures=0
for case,row in zip(cases,rows):
    obs=row['observation'];assert row['research_status']=='repeatable' and row['process_stderr_hex']==''
    assert obs['case_id']==case['case_id'] and obs['operation_id']=='calendar.weekday'
    assert obs['profile']==case['profile'] and obs['binding']==case['binding'] and obs['request']==case['portable_request']
    assert obs['perl_version']=='v5.40.1' and obs['perl_archname']=='x86_64-linux-gnu-thread-multi' and obs['os_name']=='linux'
    assert obs['observed_distribution_version']=='7.00'
    assert obs['observed_backend_version']==('5.66' if case['profile']=='dm5' else '7.00')
    assert obs['load_stdout']=='' and obs['setup']['call_completed'] and obs['setup']['exception'] is None
    assert obs['setup']['warnings']==[] and obs['setup']['stdout']==''
    expected_profile=reference_profiles['dm5' if case['profile']=='dm5' else 'oo']
    assert obs['fixture_profile']==expected_profile
    expected_configuration=list(expected_profile['configuration'])
    if case['profile']=='base':expected_configuration=[value for value in expected_configuration if not value.startswith('ForceDate=')]
    if 'short_year_rule' in case['setup']:expected_configuration.append('YYtoYYYY='+case['setup']['short_year_rule'])
    assert obs['setup']['requested_configuration']==expected_configuration
    assert len(obs['load_warnings'])==(1 if case['profile']=='dm5' else 0)
    if case['profile']=='dm5':assert 'Date::Manip::DM5 is deprecated' in obs['load_warnings'][0]
    assert len(obs['invocations'])==len(case['invocations'])
    for request,invocation in zip(case['invocations'],obs['invocations']):
        assert invocation['binding_request']==request
        scalar=invocation['scalar'];listed=invocation['list']
        assert scalar['context']=='scalar' and listed['context']=='list'
        assert scalar['call_completed']==listed['call_completed'] and scalar['stdout']==listed['stdout']==''
        assert scalar['warnings']==listed['warnings']
        if case['profile']=='base':
            assert scalar['public_error_before']==scalar['public_error_after']==''
            assert listed['public_error_before']==listed['public_error_after']==''
        if scalar['call_completed']:
            completed+=1;assert scalar['exception'] is None and listed['exception'] is None
            assert scalar['return_type']=='scalar' and listed['return_type']=='list'
            assert listed['return_count']==1 and listed['return_element_types']==['scalar']
            assert listed['return']==[scalar['return']]
        else:
            failures+=1;assert 'return' not in scalar and 'return_type' not in scalar
            assert 'return' not in listed and 'return_type' not in listed and 'return_count' not in listed
            assert scalar['exception'] and listed['exception']
    expectations=case['independent_expectations']
    if expectations:
        assert len(expectations)==len(obs['invocations'])
        for expected,invocation in zip(expectations,obs['invocations']):
            date=expected['civil_date'];weekday=dt.date(*date).isoweekday()
            assert weekday==expected['weekday']==invocation['scalar']['return']
            independent_calls+=1

for profile in PROFILE:
    p1=[c for c in cases if c['partition_id']=='calendar.weekday.p1' and c['profile']==profile]
    assert [c['independent_expectations'][0]['weekday'] for c in p1]==list(range(1,8))
    types={(c['portable_request']['year_type'],c['portable_request']['january_1_weekday']) for c in cases if c['category']=='gregorian-year-type' and c['profile']==profile}
    assert types=={(kind,weekday) for kind in ('common','leap') for weekday in range(1,8)}
assert independent_calls==265

PROFILE_ROWS=[
 {'profile':'calendar-service','behavior version':'7.00','public input shape':'one ordered collection of year, month, day','full-year domain':'0001 through 9999','default short-year rule':'not applicable','clock setting':'none because weekday arithmetic has no clock input'},
 {'profile':'current-functional','behavior version':'7.00','public input shape':'separate month, day, year fields','full-year domain':'0001 through 9999','default short-year rule':'89','clock setting':'2040-02-28 10:20:30 UTC'},
 {'profile':'legacy-functional','behavior version':'5.66 from distribution 7.00','public input shape':'separate month, day, year fields','full-year domain':'0001 through 9999','default short-year rule':'89','clock setting':'2040-02-28 10:20:30 UTC'}]
FEATURE_BY_PART={'calendar.weekday.p1':'spec/drafts/weekdays/weekdays.feature','calendar.weekday.p2':'spec/drafts/weekdays/gregorian-boundaries.feature','calendar.weekday.p3':'spec/drafts/weekdays/invalid-and-short-years.feature'}
portable_paths=[ROOT/path for path in FEATURE_BY_PART.values()];binding_path=FEATURES/'perl-binding.feature'
assert {p.name for p in FEATURES.glob('*.feature')}=={p.name for p in portable_paths+[binding_path]}
portable_rows=[]
for partition,path_string in FEATURE_BY_PART.items():
    path=ROOT/path_string;tables=read_tables(path)
    assert [header for header,_ in tables]==[
      ['profile','behavior version','public input shape','full-year domain','default short-year rule','clock setting'],
      ['case','profile','request','result']]
    assert tables[0][1]==PROFILE_ROWS
    selected=[c for c in cases if c['partition_id']==partition]
    expected=[]
    for case in selected:
        obs=observations[case['case_id']]
        expected.append({'case':case['case_id'],'profile':PROFILE[case['profile']],
          'request':compact(portable_request(case)),'result':compact(portable_result(case,obs))})
    assert tables[1][1]==expected
    portable_rows+=tables[1][1]
assert len(portable_rows)==190 and len({r['case'] for r in portable_rows})==190

binding_tables=read_tables(binding_path)
assert [header for header,_ in binding_tables]==[['case','native profile','binding','binding requests','setup','load diagnostics','native outcomes']]
expected_binding=[]
for case in cases:
    obs=observations[case['case_id']]
    expected_binding.append({'case':case['case_id'],'native profile':case['profile'],'binding':compact(case['binding']),
      'binding requests':compact(case['invocations']),'setup':compact(obs['setup']),
      'load diagnostics':compact(obs['load_warnings']),'native outcomes':compact(obs['invocations'])})
assert binding_tables[0][1]==expected_binding

portable_text=''.join(path.read_text() for path in portable_paths)
assert 'Date::Manip' not in portable_text and '@perl-binding' not in portable_text
for phrase in ('weekday 1 means Monday through weekday 7 meaning Sunday','functional profiles use reference clock 2040-02-28 10:20:30 UTC',
 'one ordered collection of year, month, day'):
    assert portable_text.count(phrase)==3
assert portable_text.count('separate month, day, year fields')==6
for obs in observations.values():
    for warning in obs['load_warnings']:
        assert warning not in portable_text
    for invocation in obs['invocations']:
        for context in ('scalar','list'):
            native=invocation[context]
            for warning in native['warnings']:assert warning not in portable_text
            if native['exception']:assert native['exception'] not in portable_text
binding_text=binding_path.read_text()
for tag in ('@source-binding','@perl-binding','@excluded-from-portable-handoff'):assert tag in binding_text

expected_map=[]
for case in cases:
    obs=observations[case['case_id']]
    expected_map.append({'case_id':case['case_id'],'partition_id':case['partition_id'],'category':case['category'],
      'profile':PROFILE[case['profile']],'feature':FEATURE_BY_PART[case['partition_id']],
      'request':portable_request(case),'result':portable_result(case,obs),'disposition':case['disposition'],
      'independent_expectations':case['independent_expectations']})
assert feature_map=={'schema_version':1,'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','evidence_sha256':sha(FAMILY/'observations.json'),'case_map':expected_map,
 'binding_only_feature':{'path':'spec/drafts/weekdays/perl-binding.feature','tags':['source-binding','perl-binding','excluded-from-portable-handoff'],'case_ids':[c['case_id'] for c in cases]}}
assert bindings=={'schema_version':1,'status':'research-only source binding map; excluded from portable handoff',
 'reference':'Date-Manip 7.00','operation_id':'calendar.weekday','bindings':manifest['bindings'],'profile_names':PROFILE,
 'case_bindings':[{'case_id':c['case_id'],'profile':c['profile'],'binding':c['binding'],'invocations':c['invocations']} for c in cases],
 'native_feature':'spec/drafts/weekdays/perl-binding.feature'}
assert source_review['reviewed_source_sha256']==evidence['reviewed_source_sha256']
assert source_review['public_entry_points']==manifest['bindings'] and source_review['direct_private_calls']==[]
assert len(source_review['findings'])==5
assert coverage_map=={'schema_version':1,'reference':'Date-Manip 7.00','operation_id':'calendar.weekday',
 'status':'bounded observations; no partition is declared complete','partitions':[
  {'partition_id':'calendar.weekday.p1','portable_case_count':21,
   'observed_domains':['weekday results 1 through 7 through each of three public profiles'],
   'remaining_domains':['every supported civil date rather than one representative of each weekday']},
  {'partition_id':'calendar.weekday.p2','portable_case_count':66,
   'observed_domains':['all fourteen Gregorian common/leap and January-1-weekday year types through each profile','both year-transition sides for every representative year type','years 0001 and 9999','non-century leap, non-leap centuries, and leap centuries'],
   'remaining_domains':['every year from 0001 through 9999 and every date within those years','additional transition representatives within each Gregorian year type']},
  {'partition_id':'calendar.weekday.p3','portable_case_count':103,
   'observed_domains':['zero, negative, fractional, empty, absent, nonnumeric, and out-of-range date fields','missing and extra positions','omitted, undefined, text, and mapping calendar-service carriers','current-functional and legacy-functional short-year behavior under selected rules'],
   'remaining_domains':['the full cross-product of invalid field values and arities','all 00 through 99 short years under every numeric, c, cNN, and cNNNN short-year rule','invalid short-year settings and additional coercive native value kinds','extreme magnitudes, non-finite numbers, numeric text variants, and Unicode numeric text']}]}
print(json.dumps({'portable_rows_checked':190,'binding_rows_checked':190,'repeatable_cases':190,
 'independently_checked_calls':independent_calls,'completed_public_calls':completed,'failed_public_calls':failures,
 'gregorian_year_types_per_profile':14,'approved_specification_cases':0},indent=2))
