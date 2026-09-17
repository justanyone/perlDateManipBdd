# Public leap-year behavior family

This family characterizes canonical operation `calendar.is-leap-year` through
its three public Date-Manip 7.00 bindings:

- `Date::Manip::Base::leapyear(year)`
- `Date::Manip::DM6::Date_LeapYear(year)`
- `Date::Manip::DM5::Date_LeapYear(year)`

The contract source is `docs/research/contracts/calendar.json`. Its partitions
are ordinary divisible-by-four/common years (`p1`), century and 400-year
boundaries (`p2`), and invalid, signed, outside, or short-year inputs (`p3`).
[feature-map.json](feature-map.json) maps every request to those canonical IDs,
the exact public binding, evidence record, and portable and binding feature.

## Evidence method

[cases.json](cases.json) contains 84 original explicit requests. Three requests
each classify the complete integer interval 2000 through 2399, once per public
binding. The other 81 requests cover supported endpoints and first/last leap
years, external century controls, default and configured short-year behavior,
omitted and explicitly undefined arguments, empty and nonnumeric text,
fractions, zero, three negative residue classes, and the first year above the
documented interval.

Run the probe with:

```sh
python3 tools/probes/leap-year-family/run.py > /tmp/leap-year-observations.json
```

The runner uses `/usr/bin/perl`, a literal `/usr/bin:/bin` `PATH`, the pinned
Date-Manip 7.00 `PERL5LIB`, `Etc/UTC`, and `C.UTF-8`. Every case and backend runs
twice in a fresh temporary directory with at most four workers and a 15-second
timeout. The complete runner was itself run twice; the two JSON records were
byte-identical. [observations.json](observations.json) stores module, POD,
contract, manifest, profile, probe, and runner hashes; loaded module paths,
versions, configuration results, scalar/list carriers, warnings, standard
output, exceptions, and completion flags remain literal.

Interrupted calls omit return fields. A null or empty placeholder is never used
to imply that an interrupted call returned an absent value.

## Independent review

Run:

```sh
python3 tools/probes/leap-year-family/review.py
PERL5LIB=local/bdd-runner/lib/perl5 perl tools/runner-trial/parse-features.pl spec/drafts/leap-years/*.feature
```

The reviewer verifies every stored hash and all 84 mappings. Python's
independent Gregorian calendar implementation checks all 400 years in the
cycle and the seven explicit valid boundaries. The fixed-2040 short-year
windows are resolved separately and then compared with the observations. It
checks 1,200 per-year cycle records and all 2,562 native scalar/list calls,
including carrier absence on interruption. This is an evidence consistency and
fact review, not an executable BDD result or portable approval.

The complete cycle contains exactly 97 leap years and 303 common years. All
three public bindings agree for four-digit years from the documented interval.
The profile split is visible for short and invalid inputs: Base and DM6 apply
arithmetic to the supplied scalar, while DM5 applies its short-year conversion
to non-four-character values and interrupts for some other lengths. These
profile-specific outcomes remain tagged `@compatibility @disputed`.

Exact Perl warnings, the DM5 loading warning, native scalar/list shapes, and the
four interrupted DM5 diagnostic families appear only in
`perl-binding.feature`, which has the feature-level
`@excluded-from-portable-handoff` tag. Portable drafts contain generic flags or
no-return completion outcomes and do not require another implementation to
reproduce Perl warning text or backtraces.

[remaining-domains.md](remaining-domains.md) states the precise limits. Counts,
one complete cycle, and clean validation do not by themselves establish total
behavioral completeness. No case in this family is approved as a portable
expectation yet.
