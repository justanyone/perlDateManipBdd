#!/usr/bin/env python3
"""Generate portable weekday drafts and research maps from frozen observations."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/weekday-family'; FEATURES=ROOT/'spec/drafts/weekdays'
manifest=json.loads((FAMILY/'cases.json').read_text())
evidence=json.loads((FAMILY/'observations.json').read_text())
cases=manifest['cases']; observations={row['case_id']:row['observation'] for row in evidence['observations']}
PROFILE={'base':'calendar-service','dm6':'current-functional','dm5':'legacy-functional'}

def compact(value):return json.dumps(value,ensure_ascii=False,separators=(',',':'))
def cell(value):return str(value).replace('\\','\\\\').replace('|','\\|').replace('\n','\\n')
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
    if category=='gregorian-year-type':
        return {'year_type':source['year_type'],'january_1_weekday':source['january_1_weekday'],
                'civil_dates':[civil_date(v) for v in source['civil_dates']]}
    if category=='gregorian-control':
        return {'control':source['control'],'civil_dates':[civil_date(v) for v in source['civil_dates']]}
    if category=='invalid-field':
        names=['year','month','day'];return {'shape':'three named date fields',
          'fields':{name:typed(value) for name,value in zip(names,source['civil_date_fields'])}}
    if category in ('missing-field','extra-field'):
        values=source['provided_fields'];return {'shape':'positional fields','field_order':field_order(case),
          'provided':[typed(v) for v in values]}
    if category=='invalid-carrier':return {'shape':source['carrier']+' date carrier'}
    if category=='extra-method-argument':
        return {'shape':'date collection plus an extra argument',
          'date_fields':{name:typed(value) for name,value in zip(['year','month','day'],source['civil_date_fields'])},
          'extra_argument':typed('ignored')}
    if category=='short-year':
        return {'shape':'short-year positional fields','field_order':['month','day','year'],
          'provided':[typed(source['month']),typed(source['day']),typed(source['short_year'])],
          'short_year_rule':typed(source['short_year_rule'])}
    raise AssertionError(category)
def portable_result(case,obs):
    calls=[]
    for invocation in obs['invocations']:
        scalar=invocation['scalar'];listed=invocation['list']
        assert scalar['call_completed']==listed['call_completed']
        if scalar['call_completed']:
            assert listed['return']==[scalar['return']]
            calls.append({'status':'completed','weekday':scalar['return'],
              'diagnostic':'arithmetic-input diagnostic' if scalar['warnings'] else 'none'})
        else:
            assert 'return' not in scalar and 'return' not in listed
            calls.append({'status':'failed','diagnostic':'invalid-input failure'})
    return {'calls':calls}

def profile_background():
    return ['  Background:',
      '    Given each case starts in a fresh process and temporary working directory',
      '    And the timezone is UTC, the language is English, and the locale is C UTF-8',
      '    And the functional profiles use reference clock 2040-02-28 10:20:30 UTC',
      '    And weekday 1 means Monday through weekday 7 meaning Sunday',
      '    And a named civil date has fields year, month, and day',
      '    And the profiles are defined exactly as follows:',
      '      | profile | behavior version | public input shape | full-year domain | default short-year rule | clock setting |',
      '      | calendar-service | 7.00 | one ordered collection of year, month, day | 0001 through 9999 | not applicable | none because weekday arithmetic has no clock input |',
      '      | current-functional | 7.00 | separate month, day, year fields | 0001 through 9999 | 89 | 2040-02-28 10:20:30 UTC |',
      '      | legacy-functional | 5.66 from distribution 7.00 | separate month, day, year fields | 0001 through 9999 | 89 | 2040-02-28 10:20:30 UTC |']

FEATURE_BY_PART={
 'calendar.weekday.p1':'spec/drafts/weekdays/weekdays.feature',
 'calendar.weekday.p2':'spec/drafts/weekdays/gregorian-boundaries.feature',
 'calendar.weekday.p3':'spec/drafts/weekdays/invalid-and-short-years.feature'}
TITLES={
 'calendar.weekday.p1':'Every numeric weekday',
 'calendar.weekday.p2':'Gregorian year types and supported boundaries',
 'calendar.weekday.p3':'Malformed weekday inputs and short years'}
FEATURES.mkdir(parents=True,exist_ok=True)
for partition,path_string in FEATURE_BY_PART.items():
    selected=[c for c in cases if c['partition_id']==partition]
    lines=['@draft @portable @calendar @weekday @reference-dm700',f'Feature: {TITLES[partition]}',
      '  These rows freeze one numeric weekday result or one public failure for each original request.',
      '  Arithmetic-input diagnostics are portable categories; native warning and exception text is excluded.','']
    lines+=profile_background()
    lines+=['','  Scenario Outline: Observe one weekday request',
      '    Given I select profile <profile>',
      '    When I request weekdays with <request>',
      '    Then the ordered public outcomes are <result>','','    Examples:',
      '      | case | profile | request | result |']
    for case in selected:
        obs=observations[case['case_id']]
        row=[case['case_id'],PROFILE[case['profile']],compact(portable_request(case)),compact(portable_result(case,obs))]
        lines.append('      | '+' | '.join(cell(value) for value in row)+' |')
    (ROOT/path_string).write_text('\n'.join(lines)+'\n')

binding_lines=['@draft @calendar @weekday @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff',
 'Feature: Preserve native weekday carriers and diagnostics',
 '  This feature records Perl scalar/list carriers, warnings, failures, and load diagnostics for reference review.',
 '  It is excluded from the portable implementation handoff.','',
 '  Scenario Outline: Preserve one native public-call observation',
 '    Given native profile <native profile> uses public binding <binding>',
 '    When native requests <binding requests> run after setup <setup>',
 '    Then load diagnostics are <load diagnostics>',
 '    And exact native invocation outcomes are <native outcomes>','','    Examples:',
 '      | case | native profile | binding | binding requests | setup | load diagnostics | native outcomes |']
for case in cases:
    obs=observations[case['case_id']]
    row=[case['case_id'],case['profile'],compact(case['binding']),compact(case['invocations']),
         compact(obs['setup']),compact(obs['load_warnings']),compact(obs['invocations'])]
    binding_lines.append('      | '+' | '.join(cell(value) for value in row)+' |')
(FEATURES/'perl-binding.feature').write_text('\n'.join(binding_lines)+'\n')

case_map=[]
for case in cases:
    obs=observations[case['case_id']]
    case_map.append({'case_id':case['case_id'],'partition_id':case['partition_id'],'category':case['category'],
      'profile':PROFILE[case['profile']],'feature':FEATURE_BY_PART[case['partition_id']],
      'request':portable_request(case),'result':portable_result(case,obs),
      'disposition':case['disposition'],'independent_expectations':case['independent_expectations']})
feature_map={'schema_version':1,'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','evidence_sha256':sha(FAMILY/'observations.json'),'case_map':case_map,
 'binding_only_feature':{'path':'spec/drafts/weekdays/perl-binding.feature',
  'tags':['source-binding','perl-binding','excluded-from-portable-handoff'],'case_ids':[c['case_id'] for c in cases]}}
(FAMILY/'feature-map.json').write_text(json.dumps(feature_map,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

bindings={'schema_version':1,'status':'research-only source binding map; excluded from portable handoff',
 'reference':'Date-Manip 7.00','operation_id':'calendar.weekday','bindings':manifest['bindings'],
 'profile_names':PROFILE,'case_bindings':[{'case_id':c['case_id'],'profile':c['profile'],
   'binding':c['binding'],'invocations':c['invocations']} for c in cases],
 'native_feature':'spec/drafts/weekdays/perl-binding.feature'}
(FAMILY/'bindings.json').write_text(json.dumps(bindings,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

source_review={'schema_version':1,'reference':'Date-Manip 7.00','operation_id':'calendar.weekday',
 'reviewed_source_sha256':evidence['reviewed_source_sha256'],
 'public_entry_points':manifest['bindings'],
 'findings':[
  {'entry':'Date::Manip::Base::day_of_week','public':True,'finding':'Documented Monday=1 through Sunday=7; documented numeric fields and year 1 through 9999; most low-level routines do no input checking.'},
  {'entry':'Date::Manip::DM6::Date_DayOfWeek','public':True,'finding':'The public functional wrapper accepts month, day, year and delegates the fields to the calendar service; its POD describes two- or four-digit functional years.'},
  {'entry':'Date::Manip::DM5::Date_DayOfWeek','public':True,'finding':'The public legacy wrapper resolves a year whose text length is not four through configured short-year behavior before weekday arithmetic.'},
  {'entry':'legacy short-year helper','public':False,'finding':'Inspected only to select public YYtoYYYY requests; never invoked directly.'},
  {'entry':'calendar arithmetic helpers','public':False,'finding':'Inspected only to select leap, century, invalid-field, and carrier cases; never invoked directly.'}],
 'direct_private_calls':[]}
(FAMILY/'source-review.json').write_text(json.dumps(source_review,indent=2,sort_keys=True,ensure_ascii=False)+'\n')
coverage_map={'schema_version':1,'reference':'Date-Manip 7.00','operation_id':'calendar.weekday',
 'status':'bounded observations; no partition is declared complete',
 'partitions':[
  {'partition_id':'calendar.weekday.p1','portable_case_count':21,
   'observed_domains':['weekday results 1 through 7 through each of three public profiles'],
   'remaining_domains':['every supported civil date rather than one representative of each weekday']},
  {'partition_id':'calendar.weekday.p2','portable_case_count':66,
   'observed_domains':['all fourteen Gregorian common/leap and January-1-weekday year types through each profile',
    'both year-transition sides for every representative year type','years 0001 and 9999',
    'non-century leap, non-leap centuries, and leap centuries'],
   'remaining_domains':['every year from 0001 through 9999 and every date within those years',
    'additional transition representatives within each Gregorian year type']},
  {'partition_id':'calendar.weekday.p3','portable_case_count':103,
   'observed_domains':['zero, negative, fractional, empty, absent, nonnumeric, and out-of-range date fields',
    'missing and extra positions','omitted, undefined, text, and mapping calendar-service carriers',
    'current-functional and legacy-functional short-year behavior under selected rules'],
   'remaining_domains':['the full cross-product of invalid field values and arities',
    'all 00 through 99 short years under every numeric, c, cNN, and cNNNN short-year rule',
    'invalid short-year settings and additional coercive native value kinds',
    'extreme magnitudes, non-finite numbers, numeric text variants, and Unicode numeric text']}]}
(FAMILY/'coverage-map.json').write_text(json.dumps(coverage_map,indent=2,sort_keys=True,ensure_ascii=False)+'\n')
print(f'wrote {len(cases)} portable rows and {len(cases)} binding rows')
