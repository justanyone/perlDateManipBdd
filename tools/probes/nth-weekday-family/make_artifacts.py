#!/usr/bin/env python3
"""Generate portable nth-weekday drafts and research maps from saved evidence."""
import hashlib,json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3];FAMILY=ROOT/'docs/research/nth-weekday-family';FEATURES=ROOT/'spec/drafts/nth-weekdays'
manifest=json.loads((FAMILY/'cases.json').read_text());evidence=json.loads((FAMILY/'observations.json').read_text())
cases=manifest['cases'];observations={r['case_id']:r['observation'] for r in evidence['observations']}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def compact(value):return json.dumps(value,ensure_ascii=False,separators=(',',':'))
def cell(value):return str(value).replace('\\','\\\\').replace('|','\\|').replace('\n','\\n')
def typed(value,omitted=False):
    if omitted:return {'type':'omitted'}
    if value is None:return {'type':'absent'}
    if isinstance(value,bool):return {'type':'boolean','value':value}
    if isinstance(value,(int,float)):return {'type':'number','value':value}
    if value=='':return {'type':'empty-text'}
    return {'type':'text','value':value}
def portable_request(case):
    source=case['portable_request']
    if case['category']!='invalid':
        return {'year':typed(source['year']),'occurrence':typed(source['occurrence']),
          'weekday':typed(source['weekday']),'month':source['month']}
    return {'description':source['description'],
      'fields':{item['name']:item['value'] for item in source['arguments']}}
def portable_result(obs):
    native=obs['scalar'];assert native['call_completed']
    result={'status':'completed','diagnostic':'arithmetic-input diagnostic' if native['warnings'] else 'none'}
    value=native['return']
    result['value']={'type':'absent'} if value is None else {
      'type':'ordered-date-fields','field_order':['year','month','day'],'fields':[typed(item) for item in value]}
    return result
def profile_background():return ['  Background:',
 '    Given each case starts in a fresh process and temporary working directory',
 '    And the timezone is UTC, the language is English, and the locale is C UTF-8',
 '    And weekday 1 means Monday through weekday 7 meaning Sunday',
 '    And positive occurrences count forward and negative occurrences count backward',
 '    And profile calendar-service is defined exactly as follows:',
 '      | behavior version | public input shape | year domain | whole-year occurrence domain | month occurrence domain | optional month | clock setting |',
 '      | 7.00 | year, occurrence, weekday, optional month | 0001 through 9999 | 1 through 53 or -1 through -53 | 1 through 5 or -1 through -5 | omitted means whole year | none because calendar arithmetic has no clock input |']

FEATURE_GROUPS=[
 ('year-occurrences.feature','Whole-year ordinal weekday occurrences',lambda c:c['category'].startswith('year-') and c['category']!='year-no-match'),
 ('month-occurrences.feature','Monthly ordinal weekday occurrences',lambda c:c['category'].startswith('month-') and c['category']!='month-no-match'),
 ('no-match-boundaries.feature','Documented-limit occurrences that are absent',lambda c:c['category'].endswith('no-match')),
 ('invalid-inputs.feature','Malformed and out-of-domain ordinal weekday inputs',lambda c:c['category']=='invalid')]
FEATURES.mkdir(parents=True,exist_ok=True);feature_for={}
for filename,title,select in FEATURE_GROUPS:
    selected=[c for c in cases if select(c)]
    lines=['@draft @portable @calendar @nth-weekday @reference-dm700',f'Feature: {title}',
     '  Each row freezes an observed ordered three-field value or absent result from one original public request.',
     '  Generic arithmetic diagnostics are portable; native warning text and call contexts are excluded.','']
    lines+=profile_background();lines+=['','  Scenario Outline: Find one ordinal weekday occurrence',
     '    Given I select profile <profile>','    When I request an ordinal weekday with <request>',
     '    Then the public outcome is <result>','','    Examples:','      | case | profile | request | result |']
    for case in selected:
        feature_for[case['case_id']]='spec/drafts/nth-weekdays/'+filename
        row=[case['case_id'],'calendar-service',compact(portable_request(case)),compact(portable_result(observations[case['case_id']]))]
        lines.append('      | '+' | '.join(cell(v) for v in row)+' |')
    (FEATURES/filename).write_text('\n'.join(lines)+'\n')
assert len(feature_for)==len(cases)

binding_lines=['@draft @calendar @nth-weekday @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff',
 'Feature: Preserve native nth-weekday carriers and diagnostics',
 '  This feature records Perl scalar/list carriers and exact warnings for reference review.',
 '  It is excluded from the portable implementation handoff.','',
 '  Scenario Outline: Preserve one native public-call observation',
 '    Given native profile <native profile> uses binding <binding>',
 '    When native arguments <arguments> run after setup <setup>',
 '    Then the scalar outcome is <scalar>',
 '    And the list outcome is <list>','','    Examples:',
 '      | case | native profile | binding | arguments | setup | scalar | list |']
