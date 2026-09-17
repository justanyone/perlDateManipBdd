# Required completion gate

The user's definition of done is:

> Is Every single thing that Date::Manip can do reflected in the tests?
> Are there any edge cases that can be found or predicted (based on logic or
> the code, either one), that have no test case?
> Done is a COMPLETE test suite of the existing date::manip codebase,
> Every function, every usage type.

This requirement supersedes any interpretation of earlier plans that would allow
representative sampling, untested private functions, or deferred known cases to
count as completion. The pinned reference is Date-Manip 7.00, including its current
and legacy backends. Preserve the language-neutral portable specification and
keep implementation-specific tests on the research/binding side.

Completion requires all of the following evidence:

- Every declared, inherited, exported, aliased, generated, and compatibility
  callable has test evidence for its supported usage types. Private functions
  require demonstrated execution through public scenarios or separate original
  tests; a proposed caller mapping alone is insufficient.
- Every identified grammar production, directive, option, argument shape, result
  carrier, error channel, mutation, and configuration domain has explicit cases.
- Source inspection and domain reasoning identify boundaries, invalid inputs,
  state sequences, and interacting settings. Every identifiable uncovered case
  becomes a tracked obligation and prevents completion until tested.
- Source execution coverage is audited for uncovered functions and branches.
  Coverage percentages support the audit but cannot replace behavioral tests.
  Unreachable code needs evidence and a reviewed explanation, not an assumed
  exclusion. Earlier tooling exclusions must be revisited under this requirement.
- Suspected bugs have minimal characterization tests, recorded actual results,
  and explicit semantic dispositions. They must not disappear from coverage or
  become silently mandated behavior in the portable default profile.
- Every English assertion names concrete inputs, context, and literal outcomes.
  References to raw evidence rows or unspecified catalogue order are not tests.
- The original Perl harness executes the completed features and binding tests,
  preserves observed distinctions, and demonstrates assertion sensitivity.
  Frozen expected values are never recalculated using Date::Manip during tests.
- The final coverage report has no known untested in-scope function, usage type,
  or identifiable edge case. It reports evidence, not scenario counts alone.
- The portable export passes the licensing/source-separation audit. The future
  non-Perl implementation remains outside this task.

Finite testing cannot exhaust every possible input string or prove that no unknown
defect exists. That fact does not permit leaving an identifiable case untested or
weakening the user's completion gate. The current drafts do not meet this gate.
