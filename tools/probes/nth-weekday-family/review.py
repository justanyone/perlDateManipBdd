#!/usr/bin/env python3
"""Strict row-keyed review of the nth-weekday research family."""
import calendar,datetime as dt,hashlib,json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3];FAMILY=ROOT/'docs/research/nth-weekday-family';FEATURES=ROOT/'spec/drafts/nth-weekdays'
load=lambda p:json.loads(p.read_text());compact=lambda v:json.dumps(v,ensure_ascii=False,separators=(',',':'))
manifest=load(FAMILY/'cases.json');evidence=load(FAMILY/'observations.json');feature_map=load(FAMILY/'feature-map.json')
bindings=load(FAMILY/'bindings.json');source_review=load(FAMILY/'source-review.json');coverage=load(FAMILY/'coverage-map.json')
navigation=load(ROOT/'docs/research/inputs/calendar.json')
cases=manifest['cases'];rows=evidence['observations'];observations={r['case_id']:r['observation'] for r in rows}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def typed(value,omitted=False):
    if omitted:return {'type':'omitted'}
    if value is None:return {'type':'absent'}
    if isinstance(value,bool):return {'type':'boolean','value':value}
    if isinstance(value,(int,float)):return {'type':'number','value':value}
    if value=='':return {'type':'empty-text'}
    return {'type':'text','value':value}
def portable_request(case):
    source=case['portable_request']
    if case['category']!='invalid':return {'year':typed(source['year']),'occurrence':typed(source['occurrence']),'weekday':typed(source['weekday']),'month':source['month']}
    return {'description':source['description'],'fields':{item['name']:item['value'] for item in source['arguments']}}
def portable_result(obs):
    native=obs['scalar'];result={'status':'completed','diagnostic':'arithmetic-input diagnostic' if native['warnings'] else 'none'};value=native['return']
    result['value']={'type':'absent'} if value is None else {'type':'ordered-date-fields','field_order':['year','month','day'],'fields':[typed(item) for item in value]}
    return result
def independent(year,n,weekday,month=None):
    start=dt.date(year,month,1) if month else dt.date(year,1,1)
    end=dt.date(year,month,calendar.monthrange(year,month)[1]) if month else dt.date(year,12,31)
    values=[];current=start
    while current<=end:
        if current.isoweekday()==weekday:values.append([current.year,current.month,current.day])
        current+=dt.timedelta(days=1)
    index=n-1 if n>0 else n
    return values[index] if -len(values)<=index<len(values) else None
def split_table_line(line):
    value=line.strip();assert value.startswith('|')and value.endswith('|'),line
    value=value[1:-1];cells=[];current=[];index=0
    while index<len(value):
        char=value[index]
        if char=='\\':
            assert index+1<len(value),line;following=value[index+1];current.append('\n' if following=='n' else following);index+=2;continue
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
        values=split_table_line(line);assert all(v!='' for v in values),(path,line)
        if header is None:header=values
        else:
            assert len(values)==len(header),(path,values);table_rows.append(dict(zip(header,values)))
    return tables
assert split_table_line(r'| left \| value | one \\ slash |')==['left | value','one \\ slash']

assert len(cases)==len(rows)==len(observations)==28 and len({c['case_id'] for c in cases})==28
assert [c['case_id'] for c in cases]==[r['case_id'] for r in rows]
for path,digest in evidence['artifact_sha256'].items():assert sha(ROOT/path)==digest,path
for path,digest in evidence['reviewed_source_sha256'].items():assert sha(ROOT/path)==digest,path
for path,digest in evidence['installed_module_sha256'].items():assert sha(ROOT/path)==digest,path
assert evidence['execution']=={'repetitions_per_case':2,'parallel_workers':4,'timeout_seconds':20,
 'fresh_process_and_temporary_working_directory_per_attempt':True,
 'environment':{'PATH':'/usr/bin:/bin','PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5'),'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','PERL_HASH_SEED':'0','PERL_PERTURB_KEYS':'0'}}

