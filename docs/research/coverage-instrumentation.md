# Logical-branch coverage instrumentation

This repository uses Devel::Cover 1.52 with Perl 5.40.1. A bounded diagnostic
found that collecting `statement,branch` alone creates branch criteria for Perl
statement modifiers and short-circuit expressions but leaves both recorded
outcomes at zero. The program still executes normally, so those zero counters
cannot support an unreachable-code conclusion.

The behavior follows directly from the installed coverage tool. In
`Cover.xs`, `cover_logop` returns unless condition collection is active. In
`Devel/Cover.pm`, `add_branch_cover` derives branch counts for `and`, `or`, and
the corresponding modifier forms from the condition counter associated with
that logical op. Requesting branch coverage does not implicitly activate that
condition collector. Devel::Cover 1.52's change log records testing with the
Perl 5.40 series, so this finding is a criterion-selection dependency in this
pinned combination, not evidence that the target branch is unreachable.

The original fixture in
[`tools/coverage-healthcheck/fixture.pl`](../../tools/coverage-healthcheck/fixture.pl)
executes both outcomes of a simple statement modifier and all short-circuit
paths of a two-term modifier. Its runner starts fresh processes with an empty,
fixed environment and compares uninstrumented output with both instrumented
runs. The `statement,branch` run is retained as a zero-hit control. The
`statement,branch,condition` run must record branch counts `[1,1]` and `[2,1]`;
any zero target outcome makes the command and unit test fail. Missing pinned
Devel::Cover files cause an explicit test skip instead of a false pass. A
different Perl or Devel::Cover version at the pinned paths fails the check,
because this health result is specific to Perl 5.40.1 and Devel::Cover 1.52.

Run the focused diagnostic and its regression test with:

```sh
python3 tools/coverage-healthcheck/run.py
python3 -m unittest tests.coverage.test_instrumentation_health -v
```

The verified command shape for coverage collection is:

```text
/usr/bin/perl -MDevel::Cover=-db,DATABASE,-coverage,statement,branch,condition,-silent,1,-select,SOURCE SOURCE
```

Reports may omit condition criteria from their published totals, but runtime
instrumentation must request `condition` whenever branch totals include Perl
logical ops. Historical databases collected without it retain their literal
numeric evidence, while their zero logical-branch counters remain unsuitable
for branch-completeness claims.
