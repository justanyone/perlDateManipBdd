# Recurrence feature-family draft evidence

This directory records original, research-side probes for the Date-Manip 7.00
reference. The observations are repeatable, but none is an approved portable
expectation or an executable BDD test.

Run the bounded probe suite with:

```sh
python3 tools/probes/recurrence-family/run.py
```

The driver invokes every case twice in distinct reference processes with a
fifteen-second limit. It fixes `Etc/UTC`, English, the supplied reference
clock, a Monday-through-Friday work schedule, and empty holiday/event data.
It captures warnings, process diagnostics, object state, statuses, and lookup
errors. The DM5 deprecation warning is retained as an observed warning channel.

The resulting record contains 36 repeatable reference cases with narrow samples
for all 20 modifier families and the 12 public recurrence operation IDs, and separate DM5/DM6
functional description and exact-endpoint calls. It also records finite numeric
and written frequency forms, invalid frequency and field values, typed field
carriers, a day-sized default range, a one-attempt no-match exception, modifier
boundaries, ordering, append behavior, and rejected-update recovery. [coverage.json](coverage.json)
maps every draft feature case to its contract partition and evidence case.

The draft features deliberately retain three compatibility/disputed records:
modifier carrier/case behavior, modifier replacement clearing an existing
anchor, and a textual first optional parse argument (second argument overall) that reports success while
leaving an invalid-modifier error. These are minimal reproducers, not portable
normalization rules. DM5's exclusive and DM6's inclusive exact-upper-bound
results remain separate profile expectations.

Every known unfinished method partition, grammar/context inventory, modifier
family boundary, and predicted edge is listed in
[remaining-obligations.md](remaining-obligations.md). That register contains all
105 method partitions, all seven grammar/context inventories, and all 20
modifier families. It prevents sampled rows from being mistaken for completion.

Coordinator review corrected the derived-value probe to observe the actual source
date before and after creation. Recovery now supplies an explicit serialized
recurrence and checks its cleared error and first event. Frequency replacement
preserves both before and after snapshots. Two full review runs, each repeating
every case twice, were byte-identical. The English drafts now reflect actual
modifier setup order, fresh carrier cases, and explicit navigation results.
These targeted corrections do not approve all literals or discharge whole
partitions; semantic review and the unfinished obligations above remain required.

The one-attempt impossible-February probe terminates with a captured runtime
exception instead of a lookup return. It is retained as a bounded suspected bug
with a compatibility/disputed feature, and must be investigated before any
completion claim.

Coordinator review of the expanded batch corrected anchor installation order in
frequency and modifier-order cases. Append/recovery scenarios now explicitly
restore the anchor and include the intervening lookup performed by the probe.
The impossible-February case names its exact frequency text. These changes keep
the English steps faithful to state transitions; they do not conceal the separate
modifier-induced anchor-clearing compatibility behavior.

`python3 tools/review/recurrence_literals.py` checks evidence hashes and 49 draft
table rows against recorded frequency, setter, modifier, and lookup results. It
also checks append and recovery literals. The record has36 repeated multi-action
probe cases and69 feature IDs; neither count discharges the outstanding partition
register or establishes an executable BDD pass.
