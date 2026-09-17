# Behavioral partition catalogue

This is the case-design worklist, not an implemented or fully enumerated suite.
For each item, enumerate actual supported values from the pinned reference, then
choose independently authored inputs and record literal observed outputs. A heading
cannot count as coverage. Each accepted case becomes Gherkin, with its API mapping
kept on the research side.

## Universal dimensions

For every operation: minimal/typical/maximal valid input; omitted, absent, empty and
malformed input; wrong kind; defaults and overrides; output shape; errors and recovery;
observable state before/after. At numeric/domain limits test immediately below,
at, and immediately above the boundary. A method's internal branch suggests a
partition; do not turn its algorithm into the test's expected-value computation.

## Capability obligations

| Family | Partitions and exact questions to resolve |
| --- | --- |
| Calendar validity | Earliest/latest supported years, year zero and negative years, century/400-year rules, every month length, invalid day/month, time-field limits, leap-second acceptance and representation |
| Calendar properties | All weekdays, year ordinal/inverse including fractional ordinals, civil-day origin, negative/pre-epoch values, nth weekday including absent fifth occurrence, all supported first-weekday/week-one rules |
| Absolute date parsing | Each ISO/calendar/ordinal/week-date production, basic/extended and partial forms, each common/uncommon grammar, weekday consistency, timezone suffixes, date-only/time-only/combined inputs |
| Relative parsing | now/today/tomorrow/yesterday, relative weekdays, explicit offsets, holidays and named dates, rollover across month/year/DST; fixed current clock is mandatory |
| Ambiguous/default parsing | Numeric day/month ordering; two-digit-year window endpoints and century modes; missing date/time fields; default time; period separator; month/year shorthand; parser-family disabling options |
| Token input | All tokens consumed, valid prefix with trailing tokens, no match, empty tokens, array versus text, ambiguous token boundaries; remaining-token order and whether failures mutate input |
| Text/language | Every supported language module (16 language implementations plus the index at this release), aliases, accents, case, separators, month/day/unit vocabulary, language switching and encoding errors; never copy the language module tables |
| Pattern parsing | Each supported directive and combination, literals/escapes, partial patterns, inconsistent fields, trailing text and unsupported directives |
| Date formatting | Every directive, modifier and composite expansion; local/UTC/zone data, weekday/year boundaries, ordinal language, multiple formats and return ordering, POSIX mode versus native mode, unknown directives |
| Intervals | Every accepted compact/text notation, omitted fields, fractional units, signed and mixed-sign fields, normalization on/off, every type/mode, unsupported combinations, formatting units and precision |
| Arithmetic | Date±interval, date−date, interval±interval; exact/semi/approximate/estimated/business modes as supported; type inference ambiguity in legacy calls; month-end clamp/roll rules; leap days; sign and reversibility limits |
| Comparison | Equal/earlier/later, same instant in different zones, incomplete/invalid values, mixed interval types, context dependence, whether comparison mutates or reports an error |
| Navigation/field updates | Strict versus inclusive next/previous, each weekday predicate, count zero/negative where accepted, time preservation, invalid field changes, state after failed update |
| Epoch conversion | Zero, before zero, after zero, local versus UTC origin, signed/large values, 2038 boundary and supported range, timezone offset and daylight changes |
| Zone resolution | Canonical names, aliases, abbreviations, numeric offsets and sign conventions, unknown/ambiguous identifiers, custom definitions/overwrites, candidate ordering and preference |
| Zone transitions | Just before/at/after transitions, spring gaps, repeated autumn times, explicit DST preferences, half-/quarter-hour offsets, second-level historical offsets, skipped dates, historical/future rules with pinned dataset |
| Zone discovery | Explicit context versus environment/OS methods, missing/bad environment, precedence; separate deterministic injected-environment cases from host integration checks |
| Business days | Workweek bounds, nonstandard weekends, full-day versus working-hours mode, open/close endpoints, non-working starting date, zero/positive/negative movement, nearest-day tie, multiple consecutive holidays |
| Business durations | Workday-hour units, crossing lunch/non-working periods if supported, weekends and holidays, exact versus approximate modes, partial business days, DST interactions; observe what the library actually supports |
| Holidays | Fixed/recurring definitions, names, observance shifts, multiple same-day holidays, clear/replace/merge, date lookup, query ranges and return shape |
| Events | Single/ranged/repeated definitions, overlapping events, boundaries and clipping, labels, ordering/duplicates, all query modes, clearing and context isolation |
| Recurrence grammar | Each period/selection layout and accepted notation, positive/negative ordinals, missing anchor, requested/effective base, implicit-range settings, modifier order/replacement/appending and invalid syntax |
| Recurrence enumeration | Empty/single/multiple result, endpoints exactly on occurrence, pre/post-modifier bounds, finite truncation, nth/next/prev inclusion, out-of-range indices, invalid/no-match distinction, MaxRecurAttempts behavior |
| State/lifecycle | Constructor variants, new versus shared context, copy then override, partial date/time updates, original-input retention, valid→invalid→valid recovery, changing recurrence frequency, reading unset values |
| Configuration | Every named key, accepted values/ranges, invalid/unknown key, case/encoding, precedence, repeated changes, query results, file/environment/default sources, deprecated settings and warnings |
| Metadata/data access | Type/version queries, timezone code/data identifiers, period enumeration; distinguish reference metadata from portable capabilities |
| Errors/resources | Return/error/warning/exception channels, no-result versus failure, invalid grammar and overlarge inputs; explicit finite time/input budgets rather than encoding hangs as expected success |

