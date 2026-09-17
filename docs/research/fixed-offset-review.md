# Independent review: fixed-offset family

Reviewed the checked-in fixed-offset research and portable draft against the
authoritative external artifacts in `/tmp/fixed-offset-family-run-v6`. I did not
rerun the 408-case corpus. One narrow fresh public-call check repeated the common
setup and the `+00:00:00` case to determine whether configuration preloaded an
offset module; it did not. This was needed because the saved row records only the
post-call target flag and new-module count.

## Verdict

The external evidence supports the bounded claim that all 408 generated offset
modules were reached through public date construction. It does not support a
claim that all 408 offsets parse successfully or that the family has complete
timezone behavior coverage. The recorded outcome split is exactly 40 successful
parses and 368 rejections, and every rejection has the literal error
`[parse] Unable to determine timezone`.

The portable feature's seven literals match the authoritative observations. It
is a selected behavioral subset: six of the 40 successes and one of the 368
rejections. The remaining 33 successes and 367 rejections remain external
research observations rather than portable scenarios. All 408 module rows have
fulfilled this batch's reachability obligation, while most have no reviewed
portable behavioral contract.

## Findings requiring correction

### 1. Failure value fields are wrapper defaults, not native observations

On a parse error, `probe.pl` deliberately does not call `value` or `printf`.
Nevertheless, it emits `parsed_scalar: null`, `parsed_list: []`, `gmt_scalar:
null`, `gmt_list: []`, and `formatted: null` because those lexical variables were
never assigned. It then labels a copied parse error as `error_after_reads`, even
though no reads occurred. These fields cannot distinguish a skipped observer from
a public absent scalar or empty-list result.

The feature turns those placeholders into the claim that no normalized local or
UTC value is available. That state was not observed through a public value call.
Change rejected records to state explicitly that value reads were skipped and
omit the value fields, or execute and record a deliberate error/read/clear
sequence with native carriers. The portable rejection should say that no value is
read after the failed request unless such an observer sequence is added.

### 2. The durable record does not authenticate the instrumented proof

`fixed-offset-result.json` correctly pins the manifest and plain-observation
hashes, and all its installed-source and probe hashes match the current files.
It does not record hashes for `coverage-observations.json`, `report/cover.json`,
or `summary.json`. Those transient files are the evidence for the statements that
instrumentation preserved behavior and that every generated module appeared in
the coverage report. Once `/tmp/fixed-offset-family-run-v6` is removed, the
checked-in record cannot authenticate those claims.

Add the instrumented-observation and coverage-report hashes to the compact result.
The current authoritative hashes are:

```text
coverage-observations.json  29687c4ba9eb9cc0774c8c94c35142e93564d0f0f6446a88c5ed40206855f857
report/cover.json           ef243622d0c8b6b9f6fddfae88c1c33c92fd52fc7541a8d4bc685a4ff33c0bc8
summary.json                63bf03ef64e7d0a04e1a41b614de31744c657d5ee0e5360ad3e85c0d97517f42
```

Keeping the full manifest and source-derived module names outside the portable
draft is correct. A durable research hash for an external artifact does not copy
that source-derived table into the future implementation handoff.

### 3. Finalization checks path presence rather than executed coverage

The finalizer counts a target row when any coverage-summary path ends with the
manifest module path. It does not require a unique match or inspect the statement
coverage values. In the authoritative `cover.json`, manual review found one exact
path for every manifest entry and 100% statement coverage, specifically 9 of 9
statements for each of all 408 modules. The result is sound, but the automated
proof is weaker than the reported evidence and could accept a listed module with
zero executed statements.

Require exactly one report path per target and require positive covered statement
count; for this batch the stronger exact check can require 9/9. Record the
aggregate in `summary.json` and the compact checked-in result.

The isolated probe has a similar avoidable inference: it validates that the target
is loaded afterward but does not assert that it was absent beforehand or that the
new offset-module set is exactly the target. The saved data shows one new offset
module in every row, and the targeted clean-process check found an empty pre-parse
offset-module set, so the present evidence is consistent. Record and validate the
actual new module names to make attribution direct.

