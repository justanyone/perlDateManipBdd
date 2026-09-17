#!/usr/bin/env python3
"""Review every frozen week-rule edge request, channel, map, and literal."""
import datetime as dt
import hashlib, json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/week-rules-edges'; FEATURES=ROOT/'spec/drafts/week-rules-edges'
load=lambda name:json.loads((FAMILY/name).read_text())
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
compact=lambda value:json.dumps(value,ensure_ascii=False,separators=(',',':'))
PROFILE_LABELS={'base':'generic calendar','oo':'current object',
                'dm6':'current functional','dm5':'legacy functional'}
CLASSIFICATION_LABELS={'binding-failure':'generic-failure'}

def split_table_line(line):
    """Split one Gherkin table line, honoring escaped pipe/backslash/newline."""
    value=line.strip()
    assert value.startswith('|') and value.endswith('|'),line
    value=value[1:-1]; cells=[]; current=[]; index=0
    while index<len(value):
        char=value[index]
        if char=='\\':
            assert index+1<len(value),line
            following=value[index+1]
            current.append('\n' if following=='n' else following)
            index+=2; continue
        if char=='|':
            cells.append(''.join(current).strip()); current=[]
        else: current.append(char)
        index+=1
    cells.append(''.join(current).strip())
    return cells

def read_single_table(path,expected_header):
    header=None; records=[]; table_count=0
    for line in path.read_text().splitlines():
        if not line.strip().startswith('|'):
            header=None; continue
        cells=split_table_line(line)
        if header is None:
            header=cells; table_count+=1
            assert header==expected_header,(path,header)
            continue
        assert len(cells)==len(header),(path,cells)
        records.append(dict(zip(header,cells)))
    assert table_count==1,(path,table_count)
    return records

assert split_table_line(r'| left \| value | one \\ slash |')==['left | value','one \\ slash']

def portable_request(case):
    request=case['request']; family=case['family']
    if family=='base-config':
        setting={'FirstDay':'first weekday','Week1ofYear':'first-week rule'}[request['setting']]
        if request['value_shape']=='value': value=request['value']
        elif request['value_shape']=='undefined': value='absent value'
        else: value='omitted value'
        return f"set {setting} to {compact(value)}"
    if family=='facade-call':
        shape=request['override_shape']
        override='omitted' if shape=='omitted' else 'absent value' if shape=='undefined' else compact(request['first_weekday'])
        return f"week number for 2040-01-01 with first-weekday {override}"
    if request['shape']=='inverse':
        return 'first date of configured week '+compact({'week_year':request['method_arguments'][0],'week':request['method_arguments'][1]})
    if request['shape']=='forward' and request['argument_carrier']=='date-list':
        return 'week pair for civil fields '+compact(request['argument_value'])
    if request['shape']=='forward' and request['argument_carrier']=='undefined':
        return 'week pair for an absent civil date'
    if request['shape']=='raw-arguments' and not request['method_arguments']:
        return 'week pair with the civil date omitted'
    if request['shape']=='raw-arguments' and len(request['method_arguments'])==1:
        return 'first date of configured week with the week field omitted'
    return None

def portable_outcome(case,obs):
    if case['family']=='base-config':
        attempt=obs['configuration_attempt']
        state=attempt['after']
        return compact({'configuration_after':{'first_weekday':state['first_day'],
                                                'first_week_rule':state['week1_of_year']},
                        'control_week_pair':attempt['control_week_result']})
    if case['family']=='facade-call': return compact(obs['calls'][0]['return'])
    selected=obs['calls'][0 if case['request']['shape']=='inverse' else 1]
    return compact(selected['return']) if selected['call_completed'] else 'failure without a result'

def native_observation(obs,case):
    if case['family']=='base-config': return {'configuration_attempt':obs['configuration_attempt']}
    def native(call):
        keys=['context','call_completed']
        keys += ['return','return_type','return_count','return_element_types'] if call['call_completed'] else ['exception']
        keys += ['warnings','stdout','public_error_before','public_error_after']
        return {key:call[key] for key in keys if key in call}
    return {'scalar':native(obs['calls'][0]),'list':native(obs['calls'][1])}

manifest=load('cases.json'); evidence=load('observations.json'); fmap=load('feature-map.json')
coverage=load('coverage-map.json'); bindings=load('bindings.json')
fixture=json.loads((ROOT/'docs/automation/reference-profiles.json').read_text())
cases=manifest['cases']; rows=evidence['observations']; ids=[case['case_id'] for case in cases]
assert len(ids)==236 and len(ids)==len(set(ids))
assert [row['case_id'] for row in rows]==ids
assert evidence['execution']=={
 'repetitions_per_case':2,'parallel_workers':4,'timeout_seconds':20,
 'fresh_process_and_temporary_working_directory_per_attempt':True,
 'environment':{'PATH':'/usr/bin:/bin','PERL5LIB':str(ROOT/'local/date-manip-7.00/lib/perl5'),
                'TZ':'Etc/UTC','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','PERL_HASH_SEED':'0','PERL_PERTURB_KEYS':'0'}}
