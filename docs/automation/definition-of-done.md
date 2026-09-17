# Required completion gate

The user's original completeness requirement was:

> Is Every single thing that Date::Manip can do reflected in the tests?
> Are there any edge cases that can be found or predicted (based on logic or
> the code, either one), that have no test case?
> Done is a COMPLETE test suite of the existing date::manip codebase,
> Every function, every usage type.

The user subsequently clarified that this means **public, non-private APIs only**.
Private functions are not part of the requested feature set. This clarification
supersedes earlier requirements for direct private tests, indirect execution
coverage, and private function/branch accounting. Internal generation tools are
also outside the public library API. Private declarations may remain in discovery
inventories solely to document this boundary.

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
  Source inspection may identify additional public edge cases, but executing
  private functions or covering their implementation branches is not a gate.
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
