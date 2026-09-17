# Specification work checkpoint

This file is the human-readable companion to [queue.json](queue.json). It records
the durable state of the planning queue, rather than claiming that its work has run.

## Current state

- Queue schema: 1
- Workspace baseline: `workspace-setup` is `current`, owned by `root`.
- Completed batches: `reference-setup` and `api-reconciliation`, reviewed by the coordinator.
- Active batches: `spec-interpretation-formatting`, `spec-arithmetic-deltas`, and
  `spec-recurrence`, `spec-zones-business`, and `spec-configuration-objects`.
  Coverage review and harness stages remain `pending`.
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
  Auxiliary syntax/option obligations link the finite inventories in `docs/research/syntax/`.
  Source support is distinct from runtime coverage; DM5 support is recorded per row.
- Completed worker drafts: `docs/research/contracts/{calendar,values,arithmetic,
  recurrence,zones-business}.json` and companion Markdown. The coordinator
  checked all 96 operation IDs and binding sets against the API map. These contain
  397 unobserved method-partition obligations, not 397 executed cases.
- `configuration-domains.json` records 38 configuration keys and documented
  domains/defaults; runtime-only ambiguities and file-section grammar remain open.
- Active workers: `zones_business_features`, `arithmetic_features`, and
  `configuration_features`. Rendering has returned a draft for coordinator review. Each owns its corresponding `spec/drafts/` family,
  `tools/probes/*-family/`, and `docs/research/*-family/` directories. Inspect live
  agent status before restarting workers; partial files are not completion evidence.
- Worker batches under coordinator review: arithmetic has
  59 repeated cases spanning 16 operation IDs; recurrence has 35 candidate IDs in
  three drafts, 31 repeatable observations, and mappings spanning 12 operation IDs.
  Their README files list substantial remaining obligations. A partition-ID link
  is not evidence that every dimension in that partition has been discharged.

Independent read-only audit found exact correspondence with all 423 declaration
rows, mappings for 164 public declaration bindings and 96 generic operation IDs,
and runtime evidence for 153 concrete OO receiver/method combinations. Both export
lists (34 DM6, 33 DM5) are accounted for. This establishes entrypoint accounting,
not complete behavioral coverage: signatures, option partitions, reference
observations and English features still need completion and review.

Current next actions: continue English feature authoring and literal-observation
review against the accepted catalogues. Review arithmetic and recurrence worker
artifacts first, including fixture fidelity, literal results, English step meaning,
and incomplete coverage. The coordinator also owns calendar, parsing, and language
work; rendering, zone/business, and configuration/object workers are active.
Do not re-enumerate finished syntax inventories. Required input/option variants
and unobserved partitions stay visible during feature authoring.

The date inventory covers 61 rendering spellings, 52 pattern directives, 167 text
production spellings, and 7 grammar gates, with a complete DM5 comparison. Delta
inventory covers 20 productions, 5 format families, 7 fields, 28 field ranges,
calculation modes, and dispatch variants. Language/config inventory accounts for
16 languages, 45 selectors, token classes, 38 keys, and file/holiday/event grammar.

Calendar evidence: 231 binding cases each repeated twice in isolated processes.
Independent stdlib review classifies 190 reviewed, 28 compatibility, 3 invalid, and
10 unreviewed incomplete-field calls. Fifty-two English candidate cases are in
`spec/drafts/calendar.feature` and `calendar-validation.feature`, linked by
`docs/research/calendar-feature-map.json` and `calendar-validation-map.json`.
Their literals match 116 original calls; 50 cases have independent fact review,
while 24:00 acceptance and fractional-second rejection retain compatibility review.
They remain draft, and no BDD runner has executed them. The initial Base fixture
warning was fixed by configuring a Date object then retrieving its Base service;
the entire corpus was rerun after that fix.

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

## Latest review checkpoint

The user reconfirmed scope: complete the specification, then implement and verify
its Perl harness. Arithmetic is undergoing targeted authoring corrections for
unspecified options, patterns, profiles and field types. Configuration is correcting
snapshot reads that themselves created unset-value errors. Rendering returned
13 repeatable invocations with 61 native spellings/families and 12 POSIX override
samples; its evidence and English drafts still await coordinator review.

Recurrence coordinator corrections now capture the actual source date before and
after derived creation, use concrete serialized recovery input, retain before/after
frequency replacement states, and align feature setup order with the probe.
Navigation assertions and functional lower bounds are explicit. All 31 cases
repeated twice in each of two byte-identical review runs. Targeted lifecycle
literal checks and all partition links pass. These are reviewed draft corrections,
not a completed recurrence family or an executed BDD suite. Continue full semantic
review and the listed gaps before promoting any family.
