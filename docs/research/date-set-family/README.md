# Public Date `set` reference observations

This bounded batch characterizes the public `Date::Manip::Date::set` method in
Date-Manip 7.00. It uses the repository's pinned installation with tzdata
`tzdata2026c`, tzcode `tzcode2026c`, Perl v5.40.1, and 108 original concrete
fixtures. The fixed profile is English, ASCII, non-US numeric-date order, UTC
local time, and a clock of 2040-02-28 10:20:30.

Run the batch from the repository root. The candidate is written outside the
repository so reviewed evidence is never replaced implicitly:

```sh
python3 tools/probes/date-set-family/run.py > /tmp/date-set-observations.json
cmp /tmp/date-set-observations.json docs/research/date-set-family/observations.json
python3 tools/probes/date-set-family/review.py
python3 tools/review/feature_structure.py spec/drafts/date-set
```

This source-separation repair changes the features, mapping, and reviewer and
pins PATH to /usr/bin:/bin. The coordinator also made mutation-call completion
explicit: interrupted calls have no returned status fields, rather than a
fabricated undefined return. A fresh twice-isolated capture retained all 108
underlying value/error/warning outcomes. Probe and runner hashes reflect these
recording repairs. Exact native exception prefixes remain binding-only.

The runner launches each attempt in a fresh temporary working directory. It
fixes the locale, timezone, hash seeds, installed-module prefix, and `PATH`. It
uses at most four workers, gives each process 15 seconds, and executes every
case twice. The stored file records hashes for the fixtures, runner, probe,
public documentation, and installed Date, Obj, Base, and TZ modules. All 108
stored cases exited zero, decoded as JSON, matched the fixture hash, and
repeated byte for byte. Per-call exceptions and warnings are part of the
payload; they are not process failures.

The public documentation permits `zone`, `zdate`, `date`, `time`, and the six
individual selectors `y`, `m`, `d`, `h`, `mn`, and `s`. The cases exercise the
documented arities, omitted zone and daylight arguments, both daylight flags,
zero values, invalid arities and selectors, malformed carriers, named zones,
an alias, documented offset representations, unset and error-bearing receivers,
and New York gap and overlap times. `signature-inventory.json` states the exact
forms and separates documented behavior from observed compatibility behavior.

Every record captures configuration return definedness and type, exceptions,
the effective Language/Encoding/DateFormat settings, and error state around
each setup call. A valid receiver is observed in scalar and list context before
`set`; it is deliberately not converted before mutation. Unset and error-bearing
receivers are not value-read before the call because doing so would change their
error precondition. After `set`, the observer order is scalar, list, local, then
GMT. Error state is recorded immediately before and after every observer.

Successful `date` and `zdate` calls can initialize an unset receiver or recover
an error-bearing receiver. `time`, `zone`, and individual-field calls require a
valid receiver. Reported failures clear the stored date. The first following
scalar `value` call returns defined empty text and replaces the call error with
`[value] Object does not contain a date`; list context then returns zero values,
and later converted reads retain the value error. On successful calls, scalar
results are defined, list context returns six fields, and all observer errors
are empty.

The overlap observations distinguish whole replacements from partial changes.
Omitted daylight selection on `zone`, `zdate`, and `date` chooses the standard
side as documented. Omitted selection on `time` and an individual field retains
the daylight side of the tested source receiver. The latter two cases are tagged
`@disputed`. Explicit zero and one choose standard and daylight respectively.
The undocumented value 2 is accepted as truthy in explicit option positions and
is also tagged as compatibility behavior. Gap civil times fail for every tested
selector and explicit flag.

Two 7.00 binding behaviors conflict with the documented input surface. Text and
list offsets, along with an unresolved zone name, terminate without a returned
status after clearing the carrier. Portable disputed scenarios retain that
generic result, the empty request-error boundary, the empty typed value reads,
and the later value error. The private `Date::Manip::Base::__zone` exception is
kept only in the excluded Perl-binding feature. Text supplied where an ordered
date/time field record is required has the same separation: its generic public
outcome remains portable and its array-reference exception remains binding-side.

Individual-field replacement performs substantially less validation than whole
date or time replacement. Month 0 or 13, day 0, 31, 32 or -1, hour 24 with
nonzero minutes, minute 60, second 60, text, and undefined input all return
status zero in the tested binding. Portable disputed rows retain the exact
stored field record and UTC presentation. The native Perl scalar/list carriers
and warning counts are asserted separately in the excluded binding feature. A
later UTC read may normalize some values and may retain other non-civil fields.
In contrast, whole `date` and `time` calls reject the corresponding invalid
shapes or ranges, except that exactly 24:00:00 succeeds and converts to next-day
midnight.

Research records and the excluded binding feature preserve Date-Manip's native
scalar format `YYYYMMDDHH:MN:SS`, including malformed strings. Portable feature
prose names language-neutral stored-date text, ordered field records,
fixed-local text, and UTC text. Valid fields render as
`YYYY-MM-DD HH:MM:SS`; this is a lossless presentation normalization and does
not claim that the binding returns the readable spelling.

The complete contract map supplies all canonical operation IDs. Every source
case maps the direct context constructor and its public zone/version checks,
`date.replace-field`, the public receiver constructor, scalar/list/conversion
observer, error observer, configuration mutation, and configuration reader. The
five error-bearing receiver cases also map their explicit public `parse` setup.
`coverage.json` maps all 108 fixture IDs to one portable English scenario each.
It also maps 27 binding-case IDs back to their source fixture IDs: nine exact
runtime exceptions, twelve native malformed carriers, and six nonzero warning
rows. The binding warning census covers all 108 cases and asserts zero warnings
for the remaining 102. No private callable is a portable test entrypoint.

Every case row also includes a typed `initial receiver` and `exact request`.
Those columns preserve text, numbers, lists, undefined values, omitted selectors,
empty argument lists, and the full parse-error preparation without relying on
scenario shorthand. The reviewer compares both columns directly with all 108
fixtures. Perl warnings from undersized arrays, year zero, nonnumeric and
undefined field values, and an omitted selector are asserted in the feature-level
`@source-binding @perl-binding @excluded-from-portable-handoff` profile.
Portable scenarios retain only typed status, error, mutation, and value-read
semantics. The excluded feature also preserves exact stable exception prefixes,
native malformed scalar/list values, and observer call contexts.

Remaining finite obligations are additional named-zone aliases and offset
spellings after the 7.00 offset exception is resolved; dates near the supported
year limits; non-array Perl reference types; fractional or non-integer individual
values; more invalid overlap flags such as negative and text values; selectors
containing surrounding whitespace; receiver defaults produced by truncated
parses; and profiles whose configured local zone is not UTC. Converted-value
reads before later mutation belong to `parse-cache-family`. The separate
`input-history` family owns the public `input` source-text lifecycle. This batch
does not claim every Perl carrier shape or every timezone transition.

The expected literals were reviewed against the raw observations. The stored
records and draft features remain research characterization pending project-level
approval; they are not executable BDD test results.

The reviewer confirms all 108 exact portable request rows against their fixtures
and compares result, status, error, mutation, field-record, warning, and native
binding columns with the same case's observation. It no longer relies only on a
literal occurring somewhere in the feature corpus. Six binding assertions and
27 binding rows have stable IDs and source-case mappings. The actual pinned BDD
parser accepts all four feature files and 28 scenarios containing 108 portable
request rows. This does not mean those requests have executed through BDD step
definitions.