## Configuration inventory to expand

The 7.00 Config POD names: `Defaults`, `ConfigFile`, `Language`, `Encoding`,
`FirstDay`, `Week1ofYear`, `Printable`, `DateFormat`, `YYtoYYYY`, `DefaultTime`,
`PeriodTimeSep`, `Format_MMMYYYY`, `WorkWeekBeg`, `WorkWeekEnd`, `WorkDay24Hr`,
`WorkDayBeg`, `WorkDayEnd`, `TomorrowFirst`, `EraseHolidays`, `EraseEvents`,
`RecurRange`, `MaxRecurAttempts`, `SetDate`, `ForceDate`, `Use_POSIX_Printf`,
`TZ`, and `Jan1Week1`. Reconcile these with configuration parsing, config-file
sections, holiday/event definitions and runtime access; this list is not proof
that every key has the same status in both backends.

Every setting needs a generic name/meaning or a binding-only disposition. Avoid
one global fixture that accidentally hides the effect of a setting being tested.
Treat moving-clock (`SetDate`) and frozen-clock (`ForceDate`) behavior separately.

## Essential interaction matrix

| Combination | Why single-axis tests are insufficient |
| --- | --- |
| DST × exact elapsed/calendar/business arithmetic | One calendar day may differ from 24 elapsed hours |
| Week-one rule × first weekday × year boundary | Week number and week year can diverge from civil year |
| Language × grammar × ambiguous numeric order | Configuration changes accepted syntax and meaning |
| Current clock × two-digit window × omitted fields | Hidden moving defaults cause changing results |
| Recurrence × modifier order × range boundaries | Shifting an occurrence may move it into/out of range |
| Holiday × working hours × zero offset | “Next” may preserve or advance depending on starting state |
| Zone alias/abbreviation × date × DST preference | Resolution can change with time and ambiguity policy |
| Shared context × mutation × parse failure | Earlier calls can change later results |
| Scalar/list/token form × invalid input | Equivalent-looking Perl calls can differ in outputs and side effects |

Use systematic combinations after enumerating each dimension; do not take a full
Cartesian product by default. Explain pairwise sampling and add higher-order cases
where source observations or domain rules indicate interactions.

## Case lifecycle and coverage metrics

Use `discovered → designed → observed → reviewed → specified → implemented → passing`.
Alternative explicit states are `disputed`, `unsupported`, `binding-only`,
`indirectly-covered`, and `excluded-with-reason`. Retain history when a case changes.

Track public contract variants, input partitions, directives/options, supported
languages, config settings, recurrence rule classes and backend profiles separately.
Record scenario/row IDs for each. Preserve the original denominator and show exclusions
and skips; “all passing” is not equivalent to “all functionality specified.”
Property checks (e.g. round trips on a proven-safe domain) and fuzzing can find missing
cases later; promote concrete discoveries into explicit English scenarios. They
supplement the feature set rather than replacing the required literal examples.
