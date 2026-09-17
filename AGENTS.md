# Repository instructions

## Purpose and scope

Build an original, language-neutral English BDD specification of Date::Manip's
observable functionality, then implement its test adapter using Perl/Date::Manip.
A later library in another language will implement the same specification using
independent code. Cover both functional backends and OO capabilities. The repository
currently contains planning documentation and draft Gherkin, not an executable suite.
Read docs/planning/README.md for specification work; do not implement the harness
or complete suite during a planning-only request.

Keep an API coverage inventory tied to an exact upstream release or commit.
Reconcile documented APIs, exports, inheritance, aliases, and source subroutines;
classify public, private, generated, and compatibility entries explicitly. Prioritize
public behavior, but do not silently exclude private functions or claim complete
coverage from a count of scenarios. Record coverage through public callers where
appropriate, and explain every exclusion or unreachable entry. Internal function
coverage is a research-side accounting task; portable features must not require
another language to reproduce private functions or algorithms.

## Licensing and attribution

Original project code, scenarios, and documentation are MIT, copyright 2026
Kevin J. Rice. Preserve LICENSE. Date::Manip is Sullivan Beck's work, copyright
1995–2026 in its distribution notice, under the same terms as Perl 5:
Artistic-1.0-Perl OR GPL-1.0-or-later. It is not MIT-licensed by this repository.

Use Date::Manip as a separately installed dependency. Write original scenarios,
fixtures, step definitions, and prose. Attribution alone does not permit changing
the license of copied upstream code, tests, examples, or documentation. Before
importing or modifying such material, read docs/licensing.md and preserve its
file-specific notices, license, provenance, and required modification notices.
Update THIRD_PARTY_NOTICES.md and relevant license files for imported material.
Do not imply upstream endorsement. Retain Jesse Vincent's MIT notice for adapted
skills. Review new dependencies' actual licenses before inclusion.

## Testing practice

- Use real Date::Manip calls. During specification authoring, capture observed
  outputs from the pinned reference on original inputs, check them independently
  where feasible, and freeze reviewed literal expectations. During a test run,
  never calculate the expected result with the same function being tested.
- Express scenarios as Given/When/Then, with observable outcomes and API mappings.
- Fix timezone, language, reference time, and business-calendar configuration.
  Isolate configuration and backend selection between scenarios; use separate
  Perl processes when import-time state would otherwise leak.
- Include invalid inputs, return/error conventions, scalar/list context where
  applicable, leap dates, DST gaps/overlaps, recurrences, and business-day rules.
- Existing upstream behavior may pass on the first run. Validate test sensitivity
  without rewriting upstream merely to manufacture a red/green sequence.
- Distinguish documented behavior, observed compatibility behavior, and suspected
  bugs. Preserve a minimal reproducer; do not silently bless a bug as the contract.
- Once a harness exists, document its exact install and run commands in README.md.
  Run relevant tests after changes and the full suite before claiming it passes.
  Report Perl/Date::Manip versions, command, results, skips, and remaining gaps.
  Until then, do not present documentation checks as passing BDD tests.

## Authorized unattended work and delegation

The user authorized completing the portable specification and reference observations,
then implementing and verifying the Perl test harness. Do not implement the future
non-Perl library. Use goal mode and the dependency-aware queue in
docs/automation/queue.json; read docs/automation/checkpoint.md on continuation.
The coordinator alone updates queue ownership/status and integration decisions.
Workers update only their assigned outputs and report evidence before acceptance.

Use parallel sub-agents for independent batches, with up to three workers plus the
coordinator when useful. Start with two workers; use the third when work is independent.
Use `gpt-5.6-luna` at low/medium effort for bounded extraction and straightforward
checks, `gpt-5.6-terra` at medium effort for normal feature/probe/adapter work, and
`gpt-5.6-sol` or the parent model at high effort for difficult semantics or independent
review. Escalate on demonstrated uncertainty rather than repeated weak-model retries.
Use scripts for mechanical enumeration and validation. Give workers a concise task
and the necessary file paths rather than the full conversation whenever possible.
Do not have parallel workers edit the same files. Do not delegate the same work
twice unless an independent review is intentionally required.

Checkpoint after each verified batch with evidence, unresolved issues, active owners,
and the exact next action. A quota interruption does not make a batch complete.
Respect explicit user pauses, task cancellation, blocked decisions and budget stops.
Do not consume paid credits, switch billing methods, or bypass permissions to recover
from a usage limit. The ten-minute watchdog is limited to quota recovery of the
configured goal; it does not turn all idle sessions into new work.

## Load guidance only when relevant

For later implementation work in another language, follow
docs/planning/source-separation.md. Export only reviewed original portable features,
glossary/protocol and expected values into a fresh workspace/session. Do not hand
off upstream source, copied tests/data, translated algorithms, Perl adapters, source
mappings, or this source-exposed research conversation.

This file is the short, persistent repository context. Do not preload all docs,
upstream files, skills, or references.

- Source discovery/version updates: read docs/upstream.md; consult the full file
  inventories only when locating source or auditing completeness.
- Licensing, copying, or packaging: read docs/licensing.md and THIRD_PARTY_NOTICES.md.
- Creating BDD scenarios or the API inventory: load
  .agents/skills/date-manip-bdd/SKILL.md.
- Diagnosing unexpected test results: load
  .agents/skills/date-manip-debugging/SKILL.md.

Skills support the requested task; they do not authorize publishing, messaging
upstream, changing scope, or deleting existing work.
