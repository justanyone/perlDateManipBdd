#!/usr/bin/env python3
"""Create branch-distinct public Base nth-day-of-week requests."""
import calendar
import datetime as dt
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'docs/research/nth-weekday-family/cases.json'

def occurrences(year,weekday,month=None):
    if month is None:
        start=dt.date(year,1,1);end=dt.date(year,12,31)
    else:
        start=dt.date(year,month,1);end=dt.date(year,month,calendar.monthrange(year,month)[1])
    result=[];current=start
    while current<=end:
        if current.isoweekday()==weekday:result.append([current.year,current.month,current.day])
        current+=dt.timedelta(days=1)
    return result
def expected(year,n,weekday,month=None):
    values=occurrences(year,weekday,month)
    index=n-1 if n>0 else n
    return values[index] if -len(values)<=index<len(values) else None

cases=[]
def add(case_id,partitions,category,args,portable,expectation,branches):
    cases.append({'case_id':case_id,'operation_id':'calendar.nth-weekday','partition_ids':partitions,
      'category':category,'profile':'base','arguments':args,'portable_request':portable,
      'independent_expected':expectation,'source_branch_refs':branches})

def valid(case_id,partitions,category,year,n,weekday,month='omitted',branches=()):
    args=[year,n,weekday] if month=='omitted' else [year,n,weekday,month]
    resolved_month=None if month in ('omitted',None) else month
    request={'year':year,'occurrence':n,'weekday':weekday,
             'month':{'type':'omitted'} if month=='omitted' else ({'type':'absent'} if month is None else {'type':'number','value':month})}
    add(case_id,partitions,category,args,request,expected(year,n,weekday,resolved_month),list(branches))

# Whole-year searches: first/later/limit, forward/backward, both offset comparisons,
# and omitted versus explicitly absent optional month.
valid('NWD-P1-YEAR-FIRST-FORWARD',['calendar.nth-weekday.p1'],'year-positive',2041,1,1,
      branches=['Base.pm:527-536 year/positive origin','Base.pm:542-547 weekday offset','Base.pm:566 year return'])
valid('NWD-P1-YEAR-LATER-FORWARD-ABSENT-MONTH',['calendar.nth-weekday.p1'],'year-positive',2041,2,4,None,
      branches=['Base.pm:527-536 year/positive origin','Base.pm:553-556 later positive','Base.pm:566 year return'])
valid('NWD-P1-YEAR-LIMIT53-FORWARD',['calendar.nth-weekday.p1','calendar.nth-weekday.p3'],'year-positive-limit',2040,53,7,
      branches=['Base.pm:527-536 year/positive origin','Base.pm:553-556 positive limit','Base.pm:566 year return'])
valid('NWD-P1-YEAR-LAST-REVERSE',['calendar.nth-weekday.p1'],'year-negative',2041,-1,7,
      branches=['Base.pm:527-536 year/negative origin','Base.pm:542-550 reverse offset','Base.pm:566 year return'])
valid('NWD-P1-YEAR-LATER-REVERSE',['calendar.nth-weekday.p1'],'year-negative',2041,-2,2,
      branches=['Base.pm:527-536 year/negative origin','Base.pm:557-560 later negative','Base.pm:566 year return'])
valid('NWD-P1-YEAR-LIMIT53-REVERSE',['calendar.nth-weekday.p1','calendar.nth-weekday.p3'],'year-negative-limit',2040,-53,1,
      branches=['Base.pm:527-536 year/negative origin','Base.pm:557-560 negative limit','Base.pm:566 year return'])

# Month searches include February and a 31-day month with actual fifth occurrences.
valid('NWD-P2-MONTH-FIRST-FORWARD',['calendar.nth-weekday.p2'],'month-positive',2040,1,3,2,
      branches=['Base.pm:523-526 month/positive origin','Base.pm:542-547 weekday offset','Base.pm:563-565 month return'])
valid('NWD-P2-MONTH-LATER-FORWARD',['calendar.nth-weekday.p2'],'month-positive',2040,2,7,2,
      branches=['Base.pm:523-526 month/positive origin','Base.pm:553-556 later positive','Base.pm:563-565 month return'])
valid('NWD-P2-MONTH-FIFTH-FORWARD',['calendar.nth-weekday.p2','calendar.nth-weekday.p3'],'month-positive-limit',2041,5,4,5,
      branches=['Base.pm:523-526 month/positive origin','Base.pm:553-556 positive month limit','Base.pm:563-565 month return'])
valid('NWD-P2-MONTH-LAST-REVERSE',['calendar.nth-weekday.p2'],'month-negative',2040,-1,4,2,
      branches=['Base.pm:523-526 month/negative origin','Base.pm:542-550 reverse offset','Base.pm:563-565 month return'])
valid('NWD-P2-MONTH-LATER-REVERSE',['calendar.nth-weekday.p2'],'month-negative',2040,-2,1,2,
      branches=['Base.pm:523-526 month/negative origin','Base.pm:557-560 later negative','Base.pm:563-565 month return'])
