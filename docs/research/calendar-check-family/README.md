# Public civil date and time validation observations

This family records 36 original requests for canonical operations
`calendar.validate-time` and `calendar.validate-date` through their public
Date-Manip 7.00 Base bindings, `check_time` and `check`. The probe obtains the
Base service from a fully configured `Date::Manip::Date` using the pinned `oo`
profile. No private callable is invoked.

The cases target the observable decisions at
`local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm:602-623`: clock field shape,
hour/minute/second limits, the exact `24:00:00` exception, year and month bounds,
and month-dependent day bounds. The 16 clock cases and 20 date cases cover valid
ordinary values, leap day, years 1 and 9999, 30-day month end, every numeric
lower/upper rejection branch, selected malformed field shapes, and one malformed
scalar carrier.

Each case calls the public operation once in scalar context and once in list
context. Completed calls retain their literal native value. The scalar-carrier
case throws in both contexts and therefore has no return fields. Before each
call the probe reads and clears the inherited public `err` observer, records the
clear return, reads it again, and records the post-call value. Warnings,
exceptions, standard output, and setup returns remain separate channels.

Two complete captures were run. Within each capture every case ran twice in a
fresh process and temporary working directory with four workers and a 15-second
timeout. Both complete JSON files were byte-identical. The environment fixes
`PATH=/usr/bin:/bin`, the pinned local library, UTC, C UTF-8, and Perl hash
ordering. Evidence includes the full external profile, reference version and
timezone metadata, runtime identity, loaded module paths, and hashes of every
installed module plus the manifest, probe, runner, fixture, contract, Base
source, and Base POD.

The portable features contain 35 concrete ordered-field requests. Exact Perl
carriers and diagnostics for all 36 cases live in `perl-binding.feature`, tagged
`@excluded-from-portable-handoff`. Fractional and whitespace-padded years and
extra fields are retained as observed compatibility behavior rather than
promoted as valid portable inputs.

`coverage-map.json` keeps every partition observed-partial. A focused run of all
36 public requests preserved identical instrumented and plain output. All ten
target statements executed, but Devel::Cover recorded zero hits for all six
branch outcomes in these routines, despite the observed valid and invalid
results. Branch completeness remains unproven pending instrumentation review.
The measured records are in `target-coverage.json`; the complete capture summary
is `coverage-result.json`. No zero-hit branch is excluded as unreachable.
Remaining domains are other field positions
and arities, mapping/nested/blessed/overloaded carriers, non-finite values,
Unicode numeric text, and other releases. Timezone gaps and overlaps are not a
gap here because the documented operations deliberately validate civil fields
without resolving a zone.

Reproduce without replacing the frozen evidence:

```sh
python3 tools/probes/calendar-check-family/run.py > /tmp/calendar-check-observations.json
cmp /tmp/calendar-check-observations.json docs/research/calendar-check-family/observations.json
python3 tools/probes/calendar-check-family/review.py
```

The reviewer verifies every typed request, profile field, source/evidence hash,
return-presence rule, scalar/list carrier, diagnostic, error sequence, feature
literal, binding, partition map, and selected Gregorian fact. It parses every
feature with the repository's installed Gherkin parser. These checks review
research evidence; they are not passing executable BDD scenarios.
