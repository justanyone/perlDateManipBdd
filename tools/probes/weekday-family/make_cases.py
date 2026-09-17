#!/usr/bin/env python3
"""Create original public calendar.weekday requests for all three bindings."""
import calendar
import datetime as dt
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'docs/research/weekday-family/cases.json'
PROFILES=('base','dm6','dm5')
BINDINGS={
 'base':{'module':'Date::Manip::Base','callable':'day_of_week','call_shape':'one date-list'},
 'dm6':{'module':'Date::Manip::DM6','callable':'Date_DayOfWeek','call_shape':'month, day, year'},
 'dm5':{'module':'Date::Manip::DM5','callable':'Date_DayOfWeek','call_shape':'month, day, year'},
}

def iso(date): return dt.date(*date).isoweekday()
def slug(value): return str(value).replace('-','N').replace('.','P').replace(' ','_').upper()
def invocation(profile,values,carrier=None,extra_method_arguments=None):
    if profile=='base':
        carrier=carrier or 'date-list'
        item={'carrier':carrier}
        if carrier=='date-list': item['value']=values
        elif carrier=='undefined': item['value']=None
        elif carrier=='text': item['value']='2040-02-29'
        elif carrier=='mapping': item['value']={'year':2040,'month':2,'day':29}
        elif carrier=='nested-list': item['value']=[values]
        if extra_method_arguments is not None:item['extra_method_arguments']=extra_method_arguments
        return item
    ordered=[values[1],values[2],values[0]] if len(values)==3 else values
    return {'carrier':'functional-fields','arguments':ordered}
def valid_invocation(profile,date):
    values=list(date)
    if profile=='dm5' and isinstance(values[0],int) and values[0]<1000:
        values[0]=f'{values[0]:04d}'
    return invocation(profile,values)

cases=[]
def add(case_id,partition,category,profile,portable_request,invocations,
        independent=None,setup=None,disposition='portable-observation'):
    cases.append({'case_id':case_id,'operation_id':'calendar.weekday',
      'partition_id':partition,'category':category,'profile':profile,
      'binding':BINDINGS[profile],'setup':setup or {},
      'portable_request':portable_request,'invocations':invocations,
      'independent_expectations':independent or [],'disposition':disposition})

# Each documented weekday number, using seven consecutive civil dates.
for profile in PROFILES:
    for day in range(9,16):
        date=[2040,4,day]; expected=iso(date)
        add(f'WD-P1-{profile.upper()}-{expected}','calendar.weekday.p1','weekday',profile,
            {'civil_dates':[date]},[valid_invocation(profile,date)],
            [{'civil_date':date,'weekday':expected}])

# The Gregorian calendar has fourteen year types: common/leap crossed with the
# seven possible weekdays of January 1. Pick the first example in 2000..2399 and
# observe both sides of each year's transitions.
year_types={}
for year in range(2000,2400):
    key=('leap' if calendar.isleap(year) else 'common',dt.date(year,1,1).isoweekday())
    year_types.setdefault(key,year)
assert len(year_types)==14
for profile in PROFILES:
    for (kind,start_weekday),year in sorted(year_types.items()):
        dates=[[year-1,12,31],[year,1,1],[year,12,31],[year+1,1,1]]
        label=f'{kind.upper()}-JAN1-{start_weekday}'
        add(f'WD-P2-TYPE-{profile.upper()}-{label}','calendar.weekday.p2','gregorian-year-type',profile,
            {'year_type':kind,'january_1_weekday':start_weekday,'civil_dates':dates},
            [valid_invocation(profile,date) for date in dates],
            [{'civil_date':date,'weekday':iso(date)} for date in dates])

# Leap, non-leap century, leap-century, and supported endpoint controls.
controls={
 'LOWER-ENDPOINT':[[1,1,1],[1,12,31],[2,1,1]],
 'EARLY-LEAP':[[4,2,28],[4,2,29],[4,3,1]],
 'CENTURY-1900':[[1900,2,28],[1900,3,1]],
 'CENTURY-2000':[[2000,2,28],[2000,2,29],[2000,3,1]],
 'CENTURY-2100':[[2100,2,28],[2100,3,1]],
 'CENTURY-2400':[[2400,2,28],[2400,2,29],[2400,3,1]],
 'UPPER-ENDPOINT':[[9998,12,31],[9999,1,1],[9999,12,31]],
 'NUMERIC-YEAR-40':[[40,1,1],[40,2,29],[40,12,31]],
}
for profile in PROFILES:
    for label,dates in controls.items():
        add(f'WD-P2-CONTROL-{profile.upper()}-{label}','calendar.weekday.p2','gregorian-control',profile,
            {'control':label.lower().replace('-',' '),'civil_dates':dates},
            [valid_invocation(profile,date) for date in dates],
            [{'civil_date':date,'weekday':iso(date)} for date in dates])

