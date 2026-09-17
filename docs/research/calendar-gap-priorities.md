# Calendar behavior gap priorities

This is a read-only semantic audit of the calendar contract and the accepted
leap-year, calendar-length, week-count, and weekday research families. It
distinguishes inputs that select a different observable implementation branch
from inputs that merely enumerate more points in arithmetic already covered.
Private implementation was inspected only to choose public requests. Every
recommended observation must use the public bindings in
`docs/research/contracts/calendar.json`.

The contract status fields currently lag the accepted evidence: the four
families below still appear as `unobserved` in `calendar.json`. This audit uses
their reviewed manifests and observations as the evidence of record; it does
not treat the stale status labels as behavioral gaps.

## Accepted families

### Leap-year classification needs no larger valid-year batch

`docs/research/leap-year-family/` exercises all 400 residues of the Gregorian
cycle through all three public routes, plus supported endpoints, external
century controls, short-year configuration forms, and selected malformed
values. The Base implementation has only the divisible-by-4, divisible-by-100,
and divisible-by-400 decision at
`local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm:427-431`. The legacy route
expresses the same three decisions at
`local/date-manip-7.00/lib/perl5/Date/Manip/DM5.pm:3297-3304`; its additional
observable branch is short-year resolution at `DM5.pm:5442-5470`, already
sampled across `C`, `C19`, `C20`, `C2000`, numeric windows, and their threshold
suffixes.

Calling every year from 0001 through 9999 would repeat the same 400-year
residues. More two-digit suffixes within a fixed short-year window are likewise
linear repetitions unless they cross the selected window boundary or change
leap class. Signed numeric text, whitespace, scientific notation, references,
NaN, and infinity can reveal coercion or exception behavior. They are lower
priority than untouched public operations, not approved exclusions. Any distinct
public behavior they expose still needs a test or an evidenced scope disposition.

### Month and year lengths have their valid branches represented

`docs/research/calendar-lengths-family/` covers every month in one common and
one leap year on Base, DM6, and DM5; Gregorian century controls; Base and facade
month-zero carriers; short-year windows; and selected invalid inputs. The Base
month operation has exactly three semantic paths: false month returns all
months, February consults leap classification, and every other month follows
the alternating-month arithmetic (`Base.pm:442-452`). Year length is only a
leap-result choice (`Base.pm:434-436`). DM6 delegates directly
(`DM6.pm:793-800`). DM5 adds array indexing and short-year conversion
(`DM5.pm:3166-3172`, `3264-3269`), both already observed.

More valid years add no month/year-length branch beyond leap classification.
More `YYtoYYYY` forms would duplicate the leap-year family unless a chosen
suffix changes common versus leap classification. Larger out-of-range numbers
and malformed native carriers are compatibility fuzzing. No further public
length batch is recommended before untouched calendar operations.

### Weekday valid-date enumeration is already redundant

`docs/research/weekday-family/` observes all seven results, all fourteen
common/leap and January-1-weekday year types, both sides of year transitions,
Gregorian century controls, endpoints, short-year rules, and malformed field
shapes on all three routes. Base weekday arithmetic is branchless except for
mapping numeric zero to Sunday (`Base.pm:415-424`). DM6 only repackages public
arguments (`DM6.pm:760-763`). DM5 adds short-year resolution and derives the
weekday from its ordinal arithmetic (`DM5.pm:3175-3184`).

Enumerating every date or adding more representatives of a fourteen-type year
does not exercise a new conditional. The full invalid-field Cartesian product
would measure coercion combinations in a helper that deliberately performs no
validation. Invalid civil-date semantics belong in `calendar.validate-date`;
additional reference and Unicode-number kinds need a binding compatibility audit
before disposition. No further valid weekday batch is recommended now.

### Configured week counts need one small edge/state batch

`docs/research/week-count-family/` already crosses all 105 valid
`FirstDay`/`Week1ofYear` settings with the fourteen Gregorian year types. This
covers the `janN`, `dowN`, and `firstday` rule families
(`Base.pm:641-651`), forward and backward weekday adjustment
(`Base.pm:657-677`), the input classes that drive the four current/next-year
boundary adjustments in the count (`Base.pm:691-706`), and both 52- and
53-week results. Its repeated read
also exercises the same-key cache return at `Base.pm:688-689`.

The remaining direct-operation gap is narrow and observable:

- supported endpoint years `1` and `9999`; year `9999` is distinctive because
  the calculation requests the next year's week start at `Base.pm:692-693`;
- omitted, explicitly absent, nonnumeric, fractional, zero, negative, and
  `10000` years, because `weeks_in_year` itself performs no range validation;
- a reused public Base service configured A, then B, then A for the same year,
  proving that the configuration-keyed cache does not leak the first count;
- one invalid `FirstDay` and one invalid `Week1ofYear` attempt followed by a
  direct `weeks_in_year` read, preserving the prior valid state. The generic
  invalid-configuration retention behavior is already observed in
  `docs/research/week-rules-edges/`; only its direct effect on this public
  operation is missing.

A 14-18 request batch under the default rule plus one configuration sequence is
enough. Crossing all 105 configurations with every invalid year or repeating a
full 400-year cycle would not close another identifiable branch.

## Recommended new public-call batches

The following batches close currently untouched contract partitions more
efficiently than expanding the four accepted matrices.

