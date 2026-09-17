# Feature batch handoff

This is a research-side work convention, not part of the portable specification.
Use it after the reference and API inventories pass their acceptance gates.

Each worker owns one feature family and its corresponding original probes,
observations, and coverage records. The coordinator assigns non-overlapping paths
before work starts. Read only the applicable inventory entries, fixture definitions,
and upstream documentation/source. Do not copy upstream tests or algorithms.

## Required artifacts

- English `.feature` files using the common Gherkin subset: Background, Scenario,
  Scenario Outline, Examples, and step tables. Give every outline row a unique
  case ID. Steps name generic operations and observable outcomes.
- An original probe program, with an exact command that invokes the pinned
  reference in a fresh process. Capture returns, error/warning channels, and
  observable state as required by that operation. Do not suppress unexpected
  diagnostics to obtain a clean observation file.
- Research-side observations containing case ID, contract/partition IDs, profile,
  all input fields, context overrides, raw outputs, normalized outputs, and
  evidence commands. Distinguish omitted arguments, absent values, empty strings,
  zero, and empty collections explicitly.
- Coverage records linking each case to its contracts and partitions. Keep
  unimplemented obligations visible; a broad scenario name is not evidence that
  every option or return form was exercised.

Use a human-readable named fixture for shared context. Its definition must include
language, zone, fixed clock, numeric-date ordering, omitted-time behavior, week
rules, business hours, holidays/events, and reference data version. A scenario
states any overrides. Shared defaults must not depend on the machine or a preceding
scenario. DM5 and DM6 observations are separate profiles even when values agree.

## Observation review

Run probes twice with fresh state and compare results. That demonstrates
repeatability, not correctness. Review calendar facts independently where possible;
for compatibility quirks inspect the documented contract and preserve the observed
result with an explicit classification. Record a minimal reproducer for disputes.

Use these research states:

| State | Meaning |
| --- | --- |
| proposed | Original input/expected behavior has not been observed |
| observed | A pinned-reference run produced the recorded output |
| repeatable | Independent fresh-process runs agree |
| reviewed | Meaning and normalization checked; literal expectation approved |
| disputed | Output or intended portable behavior remains unresolved |
| environment-dependent | Requires a separately specified host/data profile |

Promotion to reviewed requires an explicit review record with reviewer, evidence,
and decision. A generator must never promote its own output merely because the
same result occurs twice. Freeze approved literal expectations before adapter
implementation; conformance runs must not regenerate them with the reference.

## Integration and continuation

Report artifact paths, exact commands/results, counts by review state, unresolved
partitions, and the next bounded task. The coordinator checks consistency against
the API inventory and updates the queue. Workers do not claim the entire family is
complete while obligations remain unaccounted for.

Portable exports contain only reviewed original features, the glossary/protocol,
small necessary expected-value fixtures, profile facts, attribution, and MIT notice.
Probe programs, source mappings, raw Perl observations, and this workflow document
stay on the research side. Follow [source separation](../planning/source-separation.md).
