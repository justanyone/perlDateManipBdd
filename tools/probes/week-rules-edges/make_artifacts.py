#!/usr/bin/env python3
"""Freeze portable/binding features and canonical maps from reviewed observations."""
import argparse, json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/week-rules-edges'
FEATURES=ROOT/'spec/drafts/week-rules-edges'

def compact(value): return json.dumps(value,ensure_ascii=False,separators=(',',':'))
def table_cell(value): return str(value).replace('\\','\\\\').replace('|','\\|').replace('\n','\\n')
PROFILE_LABELS={'base':'generic calendar','oo':'current object',
                'dm6':'current functional','dm5':'legacy functional'}
CLASSIFICATION_LABELS={'binding-failure':'generic-failure'}
def native(call):
    keys=['context','call_completed']
    if call['call_completed']: keys += ['return','return_type','return_count','return_element_types']
    else: keys += ['exception']
    keys += ['warnings','stdout','public_error_before','public_error_after']
    return {key:call[key] for key in keys if key in call}
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
    call=obs['calls'][0 if case['request']['shape']=='inverse' else 1] if case['family']=='base-call' else obs['calls'][0]
    if not call['call_completed']: return 'failure without a result'
    value=call['return']
    if case['family']=='base-call' and case['request']['shape']=='inverse': value=call['return']
    return compact(value)

parser=argparse.ArgumentParser();parser.add_argument('observations',nargs='?',default=str(FAMILY/'observations.json'));args=parser.parse_args()
evidence=json.loads(Path(args.observations).read_text()); rows=evidence['observations']
FEATURES.mkdir(parents=True,exist_ok=True)

base=[];legacy=[];binding=[];portable_ids=[]
for row in rows:
    obs=row['observation'];case=obs['request'];cid=case['case_id'];req=portable_request(case)
    if req is not None:
        portable_ids.append(cid)
        classification=CLASSIFICATION_LABELS.get(case['classification'],case['classification'])
        record=[cid,PROFILE_LABELS[case['profile']],case['configuration']['week1_of_year'],case['configuration']['first_day'],req,portable_outcome(case,obs),classification]
        (legacy if case['family']=='facade-call' else base).append(record)
    if case['family']=='base-config':
        attempt=obs['configuration_attempt']; binding_obs={'configuration_attempt':attempt}
    else:
        binding_obs={'scalar':native(obs['calls'][0]),'list':native(obs['calls'][1])}
    binding.append([cid,case['profile'],case['family'],compact(case['request']),compact(binding_obs)])

base_lines=['@draft @portable @calendar @week-rules-edges','Feature: Generic calendar week-number edge requests',
 '  These rows preserve generic public outcomes for invalid, incomplete, malformed,','  and year-limit requests without prescribing a library implementation.','',
 '  Background:','    Given the proleptic Gregorian civil calendar in UTC','    And the language context is English','    And these requests do not depend on the current clock','    And profile generic calendar means the route that returns week pairs and inverse dates','    And weekday numbers 1 through 7 mean Monday through Sunday','    And rule janN makes week one the week containing January N','    And civil date fields are ordered as [year, month, day]','    And an inverse date outcome is ordered as [year, month, day]','    And a forward week outcome is ordered as [week-year, week-number]','    And null in a request or observed compatibility outcome means an absent value','',
 '  Scenario Outline: Observe a generic calendar edge request','    Given <profile> uses week rule <rule> and first weekday <configured first>','    When I make <request>','    Then the generic outcome is <outcome>','    And its review classification is <classification>','',
 '    Examples:','      | case | profile | rule | configured first | request | outcome | classification |']
for row in base: base_lines.append('      | '+' | '.join(table_cell(x) for x in row)+' |')
(FEATURES/'base-edge-requests.feature').write_text('\n'.join(base_lines)+'\n')

legacy_lines=['@draft @portable @calendar @week-rules-edges @compatibility','Feature: Legacy week-number override behavior',
 '  These literal numbers preserve current and legacy public behavior, including','  omitted, absent, and invalid overrides that still produce a numeric result.','',
 '  Background:','    Given the proleptic Gregorian civil calendar in UTC','    And the language is English with the fixed reference time 2040-02-28 10:20:30','    And weekday numbers 1 through 7 mean Monday through Sunday','    And rule janN makes week one the week containing January N','    And profile current object means the stateful current date-value interface','    And profile current functional means the current functional interface','    And profile legacy functional means the versioned legacy functional interface','    And the observable result is one legacy week number','',
 '  Scenario Outline: Observe a configured legacy week number','    Given <profile> uses rule <rule> and configured first weekday <configured first>','    When I request the <request>','    Then the observable number is <outcome>','    And its review classification is <classification>','',
 '    Examples:','      | case | profile | rule | configured first | request | outcome | classification |']
for row in legacy: legacy_lines.append('      | '+' | '.join(table_cell(x) for x in row)+' |')
(FEATURES/'legacy-overrides.feature').write_text('\n'.join(legacy_lines)+'\n')

