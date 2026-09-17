# Public configured week-count research

Work in progress: original public `Date::Manip::Base->weeks_in_year(year)`
observations for canonical `calendar.weeks-in-year`, distinct from week-number
lookup. The manifest crosses all105 valid FirstDay/Week1ofYear configurations
with14 representative Gregorian year types. Each request reads the count twice
and then in native list context, using only public construction/configuration
and week-count calls. Two isolated process runs match exactly; all1470 counts
agree with an independent Python Gregorian week-start calculation.

`observations.json` freezes the candidate values, probe/manifest/runner hashes,
loaded dependency hashes, runtime and fixed environment. No upstream code or
algorithm is copied. These are research records, not executable BDD tests.

Next: author generic Gherkin with explicit input years, rule meanings, count
vectors and repeat-read outcomes; separate native contexts in excluded binding
scenarios; add exact per-row reviewer, canonical map and remaining partitions.
Invalid years, absent/nonnumeric inputs, invalid configuration and configuration
changes on reused contexts remain open; this matrix does not discharge them.

Reproduce without overwriting evidence:

```sh
python3 tools/probes/week-count-family/run.py > /tmp/week-count-candidate.json
cmp /tmp/week-count-candidate.json docs/research/week-count-family/observations.json
```
