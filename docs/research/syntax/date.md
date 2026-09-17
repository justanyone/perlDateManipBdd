# Date and time syntax inventory

This is an original, finite research inventory for Date-Manip 7.00. It records public spellings and source-visible routing without importing upstream examples, fixtures, prose, regular expressions, or data tables. It is not a passing test report: no runtime observations have been taken.

The machine-readable source is [date.json](date.json). `DM6` means the 7.00 object/reference backend. `DM5` means the bundled 5.66 compatibility backend. A profile appearing on a row identifies a probe target; it does not assert support. `dm5_row_status` in the JSON is the authoritative per-row support gate and links to the detailed [date-dm5.json](date-dm5.json) source/POD audit. Controlled runtime observations remain pending.

## Rendering

The default renderer has 32 atomic data directives: `%Y %y`, `%m %f %b %h %B`, `%j %d %e %v %a %A %w %E`, `%H %k %i %I %p`, `%M %S %Z %z %N`, `%s %o`, and `%G %W %L %U %J`. The JSON gives every directive’s field, domain, padding, source location, and profile status.

There are 18 composite directives, all with a fixed expansion except `%x` (which follows `DateFormat`) and `%l` (which depends on a six-month window around the reference instant): `%c %C %u %g %D %x %l %r %R %T %X %V %Q %q %P %O %F %K`.

Four literal directives are `%n`, `%t`, `%%`, and `%+`. The seven extended renderer forms are `%<A=1..7>`, `%<a=1..7>`, `%<v=1..7>`, `%<B=1..12>`, `%<b=1..12>`, `%<p=1..2>`, and `%<E=1..53>`. An out-of-domain extended form is retained text; an unknown one-character directive emits its following character; a final percent is dropped. Those are source findings awaiting behavioral observations.

With `Use_POSIX_Printf`, twelve tokens change meaning: `%C %F %l %P %u %G %g %W %V %L %U %J`. The POSIX forms `%c %x %X %E %O %+` remain the Date::Manip meanings because the documented POSIX forms are unsupported. These are separate test partitions, not aliases.

## Explicit-pattern parsing

`parse_format` accepts the finite list in `pattern_parsing.accepted_directives` of the JSON. It shares data tokens and fixed composites with rendering, but it does not accept `%l`, `%n`, or renderer-only `%<...>` forms. A pattern is a regular expression with these special tokens expanded before matching. The reviewed pattern-expansion source has no `Use_POSIX_Printf` branch, so its documented default expansions need a focused configuration observation before claiming cross-mode behavior.

Its public shape rules are also finite: date requires both month and day; a time requires hour and minute; meridiem requires hour; `%G` pairs with `%W`; `%L` pairs with `%U`; and duplicate logical fields are rejected. The accepted field sets are date, date-plus-minute precision time, date-plus-second precision time, minute precision time, and second precision time, with the stated optional year, zone, and weekday fields. Pattern caching means `%x` must be configured before first use.

## Text-date and text-time grammar

The JSON carries stable IDs and every production spelling. The counts below are counts of inventory records, rather than a misleading claim that every variable production has already been observed.

| Area | Records | What is enumerated |
|---|---:|---|
| Default atomic rendering | 32 | Every one-character data directive, with aliases kept distinct |
| Composite/literal/extended rendering | 3 | 18 composites, four literals, seven extended forms |
| POSIX behavior | 13 | 12 semantic overrides and one unsupported-token group |
| Parser options | 7 | Each public grammar gate |
| Text grammar | 20 | ISO, common, other, special, combined, epoch, now, and zone productions |

Across those records there are 61 rendering spellings (including composite, literal, and extended forms), 52 pattern directives, 167 explicitly listed text-production spellings, and seven parser-option gates. POSIX mode changes meanings for 12 existing spellings; it does not add another directive alphabet.

ISO complete-date spellings are listed in `DATE.GRAMMAR.ISO.DATE.COMPLETE`; truncated ISO date spellings are listed separately. The inventory retains the documented DM6 change: a two-digit standalone ISO date is a century, six compact digits are `YYMMDD`, and partially dashed ISO layouts are not accepted. The corresponding DM5 rows are classified as different in the companion audit because DM5 has its own flexible-dash layouts.

Common-date records split numeric, named-separated, named-joined, and configurable month-year forms, so every displayed production is finite. Their separator, DateFormat, Format_MMMYYYY, localization, and civil-validity partitions are explicit. Other date records similarly separate weekday, ordinal month, ordinal year/week, relative unit, and special/holiday productions.

Time records separate complete/truncated ISO, other numeric/meridiem, and special time words. Combined records separately cover ISO composition, non-ISO composition including permitted delta combinations, epoch, now, and zones. The zone record enumerates all five offset layouts and both optional-abbreviation layouts instead of collapsing them into “numeric offset.”

## Reconciliation and remaining work

`Date.pm` confirms the formatter’s fallback and extended-form behavior, the explicit-pattern field checks, and the distinct internal parser routes. `Date.pod` supplies the public grammar. `DM6.pod` and `DM5.pod` confirm the public facade routes. The inventory does not treat private regular expressions or language/zone data as portable specification.

The next research step is a controlled probe matrix: one original valid input plus each boundary/invalid obligation per record, with fixed timezone, language, configuration, and reference instant. DM5 comparison must run in a separate process. Record literal outcomes in observations, then link reviewed scenario IDs; do not turn this source audit into a pass claim.
