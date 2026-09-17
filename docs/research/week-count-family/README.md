# Public configured week-count research

Original public `Date::Manip::Base->weeks_in_year(year)`
observations for canonical `calendar.weeks-in-year`, distinct from week-number
lookup. The manifest crosses all105 valid FirstDay/Week1ofYear configurations
with14 representative Gregorian year types. Each request reads the count twice
and then in native list context, using only public construction/configuration
and week-count calls. Two isolated process runs match exactly; all1470 counts
agree with an independent Python Gregorian week-start calculation.

`observations.json` freezes the candidate values, probe/manifest/runner hashes,
loaded dependency hashes, runtime and fixed environment. No upstream code or
algorithm is copied. These are research records, not executable BDD tests.

The draft features now define explicit input years, weekday/rule meanings and
literal count vectors. Every portable example requests each year's count twice;
the excluded binding example also freezes the native one-item list result.
`feature-map.json` links the canonical operation and four partitions, retaining
invalid-input and state-transition domains as unresolved. The reviewer checks
all105 exact rows against observations and independent Gregorian calculations.

Invalid years, absent/nonnumeric inputs, invalid configuration and configuration
changes on reused contexts remain open; this matrix does not discharge them.
No whole-operation or source-coverage completion is claimed.

Reproduce without overwriting evidence:

```sh
python3 tools/probes/week-count-family/run.py > /tmp/week-count-candidate.json
cmp /tmp/week-count-candidate.json docs/research/week-count-family/observations.json
```

Validate with `python3 tools/probes/week-count-family/review.py`. The authoring
generator `make_features.py` renders already reviewed research values; it must not
run as part of future conformance testing or replace a failing expected result.
