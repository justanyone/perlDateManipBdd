# Coverage denominator audit

This audit addresses the 788 Date::Manip modules absent from the small
public-call pilot. It describes how a final Perl harness can make the complete
runtime-library denominator visible through public behavior. It does not turn
module loading into a behavioral assertion, and it does not copy upstream
language, timezone, or offset data tables into this repository or the portable
specification.

## Release roles

The separately installed Date-Manip 7.00 `Date/*.pm` inventory has 804 files:

| Role | Files | Final public route |
| --- | ---: | --- |
| OO/current and legacy backend core, including the facade | 10 | Documented OO, DM6, DM5, and `Date::Manip` facade behavior. |
| Language index and generated language data | 17 | Public `config(Language => ...)` followed by a language-specific parse/render assertion. |
| Timezone runtime support and generated zone data | 368 | Public `tz`, `all_periods`, `periods`, `date_period`, conversion, and date parsing with named zones. |
| Timezone-generation tooling | 1 | No supported runtime route; explicit exclusion review. |
| Generated fixed-offset data | 408 | Public parsing/conversion with valid fixed-offset input. |

The 368 runtime timezone files are 366 generated zone modules plus `TZ_Base.pm`
and `Zones.pm`; `TZ.pm` is counted in the core/backend group. `TZdata.pm` is
not in that runtime group: the API
inventory classifies its sole constructor and helpers as timezone-generation
tooling (`excluded-generation-tool; zone-data-results-remain-observable`). Its
own POD calls it an internal module for working with tzdata files, and the
runtime `TZ.pm` uses `Zones.pm`, not `TZdata.pm`. There is no evidence of a
supported public runtime call that loads it. It is therefore a documented
coordinator-reviewed application of the repository's internal-generation-tool
exclusion; it must not disappear silently from a
coverage report.

The public API does not document an operation that enumerates every generated
zone-module identifier or every offset-module identifier. A final denominator
pass must therefore derive an *ephemeral, binding-only* module-to-public-input
manifest from the pinned source during audit, hash it, and retain it with the
coverage artifact outside the portable export. It must not import those modules
in the test process or commit the source data table. For every entry in that
manifest, the harness must execute the mapped public call and assert an
observable result appropriate to that call before accepting the resulting
coverage row.

## Verified representative routes

[`tools/coverage-denominator/public_load_trial.pl`](../../../tools/coverage-denominator/public_load_trial.pl)
contains three fresh-process OO calls only:

| Public behavior | Newly loaded generated module category | Observable check |
| --- | --- | --- |
| Configure French, then parse a French date | Language | Successful serialized date. |
| Call `all_periods` for Asia/Tokyo in 2040 | Named zone | Nonzero period count. |
| Parse a timestamp with `+05:30` | Fixed offset and matching zones | Successful serialized date. |

The run uses the pinned 7.00 reference and Devel::Cover 1.52. Plain and
instrumented JSON stdout were byte-identical, and every process stderr capture
was empty and identical. The coverage JSON contains a statement row for the
French language module, the Tokyo zone module, the offset module, and each
named-zone module loaded by the fixed-offset case. These are discovery proofs;
they are not claims that their data semantics are fully tested. Exact run
evidence, hashes, and counts are in [trial-result.json](trial-result.json).

Run the trial only into a new external directory:

```sh
tools/coverage-denominator/run_public_loading_trial.sh /tmp/date-manip-public-loading-trial
```

The script uses fresh working directories and a clean environment for every
plain and instrumented case. The full Devel::Cover database stays in the chosen
directory. No generated data table is written to the repository.

## Finite final-denominator plan

1. Start from the 804-file release inventory and publish the raw count and
   source manifest hash. Keep `TZdata.pm` in a separate, explicit tooling line
   with its evidence and coordinator decision; do not subtract it in a report.
2. Cover the facade through supported `Date::Manip` functional use, the OO and
   DM6 core through their documented operation matrix, and DM5 through its
   supported compatibility matrix. The existing public-call pilot already
   demonstrates most of this group; the facade remains a required route.
3. Use one original language-specific assertion for each supported language,
   in fresh configuration state. Require the resulting coverage artifact to
   show each of the 16 data modules plus the shared language index; loading a
   language without a literal observable assertion is insufficient.
4. Generate the temporary source-audit map from each of the 366 generated zone
   module paths to a valid public named-zone input. For each mapping, use a
   documented timezone operation such as `all_periods` or `date_period` with a
   literal assertion. Independently cover aliases, transition behavior,
   no-transition behavior, and invalid-zone handling as behavioral partitions.
5. Generate the temporary source-audit map from each of the 408 offset module
   paths to a valid public fixed-offset input. For each mapping, parse or
   convert a date and assert a frozen observable carrier. Check the coverage
   database identifies that offset module; also retain separate assertions for
   offset syntax, sign, minute/second, invalid, and ambiguity cases.
6. Compare the final Devel::Cover source rows to the whole release inventory.
   Every absent runtime module requires either a new public behavioral route or
   a documented evidence-backed exclusion. Review all statement/branch errors
   after this loading pass; generated modules loading at 100% do not prove that
   their associated public behavior has enough assertions.

The map-generation step is source-side coverage accounting only. The portable
BDD specification keeps only public inputs and reviewed outcomes, never module
names, generated data, or source mappings.

## Coordinator validation

A fresh run at `/tmp/date-manip-public-loading-root-review` reproduced the
three public routes with identical plain/instrumented bytes and empty stderr.
The probe now checks errors on the actual Date or TZ receiver and asserts
literal parsed values or a nonempty period result before reporting success.
All nine newly loaded generated modules have9/9 statement rows.

The coordinator read TZdata.pod lines19–21 and confirmed its explicit non-public
generation role, consistent with the existing scope inventory. Exclude this tool
from public-runtime obligations, retaining the original804-file total and explicit
803-file runtime scope. This is a scope decision, not evidence of full coverage.
