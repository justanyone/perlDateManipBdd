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
retains the original contract-partition inventory. [feature-map.json](feature-map.json)
maps all 69 original portable case IDs to their actual feature, public operation
IDs, and evidence selector; its separately named binding case is excluded from
portable handoff.

[portability-map.json](portability-map.json) records the exact fixed fixture,
the six modifier-boundary requests and typed outcomes, and the impossible-February
request split. The portable disputed case says only that the public lookup is
interrupted before either return value exists. The raw Perl array-reference
diagnostic is preserved in `perl-binding.feature`, whose feature-level
`@excluded-from-portable-handoff` tag keeps it out of the portable contract.

The draft features deliberately retain three compatibility/disputed records:
modifier carrier/case behavior, modifier replacement clearing an existing
anchor, and a textual first optional parse argument (second argument overall) that reports success while
leaving an invalid-modifier error. These are minimal reproducers, not portable
normalization rules. DM5's exclusive and DM6's inclusive exact-upper-bound
results remain separate profile expectations.

Every recurrence feature now defines `utc-working-week-2040` in its own
Background. The repeated definition is intentional: each exported feature is
self-contained and fixes language, zone, clock, numeric-date order, omitted-time
rule, week rules, work schedule, and empty holiday/event data. Successful FD0
and FW0 modifier rows use the typed literal `empty text`; failed rows use
`text "..."`, so no empty error value is encoded as a blank table cell.

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

The one-attempt impossible-February probe terminates before returning an event
or lookup-error value. It is retained as a bounded suspected bug with a portable
compatibility/disputed case. Its exact Perl runtime diagnostic is asserted only
in the excluded binding feature and must be investigated before any completion
claim.

The original probe serialized `date: null` and `lookup_error: null` after that
interruption because its predeclared capture variables had never been assigned.
Those nulls were probe placeholders, not absent values returned by the public
call. The corrected record emits `call_completed: false` and omits both return
fields. Two independent fresh captures were identical, and a structural
comparison found no behavioral change beyond the new probe hash and this return
schema correction.

Coordinator review of the expanded batch corrected anchor installation order in
frequency and modifier-order cases. Append/recovery scenarios now explicitly
restore the anchor and include the intervening lookup performed by the probe.
The impossible-February case names its exact frequency text. These changes keep
the English steps faithful to state transitions; they do not conceal the separate
modifier-induced anchor-clearing compatibility behavior.

`python3 tools/review/recurrence_literals.py` checks evidence hashes and 49 draft
table rows against recorded frequency, setter, modifier, and lookup results. It
also checks append and recovery literals, every original case-to-operation map,
the repeated fixture against the pinned `oo` reference profile, the exact
impossible-February request block, and the portable/binding split. The record has 36 repeated
multi-action probe cases and 69 original portable feature IDs; neither count
discharges the outstanding partition register or establishes an executable BDD
pass.

Coordinator verification repeated every case twice with fixed PATH `/usr/bin:/bin`.
All36 prior observation records compare equal after restoring only the historical
unassigned placeholders and removing the new completion flag for the interrupted
lookup. The current evidence uses the fixed PATH; historical coverage is unchanged.
