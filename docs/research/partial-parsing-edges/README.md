# Partial parsing edge observations

This original Date-Manip 7.00 batch adds bounded public observations for gaps
left by the partial-parsing family: selected date-only delta/holiday gate
controls, selected date-only zones and daylight-saving transitions, time-only
zones and fractional boundaries, and additional functional leading-prefix
carrier shapes. It uses public entrypoints for every case. Private helper logic
was inspected only to identify public edge inputs and is not part of the
portable contract or a direct test target.

The 52 cases run twice, each in a fresh process and temporary working directory,
with at most four workers and a 15-second timeout. The environment fixes
`TZ=Etc/UTC`, `LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`; `PERL5LIB` contains the pinned
local Date-Manip 7.00 installation. New York DST cases override the configured
local zone explicitly. The holiday-gate case writes an original one-line holiday
fixture only inside its temporary working directory.

For object operations, the probe records numeric status, the operation error
before any observer, scalar/list results with native carrier types, errors after
each observer, rendered zone/offset, and retained state after error clearing. No
value is read before the operation under test. On failure, the exact public
observer order is: error, scalar value, error, error clear, error, scalar value,
error. The absent return from the error-clear call is retained separately from
empty text. Functional-prefix cases record output type, carrier state, consumed
count, remainder, stdout, stderr, warnings, and exceptions.

Runtime backend versions come from the public OO `version` or functional
`DateManipVersion` calls. Fixture expectations are labeled separately. Each
row records the loaded entry module, while the observation header hashes the
installed Base.pm, Date.pm, DM5.pm, DM6.pm, Obj.pm, TZ.pm, and Zones.pm files in
addition to the corpus, probe, runner, and shared profile.

Run the batch with:

```sh
python3 tools/probes/partial-parsing-edges/run.py
```

## Manually reviewed findings

- The full parser accepts `2 days ago` and a configured `Founders Day`, and the
  corresponding `nodelta` and `noholidays` gates reject them. Date-only parsing
  rejects these two spellings even without a gate and retains its receiver. The
  public date-only signature accepts both option tokens; this batch does not
  generalize from these isolated controls to every possible spelling. The
  holiday control also emits 12 undefined-component warnings while resolving the
  leap-day holiday across the reference years; raw evidence preserves each
  warning.
- Date-only parsing rejects the tested canonical zone name and numeric offset
  suffixes. A successful date-only request applies the configured local zone
  rather than preserving the receiver's earlier parsed zone.
- With New York configured locally, a retained `02:30` clock makes the 2040 spring
  transition date invalid. `01:30` resolves to EST and `03:30` resolves to EDT.
  The fall-overlap default selects EST.
- Time-only parsing accepts a complete time followed by a canonical zone, numeric
  offset, abbreviation, or non-ISO meridiem plus zone. A truncated hour followed
  by a zone is rejected. New York's spring gap is rejected whether selected by
  local configuration or explicit zone text. In the fall overlap, the default is
  EST, while explicit EDT and EST select distinct GMT instants.
- Fractional seconds are discarded. Fractional minutes and hours are truncated to
  whole seconds. The before/after cases around one-second and one-minute results
  show the public carry boundaries. Values arbitrarily close to the next minute or
  hour remain one second below it.
- Time-only `24:00:00` succeeds as midnight on the same retained date instead of
  advancing the civil date. Fractional 24-hour text and multiple decimal points
  are rejected and preserve the receiver.
- Both functional profiles count carrier elements rather than words. One token
  may contain a whole date; empty, absent, and numeric tokens have concrete
  accepted cases; and date-plus-time uses the longest accepted prefix. Plain and
  scalar-reference text do not fall back to the tested valid leading substring.
  The absent-token warning counts and DM5 deprecation warning are retained in
  the excluded Perl binding feature rather than the portable behavior feature.

The 24:00 result, absent-token behavior, and gate-control results are tagged as
disputed observed compatibility where appropriate. They are frozen reference
literals rather than recommendations for a portable implementation. Perl
warning assertions live in `perl-binding-warnings.feature`, tagged
`@excluded-from-portable-handoff`.

## Remaining obligations

The finite batch does not exhaust all time-zone aliases and numeric offset forms,
historical non-hour DST transitions, or fractional strings of unbounded length.
It leaves list elements containing objects or overloaded values out of the portable
carrier contract, and does not characterize process arguments with tied arrays.
Further compatibility work could compare these cases with later Date-Manip
releases. Direct private API tests are excluded. The project-wide99% statement/95% branch
coverage gate includes internal execution reached through these public calls;
this bounded batch makes no coverage-percentage claim.

## Coordinator integration checks

Fresh coordinator observations match all52 stored payloads and provenance hashes.
`python3 tools/review/partial_parsing_edge_literals.py` verifies52 unique mappings,
48 outline rows against explicit frozen channels,11 hashes,14 native failure
lifecycles,24 successful scalar/list pairs and3 binding warning assertions.
Four feature files pass the lightweight structure checker. The coordinator made
the holiday definition, default local zone, overlap initial clock, per-row local
zone and lossless date presentation explicit. These checks are evidence review,
not an executable BDD suite or a complete parsing coverage claim.