binding_lines=['@draft @reference-dm700 @calendar @week-rules-edges @source-binding @perl-binding @excluded-from-portable-handoff',
 'Feature: Preserve native Perl week-number edge channels',
 '  Every row records scalar/list context, native carriers, exceptions, warnings,',
 '  standard output, and public error snapshots exactly as observed.','',
 '  Scenario Outline: Preserve one native binding observation','    Given native profile <profile> and public request <request>','    When the <family> request is called in its recorded native contexts','    Then its exact native observation is <native observation>','',
 '    Examples:','      | binding case | profile | family | request | native observation |']
for row in binding: binding_lines.append('      | '+' | '.join(table_cell(x) for x in row)+' |')
(FEATURES/'perl-binding.feature').write_text('\n'.join(binding_lines)+'\n')

feature_map={'schema_version':2,'status':'exact research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','operation_id':'calendar.week-number',
 'portable_features':{
  'spec/drafts/week-rules-edges/base-edge-requests.feature':[r[0] for r in base],
  'spec/drafts/week-rules-edges/legacy-overrides.feature':[r[0] for r in legacy]},
 'binding_only_feature':{'path':'spec/drafts/week-rules-edges/perl-binding.feature',
  'tags':['source-binding','perl-binding','excluded-from-portable-handoff'],
  'assertion_ids':[r[0] for r in binding]},
 'case_map':[{'case_id':row['case_id'],'partition_id':row['observation']['request']['partition_id'],
              'profile':row['observation']['request']['profile'],'classification':row['observation']['request']['classification'],
              'portable':row['case_id'] in portable_ids,'observation_index':i}
             for i,row in enumerate(rows)]}
(FAMILY/'feature-map.json').write_text(json.dumps(feature_map,indent=2,sort_keys=True)+'\n')

coverage={'schema_version':2,'operation_id':'calendar.week-number',
 'external_coverage':{'calendar.week-number.p1':'docs/research/week-rules-family/coverage-map.json',
                      'calendar.week-number.p2':'docs/research/week-rules-family/coverage-map.json',
                      'calendar.week-number.p3':'docs/research/week-rules-family/coverage-map.json'},
 'partition_map':[
  {'partition_id':'calendar.week-number.p4','status':'observed-bounded-edge-domain','case_ids':[r['case_id'] for r in rows if r['observation']['request']['partition_id'].endswith('.p4')],
   'detail':'Base inverse week limits, missing/malformed forward requests and fields, year limits, and invalid FirstDay/Week1ofYear attempts.'},
  {'partition_id':'calendar.week-number.p5','status':'observed-bounded-compatibility-domain','case_ids':[r['case_id'] for r in rows if r['observation']['request']['partition_id'].endswith('.p5')],
   'detail':'Date, DM6, and DM5 with true omission, explicit absent value, overrides 1..7, six malformed overrides, and four rule/first-day configurations.'}],
 'remaining_domains':['arbitrary-magnitude years and inverse week numbers beyond the selected limits','every possible malformed native reference or argument-count shape','the full invalid month/day Cartesian product','legacy facade dates beyond the selected January transition control','crossing every one of the 105 valid Base rule settings with every edge request'],
 'claim':'Complete for the stated p4/p5 batch, not an exhaustive mathematical or native-type domain.'}
(FAMILY/'coverage-map.json').write_text(json.dumps(coverage,indent=2,sort_keys=True)+'\n')

bindings={'schema_version':2,'status':'research-only public binding map; excluded from portable implementation handoff',
 'reference':'Date-Manip 7.00','operation_id':'calendar.week-number',
 'bindings':[
  {'profile':'base','module':'Date::Manip::Base','callable':'week_of_year','source':'local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm:713','contexts':['scalar','list'],'public_error_observer':'err'},
  {'profile':'oo','module':'Date::Manip::Date','callable':'week_of_year','source':'local/date-manip-7.00/lib/perl5/Date/Manip/Date.pm:3968','contexts':['scalar','list'],'public_error_observer':'err'},
  {'profile':'dm6','module':'Date::Manip::DM6','callable':'Date_WeekOfYear','source':'local/date-manip-7.00/lib/perl5/Date/Manip/DM6.pm:803','contexts':['scalar','list'],'public_error_observer':None},
  {'profile':'dm5','module':'Date::Manip::DM5','callable':'Date_WeekOfYear','source':'local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm:3272','contexts':['scalar','list'],'public_error_observer':None}],
 'supporting_public_calls':['Date::Manip::Obj::config','Date::Manip::Obj::get_config','Date::Manip::Obj::err','Date::Manip::Obj::version','Date::Manip::Date::parse','Date::Manip::DM6::Date_Init','Date::Manip::DM6::DateManipVersion','Date::Manip::DM5::Date_Init','Date::Manip::DM5::DateManipVersion'],
 'return_fidelity':'A completed undefined return, empty text, zero, scalar/list carrier, exception without return, warning sequence, stdout, and public error snapshot remain distinct.',
 'isolation':'Every request is repeated in two fresh Perl processes and temporary directories. Base scalar/list contexts use fresh receivers to prevent cache-dependent diagnostics.',
 'binding_only_feature':'spec/drafts/week-rules-edges/perl-binding.feature'}
(FAMILY/'bindings.json').write_text(json.dumps(bindings,indent=2,sort_keys=True)+'\n')
print(f'wrote {len(base)} Base portable rows, {len(legacy)} facade rows, and {len(binding)} binding rows')
