# Public-probe coverage corpus diagnostic

This is a bounded source-coverage diagnostic that reuses existing original
public-reference probes. It is neither an executable BDD suite nor a completion
coverage result. Every collected process invokes only a selected probe's public
Date-Manip calls; private implementation code is measured only if reached by
those calls.

The committed manifest selects 30 varied cases: 12 `Date->set` cases, all 11
completeness cases, and seven partial-parser cases. The collector requires an
explicit manifest, so it cannot silently choose or expand the corpus.

```sh
python3 tools/coverage-corpus/collect.py \
  --manifest tools/coverage-corpus/representative-manifest.json \
  --output /tmp/public-coverage-corpus
```

Each case runs in a fresh plain process and a fresh Devel-Cover process with a
minimal environment (`PATH`, `LANG`, `LC_ALL`, `TZ`, and profile-specific
`PERL5LIB`; no inherited `HOME` or `PERL5OPT`). The collector rejects changed
native JSON stdout, changed process stderr, nonzero exit, malformed JSON, or a
shared coverage database. It gives every covered process its own database, then
merges the databases only after all fidelity checks pass.

The external run at `/tmp/public-coverage-corpus-v4` had byte-identical native
JSON and empty identical stderr for all 30 pairs. It loaded 14 of 804 installed
Date-Manip modules; the other 790 are named in the external summary as unloaded
files with no fabricated criterion rows. For the loaded-file denominator it
reached 2,231/5,802 statements (38.4523% raw) and 333/3,080 branches (10.8117%
raw). Devel-Cover's tool-effective values are separate and do not approve its
two statement and one branch `uncoverable` annotations.

[`result.json`](result.json) is the compact checked-in record. The full merged
database, JSON report, all loaded/unloaded paths, and per-case fidelity hashes
remain under the chosen `/tmp` output directory.

The report ranks remaining branch criteria by loaded core module and lists
public-operation source entry locations to guide the next corpus expansion:
`Date::Manip::Date` parsing and `set`, `Date::Manip::TZ` resolution and period
enumeration, `Date::Manip::Base` configuration, and `Date::Manip::Obj`
construction. These locations identify public domains with remaining branches;
they do not claim a one-to-one mapping from a particular Devel-Cover criterion to
a source line. No upstream source excerpt or private call is included.

## Expanded committed-family diagnostic

The expanded manifest enumerates 472 cases from eight committed families. Run:

```sh
python3 tools/coverage-corpus/collect.py \
  --manifest tools/coverage-corpus/expanded-manifest.json \
  --output /tmp/public-coverage-expanded \
  --normalize-dm5-deprecation-sites
```

The option addresses an observed instrumentation effect: Devel::Cover changes the
`(eval NUMBER)` location and adds a caller annotation to DM5's module-load
warning. Comparison removes that attribution only from the known deprecation
message in warning fields. Return values, exceptions, other warnings, warning
counts, and process stderr must still agree. Both raw stdout/stderr payloads are
saved before comparison, and each adjusted case is marked. The default remains
strict byte comparison. The dedicated tests verify that changed return values,
warning content/counts and other diagnostics cannot use this exception.

The verified run at `/tmp/public-coverage-corpus-expanded-root-v2` contains 412
byte-identical pairs and 60 pairs requiring that documented adjustment. All 472
process stderr pairs were empty and identical. It measured 34 of 804 installed
files, retaining the other 770 as unloaded. Raw coverage was 4,719/11,537
statements (40.9032%) and 655/6,376 branches (10.2729%). This corpus does not yet
include all existing research families, and these are not full-library or final
BDD-suite percentages. Its collector environment, recorded in the result, is
authoritative; reused probes can also emit descriptive fixture-environment fields.

`expanded-result.json` retains the module inventory, criteria totals, tool/runtime
metadata, source hashes, fidelity policy and external report hashes.
`expanded-locations.json` records all 12,539 unexecuted or annotated outcomes as
file, tool-reported location, criterion index, outcome index, execution count and
annotation flag. These are research-side review obligations, not portable tests;
no upstream source expressions or algorithms are included. All are unresolved.
The two statement and one branch upstream annotations remain unapproved exclusions.

The original `locations.pl` extractor uses the separately installed coverage
library's database API. With that library's architecture directory and ordinary
library directory on `PERL5LIB`, run:

```sh
perl tools/coverage-corpus/locations.pl \
  /tmp/public-coverage-expanded/merged_db \
  "$PWD/local/date-manip-7.00/lib/perl5" > /tmp/coverage-locations.json
```

The coordinator verified every saved raw payload hash and comparison, and checked
that the extracted statement/branch totals exactly match the merged JSON report.
Location identifiers identify measured criteria; assigning each gap to a public
behavior and writing a discriminating assertion still requires source review.
