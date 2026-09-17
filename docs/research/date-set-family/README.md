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

The runner launches each attempt in a fresh temporary working directory with a
small fixed environment. It uses at most four workers, gives each process 15
seconds, and executes every case twice. The stored file records hashes for the
fixtures, both probe programs, the public documentation, and the installed
Date, Obj, Base, and TZ modules. All 108 stored cases exited zero, decoded as
JSON, matched the fixture hash, and repeated byte for byte. Per-call exceptions
and warnings are part of the payload; they are not process failures.

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
list offsets, along with an unresolved zone name, reach a nonexistent
`Date::Manip::Base::__zone` method and raise an exception after clearing the
carrier. The exact exception, including source path and line, remains in raw
evidence; portable scenarios use its stable prefix and are tagged
`@reference-binding @disputed`. Scalar text supplied in place of a date/time
array similarly raises a stable array-reference exception.

Individual-field replacement performs substantially less validation than whole
date or time replacement. Month 0 or 13, day 0, 31, 32 or -1, hour 24 with
nonzero minutes, minute 60, second 60, text, and undefined input all return
status zero in the tested binding. The raw scalar and returned six-field list
preserve those malformed values; a later GMT read may normalize some values and
may retain other non-civil fields. These rows are characterization scenarios,
not portable validation requirements, and are tagged disputed. In contrast,
whole `date` and `time` calls reject the corresponding invalid shapes or ranges,
except that exactly 24:00:00 succeeds and converts to next-day midnight.

Research records preserve Date-Manip's native scalar format
`YYYYMMDDHH:MN:SS`, including malformed strings. Portable feature prose renders
valid six-field values as `YYYY-MM-DD HH:MM:SS`. This is a lossless presentation
normalization and does not claim that the binding returns the readable spelling.
Malformed-field scenarios show the native scalar and the returned list
separately and call converted output a six-field presentation rather than a
normalized civil date.

The complete contract map supplies all canonical operation IDs. Every case maps
the direct context constructor and its public zone/version checks,
`date.replace-field`, the public receiver constructor, scalar/list/conversion
observer, error observer, configuration mutation, and configuration reader. The
five error-bearing receiver cases also map their explicit public `parse` setup.
`coverage.json` maps all 108 fixture IDs to one English scenario each. No private
callable is a portable test entrypoint.

Every case row also includes a typed `initial receiver` and `exact request`.
Those columns preserve text, numbers, lists, undefined values, omitted selectors,
empty argument lists, and the full parse-error preparation without relying on
scenario shorthand. The reviewer compares both columns directly with all 108
fixtures. Perl warnings from undersized arrays, year zero, and an omitted
selector are asserted in separate `@reference-binding` scenarios; portable
failure scenarios retain only status, error, and carrier semantics.

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

Coordinator review confirmed the108 exact request rows against their fixtures and
strengthened the checker to compare result/status/error/list/warning columns with
the same case's observation. It no longer relies only on a literal occurring
somewhere in the feature corpus. Two additional Perl diagnostic scenarios have
separate stable assertion IDs and source-case mappings. The actual pinned BDD
parser accepts all three feature files,24 scenarios containing108 request rows.
This does not mean those requests have executed through BDD step definitions.
