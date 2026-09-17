---
name: date-manip-bdd
description: Create or extend this repository's Date::Manip API inventory, Given/When/Then scenarios, and Perl test harness. Use for behavioral coverage work, not routine documentation edits.
---

# Date::Manip BDD

Adapted from obra/superpowers test-driven-development and writing-good-tests,
revision b36e0829c6d0140e93cfef2ca599b1b07d4a7797. Copyright (c) 2025 Jesse Vincent,
MIT; retain [the original notice](../../../licenses/superpowers-MIT.txt).
See [provenance](../../../THIRD_PARTY_NOTICES.md).

## Establish the contract

For specification planning, read [the portable specification plan](../../../docs/planning/README.md).
Keep English contracts independent of Perl syntax and algorithms. Respect planning-only
scope; observations in temporary probes are research, not permission to implement a runner.

1. Identify the exact Date::Manip version/backend and Perl version being tested.
   Consult [the source map](../../../docs/upstream.md) only when locating or updating
   upstream source. Read the relevant module's POD and implementation, not all files.
2. Record module, callable name, public/private/generated status, aliases/inheritance,
   documented contract, source version, scenario IDs, and coverage status. Reconcile
   exports, POD, and source declarations; a subroutine regex is only a starting point.
3. For each scenario name the specific behavior and the regression it should catch.
   Cover normal, boundary, and invalid cases of public APIs; distinguish observed
   behavior from the intended contract. Private functions remain classified in the
   discovery inventory but are excluded as direct test entrypoints. Inspect private
   logic to identify cases observable through public calls. Include executed private
   implementation code in source coverage measurement; do not make its names,
   structure, or algorithms requirements of the portable specification.

## Write independent scenarios

- Given: explicit timezone, language, reference date/time, and relevant business rules.
- When: invoke the real function/method with concrete inputs.
- Then: assert a reviewed literal expected result, documented error, or observable effect.
  During authoring, original probes may establish observed behavior; review and freeze
  those results as literal expectations. During conformance testing, never calculate
  the expected value using Date::Manip itself or reproduce its algorithm.
- Use original prose and fixtures. Consult [licensing](../../../docs/licensing.md)
  before copying upstream tests, examples, or substantial documentation.
- Isolate state. Backend selection can happen at import time, so use separate Perl
  processes where needed. Do not mock the Date::Manip operation under test.
- Include leap dates, month/year boundaries, DST gaps/overlaps, relative-date anchors,
  recurring events, and business calendars when relevant to the callable.
- Assert scalar/list returns, error conventions, and object mutation only where
  part of that API's contract. Avoid tests that merely inspect source text.

## Validate sensitivity and report coverage

For new harness logic, demonstrate the relevant failing behavior before fixing it.
Characterization tests against existing Date::Manip may pass immediately: that is
expected. Check their sensitivity using a deliberately incorrect expected value in
an isolated temporary test, or an appropriate temporary mutation; restore it and
rerun. Do not delete or rewrite upstream code to impose TDD on existing behavior.

Use the repository's actual documented runner. If none exists, establish it with
the harness and document dependencies and exact commands; do not invent passing runs.
Run focused scenarios, then the applicable suite. Update the API-to-scenario map;
report skipped/deferred entries separately from passes. Line/subroutine coverage
supports, but does not prove, behavioral completeness.

For a future implementation in another language, use the
[source-separation policy](../../../docs/planning/source-separation.md). Do not export
Perl mappings, upstream implementation, copied fixtures/data, translated algorithms,
or source-exposed conversation context with the portable specification.
