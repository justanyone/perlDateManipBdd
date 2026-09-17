#!/usr/bin/env python3
"""Render original draft literals from separately reviewed week-count observations."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / 'docs/research/week-count-family'
manifest = json.loads((FAMILY / 'cases.json').read_text())
observations = json.loads((FAMILY / 'observations.json').read_text())['observation']['observations']
target = ROOT / 'spec/drafts/week-counts'
target.mkdir(exist_ok=True)
compact = lambda value: json.dumps(value, separators=(',', ':'))
years = compact(manifest['years'])
common = f'''  Background:
    Given an independently configured Gregorian calendar for each example
    And weekday numbers 1 through 7 mean Monday through Sunday
    And rule janN selects the week containing January N as week one
    And rule dowN selects the week containing the first weekday N in January as week one
    And rule firstday selects the first configured weekday in January as the start of week one
    And the ordered input years are {years}
    And these civil-calendar requests do not depend on the clock or time zone

'''
portable = '''@draft @calendar @week-counts @reference-observed
Feature: Count weeks under configured calendar rules
  Count each week belonging to the requested week-rule year.

''' + common + '''  Scenario Outline: Count configured weeks for <case>
    Given the first weekday is <first weekday> and the week-one rule is <rule>
    When I request the week count twice for each input year before advancing to the next year
    Then the first results in input-year order are <counts>
    And the repeated results in input-year order are <counts>

    Examples:
      | case | first weekday | rule | counts |
'''
binding = '''@draft @calendar @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve native week-count return shapes
  Native context fidelity supports the Perl adapter and is excluded from the portable handoff.

''' + common + '''  Scenario Outline: Preserve native week-count reads for <case>
    Given a fresh Date::Manip::Base configured with first weekday <first weekday> and rule <rule>
    When I call public weeks_in_year for each year in scalar context, repeated scalar context, then list context
    Then both scalar result vectors are <counts>
    And the list result vector is <lists>
    And no call throws or emits a warning

    Examples:
      | case | first weekday | rule | counts | lists |
'''
for row in observations:
    case = row['request']
    counts = [r['first'] for r in row['results']]
    cells = [case['case_id'], str(case['first_day']), case['rule'], compact(counts)]
    portable += '      | ' + ' | '.join(cells) + ' |\n'
    binding += '      | ' + ' | '.join(cells + [compact([r['listed'] for r in row['results']])]) + ' |\n'
(target / 'week-counts.feature').write_text(portable)
(target / 'perl-binding.feature').write_text(binding)
mapping = {
    'operation_id': 'calendar.weeks-in-year',
    'binding': {'module':'Date::Manip::Base', 'callable':'weeks_in_year', 'arguments':['year']},
    'public_setup_calls':['Date::Manip::Base->new', 'Date::Manip::Base->config'],
    'portable_feature':'spec/drafts/week-counts/week-counts.feature',
    'binding_feature':'spec/drafts/week-counts/perl-binding.feature',
    'case_ids':[c['case_id'] for c in manifest['cases']],
    'partitions':[
        {'id':f'calendar.weeks-in-year.p{i}', 'status':'observed-partial',
         'scope':'105 valid configurations across 14 Gregorian year types; repeated count reads'} for i in (1,2,3)
    ] + [{'id':'calendar.weeks-in-year.p4','status':'unobserved','scope':'invalid years and configuration'}],
    'remaining':['unsupported, missing, nonnumeric and fractional years',
                 'invalid configuration attempts and retained state',
                 'configuration changes on reused calendar services',
                 'numeric year limits and years outside representative cycle'],
    'completion_status':'unresolved; no whole-operation or source-coverage completion claim',
}
(FAMILY / 'feature-map.json').write_text(json.dumps(mapping,indent=2)+'\n')