for name,digest in evidence['sha256'].items(): assert sha(ROOT/name)==digest,name
for name,digest in evidence['installed_module_sha256'].items(): assert sha(ROOT/name)==digest,name

profiles={item['name']:item for item in fixture['profiles']}
family_counts={}; profile_counts={}; exception_cases=[]; warning_calls=0
for case,row in zip(cases,rows):
    assert row['research_status']=='repeatable' and row['process_stderr_hex']==''
    obs=row['observation']; assert obs['case_id']==case['case_id'] and obs['request']==case
    assert obs['operation_id']=='calendar.week-number' and obs['perl_version']=='v5.40.1'
    assert obs['fixture_reference']==fixture['reference']
    expected_fixture=profiles['oo' if case['profile']=='base' else case['profile']]
    assert obs['fixture_profile']==expected_fixture
    assert obs['observed_distribution_version']=='7.00'
    expected_backend={'oo':'7.00','dm6':'7.00','dm5':'5.66'}.get(case['profile'])
    if expected_backend: assert obs['observed_backend_version']==expected_backend
    assert obs['load_stdout']==''
    if case['profile']=='dm5':
        assert len(obs['load_warnings'])==1 and 'Date::Manip::DM5 is deprecated' in obs['load_warnings'][0]
    else: assert obs['load_warnings']==[]
    assert obs['setup']['call_completed'] and obs['setup']['exception'] is None
    assert obs['setup']['stdout']=='' and obs['setup']['warnings']==[]
    if case['profile']=='oo':
        assert obs['setup']['requested_profile_configuration']==expected_fixture['configuration']
        assert obs['setup']['parse_return']==0 and obs['setup']['parse_error']==''
        assert obs['setup']['effective_configuration']==case['configuration']
    for module,path in obs['loaded_date_manip_module_files'].items():
        resolved=Path(path).resolve(); assert resolved==ROOT/'local/date-manip-7.00/lib/perl5'/module
        assert str(resolved.relative_to(ROOT)) in evidence['installed_module_sha256']
    family_counts[case['family']]=family_counts.get(case['family'],0)+1
    profile_counts[case['profile']]=profile_counts.get(case['profile'],0)+1
    if case['family']=='base-config':
        attempt=obs['configuration_attempt']; assert attempt['call_completed'] and attempt['exception'] is None
        assert attempt['return'] is None and attempt['return_type']=='undefined'
        assert attempt['stdout']=='' and attempt['public_error_after']==''
        assert attempt['before']=={'first_day':1,'week1_of_year':'jan4'}
        assert attempt['control_week_result']==[2039,52]
        if case['request']['expected_domain']=='invalid':
            assert attempt['after']==attempt['before'] and attempt['warnings']
        else:
            assert case['case_id']=='WRE-BASE-CONFIG-WEEKRULE-UPPERCASE'
            assert attempt['after']=={'first_day':1,'week1_of_year':'JAN4'} and attempt['warnings']==[]
        continue
    scalar,listed=obs['calls']; assert scalar['context']=='scalar' and listed['context']=='list'
    assert scalar['stdout']==listed['stdout']==''
    assert scalar['call_completed']==listed['call_completed']
    warning_calls += bool(scalar['warnings'])+bool(listed['warnings'])
    if not scalar['call_completed']:
        exception_cases.append(case['case_id'])
        assert 'return' not in scalar and 'return' not in listed
        assert scalar['exception'] and listed['exception']
        assert scalar['exception'].split(' at ')[0]==listed['exception'].split(' at ')[0]
        continue
    assert scalar['exception'] is None and listed['exception'] is None
    if case['family']=='facade-call':
        assert listed['return_count']==1 and listed['return']==[scalar['return']]
        assert listed['return_element_types']==[scalar['return_type']]
        if case['profile']=='oo':
            assert scalar['public_error_before']==scalar['public_error_after']==''
            assert listed['public_error_before']==listed['public_error_after']==''
    elif case['request']['shape']=='inverse':
        assert scalar['return_type']=='ARRAY' and listed['return']==[scalar['return']]
    else:
        assert listed['return_count']==2 and scalar['return']==listed['return'][-1]

assert family_counts=={'base-call':39,'base-config':17,'facade-call':180}
assert profile_counts=={'base':56,'oo':60,'dm6':60,'dm5':60}
assert len(exception_cases)==7 and warning_calls>0

# Independent documented-rule calculation for every explicit valid facade override.
date=dt.date(2040,1,1)
def week_start(year,rule,first):
    target=dt.date(year,1,int(rule[3:]))
    return target-dt.timedelta(days=(target.isoweekday()-first)%7)
def legacy_week(rule,first):
    start=week_start(date.year,rule,first); next_start=week_start(date.year+1,rule,first)
    if date<start: return 0
    if date>=next_start: return 53
    return (date-start).days//7+1
