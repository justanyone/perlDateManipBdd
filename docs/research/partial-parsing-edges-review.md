# Independent review: partial parsing edges

Reviewed and repaired 2026-09-17 against the repository's public-only scope and
source-separation rules. The review covered the 52 original public edge
requests, regenerated observations, probe and runner, public Date-Manip 7.00
POD/source signatures, bindings, case map, and four feature files.

## Resolved findings

### Perl warning behavior is binding-only

The portable date-gate and leading-token scenarios retain their parsing,
mutation, status, error, and consumption outcomes without asserting Perl warning
channels. The words “stringified” and “emitted by prefix search” were removed
because the public results establish acceptance and consumption, not an internal
conversion mechanism.

The exact warning counts now live in
'spec/drafts/partial-parsing-edges/perl-binding-warnings.feature'. That file is
tagged '@source-binding', '@perl-binding', and
'@excluded-from-portable-handoff'. Its three distinct assertion IDs cover:

- 12 undefined-component warnings for the holiday comparison;
- 2 uninitialized-token warnings and no deprecation warning for the current
  functional binding; and
- 2 uninitialized-token warnings plus 1 deprecation warning for the legacy
  functional binding.

This also removes the former scenario-outline error that applied a legacy
deprecation assertion to the current-profile row.

### Native setup and observer returns preserve the full call sequence

Every OO setup now records the native configuration return and type,
configuration error, initialization status and type, and initialization error.
Every failed call records, in order:

1. the operation status and error;
2. scalar value and type while the error is present;
3. error after that value read;
4. the native absent return and type from 'err(1)';
5. the empty error immediately after clearing;
6. scalar value and type after clearing; and
7. error after the post-clear value read.

There are 14 complete failure lifecycles: 8 ordinary OO requests and 6 failed
calls nested in the 2 gate controls. The feature steps now state the same
sequence. They preserve the special full-parser result where a pre-clear value
read and a post-clear value read each set '[value] Object does not contain a
date'. Date-only and time-only failed reads retain their parse error before the
clear and expose their retained receiver afterward.

Successful OO rows retain scalar and list parsed-zone results, scalar and list
GMT results, rendered abbreviation/offset, native carrier types, and the error
after every observer. Functional rows preserve each native Date_Init and
ParseDate return and carrier mutation without coercion.

### Runtime provenance is observed and hashed

Runtime backend versions now come from the public OO 'version' and functional
'DateManipVersion' calls. Fixture expectations are stored in separate
'fixture_expected_*' fields. Observed backend versions are 7.00 for OO and DM6
and 5.66 for DM5; every row observes distribution version 7.00. OO rows also
observe tzdata2026c, tzcode2026c, and the configured context zone through public
metadata calls.

Each row records the loaded entry-module path. The schema-version-2 observation
header hashes the installed Base.pm, Date.pm, DM5.pm, DM6.pm, Obj.pm, TZ.pm, and
Zones.pm files, in addition to the cases, probe, runner, and shared profile.
All eleven hashes match the current files.

### Gate-control inputs are manifest-owned

Both date-gate requests now include their initial receiver and ordered four-call
plan in cases.json: full parser enabled/gated, followed by date-only parser
enabled/gated. The probe reads those values from the manifest. Each nested call
also records its fresh receiver's setup returns and errors. The saved request
echo therefore contains every case-specific public input behind the comparative
feature.

### Zone and grammar wording is bounded by public evidence

The two explicit EDT/EST overlap rows now assert the directly observed civil
fields, GMT instant, abbreviation, and offset. They no longer infer a canonical
'America/New_York' identifier that the saved public calls did not return.

Date-gate prose names the selected delta and holiday spellings. Date-only zone
prose names the tested canonical zone and numeric-offset suffixes. The README no
longer turns those bounded examples into grammar-wide claims. Numeric and absent
token scenarios state observable acceptance and consumption without prescribing
string conversion.

### Public operation mapping is complete for the probe

bindings.json now maps the five primary public operation/profile bindings and
the public setup, observer, rendering, error, metadata, initialization, and
version calls. It records scalar/list context, failure observer order, native
return carriers, and the excluded warning feature. The Date 'parse' declaration
coordinate is corrected from line 101 to line 97.

feature-map.json schema version 2 maps all 52 portable case IDs separately from
the three binding-only warning assertion IDs and their source observations.

## Verification

- Candidate evidence was generated at
  '/tmp/partial-parsing-edges-observations.candidate-v2.json' before replacing the
  saved observations. Comparison with the prior corpus found no change to any
  status, error, value, scalar/list result, carrier mutation, consumed count,
  warning, stdout, or stderr. Differences are the expanded gate request echoes,
  explicit native observer/setup fields, and observed provenance.
- The regenerated corpus contains 52 unique repeatable rows: 34 OO, 9 DM6, and
  9 DM5. Every attempt ran in a fresh Perl process and temporary directory,
  twice per case, with four workers and a 15-second timeout.
- Process stdout and stderr are empty for all rows, and every exception is
  absent. Warning arrays exactly support the three binding-only assertions and
  preserve the other eight DM5 deprecation warnings as raw research.
- All 52 portable case IDs appear exactly once in the portable feature files
  and once in the portable feature map. The three source-binding assertion IDs
  are distinct and map to existing observations.
- All 14 failure sequences preserve empty text as text, the absent clear return,
  empty post-clear error, post-clear receiver value, and final error. No value is
  read before the operation under test.
- All 24 ordinary OO successes have matching scalar and six-field parsed/GMT
  results and empty errors after observers. All 14 token-array consumed counts
  equal original length minus remaining length; plain and scalar-reference
  carriers remain unchanged.
- Independently checked civil facts agree: 2040 is a leap year; New York uses
  UTC-05 before and UTC-04 after the March 11 gap; the November 4 overlap has
  UTC-04 and UTC-05 instants; and the fractional-minute/hour boundary seconds
  equal decimal truncation.
- Perl syntax, JSON parsing, candidate equality, saved hashes, warning
  assertions, case/feature mapping, and whitespace checks pass.

## Disposition

The concrete findings from the independent review are resolved. The repaired
batch is ready for coordinator review as draft reference evidence. It remains a
finite behavioral batch with the explicit obligations in its README and makes
no statement/branch coverage claim.
