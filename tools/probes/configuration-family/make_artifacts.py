#!/usr/bin/env python3
"""Generate portable configuration drafts and research maps from saved evidence."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/configuration-family'; FEATURES=ROOT/'spec/drafts/configuration'
cases=json.loads((FAMILY/'cases.json').read_text())['cases']
evidence=json.loads((FAMILY/'observations.json').read_text())
profiles_doc=json.loads((ROOT/'docs/automation/reference-profiles.json').read_text())
observations={row['case_id']:row['observation'] for row in evidence['observations']}
profiles={profile['name']:profile for profile in profiles_doc['profiles']}
PROFILE={'oo':'current-object','dm5':'legacy-functional'}

def compact(value): return json.dumps(value,ensure_ascii=False,separators=(',',':'))
def cell(value): return str(value).replace('\\','\\\\').replace('|','\\|').replace('\n','\\n')
def typed(value):
    if value is None: return {'type':'absent'}
    if isinstance(value,bool): return {'type':'boolean','value':value}
    if isinstance(value,(int,float)): return {'type':'number','value':value}
    return {'type':'text','value':value}
def typed_text(value): return 'empty text' if value=='' else 'text '+json.dumps(value,ensure_ascii=False)
def profile_rows(names):
    rows=[]
    for name in names:
        for item in profiles[name]['configuration']:
            setting,value=item.split('=',1)
            rows.append([PROFILE[name],setting,typed_text(value)])
    return rows
def profile_background(names):
    lines=['  Background:',
      '    Given each case starts in a fresh process and temporary working directory',
      '    And no user, system, or prior-case configuration is inherited',
      '    And the process timezone is UTC with the C UTF-8 locale',
      '    And weekday numbers 1 through 7 mean Monday through Sunday',
      '    And US numeric date order means month, day, then year',
      '    And workweek endpoints 1 and 5 mean Monday through Friday',
      '    And workday endpoints 09:00 and 17:00 bound the workday']
    if 'oo' in names:
        lines += ['    And profile current-object uses reference behavior version 7.00',
          '    And current-object FirstDay 1 starts each week on Monday',
          '    And current-object Week1ofYear jan4 means week one contains January 4',
          '    And current-object DefaultTime midnight supplies 00:00:00 when a date omits its time',
          '    And current-object EraseHolidays 1 and EraseEvents 1 start those collections empty']
    if 'dm5' in names:
        lines += ['    And profile legacy-functional uses compatibility behavior version 5.66 from distribution 7.00',
          '    And legacy-functional FirstDay 1 starts each week on Monday',
          '    And legacy-functional Jan1Week1 0 means week one contains January 4',
          '    And legacy-functional TodayIsMidnight 1 anchors today at 00:00:00',
          '    And legacy-functional EraseHolidays 1 starts the holiday collection empty']
    lines += ['    And the selected profile has these ordered settings:',
              '      | profile | setting | typed value |']
    lines += ['      | '+' | '.join(cell(v) for v in row)+' |' for row in profile_rows(names)]
    return lines

DIAGNOSTIC={
 'CFG-DM6-CONFIGFILE-MISSING':'missing-file diagnostic for text "/tmp/date-manip-no-such-config"',
 'CFG-DM6-ENCODING-INVALID':'invalid-setting diagnostic containing text "invalid: Encoding: not-an-encoding"',
 'CFG-DM6-WEEK1-INVALID':'invalid-setting diagnostic containing text "invalid: Week1ofYear: dow9"',
 'CFG-DM6-WORKDAY-INVALID':'invalid-setting diagnostic containing text "WorkDayBeg not before WorkDayEnd"',
 'CFG-DM6-TZ-INVALID':'invalid-zone diagnostic containing text "invalid zone in SetDate"',
 'CFG-DM6-YYTOYYYY':'invalid-setting diagnostic containing text "invalid: YYtoYYYY: c##"',
 'CFG-DM6-JAN1WEEK1':'deprecated-setting diagnostic',
}
def config_request(case):
    request=case['request']
    return {'settings':[{'name':name,'value':typed(value)} for name,value in request['settings']],
            **({'read_names':request['read']} if request.get('read') is not None else {})}
def config_result(case,obs):
    raw=obs['raw_return']
    if case['profile']=='dm5': return {'initializer_result':typed(raw['initializer_return'])}
    return {'apply_result':typed(raw['return']),
            'stored':[{'name':name,'value':typed(value)} for name,value in raw['queried']]}
def config_diagnostic(case):
    if case['profile']=='dm5': return 'no request diagnostic'
    return DIAGNOSTIC.get(case['case_id'],'no diagnostic')

config_cases=[case for case in cases if case['operation_id']=='config.apply-settings']
config_lines=['@draft @portable @configuration @reference-dm700',
 'Feature: Ordered configuration contexts',
 '  Typed records distinguish omitted values, empty text, absent results, and diagnostics.',
 '  Portable profile names describe behavior independently of a source-language interface.','']
config_lines += profile_background(['oo','dm5'])
config_lines += ['',
 '  Scenario Outline: Apply one observed configuration request',
 '    Given I select profile <profile>',
 '    When I apply typed configuration request <request>',
 '    Then its typed public result is <result>',
 '    And its portable diagnostic outcome is <diagnostic>','',
 '    Examples:',
 '      | case | profile | request | result | diagnostic |']
for case in config_cases:
    obs=observations[case['case_id']]
    row=[case['case_id'],PROFILE[case['profile']],compact(config_request(case)),
         compact(config_result(case,obs)),config_diagnostic(case)]
    config_lines.append('      | '+' | '.join(cell(value) for value in row)+' |')
(FEATURES/'configuration.feature').write_text('\n'.join(config_lines)+'\n')

def lifecycle_request(case):
    request=case['request']; op=case['operation_id']
    if op=='config.read-settings':
        return {'operation':'read ordered configuration collection',
                'preload':[{'name':n,'value':typed(v)} for n,v in request['settings']],
                'names':request['names']}
    if op=='error.read-state':
        return {'operation':'parse then clear error','input':typed(request['bad_text']),
                'clear_request':typed(request['clear'])}
    if op=='object.kind-check':
        return {'operation':'read value kinds','value_kinds':['date','duration','recurrence'],
                'predicate_order':['is date value','is duration value','is recurrence value']}
    if op=='context.create': return {'operation':'derive configuration context','initial_text':{'type':'omitted'},'numeric_date_order':typed('non-US')}
    return {'operation':'read calendar context service availability','value_kinds':['date','duration']}
def lifecycle_result(case,obs):
    raw=obs['raw_return'];op=case['operation_id']
    if op=='config.read-settings':
        return {'ordered_values':[typed(value) for value in raw['list']],
                'error':typed(raw['error'])}
    if op=='error.read-state':
        return {'initial_error':typed(raw['before']),'status':typed(raw['status']),
                'parse_error':typed(raw['after']),'clear_result':typed(raw['clear_return']),
                'final_error':typed(raw['post_clear'])}
    if op=='object.kind-check':
        predicate_names=['is_date_value','is_duration_value','is_recurrence_value']
        return {'date':dict(zip(predicate_names,[bool(value) for value in raw['date']])),
                'duration':dict(zip(predicate_names,[bool(value) for value in raw['delta']])),
                'recurrence':dict(zip(predicate_names,[bool(value) for value in raw['recur']]))}
    if op=='context.create':
        return {'source_numeric_date_order':typed(raw['source']),
                'derived_numeric_date_order':typed(raw['derived']),
                'derived_kind':'date value'}
    return {'date_value':{'calendar_context_service_available':True},
            'duration_value':{'calendar_context_service_available':True}}

lifecycle_cases=[case for case in cases if case['operation_id']!='config.apply-settings']
lifecycle_lines=['@draft @portable @configuration @object-lifecycle @reference-dm700',
 'Feature: Typed values expose configuration and error lifecycle',
 '  Named operations expose typed values without prescribing native call context or classes.','']
lifecycle_lines += profile_background(['oo'])
lifecycle_lines += ['',
 '  Scenario Outline: Observe one configuration or value lifecycle request',
 '    Given I select profile <profile>',
 '    When I perform typed request <request>',
 '    Then its typed public result is <result>','',
 '    Examples:',
 '      | case | profile | request | result |']
for case in lifecycle_cases:
    obs=observations[case['case_id']]
    row=[case['case_id'],PROFILE[case['profile']],compact(lifecycle_request(case)),compact(lifecycle_result(case,obs))]
    lifecycle_lines.append('      | '+' | '.join(cell(value) for value in row)+' |')
(FEATURES/'object-lifecycle.feature').write_text('\n'.join(lifecycle_lines)+'\n')

jan_case=next(case for case in cases if case['case_id']=='CFG-DM6-JAN1WEEK1')
jan_obs=observations[jan_case['case_id']]
binding_lines=['@draft @reference-dm700 @configuration @source-binding @perl-binding @excluded-from-portable-handoff',
 'Feature: Preserve native configuration binding diagnostics',
 '  This exact warning is reference-binding evidence and is not a portable requirement.','',
 '  Scenario Outline: Preserve the native deprecated-setting warning',
 '    Given native profile <native profile> and request <request>',
 '    When the public configuration request is executed',
 '    Then the exact native warning sequence is <native warnings>','',
 '    Examples:','      | binding case | native profile | request | native warnings |',
 '      | '+' | '.join(cell(value) for value in [jan_case['case_id'],jan_case['profile'],
     compact(jan_case['request']),compact(jan_obs['warnings'])])+' |']
(FEATURES/'perl-binding.feature').write_text('\n'.join(binding_lines)+'\n')

case_map=[]
for case in cases:
    obs=observations[case['case_id']]
    is_config=case['operation_id']=='config.apply-settings'
    case_map.append({'case_id':case['case_id'],'operation_id':case['operation_id'],
      'profile':PROFILE[case['profile']],
      'feature':'spec/drafts/configuration/configuration.feature' if is_config else 'spec/drafts/configuration/object-lifecycle.feature',
      'request':config_request(case) if is_config else lifecycle_request(case),
      'result':config_result(case,obs) if is_config else lifecycle_result(case,obs),
      **({'diagnostic':config_diagnostic(case)} if is_config else {})})
feature_map={'schema_version':2,'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','case_map':case_map,
 'binding_only_feature':{'path':'spec/drafts/configuration/perl-binding.feature',
  'tags':['source-binding','perl-binding','excluded-from-portable-handoff'],
  'assertions':[{'case_id':jan_case['case_id'],'native_profile':jan_case['profile'],
                 'request':jan_case['request'],'warnings':jan_obs['warnings']}]}}
(FAMILY/'feature-map.json').write_text(json.dumps(feature_map,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

bindings={'schema_version':2,'status':'research-only source binding map; excluded from portable implementation handoff',
 'reference':'Date-Manip 7.00','bindings':[
  {'profile':'oo','portable_profile':'current-object','module':'Date::Manip::Date',
   'public_calls':['config','get_config','err','parse','new_config','new_delta','new_recur','is_date','is_delta','is_recur','base']},
  {'profile':'dm5','portable_profile':'legacy-functional','module':'Date::Manip::DM5',
   'public_calls':['Date_Init']}],
 'native_diagnostic_assertion':{'case_id':jan_case['case_id'],'feature':'spec/drafts/configuration/perl-binding.feature'},
 'return_fidelity':'Empty text, absent return, omitted input, number, boolean, and ordered collection are distinct in portable records. Native warnings remain separate.'}
(FAMILY/'bindings.json').write_text(json.dumps(bindings,indent=2,sort_keys=True)+'\n')
print(f'wrote {len(config_cases)} configuration rows, {len(lifecycle_cases)} lifecycle rows, and one binding assertion')