for row in rows:
    obs=row['observation'];case=obs['request'];req=case['request']
    if case['family']=='facade-call' and req['override_shape']=='value' and isinstance(req['first_weekday'],int) and 1<=req['first_weekday']<=7:
        assert obs['calls'][0]['return']==legacy_week(case['configuration']['week1_of_year'],req['first_weekday']),case['case_id']

# Independent ISO controls at supported datetime limits.
row_by_id={row['case_id']:row['observation'] for row in rows}
assert row_by_id['WRE-BASE-FORWARD-DATE-VALID']['calls'][1]['return']==list(dt.date(2040,1,1).isocalendar()[:2])
assert row_by_id['WRE-BASE-FORWARD-DATE-YEAR-1']['calls'][1]['return']==list(dt.date(1,1,1).isocalendar()[:2])
assert row_by_id['WRE-BASE-FORWARD-DATE-YEAR-9999']['calls'][1]['return']==list(dt.date(9999,1,1).isocalendar()[:2])
assert row_by_id['WRE-BASE-INVERSE-YEAR-1']['calls'][0]['return']==[1,1,1]
assert row_by_id['WRE-BASE-INVERSE-YEAR-9999']['calls'][0]['return']==[9999,1,4]

# Canonical maps account for every observation exactly once.
assert [item['case_id'] for item in fmap['case_map']]==ids
mapped_portable=[cid for values in fmap['portable_features'].values() for cid in values]
assert len(mapped_portable)==232 and len(mapped_portable)==len(set(mapped_portable))
for index,(item,case) in enumerate(zip(fmap['case_map'],cases)):
    assert item=={'case_id':case['case_id'],'partition_id':case['partition_id'],
                  'profile':case['profile'],'classification':case['classification'],
                  'portable':case['case_id'] in mapped_portable,'observation_index':index}
assert fmap['binding_only_feature']['assertion_ids']==ids
covered=[cid for item in coverage['partition_map'] for cid in item['case_ids']]
assert set(covered)==set(ids) and len(covered)==len(ids)
assert {item['profile'] for item in bindings['bindings']}=={'base','oo','dm6','dm5'}
canonical={item['id'] for item in json.loads((ROOT/'docs/research/api/contract-map.json').read_text())['operations']}
assert bindings['operation_id'] in canonical

# Parse every Gherkin row and bind each literal to its own case/request. This
# rejects duplicate IDs, missing/extra columns, misplaced outcomes, and a correct
# literal copied into the wrong row.
portable_header=['case','profile','rule','configured first','request','outcome','classification']
binding_header=['binding case','profile','family','request','native observation']
base_path=FEATURES/'base-edge-requests.feature'; legacy_path=FEATURES/'legacy-overrides.feature'; binding_path=FEATURES/'perl-binding.feature'
assert {path.name for path in FEATURES.glob('*.feature')}=={base_path.name,legacy_path.name,binding_path.name}
assert set(fmap['portable_features'])=={str(base_path.relative_to(ROOT)),str(legacy_path.relative_to(ROOT))}
base_rows=read_single_table(base_path,portable_header)
legacy_rows=read_single_table(legacy_path,portable_header)
binding_rows=read_single_table(binding_path,binding_header)
assert len(base_rows)==52 and len(legacy_rows)==180 and len(binding_rows)==236
assert len({row['case'] for row in base_rows})==len(base_rows)
assert len({row['case'] for row in legacy_rows})==len(legacy_rows)
assert len({row['binding case'] for row in binding_rows})==len(binding_rows)
portable_by_id={row['case']:row for row in base_rows+legacy_rows}
binding_by_id={row['binding case']:row for row in binding_rows}
assert set(portable_by_id)==set(mapped_portable)
assert set(binding_by_id)==set(ids)
assert [row['case'] for row in base_rows]==fmap['portable_features'][str(base_path.relative_to(ROOT))]
assert [row['case'] for row in legacy_rows]==fmap['portable_features'][str(legacy_path.relative_to(ROOT))]
assert [row['binding case'] for row in binding_rows]==fmap['binding_only_feature']['assertion_ids']
for evidence_row in rows:
    obs=evidence_row['observation']; case=obs['request']; cid=case['case_id']
    assert binding_by_id[cid]=={
        'binding case':cid,'profile':case['profile'],'family':case['family'],
        'request':compact(case['request']),
        'native observation':compact(native_observation(obs,case))},cid
    request=portable_request(case)
    if request is None:
        assert cid not in portable_by_id; continue
    assert portable_by_id[cid]=={
        'case':cid,'profile':PROFILE_LABELS[case['profile']],
        'rule':case['configuration']['week1_of_year'],
        'configured first':str(case['configuration']['first_day']),
        'request':request,'outcome':portable_outcome(case,obs),
        'classification':CLASSIFICATION_LABELS.get(case['classification'],case['classification'])},cid
print(f"week-rules-edges: {len(ids)} isolated requests, 438 native week-call contexts, 17 configuration attempts, {len(mapped_portable)} portable rows, exact diagnostics, mappings, hashes, and independent calendar controls verified")
