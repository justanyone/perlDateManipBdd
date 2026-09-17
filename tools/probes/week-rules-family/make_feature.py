#!/usr/bin/env python3
"""Render original compact literal Gherkin tables from reviewed matrix evidence."""
from __future__ import annotations
import json, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'spec/drafts/week-rules/week-rules.feature'

def payload(path:Path)->dict:
    value=json.loads(path.read_text())
    return value.get('observation',value)

def compact_forward(years:list[dict])->str:
    return json.dumps([[row['year'],row['forward']] for row in years],separators=(',',':'))

def compact_inverse(years:list[dict])->str:
    return json.dumps([[row['year'],row['inverse']] for row in years],separators=(',',':'))

def main()->None:
    if len(sys.argv)!=2: raise SystemExit('usage: make_feature.py MATRIX.json')
    data=payload(Path(sys.argv[1]))
    configs=data['configurations']
    forward=[]; inverse=[]
    for row in configs:
        forward.append(f"      | {row['case_id']} | {row['first_day']} | {row['week1_of_year']} | {compact_forward(row['years'])} |")
        if 'inverse' in row['years'][0]:
            inverse.append(f"      | {row['case_id']}-INVERSE | {row['first_day']} | {row['week1_of_year']} | {compact_inverse(row['years'])} |")
    OUT.write_text("""@draft @portable @calendar @week-rules
Feature: Assign configured week-year and week-number pairs
  Each matrix uses one FirstDay value from 1 through 7 and one valid
  Week1ofYear rule from jan1 through jan7, dow1 through dow7, or firstday.
  Year types are ordered as nonleap Monday-through-Sunday January 1, then leap
  Monday-through-Sunday January 1. For each year, forward results are ordered
  for Jan 1 through Jan 7, followed by Dec 25 through Dec 31. Every pair is
  [week-year, week-number].

  FirstDay numbers Monday as 1 through Sunday as 7. A janN rule selects the
  week containing January N. A dowN rule selects the week containing the first
  occurrence of weekday N in that year. The firstday rule selects the week
  containing the first occurrence of the configured first weekday.

  Background:
    Given the calendar years in request order are [2001, 2002, 2003, 2009, 2010, 2005, 2006, 2024, 2008, 2020, 2004, 2016, 2000, 2012]
    And each forward request uses January 1 through 7 followed by December 25 through 31
    And each matrix entry starts with its requested year followed by the ordered results

  @calendar.week-number.p2 @calendar.week-number.p3
  Scenario Outline: Apply every valid configured week rule at year edges
    Given FirstDay is <first day> and Week1ofYear is <week-one rule>
    When I map the stated ordered boundary dates to week-year and week-number pairs
    Then the ordered per-year pair matrix is <forward matrix>

    Examples:
      | case | first day | week-one rule | forward matrix |
"""+'\n'.join(forward)+"""

  @calendar.week-number.p1 @calendar.week-number.p2 @calendar.week-number.p3
  Scenario Outline: Find selected configured week starts by inverse lookup
    Given FirstDay is <first day> and Week1ofYear is <week-one rule>
    When I request weeks 1 and 2 for every stated year type
    Then the ordered inverse matrix gives [requested week, year, month, day] for each year as <inverse matrix>

    Examples:
      | case | first day | week-one rule | inverse matrix |
"""+'\n'.join(inverse)+"\n")

if __name__=='__main__':main()