# Prove every request differs from the seven older navigation requests.
existing=set()
for old in navigation['cases']:
    if old.get('operation_id')!='calendar.nth-weekday':continue
    req=old['request'];existing.add((req['year'],req['occurrence'],req['weekday'],req.get('month')))
assert len(existing)==7
for case in cases:
    args=case['arguments'];key=tuple((args+[None]*4)[:4]);assert key not in existing,case['case_id']

independent_checked=0;absent_results=0;warning_cases=0
expected_configuration=None
reference_profile=next(p for p in load(ROOT/'docs/automation/reference-profiles.json')['profiles'] if p['name']=='oo')
for case,row in zip(cases,rows):
    obs=row['observation'];assert row['research_status']=='repeatable' and row['process_stderr_hex']==''
    assert obs['case_id']==case['case_id'] and obs['operation_id']=='calendar.nth-weekday' and obs['profile']=='base'
    assert obs['binding']==manifest['binding'] and obs['binding_arguments']==case['arguments'] and obs['request']==case['portable_request']
    assert obs['perl_version']=='v5.40.1' and obs['perl_archname']=='x86_64-linux-gnu-thread-multi' and obs['os_name']=='linux'
    assert obs['observed_distribution_version']=='7.00' and obs['load_warnings']==[] and obs['load_stdout']==''
    setup=obs['setup'];assert setup['call_completed'] and setup['exception'] is None and setup['warnings']==[] and setup['stdout']==''
    assert obs['fixture_profile']==reference_profile
    configured=[v for v in reference_profile['configuration'] if not v.startswith('ForceDate=')]
    assert setup['requested_configuration']==configured
    expected_configuration=expected_configuration or configured;assert configured==expected_configuration
    scalar=obs['scalar'];listed=obs['list']
    assert scalar['call_completed'] and listed['call_completed'] and scalar['exception'] is None and listed['exception'] is None
    assert scalar['context']=='scalar' and listed['context']=='list' and scalar['stdout']==listed['stdout']==''
    assert scalar['warnings']==listed['warnings'];warning_cases+=bool(scalar['warnings'])
    assert scalar['public_error_before']==scalar['public_error_after']==''
    assert listed['public_error_before']==listed['public_error_after']==''
    assert listed['return_type']=='list' and listed['return_count']==1 and listed['return']==[scalar['return']]
    if scalar['return'] is None:
        absent_results+=1;assert scalar['return_type']=='undefined' and listed['return_element_types']==['undefined']
    else:
        assert scalar['return_type']=='ARRAY' and listed['return_element_types']==['ARRAY'] and len(scalar['return'])==3
    if case['category']!='invalid':
        args=case['arguments'];month=args[3] if len(args)==4 else None
        expected=independent(args[0],args[1],args[2],month)
        assert expected==case['independent_expected']==scalar['return'],case['case_id'];independent_checked+=1
assert independent_checked==16 and absent_results==8 and warning_cases==3

PROFILE_HEADER=['behavior version','public input shape','year domain','whole-year occurrence domain','month occurrence domain','optional month','clock setting']
PROFILE_ROW={'behavior version':'7.00','public input shape':'year, occurrence, weekday, optional month','year domain':'0001 through 9999',
 'whole-year occurrence domain':'1 through 53 or -1 through -53','month occurrence domain':'1 through 5 or -1 through -5',
 'optional month':'omitted means whole year','clock setting':'none because calendar arithmetic has no clock input'}
FEATURE_GROUPS=[
 ('year-occurrences.feature',lambda c:c['category'].startswith('year-') and c['category']!='year-no-match'),
 ('month-occurrences.feature',lambda c:c['category'].startswith('month-') and c['category']!='month-no-match'),
 ('no-match-boundaries.feature',lambda c:c['category'].endswith('no-match')),
 ('invalid-inputs.feature',lambda c:c['category']=='invalid')]
