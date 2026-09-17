# Required completion gate

The user's original completeness requirement was:

> Is Every single thing that Date::Manip can do reflected in the tests?
> Are there any edge cases that can be found or predicted (based on logic or
> the code, either one), that have no test case?
> Done is a COMPLETE test suite of the existing date::manip codebase,
> Every function, every usage type.

The user clarified that tests must call **public, non-private APIs only**, then
clarified that private helper logic should still inform public test cases. These
are separate boundaries: no direct tests of private helpers, but inspect and
measure the implementation reached through public calls, including private code.
The portable specification requires observable behavior, never helper names or
structure. Internal generation tools remain outside the public library scope.

The pinned reference is Date-Manip 7.00, including its current and legacy public
backends. Preserve the language-neutral portable specification and keep public
binding-specific tests on the research/binding side. Every public usage type and
identifiable public behavioral edge case remains required.

Completion requires all of the following evidence:

- Every public callable, including inherited, exported, aliased, generated, and
  supported compatibility APIs, has test evidence for its supported usage types.
  Mere package-symbol accessibility does not make a private helper a public API.
- Every identified grammar production, directive, option, argument shape, result
  carrier, error channel, mutation, and configuration domain has explicit cases.
- Source inspection and domain reasoning identify boundaries, invalid inputs,
  state sequences, and interacting settings. Every identifiable uncovered case
  becomes a tracked obligation and prevents completion until tested.
- Audit public API coverage against documented signatures and observable behavior.
  Inspect public and private implementation logic for observable edge cases.
  Measure statement and branch coverage across the pinned library, including
  private code reached through public calls, and review every uncovered path for
  missing public tests or evidenced unreachability. Record exclusions explicitly;
  never improve the reported percentage by silently removing uncovered code.
  The user accepted targets of **at least 99% statement coverage and 95% branch
  coverage** of the pinned library, including private code exercised through public
  calls. Review every uncovered statement and branch and document genuinely
  unreachable or out-of-scope code with evidence. Report measured totals and every
  exclusion explicitly. High coverage alone does not prove that the assertions
  test all relevant behavior.
- Suspected bugs have minimal characterization tests, recorded actual results,
  and explicit semantic dispositions. They must not disappear from coverage or
  become silently mandated behavior in the portable default profile.
- Every English assertion names concrete inputs, context, and literal outcomes.
  References to raw evidence rows or unspecified catalogue order are not tests.
- The original Perl harness executes the completed features and binding tests,
  preserves observed distinctions, and demonstrates assertion sensitivity.
  Frozen expected values are never recalculated using Date::Manip during tests.
- The final coverage report has no known untested public function, usage type,
  or identifiable edge case. It reports evidence, not scenario counts alone.
- The portable export passes the licensing/source-separation audit. The future
  non-Perl implementation remains outside this task.

Finite testing cannot exhaust every possible input string or prove that no unknown
defect exists. That fact does not permit leaving an identifiable case untested or
weakening the user's completion gate. The current drafts do not meet this gate.
