---
name: date-manip-debugging
description: Diagnose failing Date::Manip BDD scenarios, configuration leaks, backend differences, and unexpected date or timezone results. Use when a failure needs investigation, not for general planning.
---

# Date::Manip failure diagnosis

Adapted from obra/superpowers systematic-debugging at revision
b36e0829c6d0140e93cfef2ca599b1b07d4a7797. Copyright (c) 2025 Jesse Vincent, MIT;
retain [the original notice](../../../licenses/superpowers-MIT.txt).
See [provenance](../../../THIRD_PARTY_NOTICES.md).

1. Capture the exact command, input, expected/actual result, exit code, Perl version,
   Date::Manip version, backend, timezone, language, reference time, and business rules.
   Log only the configuration relevant to the failure, not the entire environment.
2. Reduce to one scenario in a fresh Perl process. Test whether order or import-time
   configuration matters. Separate a missing dependency or harness error from an
   assertion about Date::Manip behavior.
3. Read the specific API contract. Compare the selected version with a working case;
   trace incorrect values back through configuration, parsing, and conversions until
   the earliest divergence is identified. Inspect only relevant upstream files.
4. Form one falsifiable hypothesis. Change one factor at a time, then rerun the
   reproducer. If it fails to explain the result, revise the hypothesis using evidence.
5. Classify the cause: harness defect, incorrect expectation, state/environment leak,
   version/backend difference, or suspected upstream bug. Retain a minimal regression
   case. Do not silently weaken assertions or label unexplained failures as passes.
6. Fix authorized project code, rerun the reproducer and relevant suite, and record
   evidence. An upstream issue report can be drafted locally; posting it requires
   user authorization. Modifying or importing upstream source also requires following
   [the licensing policy](../../../docs/licensing.md).

For a complex fix or a disputed completion claim, read
[verification-before-completion](references/verification-before-completion.md).
It is a copied methodological reference, not permission to expand the task, run
unrelated checks, or require a failure from a correct existing upstream implementation.
Report unresolved failures and version limits precisely.