portable_rows=[];feature_for={}
for filename,select in FEATURE_GROUPS:
    path=FEATURES/filename;tables=read_tables(path)
    assert [h for h,_ in tables]==[PROFILE_HEADER,['case','profile','request','result']]
    assert tables[0][1]==[PROFILE_ROW]
    selected=[c for c in cases if select(c)];expected=[]
    for case in selected:
        feature_for[case['case_id']]='spec/drafts/nth-weekdays/'+filename
        expected.append({'case':case['case_id'],'profile':'calendar-service','request':compact(portable_request(case)),
          'result':compact(portable_result(observations[case['case_id']]))})
    assert tables[1][1]==expected;portable_rows+=tables[1][1]
assert len(portable_rows)==len({r['case'] for r in portable_rows})==28

binding_path=FEATURES/'perl-binding.feature';binding_tables=read_tables(binding_path)
assert [h for h,_ in binding_tables]==[['case','native profile','binding','arguments','setup','scalar','list']]
expected_binding=[]
for case in cases:
    obs=observations[case['case_id']];expected_binding.append({'case':case['case_id'],'native profile':'base','binding':compact(manifest['binding']),
      'arguments':compact(case['arguments']),'setup':compact(obs['setup']),'scalar':compact(obs['scalar']),'list':compact(obs['list'])})
assert binding_tables[0][1]==expected_binding
assert {p.name for p in FEATURES.glob('*.feature')}=={name for name,_ in FEATURE_GROUPS}|{'perl-binding.feature'}

portable_text=''.join((FEATURES/name).read_text() for name,_ in FEATURE_GROUPS)
assert 'Date::Manip' not in portable_text and '@perl-binding' not in portable_text and '/home/kevin' not in portable_text
for phrase in ('weekday 1 means Monday through weekday 7 meaning Sunday','positive occurrences count forward and negative occurrences count backward','omitted means whole year'):
    assert portable_text.count(phrase)==4
for obs in observations.values():
    for context in ('scalar','list'):
        native=obs[context]
        for warning in native['warnings']:assert warning not in portable_text
        if native['exception']:assert native['exception'] not in portable_text
binding_text=binding_path.read_text()
for tag in ('@source-binding','@perl-binding','@excluded-from-portable-handoff'):assert tag in binding_text

expected_map=[]
for case in cases:
    expected_map.append({'case_id':case['case_id'],'partition_ids':case['partition_ids'],'category':case['category'],
      'profile':'calendar-service','feature':feature_for[case['case_id']],'request':portable_request(case),
      'result':portable_result(observations[case['case_id']]),'independent_expected':case['independent_expected'],
      'source_branch_refs':case['source_branch_refs']})
assert feature_map=={'schema_version':1,'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','evidence_sha256':sha(FAMILY/'observations.json'),'case_map':expected_map,
 'binding_only_feature':{'path':'spec/drafts/nth-weekdays/perl-binding.feature','tags':['source-binding','perl-binding','excluded-from-portable-handoff'],'case_ids':[c['case_id'] for c in cases]}}
assert bindings=={'schema_version':1,'status':'research-only source binding map; excluded from portable handoff','reference':'Date-Manip 7.00',
 'operation_id':'calendar.nth-weekday','binding':manifest['binding'],'portable_profile':'calendar-service',
 'case_bindings':[{'case_id':c['case_id'],'arguments':c['arguments']} for c in cases],
 'native_feature':'spec/drafts/nth-weekdays/perl-binding.feature'}
assert source_review['reviewed_source_sha256']==evidence['reviewed_source_sha256']
assert source_review['public_entry_points']==[manifest['binding']] and source_review['direct_private_calls']==[]
assert coverage['status']=='bounded branch-distinct observations; no partition is declared complete'
assert [(p['partition_id'],p['case_count']) for p in coverage['partitions']]==[
 ('calendar.nth-weekday.p1',6),('calendar.nth-weekday.p2',6),('calendar.nth-weekday.p3',8),('calendar.nth-weekday.p4',4),('calendar.nth-weekday.p5',12)]
print(json.dumps({'portable_rows_checked':28,'binding_rows_checked':28,'repeatable_cases':28,
 'independently_checked_cases':independent_checked,'absent_results':absent_results,'warning_cases':warning_cases,
 'existing_navigation_requests_duplicated':0,'approved_specification_cases':0},indent=2))