# Field values for which these low-level calls document no validation guarantee.
invalid_fields=[
 ('MONTH-ZERO',[2040,0,15]),('MONTH-13',[2040,13,15]),('MONTH-NEG1',[2040,-1,15]),('MONTH-FRACTION',[2040,1.5,15]),
 ('DAY-ZERO',[2040,1,0]),('DAY-NEG1',[2040,1,-1]),('DAY-32',[2040,1,32]),('DAY-FRACTION',[2040,1,1.5]),
 ('COMMON-FEB29',[2041,2,29]),('LEAP-FEB30',[2040,2,30]),('APRIL31',[2040,4,31]),
 ('YEAR-ZERO',[0,1,1]),('YEAR-NEG1',[-1,1,1]),('YEAR-10000',[10000,1,1]),('YEAR-FRACTION',[2040.5,1,1]),
 ('YEAR-EMPTY',['',1,1]),('MONTH-EMPTY',[2040,'',1]),('DAY-EMPTY',[2040,1,'']),
 ('YEAR-NONNUMERIC',['year',1,1]),('MONTH-NONNUMERIC',[2040,'month',1]),('DAY-NONNUMERIC',[2040,1,'day']),
 ('YEAR-ABSENT',[None,1,1]),('MONTH-ABSENT',[2040,None,1]),('DAY-ABSENT',[2040,1,None]),
]
for profile in PROFILES:
    for label,values in invalid_fields:
        add(f'WD-P3-FIELD-{profile.upper()}-{label}','calendar.weekday.p3','invalid-field',profile,
            {'field_case':label.lower().replace('-',' '),'civil_date_fields':values},
            [invocation(profile,values)],disposition='observed-compatibility')

# Missing and extra positional fields are binding-specific shapes.
for profile in PROFILES:
    raw_lists=([ ],[2040],[2040,2]) if profile=='base' else ([],[2],[2,29])
    labels=('ALL','AFTER-FIRST','AFTER-SECOND')
    for label,args in zip(labels,raw_lists):
        inv={'carrier':'date-list','value':args} if profile=='base' else {'carrier':'functional-fields','arguments':args}
        add(f'WD-P3-MISSING-{profile.upper()}-{label}','calendar.weekday.p3','missing-field',profile,
            {'field_case':'missing '+label.lower().replace('-',' '),'provided_fields':args},[inv],
            disposition='observed-compatibility')
    values=[2040,2,29]
    inv=invocation(profile,values)
    if profile=='base': inv['value']=[2040,2,29,17]
    else: inv['arguments']=[2,29,2040,17]
    add(f'WD-P3-EXTRA-{profile.upper()}','calendar.weekday.p3','extra-field',profile,
        {'field_case':'one extra positional field','provided_fields':inv.get('value',inv.get('arguments'))},[inv],
        disposition='observed-compatibility')

# Base carrier shapes and functional single-carrier mistakes.
for carrier in ('omitted','undefined','text','mapping'):
    add(f'WD-P3-CARRIER-BASE-{carrier.upper()}','calendar.weekday.p3','invalid-carrier','base',
        {'carrier':carrier},[invocation('base',[2040,2,29],carrier)],disposition='observed-compatibility')
add('WD-P3-CARRIER-BASE-EXTRA-METHOD-ARG','calendar.weekday.p3','extra-method-argument','base',
    {'carrier':'date list plus an extra method argument','civil_date_fields':[2040,2,29]},
    [invocation('base',[2040,2,29],extra_method_arguments=['ignored'])],
    disposition='observed-compatibility')
# Explicit short-year configurations.  Independent expectations are attached
# only where the public legacy configuration defines the resolved full year.
short_cases=[
    ('dm6','C20-40','c20','40',40),('dm6','WINDOW89-40','89','40',40),
    ('dm6','C20-00','c20','00',None),('dm6','C19-40','c19','40',None),
 ('dm5','C20-00','c20','00',2000),('dm5','C20-40','c20','40',2040),('dm5','C20-99','c20','99',2099),
 ('dm5','C19-40','c19','40',1940),('dm5','C2000-40','c2000','40',2040),
 ('dm5','WINDOW89-50','89','50',2050),('dm5','WINDOW89-51','89','51',1951),
    ('dm5','C-40','c','40',2040),
 ('dm5','LENGTH1-4','c20','4',None),('dm5','LENGTH3-040','c20','040',None),
]
for profile,label,rule,short,resolved in short_cases:
    values=[short,3,1]
    # invocation() receives canonical year/month/day and reorders functional fields.
    independent=[]
    if resolved is not None and 1<=resolved<=9999:
        independent=[{'civil_date':[resolved,3,1],'weekday':iso([resolved,3,1]),'resolved_year':resolved}]
    add(f'WD-P3-SHORT-{profile.upper()}-{label}','calendar.weekday.p3','short-year',profile,
        {'short_year':short,'month':3,'day':1,'short_year_rule':rule},
        [invocation(profile,values)],independent,{'short_year_rule':rule},
        'documented-short-year' if profile=='dm5' and resolved is not None else 'observed-compatibility')

manifest={'schema_version':1,
 'status':'original public-call research requests; not BDD execution or semantic approval',
 'reference':{'distribution':'Date-Manip','version':'7.00','timezone':'Etc/UTC','language':'English','forced_clock':'2040-02-28T10:20:30Z'},
 'operation_id':'calendar.weekday','bindings':[BINDINGS[p] | {'profile':p} for p in PROFILES],
 'year_type_representatives':[{'kind':kind,'january_1_weekday':weekday,'year':year} for (kind,weekday),year in sorted(year_types.items())],
 'cases':cases}
OUT.parent.mkdir(parents=True,exist_ok=True)
OUT.write_text(json.dumps(manifest,indent=2,sort_keys=True,ensure_ascii=False)+'\n')
print(f'wrote {len(cases)} cases')
