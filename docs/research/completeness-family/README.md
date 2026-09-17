# Public field-completeness observations

This original bounded batch addresses `Date::Manip::Date::complete`, whose public
operation ID is `date.complete-missing-fields`. Despite that ID's wording, the
method queries completeness; it does not fill or mutate a date. Eleven receiver
setups each execute twelve scalar queries in a specified order, producing132
observations. No value getter runs before or between them.

Public documentation defines omitted selector and m/d/h/mn/s. Empty, zero,
absent, uppercase, year and unknown selectors are observed compatibility forms.
The portable feature uses explicit English query meanings and fixed literal
booleans; null remains distinct from false. Scalar errors are observed immediately
before and after each query. Invalid/unset receivers return absent results with
one warning per call. Exact warning text remains in the binding-only feature and
raw reference record, not the portable contract.

Full explicit dates report complete. Reduced ISO forms retain individual default
flags. Month/day-only, time-only, and relative tomorrow inputs report complete
across the five queried fields; this is an observed reference property, not proof
that all fields appeared literally in the input. Unsupported truthy selectors
report false for valid receivers. Error state is unchanged by all132 queries.

Every setup runs twice in a fresh process and temporary directory, four workers,
15-second timeout, clean environment, pinned Date-Manip7.00. Evidence records
native outputs, warnings, errors, exit/stderr, actual versions, runtime, loaded
module paths/hashes, fixture and tool hashes, and explicit configuration.
`feature-map.json` records the public bindings and canonical operation IDs.
No upstream code, tests or language data was copied.

```sh
python3 tools/probes/completeness-family/run.py > /tmp/completeness-candidate.json
python3 tools/probes/completeness-family/review.py
```

Both feature files pass the installed Test::BDD::Cucumber0.87 public parser.
The reviewer compares every ordered result, setup text/status and error against
frozen literals and checks provenance. These are reference observations and
syntax checks, not execution of the future BDD adapter.

Remaining obligations include flags after partial parse/mutation/conversion,
pattern parse, alternate grammar and locale paths, constructor forms, error clear,
list context, non-scalar selectors, extra arguments and additional default-time
configurations. Source inspection informed these public cases without directly
testing private helpers. This batch makes no percentage or completeness claim.
