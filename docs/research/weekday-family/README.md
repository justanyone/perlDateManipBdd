# Calendar weekday reference observations

This batch contains 190 original public requests for `calendar.weekday` against
Date-Manip 7.00. It calls only the three canonical public bindings: the calendar
service's one-date-collection operation, the current functional operation, and
the legacy functional operation. `source-review.json` records the public entry
points and the private arithmetic and short-year code inspected solely to choose
public edge requests. No private helper is called.

Every case ran twice in a fresh process and temporary working directory with a
20-second timeout. The runner fixes `PATH=/usr/bin:/bin`, the pinned library
path, UTC, the C UTF-8 locale, and Perl hash determinism. The evidence records
Perl v5.40.1, the x86_64 Linux architecture, the complete selected profile,
loaded module paths and hashes, inspected source/POD hashes, and input-artifact
hashes. All 190 pairs were byte-identical.

The portable profile tables state the clock relationship explicitly. The two
functional fixtures use 2040-02-28 10:20:30 UTC. The direct calendar service
does not configure a clock because this operation has no clock input; its exact
requested settings are still recorded in every native binding row.

The portable draft has 190 rows: 21 cover each weekday through all three
profiles, 66 cover the fourteen Gregorian year types and leap/century/endpoint
controls, and 103 cover invalid fields, missing/extra positions, carrier shapes,
and short-year settings. The fourteen year types are the cross-product of
common or leap year and the seven possible weekdays for January 1. Each type
observes the preceding year end, year start, year end, and following year start.
The controls include the supported years 0001 and 9999, a non-century leap year,
non-leap centuries, leap centuries, and numeric year 40.

Independent Python `datetime` checks validate 265 public calls whose inputs
denote valid proleptic-Gregorian dates. These include every weekday, every year
type transition, all leap/century/endpoint controls, and the legacy short-year
cases with an unambiguous resolved full year. The independent calculation is a
review-time check; the generated Gherkin freezes literal weekday outcomes and
does not calculate expected values at conformance time.

Empty text, absent values, omitted fields, numeric values, and text values use
different typed records. Completed low-level calls retain their literal numeric
result even when the input is malformed. Portable diagnostics use only the
generic categories `arithmetic-input diagnostic` and `invalid-input failure`.
No return is invented for a failed call. Exact Perl warnings, exceptions, stack
locations, scalar/list carriers, setup results, and the legacy load warning are
confined to `perl-binding.feature`, tagged `@source-binding`, `@perl-binding`,
and `@excluded-from-portable-handoff`.

The current functional short-year rows preserve a compatibility finding: for
the sampled calls, changing the short-year setting did not change the weekday
computed from the two-character numeric year. The legacy rows preserve the
selected `89`, `c`, `c19`, `c20`, and `c2000` behaviors, including failures for
one- and three-character years. These observations do not resolve the apparent
difference between current functional documentation and implementation.

`feature-map.json` maps every case to its exact profile, request, result,
partition, disposition, independent expectation, and portable feature.
`bindings.json` maps every case to its public native request.
`coverage-map.json` lists the observed and remaining domains without declaring
any partition complete. The strict reviewer rejects missing or extra feature
rows or columns, blank table cells, row/profile/request/result drift, map drift,
evidence or source hash drift, native diagnostics in portable files, and any
failure row that fabricates a return.

Regenerate derived artifacts and verify them from the repository root:

```sh
python3 tools/probes/weekday-family/make_artifacts.py
python3 tools/probes/weekday-family/review.py
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" perl tools/runner-trial/parse-features.pl \
  spec/drafts/weekdays/weekdays.feature \
  spec/drafts/weekdays/gregorian-boundaries.feature \
  spec/drafts/weekdays/invalid-and-short-years.feature \
  spec/drafts/weekdays/perl-binding.feature
```

Reproduce the frozen observations separately:

```sh
python3 tools/probes/weekday-family/run.py > /tmp/weekday-observations.json
cmp /tmp/weekday-observations.json docs/research/weekday-family/observations.json
```

This is a bounded draft rather than a completion claim. Remaining domains are
the full set of supported dates, additional representatives within each year
type, the full cross-product of malformed fields and arities, all 100 short
years under every supported short-year rule, invalid short-year settings,
additional coercive native value kinds, extreme magnitudes, non-finite numbers,
numeric text variants, and Unicode numeric text.
