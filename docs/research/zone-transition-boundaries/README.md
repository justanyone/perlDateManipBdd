# Zone transition boundary observations

This original Date-Manip 7.00 batch characterizes exact public behavior at a
small set of contrasting civil-time discontinuities. It covers New York and
London one-hour gaps and overlaps, Lord Howe half-hour changes, Apia's 2011
skipped day, and a UTC no-transition control. It adds boundary precision to the
existing zones/business batch rather than repeating its ordinary named-zone,
alias, fixed-offset, discovery, and invalid-zone examples.

Each of the eight cases sends the three UTC instants one second before, exactly
at, and one second after its selected boundary through both public paths: direct
zone conversion, and date parsing followed by date-object conversion. Each case
also calls the public absolute and wall-clock period lookup, lists periods that
begin during the selected UTC year, and lists all periods intersecting that
year. The raw observation preserves every field of every returned period record,
native absent values for gaps, list carriers, scalar and list date values,
numeric statuses, immediate errors, warnings, captured call stdout, and
exceptions. Scalar and list value reads, rendering, setup, and constructors
retain their own immediate error and exception boundary. Successful value reads
occur only after the immediate operation error is recorded; a failed parse or
conversion would not be read.

The eight manifest IDs identify observation processes. Each of the 67 portable
examples has a separate stable ID in the feature and `feature-map.json`; the map
links that ID back to its observation parent. This prevents the three UTC points
or multiple wall-clock queries from sharing one scenario identity.

The manifest contains only original inputs and independently reviewed literals.
The UTC arithmetic was checked by applying the stated offsets. The runner also
records Python standard-library `zoneinfo` provenance: Python version, zoneinfo
search path, `/usr/share/zoneinfo/tzdata.zi` path, its SHA-256, its `2026c`
version line, the exact UTC-to-local comparison method, and all 24 checked
instants. The portable features freeze literal results;
they do not invoke either source to calculate an expected value at test time.
No upstream test, table, or implementation code was copied. Private source was
consulted only to find public edge cases and is not called or prescribed.

Run the evidence probe with:

```sh
python3 tools/probes/zone-transition-boundaries/run.py
```

The saved observation includes two complete runner passes with canonical payload
hashes compared equal. Every runner pass
also invokes each case twice, in a fresh Perl process and fresh temporary working
directory for every attempt, with at most four workers and a 15-second timeout.
The environment contains only `PATH`, the pinned `PERL5LIB`, `TZ=Etc/UTC`, and
the two C UTF-8 locale variables. The header records the profile, corpus, probe,
and runner hashes plus the installed core and zone-specific module hashes. Each
row records the actual module paths, Perl runtime, backend version 7.00,
`tzdata2026c`, `tzcode2026c`, configured zone, and exact profile setup return.

## Reviewed behavior

- At every forward transition, the final pre-boundary UTC second maps to the
  final old-offset civil second, while the boundary itself maps to the first
  new-offset civil second. New York and London skip one wall-clock hour, Lord
  Howe skips 30 minutes, and Apia skips all of 2011-12-30.
- At every backward transition, the boundary moves into the repeated interval.
  Wall-clock period lookup with selector 0 chooses the standard period and
  selector 1 chooses the daylight period throughout the tested repeated limits.
- Gap wall times return an absent scalar period at their first and last skipped
  seconds. The adjacent valid UTC instants return the corresponding complete
  period records.
- `periods` returns only records beginning during the UTC year. `all_periods`
  adds the carry-in record that intersects January 1. The stable UTC zone has no
  beginning record in 2040 and one all-years record spanning the supported
  calendar range.
- Direct zone conversion and date-object parse/convert return identical numeric
  local fields at all 24 UTC points. All parse and convert statuses are 0, all
  recorded errors are empty, and all direct conversions return error code 0.

## Remaining domains

This bounded batch does not characterize every zone, year, alias, abbreviation,
or political time-zone change. It leaves negative daylight saving, transitions
larger than 24 hours, multiple changes on one civil day, pre-standard-time local
mean offsets, leap seconds, custom zone definitions, invalid arguments, system
zone discovery, and dates outside the supported 0001–9999 calendar range to
other work. It does not claim branch coverage or overall API completeness.