valid('NWD-P2-MONTH-FIFTH-REVERSE',['calendar.nth-weekday.p2','calendar.nth-weekday.p3'],'month-negative-limit',2041,-5,5,5,
      branches=['Base.pm:523-526 month/negative origin','Base.pm:557-560 negative month limit','Base.pm:563-565 month return'])

# Documented-limit requests whose occurrence does not exist.
valid('NWD-P4-MONTH-FIFTH-NO-MATCH',['calendar.nth-weekday.p3','calendar.nth-weekday.p4'],'month-no-match',2041,5,1,2,
      branches=['Base.pm:553-556 positive no-match'])
valid('NWD-P4-MONTH-NEG-FIFTH-NO-MATCH',['calendar.nth-weekday.p3','calendar.nth-weekday.p4'],'month-no-match',2041,-5,2,2,
      branches=['Base.pm:557-560 negative no-match'])
valid('NWD-P4-YEAR-53-NO-MATCH',['calendar.nth-weekday.p3','calendar.nth-weekday.p4'],'year-no-match',2041,53,4,
      branches=['Base.pm:553-556 positive no-match'])
valid('NWD-P4-YEAR-NEG53-NO-MATCH',['calendar.nth-weekday.p3','calendar.nth-weekday.p4'],'year-no-match',2041,-53,5,
      branches=['Base.pm:557-560 negative no-match'])

def invalid(case_id,args,description,branches):
    portable=[]
    names=['year','occurrence','weekday','month']
    for index,name in enumerate(names):
        if index>=len(args):portable.append({'name':name,'value':{'type':'omitted'}})
        else:
            value=args[index]
            if value is None:typed={'type':'absent'}
            elif isinstance(value,(int,float)):typed={'type':'number','value':value}
            elif value=='':typed={'type':'empty-text'}
            else:typed={'type':'text','value':value}
            portable.append({'name':name,'value':typed})
    add(case_id,['calendar.nth-weekday.p5'],'invalid',args,
        {'description':description,'arguments':portable},None,branches)

invalid('NWD-P5-OCCURRENCE-ZERO',[2041,0,3,5],'zero occurrence',['Base.pm:553-560 neither later-occurrence branch'])
invalid('NWD-P5-MONTH-OCCURRENCE-PLUS6',[2041,6,3,5],'month occurrence above positive limit',['Base.pm:553-556 positive no-match'])
invalid('NWD-P5-MONTH-OCCURRENCE-MINUS6',[2041,-6,5,5],'month occurrence below negative limit',['Base.pm:557-560 negative no-match'])
invalid('NWD-P5-YEAR-OCCURRENCE-PLUS54',[2041,54,2],'year occurrence above positive limit',['Base.pm:553-556 positive no-match'])
invalid('NWD-P5-YEAR-OCCURRENCE-MINUS54',[2041,-54,2],'year occurrence below negative limit',['Base.pm:557-560 negative no-match'])
invalid('NWD-P5-WEEKDAY-ZERO',[2041,1,0,5],'weekday below documented range',['Base.pm:542-550 unchecked weekday offset'])
invalid('NWD-P5-WEEKDAY-EIGHT',[2041,1,8,5],'weekday above documented range',['Base.pm:542-550 unchecked weekday offset'])
invalid('NWD-P5-MONTH-ZERO',[2041,1,2,0],'false month value selects whole-year mode',['Base.pm:515-516 month coercion','Base.pm:527-536 year origin'])
invalid('NWD-P5-MONTH-13',[2041,1,2,13],'month above documented range',['Base.pm:523-526 unchecked month mode'])
invalid('NWD-P5-ALL-OMITTED',[],'all required fields omitted',['Base.pm:515-516 field coercion','Base.pm:527-560 unchecked arithmetic'])
invalid('NWD-P5-ALL-ABSENT',[None,None,None,None],'all fields explicitly absent',['Base.pm:515-516 field coercion','Base.pm:523-560 unchecked arithmetic'])
invalid('NWD-P5-ALL-NONNUMERIC',['year','occurrence','weekday','month'],'all fields nonnumeric text',['Base.pm:515-516 field coercion','Base.pm:523-560 unchecked arithmetic'])

assert len(cases)==28
manifest={'schema_version':1,'status':'original public-call research requests; not BDD execution or semantic approval',
 'reference':{'distribution':'Date-Manip','version':'7.00','timezone':'Etc/UTC','language':'English'},
 'operation_id':'calendar.nth-weekday',
 'binding':{'module':'Date::Manip::Base','callable':'nth_day_of_week','call_shape':'year, occurrence, weekday, optional month','disposition':'public-oo-method'},
 'cases':cases}
OUT.parent.mkdir(parents=True,exist_ok=True)
OUT.write_text(json.dumps(manifest,indent=2,sort_keys=True,ensure_ascii=False)+'\n')
print(f'wrote {len(cases)} cases')
