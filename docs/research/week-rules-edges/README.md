# Week-number p4/p5 edge corpus

This batch covers the bounded edge domains assigned after the complete valid
Base rule matrix. It uses only public `week_of_year`/`Date_WeekOfYear` calls and
public configuration, error, and version observers. It never calls
`_week_of_year` or another private helper.

The manifest contains 236 requests, each repeated twice in a fresh Perl process
and temporary working directory:

- 39 Base calls cover inverse weeks 0, -1, 52, 53, and 54; absent and nonnumeric inverse
  fields; years -1, 0, 1, 9999, and 10000; incomplete and invalid date lists;
  extra date fields; absent, text, and hash carriers; and wrong arities.
- 17 Base configuration calls cover invalid or absent `FirstDay` and
  `Week1ofYear` values, plus a case-insensitive valid control. Every invalid
  attempt preserves the prior configuration and the `[2039,52]` control result.
- 180 Date/DM6/DM5 calls cross `jan4`/`jan1` with configured first weekdays 1/7.
  Each combination covers true argument omission, an explicitly absent value,
  explicit overrides 1 through 7, and invalid `0`, `8`, `-1`, empty text,
  weekday-name text, and fractional overrides.

The portable drafts contain 232 generic outcomes. This includes permissive
results from invalid Base fields and inverse weeks, and every numeric facade
result from omitted, absent, valid, and invalid overrides. Seven native calls
raise exceptions; those calls contain no fabricated return. Four exclusively
Perl-shaped carrier/arity cases remain only in the excluded binding draft.

`perl-binding.feature` preserves exact scalar and list observations for all 219
week calls and exact native observations for the 17 configuration attempts:
return carriers, exceptions, ordered warning text, standard output, and Date/Base
public error snapshots. `observations.json` also records
the full request, reference profile, runtime, effective setup, every loaded
Date-Manip module path, and hashes for all 15 loaded module files and 13 batch
artifacts. DM5's load-time deprecation warning is kept separately from call
diagnostics.

Material compatibility findings remain visibly classified. Base permits out-of-
range inverse weeks and many invalid date fields. Date and DM6 restore the
configured first weekday after an invalid override and still return a number.
DM5 applies its older arithmetic to invalid overrides and returns different
omitted/absent values (`1` under the `jan4` profile and `2` under `jan1` for the
selected date). These are observed compatibility results, not idealized rules.

`feature-map.json` accounts for every portable row and every excluded binding
row. `coverage-map.json` links p1-p3 to the separate valid Base matrix and maps
all requests here to p4 or p5. `bindings.json` records the four public entry
points and all supporting public calls. `review.py` checks request/profile/result/
error/diagnostic correspondence, hashes and provenance, native contexts, maps,
and independent ISO and configured-week facts.

The portable features name four language-neutral routes: `generic calendar`,
`current object`, `current functional`, and `legacy functional`. Their
Backgrounds fix the Gregorian calendar, UTC context, English language and
reference time where the facade fixtures use them; define weekday numbering and
`janN`; and name the field order of date and week-pair outcomes. Native module
and carrier names stay in the excluded binding feature and research maps.

Regenerate and verify the batch with:

```sh
python3 tools/probes/week-rules-edges/make_cases.py
python3 tools/probes/week-rules-edges/run.py > /tmp/week-rules-edges-observations.json
cmp /tmp/week-rules-edges-observations.json docs/research/week-rules-edges/observations.json
python3 tools/probes/week-rules-edges/make_artifacts.py /tmp/week-rules-edges-observations.json
python3 tools/probes/week-rules-edges/review.py
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" perl tools/runner-trial/parse-features.pl \
  spec/drafts/week-rules-edges/base-edge-requests.feature \
  spec/drafts/week-rules-edges/legacy-overrides.feature \
  spec/drafts/week-rules-edges/perl-binding.feature
```

The bounded p4/p5 assignment is complete, but the maps do not claim exhaustive
mathematical or native-type coverage. Explicit remaining domains are arbitrary-
magnitude years and week numbers beyond the selected limits, every possible
malformed Perl reference/arity, the full invalid month/day Cartesian product,
legacy-facade dates beyond the selected January transition, and crossing every
one of the 105 valid Base configurations with every malformed request. Those
limits stay recorded in `coverage-map.json`; the separate core matrix remains
unchanged.
