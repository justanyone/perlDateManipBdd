# Specification work checkpoint

This file is the human-readable companion to [queue.json](queue.json). It records
the durable state of the planning queue, rather than claiming that its work has run.

## Current state

- Queue schema: 1
- Workspace baseline: `workspace-setup` is `current`, owned by `root`.
- Completed batch: `reference-setup`, reviewed by the coordinator.
- Active batch: `api-reconciliation`; entrypoint accounting is audited, while
  detailed signatures and auxiliary behavior partitions remain in progress.
- Other project batches remain `pending`.
- Scope: English, language-neutral specification and reference observations, followed
  by the original Perl BDD harness, step definitions, adapter, and full-suite
verification. A future non-Perl implementation remains out of scope.

## Execution setup

The user authorized goal mode, parallel workers selected by task complexity, and
the full specification followed by a verified Perl harness. The active goal is
stored by Codex; this checkpoint is the durable fallback when a session cannot
continue. Do not mark that goal complete merely because automation setup is done.

Local protocol research found that this VS Code session uses a stdio app server
without the managed control socket needed for an external resume client. The
ten-minute watchdog is installed and enabled as a read-only detector. It
cannot promise automatic recovery after quota renewal in this topology. No
second Codex process, billing change, or direct goal-database update is used.
See [watchdog operation and stop commands](watchdog.md). Ten isolated tests pass;
the installed service successfully reported `no_action` for the active goal.

Current independent worker outputs:

- Accepted reference: `tools/reference/`, `docs/reference-environment.md`,
  `reference-profiles.json`. All three profiles repeated successfully; script
  hashes, leap-day facts, and weekday facts were independently checked.
- Accepted monitor: `tools/automation/`, `tests/automation/`, watchdog instructions.
- Accepted entrypoint accounting: `tools/inventory/`, `docs/research/api/`.
  Both enumerator checks pass (423 declarations, 153 OO receiver routes).
  The auxiliary catalogue has visible outstanding term-extraction obligations.
- Completed worker drafts: `docs/research/contracts/{calendar,values,arithmetic,
  recurrence,zones-business}.json` and companion Markdown. The coordinator
  checked all 96 operation IDs and binding sets against the API map. These contain
  397 unobserved method-partition obligations, not 397 executed cases.
- `configuration-domains.json` records 38 configuration keys and documented
  domains/defaults; runtime-only ambiguities and file-section grammar remain open.
- No workers remain active at this checkpoint. Resume by assigning the bounded
  research tasks below; avoid duplicating the finished family drafts.

Independent read-only audit found exact correspondence with all 423 declaration
rows, mappings for 164 public declaration bindings and 96 generic operation IDs,
and runtime evidence for 153 concrete OO receiver/method combinations. Both export
lists (34 DM6, 33 DM5) are accounted for. This establishes entrypoint accounting,
not complete behavioral coverage: signatures, option partitions, reference
observations, and English features still need completion and review.

Next unassigned research work: enumerate finite date formatting/pattern-parsing
directives and accepted date/time productions; refine delta grammar/directive
families into explicit cases; enumerate legacy DM5 syntax differences; complete
language/token-class and config-file grammar partitions; discharge recurrence
structural grids. Review the method catalogues for any remaining vague selectors
or signatures. The API batch is not complete until these auxiliary obligations
are explicit. Then assign the five feature families in parallel with original
probes, reviewed literal observations, and English scenarios.

Coordinator review corrected Base tuple carriers (array references differ from
list returns) and renamed `arithmetic.time-difference` to
`arithmetic.combine-times`, since the method supports both addition and
subtraction. The generator and map use the corrected ID.

Sixteen focused recurrence cases now repeat in isolated processes; seven weekday
facts were independently checked. See
[recurrence observations](../research/observations/recurrence-ambiguities.md).
They expose backend endpoint differences, modifier case/carrier differences,
modifier-induced anchor clearing, and a suspected positional-anchor parse bug.
These remain research observations, not approved portable feature expectations.

`reference-preflight.json` is historical partial evidence. Use
`reference-profiles.json` for the reviewed setup. In particular, DM5 exposes
compatibility API version 5.66 within distribution 7.00 and does not report the
DM6/OO timezone-data identifiers. Its fixed-clock relative-date behavior differs.

The coordinator reviews evidence, installs the monitor, and integrates accepted
outputs. On interruption, inspect these paths and the queue before starting new
workers; existing artifacts may be partial and are not acceptance evidence alone.

## Ordering and parallel work

`reference-setup` precedes `api-reconciliation`. Once both are complete, the five
`feature-families` batches may proceed independently in parallel. `coverage-review`
waits for API reconciliation and every feature-family batch. The approved English
specification then receives internal review before harness setup, adapter work, and
full-suite validation proceed in order.

```text
reference-setup -> api-reconciliation -> feature families -> coverage-review
                                      |-> interpretation-formatting
                                      |-> arithmetic-deltas
                                      |-> recurrence
                                      |-> zones-business
                                      `-> configuration-objects

coverage-review -> internal-spec-review -> perl-harness-setup
                -> perl-adapter-implementation -> perl-validation
```

## Checkpoint protocol

The coordinator is the sole editor of this file and `queue.json`. Before changing a
batch status, the coordinator verifies its dependency statuses and records the
completed outputs, acceptance evidence, unresolved items, and the next eligible
batches in the change summary. Contributors do not edit queue state; they provide
evidence and proposed updates to the coordinator. The coordinator also checks
source-separation requirements at internal specification review and final validation.

Use only the statuses defined by the queue: `pending`, `in_progress`, `blocked`,
`complete`, and the baseline-only `current`. A blocked batch stays visible with its
blocker and does not permit dependent batches to start. A complete batch keeps its
outputs and acceptance evidence discoverable through its linked planning artifacts.
