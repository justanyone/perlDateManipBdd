# Focused recurrence observations

Sixteen original probes were run twice each in fresh processes against the pinned
reference profiles. The [raw record](recurrence-ambiguities.json) retains inputs,
configuration linkage, runtime metadata, return/error channels, setup order, and
probe/fixture hashes. This is research evidence, not an approved feature suite.

Reproduce without overwriting any evidence:

```sh
python3 tools/probes/run-recurrence-ambiguities.py > /tmp/recurrence-observations.json
```

The runner limits each process to fifteen seconds. It verifies repeatability but
does not calculate expected outputs or approve them. The coordinator separately
checked the seven weekday results with Python's Gregorian date functions.

| Question | Observed result | Disposition |
| --- | --- | --- |
| Previous-weekday modifier numbering | Parameters 1 through 7 select Monday through Sunday; selecting the anchor's weekday moves back seven days. | Documentation inconsistency resolved for these seven original inputs; wider modifiers still need tests. |
| Upper endpoint in functional enumeration | DM5 omits the occurrence at `2040-04-15 12:34:56`; DM6 includes it. | Keep separate backend contracts. |
| Uppercase comma-separated modifier string | Accepted and yields the same date as the tested lowercase argument list. | Carrier-specific observed behavior. |
| Two uppercase modifier arguments | Rejected with a modifier error; lookup reports an invalid recurrence. | Source/POD compatibility discrepancy; do not impose this on the default portable modifier list. |
| Change modifiers after assigning an anchor | The requested anchor becomes absent; lookup reports an incomplete recurrence. | Observable state change requiring a dedicated compatibility scenario and review. |
| Positional text anchor in `parse` without an explicit modifier | Parse returns zero, but retains an invalid-modifier error and later lookup fails. | Suspected upstream bug; zero parse status alone is insufficient evidence of a usable recurrence. |
| Equivalent typed positional anchor or separate anchor setter | Both produce the anchor occurrence with zero lookup error. | Control cases supporting the positional-text reproducer. |

The initial exploratory modifier runs were affected by the positional-text error,
then by the modifier operation clearing the anchor. The retained probes isolate
both transitions as their own cases. Weekday/modifier semantics probes explicitly
set the anchor **after** modifiers; their output records that setup call. They do
not clear the error state to hide a failure.

These observations refine `recur.parse`, `recur.set-modifiers`,
`recur.set-base-date`, `recur.occurrence-at-index`, and
`recur.parse-and-enumerate` obligations in the [recurrence catalogue](../contracts/recurrence.json).
They do not discharge whole grammar partitions, approve default portable quirks,
or establish DM5/DM6 equivalence for other inputs. Semantic review and original
English scenarios are still required.