for case in cases:
    obs=observations[case['case_id']];row=[case['case_id'],'base',compact(case['binding'] if 'binding' in case else manifest['binding']),
      compact(case['arguments']),compact(obs['setup']),compact(obs['scalar']),compact(obs['list'])]
    binding_lines.append('      | '+' | '.join(cell(v) for v in row)+' |')
(FEATURES/'perl-binding.feature').write_text('\n'.join(binding_lines)+'\n')

case_map=[]
for case in cases:
    case_map.append({'case_id':case['case_id'],'partition_ids':case['partition_ids'],'category':case['category'],
      'profile':'calendar-service','feature':feature_for[case['case_id']],'request':portable_request(case),
      'result':portable_result(observations[case['case_id']]),'independent_expected':case['independent_expected'],
      'source_branch_refs':case['source_branch_refs']})
feature_map={'schema_version':1,'status':'research-to-draft correspondence; not BDD execution or semantic approval',
 'reference':'Date-Manip 7.00','evidence_sha256':sha(FAMILY/'observations.json'),'case_map':case_map,
 'binding_only_feature':{'path':'spec/drafts/nth-weekdays/perl-binding.feature',
  'tags':['source-binding','perl-binding','excluded-from-portable-handoff'],'case_ids':[c['case_id'] for c in cases]}}
(FAMILY/'feature-map.json').write_text(json.dumps(feature_map,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

bindings={'schema_version':1,'status':'research-only source binding map; excluded from portable handoff',
 'reference':'Date-Manip 7.00','operation_id':'calendar.nth-weekday','binding':manifest['binding'],
 'portable_profile':'calendar-service','case_bindings':[{'case_id':c['case_id'],'arguments':c['arguments']} for c in cases],
 'native_feature':'spec/drafts/nth-weekdays/perl-binding.feature'}
(FAMILY/'bindings.json').write_text(json.dumps(bindings,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

source_review={'schema_version':1,'reference':'Date-Manip 7.00','operation_id':'calendar.nth-weekday',
 'reviewed_source_sha256':evidence['reviewed_source_sha256'],'public_entry_points':[manifest['binding']],
 'findings':[
  {'entry':'Date::Manip::Base::nth_day_of_week','public':True,'finding':'The only canonical binding selects month or whole-year mode, forward or reverse origin, later occurrence adjustment, no-match absence, and month or year return conversion.'},
  {'entry':'Date::Manip::Base calendar support methods','public':True,'finding':'Public length, weekday, and day-of-year methods are reached internally; the probe does not call them as substitutes for the operation under test.'},
  {'entry':'private helpers','public':False,'finding':'No private helper is an entry point on the reviewed direct path and none is called by the probe.'}],
 'direct_private_calls':[],'source_branch_refs':sorted({ref for c in cases for ref in c['source_branch_refs']})}
(FAMILY/'source-review.json').write_text(json.dumps(source_review,indent=2,sort_keys=True,ensure_ascii=False)+'\n')

coverage={'schema_version':1,'reference':'Date-Manip 7.00','operation_id':'calendar.nth-weekday',
 'status':'bounded branch-distinct observations; no partition is declared complete','partitions':[
  {'partition_id':'calendar.nth-weekday.p1','case_count':6,'observed_domains':['forward and reverse whole-year origins','first or last and later occurrences','existing positive and negative 53rd occurrences','omitted and explicitly absent optional month'],
   'remaining_domains':['other weekdays, years, and occurrence values that repeat these branches','supported year endpoints 0001 and 9999']},
  {'partition_id':'calendar.nth-weekday.p2','case_count':6,'observed_domains':['forward and reverse month origins','first or last and later occurrences','existing positive and negative fifth occurrences','leap February and a 31-day month'],
   'remaining_domains':['other months, weekdays, and occurrence values that repeat these branches','common-February successful occurrences']},
  {'partition_id':'calendar.nth-weekday.p3','case_count':8,'observed_domains':['existing and absent requests at positive and negative year and month limits'],
   'remaining_domains':['the same documented limits across every weekday and calendar shape']},
  {'partition_id':'calendar.nth-weekday.p4','case_count':4,'observed_domains':['positive and negative no-match absence in month and year modes'],
   'remaining_domains':['other no-match weekdays and calendar shapes']},
  {'partition_id':'calendar.nth-weekday.p5','case_count':12,'observed_domains':['zero and both signs beyond month and year occurrence limits','weekday zero and eight','month zero and thirteen','all fields omitted, absent, or nonnumeric'],
   'remaining_domains':['individual missing, absent, empty, and nonnumeric field combinations','fractional values, extreme magnitudes, numeric text variants, references, and Unicode numeric text']}]}
(FAMILY/'coverage-map.json').write_text(json.dumps(coverage,indent=2,sort_keys=True,ensure_ascii=False)+'\n')
print(f'wrote {len(cases)} portable rows and {len(cases)} binding rows')
