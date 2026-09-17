# Year/day conversion reference family

This family records 40 original public-call cases for
`calendar.day-of-year` and `calendar.date-from-day-of-year` against the pinned
Date-Manip 7.00 dependency. It covers Base forward and inverse forms, current
and legacy functional forward forms, and both documented functional inverse
wrappers. It does not call a private helper.

The nearby `day-ordinal-family` concerns localized day-of-month suffix text.
It does not exercise conversion between a civil date and its ordinal position
inside a year, so none of these cases duplicates that family's operation.

## Fixed reference profiles

Every case starts with the corresponding complete configuration from
`docs/automation/reference-profiles.json`. The current profiles reset defaults,
fix the clock to `2040-02-28 10:20:30` in `Etc/UTC`, select English/ASCII/US
input, and fix calendar and business settings. The legacy profile additionally
ignores global and personal configuration and fixes `TZ=Etc/UTC`. The two
short-year cases append `YYtoYYYY=C19`; no other case changes its fixture.

Each of the 40 case/profile pairs was executed twice in independent processes
and fresh temporary directories with only `PATH=/usr/bin:/bin`, the pinned
`PERL5LIB`, `TZ=Etc/UTC`, `LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`. Four workers ran
independent cases, each with a 15-second timeout. The two attempts were byte
equal before JSON decoding. `observations.json` retains every call's completion
flag, native return only after completion, warnings, exception, captured stdout,
and setup/observer results. The probe process itself produced no stderr.

The observed runtime is Perl v5.40.1 on
`x86_64-linux-gnu-thread-multi`. Public metadata reports distribution version
7.00, current backend version 7.00, legacy backend version 5.66,
`tzdata2026c`, and `tzcode2026c`. The evidence hashes the manifest, probe,
runner, canonical contract and API map, reference profile, and every relevant
installed source/POD file.

## Reviewed behavior

Independent Gregorian checks confirm all normal civil facts: 2039 is common,
2040 is leap, ordinal 60 is 2039-03-01 but 2040-02-29, and year-end ordinals are
365 and 366. Noon contributes exactly one half-day. The recorded
`60.500005787037` forward result is the native floating representation of noon
plus one half-second; the inverse presents the decimal second as `0.50`.

The functional inverse wrappers agree on their six list fields. Their Perl
scalar contexts differ for binding reasons: DM6 returns the assignment count
`6`, while DM5 returns the final seconds field. These carriers are excluded
from portable features.

Several public outcomes conflict with the documented civil domain and remain
tagged `disputed`:

- Base performs no bounds validation for inverse ordinals. Common-year 366 and
  leap-year 367 produce month 13; zero and negative ordinals produce day 0 and
  day -1.
- DM6 exposes the same unchecked Base result for common-year ordinal 366,
  while DM5 returns no fields as documented.
- Base returns ordinal 60 for the nonexistent 2039-02-29.
- With `YYtoYYYY=C19`, DM6 treats text `00` directly as year zero and returns
  61 for March 1; DM5 resolves it to 1900 and returns 60.
- Omitted DM5 inverse arguments default to the fixed reference year and first
  day, whereas DM6 emits warnings and returns a non-civil field collection.

These observations do not bless impossible dates as portable behavior.
Portable features retain normal conversions and the legacy failure at the
documented upper bound. The disputed feature preserves exact compatibility
evidence. Missing/nonnumeric field warnings and all native scalar/list carriers
remain in the excluded Perl binding feature.

## Branch-based disposition

The finite branch inventory exercised here is:

- Base one-argument forward versus two-argument inverse dispatch;
- forward date-only versus date-time fraction, and the month-after-February
  leap adjustment;
- inverse integral versus decimal-text result shape, month scan from January
  through December, and decimal-second formatting;
- DM6 inverse padding of a three-field integral result to six fields;
- DM5 false-year and absent-day defaults, four-digit versus short-year repair,
  lower-bound and common-year upper-bound rejection, leap/common maximum,
  fractional clock extraction, and the month-consumption loop;
- scalar and list Perl contexts, completed undefined and empty-list carriers,
  warning-free and warning-producing calls, and Base error reads around calls.

Remaining finite domains are deliberately narrower: a scientific-notation
ordinal whose text has no decimal point, an explicit empty year/day distinct
from omitted and absent values, a valid supported endpoint year, a fractional
value close enough to midnight for platform rounding to carry, and extra-arity
Perl calls. Those are binding/precision partitions rather than another normal
Gregorian month or ordinal class. A future batch should also decide whether
the documented invalid bounds are corrected upstream before promoting any
disputed reference behavior.

## Reproduction and checks

```text
python3 tools/probes/year-day-conversion-family/run.py > /tmp/year-day.json
cmp /tmp/year-day.json docs/research/year-day-conversion-family/observations.json
python3 tools/probes/year-day-conversion-family/review.py
PERL5LIB=local/bdd-runner/lib/perl5 perl tools/runner-trial/parse-features.pl spec/drafts/year-day-conversions/*.feature
```

These are research and syntax checks. They are not executed BDD scenarios and
do not establish full-library coverage.
