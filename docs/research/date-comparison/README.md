# Public date comparison observations

These 49 original cases characterize the pinned Date-Manip 7.00 public comparison
operation. They remain draft evidence, not an executed BDD suite or a completed
comparison specification. The portable feature contains all literal requests and
results; `feature-map.json` records the Perl bindings separately.

The object and current functional profiles return no result for the sampled
invalid operands. The legacy functional profile instead orders invalid text
before a valid date and considers two failed parses equal. For equal wall times
in UTC and New York, the object/current profiles report UTC first; the legacy
profile reports equality. These differences remain explicitly disputed reference
behavior, not silently adopted requirements of the default portable profile.

Thirteen public calendar-service cases compare six numeric fields, with each
field independently deciding order in both directions and one equality case.
This operation does not validate calendar dates: the February 30 field collection
is deliberately retained as a field-comparison case. The other 36 cases exercise
object/current/legacy comparison, second precision, leap and year boundaries,
different zones, invalid strings, empty strings and an absent argument value.

Each case runs twice in separate processes and temporary working directories with
the shared fixed reference configuration and a minimal environment. Evidence
retains native returns, parse/error channels, warnings, captured output, runtime,
loaded module paths and hashes. Object errors are read before and after comparison
without intervening value getters. Warnings are research evidence; the portable
feature does not require Perl warning text. No private function is invoked.

Run from the repository root:

```sh
python3 tools/probes/date-comparison/run.py > /tmp/date-comparison-new.json
python3 tools/probes/date-comparison/review.py
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" perl tools/runner-trial/parse-features.pl spec/drafts/date-comparison/order.feature
```

Review fresh observations before replacing frozen evidence. The reviewer checks
each example's inputs and results against its own evidence row, not mere presence
of an expected value somewhere in a feature. The real parser expands 49 examples;
parsing does not execute them against Date::Manip.

Remaining partitions include unset/error-cleared receivers, wrong operand types,
omitted rather than explicitly absent arguments, collection length and nonnumeric
fields, list-context results, DST overlap ordering within a zone, date limits,
custom zones, changed configuration and mutation/cache sequences. Warning-specific
binding scenarios and final executable adapter coverage are also outstanding.