### Priority 1: civil date and time validation

Cover `calendar.validate-time` and `calendar.validate-date` together through
public `Date::Manip::Base->check_time` and `->check`. This is a compact,
high-branch family: `check_time` has a field-shape regular expression, upper
limits, and the special `24:00:00` condition (`Base.pm:616-623`); `check` adds
year and month bounds and a month-dependent final-day check
(`Base.pm:602-613`).

A bounded 28-36 request manifest should include:

- `00:00:00`, one-digit numeric text, `23:59:59`, and `24:00:00`;
- `24:00:01`, `24:01:00`, hour 25, minute/second 60, negative, fractional,
  whitespace, nonnumeric, missing, extra, and explicitly absent fields;
- dates `0001-01-01`, `9999-12-31`, common/leap February 28/29, and a 30-day
  month boundary;
- year 0/10000, month 0/13, day 0/month-end+1, and valid dates paired with the
  invalid clock boundaries.

These calls close real validation branches. Time zones and DST should remain
out of this family because the documented operation intentionally validates
GMT-style civil fields without zone resolution.

### Priority 2: day-of-year forward, inverse, and functional conversion

Cover `calendar.day-of-year` and `calendar.date-from-day-of-year` in one family.
Base selects inverse versus forward by argument count (`Base.pm:463-471`),
integral versus fractional inverse by the presence of a decimal point
(`Base.pm:473-494`), and date-only versus date-time forward by whether the hour
is present (`Base.pm:496-505`). DM6's public `Date_NthDayOfYear` wrapper changes
the Base array reference into six list fields (`DM6.pm:786-790`). DM5 has
distinct defaults, explicit bounds, fractional clock extraction, and a
month-consumption loop (`DM5.pm:3713-3750`).

A 30-40 request batch should use common and leap years and select ordinals 1,
59, 60, 365, and 366; fractions `1.5` and a value with nonintegral seconds;
forward date-only and date-time calls around February; inverse round trips; and
0, negative, upper-bound, omitted, absent, and nonnumeric requests. Add only
the short-year controls that discriminate DM5 conversion from DM6 direct
arithmetic. Enumerating every ordinal would merely repeat the month scan.

### Priority 3: ordinal weekday occurrence

Cover public `Date::Manip::Base->nth_day_of_week` for
`calendar.nth-weekday`. Its meaningful branches are month versus whole year,
positive versus negative search origin, first/last versus later occurrence,
and absent occurrence (`Base.pm:513-565`). A roughly 24-request batch can cover
`1`, `2`, `5`, `-1`, `-2`, and `-5` in February and a 31-day month; `1`, `53`,
`-1`, and `-53` for a whole year; one existing and one absent fifth weekday;
and zero, ±limit+1, weekday 0/8, month 0/13, omitted, absent, and nonnumeric
fields. All seven weekdays need not be crossed with every occurrence because
they enter the same offset comparison at `Base.pm:543-547`.

### Priority 4: projected-calendar day ordinal

Cover `calendar.day-ordinal` through public Base forward/inverse and the DM6 and
DM5 functional routes. Base has separate collection and scalar inverse paths
at `Base.pm:387-410`, including a correction branch for an initially negative
inverse remainder at `Base.pm:400-404`. The public functional wrappers are at
`DM6.pm:776-779` and `DM5.pm:3221-3250`.

A 20-28 request batch should include day 1 and its inverse, the last day around
common/leap and century transitions, one ordinary forward/inverse round trip,
the supported year endpoints, zero/year-0000 compatibility, negative and
fractional ordinals, malformed date collections, invalid civil fields, and
DM5/DM6 short-year controls. More ordinary dates are linear repetitions of the
same projected-calendar formula.

### Priority 5: direct week-year start, then week-count edges

The week-count matrix indirectly traverses week-start logic, but it does not
specify the public `calendar.week-year-start` result. Observe public
`Date::Manip::Base->week1_day1` for one `janN`, one `dowN`, and `firstday`
setting, with FirstDay 1 and 7 and years whose returned start stays in January
or falls in December. The public entry is `Base.pm:626-630`; the three rule
families and preceding-year adjustment are at `Base.pm:641-677`. About 10-14
requests are sufficient because the complete 105-setting behavioral matrix is
already exercised through week counts. Follow this with the 14-18 direct
week-count edge/state requests described above.

## Lower priorities and exclusions

- Do not expand leap-year, length, or weekday valid inputs solely to increase a
  scenario or date percentage. Their arithmetic equivalence classes are
  already represented.
- Do not cross every malformed field with every profile or valid week rule.
  Select one request per distinct completion, return, warning, exception, or
  retained-state behavior and keep Perl-only diagnostics in excluded binding
  features.
- `calendar.week-number` already has a large valid matrix and a separate edge
  corpus. Its remaining arbitrary magnitudes, full invalid Cartesian products,
  and every configuration/date cross-product should be reviewed for distinct
  outcomes rather than automatically enumerated or silently excluded.
- The three `epoch.*` operations in `calendar.json` require timezone and, for
  the object setter, mutation analysis. They should be prioritized in an epoch
  family rather than inferred from calendar arithmetic.
- Adapter execution and portable approval remain lifecycle obligations even
  when a research partition has no additional semantic input class. This audit
  does not convert research observations into passing BDD tests.