### 4. Portable examples lack a durable research mapping

There is no feature map or binding record. The six success IDs in the Examples
table are not referenced by the Scenario Outline name or a step, and they do not
map to the external observation IDs. The checked-in compact result contains only
counts and hashes, so the selected feature literals can currently be re-audited
only while the transient `/tmp` observation file exists or after regenerating it.

Add stable example IDs to the outline name or an explicit case step, map the seven
portable examples to their public observation inputs on the research side, and
declare the public bindings: `Date::Manip::Obj->new_date`,
`Date::Manip::Date->err`, `value` in scalar/list context, and `printf` with the
exact pattern. A small durable record of the seven original public inputs and
outputs would preserve reviewability without copying the 408-row source-derived
manifest or any generated module names into the portable feature.

## Verified evidence

- The external manifest contains 408 rows with 408 unique case IDs, literal
  offsets, and target modules. Its declared count and SHA-256 match the compact
  checked-in result.
- `run-one.json`, `run-two.json`, and finalized `observations.json` are
  byte-identical with SHA-256
  `b231ea18c43ee77b4b4e7ca6cc9d679659173cacc34e787feada0016ac8e9145`.
- All 408 plain rows record their expected target loaded, exactly one new offset
  module, absent exceptions, no warnings, and successful configuration with its
  native absent return preserved as JSON null.
- The instrumented behavioral records equal the plain records after removal of
  the two plain-only module-count fields. The coverage report has a unique target
  path for every manifest row and reports 9/9 statements covered for all 408.
- All 40 successes have empty errors before and after value reads. Scalar and list
  local/GMT forms agree field-for-field, and every GMT scalar equals the independent
  Python UTC calculation recorded in the row.
- All 368 rejected rows preserve the same parse error. Their value-shaped fields
  are not public observations, as described in finding 1.
- The driver uses a fixed five-variable environment, fresh per-case working
  directories for both plain runs, at most four workers, and a 30-second timeout.
  It rejects nonzero exits, process stderr, warnings, exceptions, version drift,
  existing output directories, and differing repeated observations.
- The feature structure checker reports one feature and zero structural errors.
  The six success offsets, their local/GMT scalars and formatted strings, and the
  selected rejection/error all match the authoritative external observations.

## Source separation and remaining work

The separation boundary is otherwise appropriate. Source discovery is confined
to `manifest.pl`; the full source-derived offset/module mapping, full observations,
coverage database, and coverage report remain under `/tmp`. Public behavior uses
only fresh OO construction, error, value, and formatting calls. The portable
feature contains selected original input/output facts and does not mention module
names, generated layout, or private algorithms.

Future behavioral work may review the other 33 successful offsets, representative
classes among the other 367 rejections, alternate accepted offset spellings,
boundary and out-of-range text not present in the generated mapping, and behavior
under other date contexts. Those are finite remaining behavior obligations, not
failures of the demonstrated 408-module reachability result. The 408/408 result
must remain described as reachability and generated-module statement execution,
not as complete fixed-offset parsing semantics or whole-library branch coverage.

## Repair and coordinator integration

The repaired run-v7 evidence addresses the four findings above. Rejected requests
now explicitly say that value observers were not called; the wrapper no longer
presents defaults as native returns. Seven selected, module-free observations and
canonical public bindings are durable repository artifacts. Full source-derived
module mappings stay outside the portable handoff.

The stronger finalizer verifies newly loaded module attribution, one unique
coverage path per target, and9/9 executed statements per target. Both plain runs,
instrumented observations, report, database tree and summary are hashed. The
coordinator verified those external hashes and the seven durable observations,
tightened outline-row comparisons, and clarified parsed-zone versus configured
local-zone terminology. The pinned parser expands seven scenarios without errors.
There are34 unselected successes and367 unselected rejections, correcting the
original review's arithmetic typo; these remain research-only observations.
