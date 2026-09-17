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

The resulting record contains 31 repeatable reference cases with narrow samples
for all 20 modifier families and the 12 public recurrence operation IDs, and separate DM5/DM6
functional description and exact-endpoint calls. [coverage.json](coverage.json)
maps every draft feature case to its contract partition and evidence case.

The draft features deliberately retain three compatibility/disputed records:
modifier carrier/case behavior, modifier replacement clearing an existing
anchor, and a textual first optional parse argument (second argument overall) that reports success while
leaving an invalid-modifier error. These are minimal reproducers, not portable
normalization rules. DM5's exclusive and DM6's inclusive exact-upper-bound
results remain separate profile expectations.

Unfinished obligations include the full numeric and written grammar grids,
modifier parameter bounds and mixed-case recovery, append/order behavior,
typed-date setter equivalence, invalid field values, default range settings,
MaxRecurAttempts, DST, holiday/event interactions, scalar/list invalid
functional results, bounds on unmodified events, duplicate/reordered events,
and all context-grid combinations. The 105 method partitions and seven grammar
or context inventories are therefore not complete.

Coordinator review corrected the derived-value probe to observe the actual source
date before and after creation. Recovery now supplies an explicit serialized
recurrence and checks its cleared error and first event. Frequency replacement
preserves both before and after snapshots. Two full review runs, each repeating
every case twice, were byte-identical. The English drafts now reflect actual
modifier setup order, fresh carrier cases, and explicit navigation results.
These targeted corrections do not approve all literals or discharge whole
partitions; semantic review and the unfinished obligations above remain required.
