# Proposed portable contract and feature vocabulary

This is original design text. Names identify conceptual operations, not required
function names or classes. Implementations may expose any API that their adapter
can map faithfully to these contracts. Decisions below are proposed for the first
specification version; unresolved semantics must be observed before promotion.

## Value types

| Type | Meaning and boundary |
| --- | --- |
| Civil date | Gregorian year, month and day; no implicit timezone or instant |
| Local time | Hour, minute, second and explicit precision; not a duration |
| Local date-time | Civil date plus wall-clock time; requires a zone/offset and ambiguity policy to identify an instant |
| Zoned date-time | Local fields, zone identifier, effective UTC offset, and resolved occurrence when ambiguous |
| Instant | Position on the UTC timeline; epoch and leap-second convention specified by the operation |
| Calendar interval | Signed years/months/weeks/days and time fields, with explicitly named arithmetic mode; not always reducible to seconds |
| Elapsed duration | Fixed amount of elapsed time, with exact unit and precision |
| Business duration | Interval interpreted using a named working schedule and holidays, with its calculation mode |
| Recurrence | Period/selection rules, anchor, bounds, modifier sequence and boundary policy |
| Context | Language, input ordering, reference clock, zone, week rules, business rules and remaining named options |
| Outcome | Success with a typed value, no-match where defined, or failure with a stable category; may also contain remaining input and state changes |

Do not assume positivity or a single sign for every interval. Preserve separate
fields and normalization mode until the relevant mixed-sign rules are characterized.
Specify conversion/estimation explicitly when calendar units cannot be exact.

## Notation in features

- Display civil dates as `YYYY-MM-DD`, wall times as `HH:MM:SS`, and combined local
  values as `YYYY-MM-DD HH:MM:SS`. These are fixture encodings, not claims that every
  parser accepts only those forms. State the zone separately. Instants may use
  `YYYY-MM-DDTHH:MM:SSZ` once supported by the relevant contract.
- Month and day-of-month are one-based. Weekdays use English names in features.
  Do not assume week numbers follow calendar years; represent both week year and
  week number when the operation supplies them. Legacy raw week numbering is a
  distinct contract until its relationship has been observed.
- Compare fixed integral fields exactly. Fractional quantities use explicit decimal
  text and a specified rounding/precision rule; do not add a blanket float tolerance.
  Dates near year limits, leap seconds and fractional truncation need dedicated rules.
- Step tables have named columns and explicit units. Missing fields mean omitted,
  never automatically zero. For tests of omission/emptiness use a `presence` column
  (`omitted`, `present`, `absent-value`) and separate `text`, not a magic string that
  makes literal user input unrepresentable. Empty collections have count zero.
- Declare whether a collection is ordered, set-like, or a multiset. Preserve duplicate
  recurrence dates and event ordering until the operation's contract decides otherwise.
- Strings compare exact Unicode code points unless a feature explicitly specifies
  normalization/case handling. ASCII digits, other digit classes, encodings, whitespace,
  escaping and malformed bytes belong in separate input partitions.
- A result described as “no date” is an absent typed value, not empty date text or
  epoch zero. Failed library calls may have empty raw returns; adapters normalize
  using that call's documented/observed error behavior, not universal truthiness.

## Common context fixture used by the examples

For these draft examples, the “selected profile” is the 7.00 reference snapshot
with timezone-data identifier `tzdata2026c` and code identifier `tzcode2026c`.
These names select behavioral data, not a required implementation technology.
The research-side observations record the archive hash and full provenance.

`Given the reference clock is fixed at "2040-02-28 10:20:30" in "Etc/UTC"`
means the clock does not advance, the default zone is UTC, and relative input is
anchored to that civil date/time. The examples additionally choose English input,
midnight for an omitted time, and month-first numeric dates unless a step overrides
that setting. They use Gregorian calendar rules.

`Given the working calendar contains no holidays` clears previous holiday entries.
A working-week table defines allowed weekdays and working hours; a business-day
movement that says “preserving the time” counts dates rather than working hours.
Every promoted feature must state all context that can affect its result, either in
steps or through a fully versioned, human-readable fixture definition.

## Generic operation families

| Request concept | Explicit inputs | Typed outputs |
| --- | --- | --- |
| Interpret date text | text, context, enabled grammar families | date-time or parse failure |
| Interpret leading date tokens | token sequence, context | date-time, consumed count, remaining tokens |
| Interpret with a pattern | text, pattern syntax version, context | date-time or pattern/parse failure |
| Render a date or interval | typed value, format pattern(s), output language/mode | ordered text result(s) |
| Inspect calendar | civil fields, requested property, week rules when relevant | Boolean, integer, weekday, civil value or invalid-input failure |
| Construct/change fields | typed value, named fields, validation/normalization mode | new value and outcome; original-value behavior explicit |
| Compare | two values of an identified kind, comparison mode | before/equal/after, or documented incomparable result |
| Add an interval | date-time, typed interval, calculation mode | resulting date-time |
| Measure separation | from, to, interval type/mode | elapsed, calendar, or business interval |
| Combine/convert intervals | typed intervals, target mode/type, context if needed | typed interval or unsupported conversion |
| Move to a matching date | starting value, weekday/date/time predicates, direction, inclusion | matching value or no-match |
| Change timezone | zoned value, destination, ambiguity policy | zoned value representing the same instant where defined |
| Resolve zone/period | identifier/alias/offset, date/time, preference | canonical zone or candidate periods |
| Define zone names | explicit user-supplied alias/abbreviation/offset records | changed context and validation outcome |
| Query business calendar | date or range, named schedule | working status, holiday labels, next/previous/nearest working value |
| Query events | event definitions, interval and selection mode | ordered occurrence/segment records |
| Enumerate recurrence | structured rule, anchor, bounded interval, modifier order | ordered occurrences and completion/error status |
| Navigate recurrence | rule, index or reference date, direction/inclusion | occurrence or no-match |
| Manage context/value | create, copy, derive with overrides, query kind/status | value/context handles and observable sharing/isolation |

Some legacy interfaces infer operand types from ambiguous text. Retain that as a
separate compatibility operation; core arithmetic accepts explicitly typed operands.
No language is required to emulate call-stack context to choose a return type.

## Recurrence representation needs a dedicated design pass

A seven-field interval alone cannot express the whole recurrence API. The contract
must distinguish advancing periods from field selections, support ordinal and
negative positions where available, preserve modifier order, expose the requested
and effective anchor when observable, and specify whether bounds apply before or
after modification. Enumeration must always have explicit bounds or a finite limit.
Do not simplify recurrence to an ISO repeating interval or cron unless equivalence
has been demonstrated for that rule family.

## Step wording rules

Each `Given` establishes observable context or input, `When` performs the named
operation, and `Then` states a fixed outcome. Avoid “correctly,” “valid result,”
“approximately,” “local time,” or “next day” without defining what those mean.
Keep one behavior per scenario; use a table for multiple fields of one result.
For each outline, `case` is a stable row identifier, not an operand.

Portable feature text does not contain package names, dollar variables, references,
hash layouts, library source paths, or control-flow descriptions from the reference.
Formatting/parser syntax that users supply is allowed as test data. It is the
adapter mapping, not the feature, that specifies the concrete Perl call.
