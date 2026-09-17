# Public behavior gap ledger

This ledger reconciles the 397 coarse public behavior partitions in the five
contract inventories with the repository's recorded observations, case maps,
feature maps, draft features, and explicit remaining-work notes. It is a work
queue, not a coverage-completion claim.

## Result

All 96 canonical operations in these five inventories have some committed
operation-level evidence. Seventy-nine operations have committed evidence in a
primary-operation role; seventeen appear only as supporting calls. These facts do
not show that the usage domains are complete. At the partition level:

| Contract family | Partitions | Committed direct observed links | No committed direct observed link |
| --- | ---: | ---: | ---: |
| Arithmetic and delta | 58 | 56 | 2 |
| Calendar and epoch | 69 | 0 | 69 |
| Recurrence | 105 | 51 | 54 |
| Values | 80 | 6 | 74 |
| Zones and business calendars | 85 | 45 | 40 |
| **Total** | **397** | **158** | **239** |

None of the 397 source partitions has an explicit reviewed full-domain completion
disposition. The ledger therefore leaves all 397 unresolved. Of the 158 directly
linked observed partitions, 141 also have a direct feature or feature-map case.
The remaining 17 are arithmetic/delta observations that still need direct feature
links. A matching operation identifier, a sampled case, or even a structured
partition link is evidence present; none is promoted automatically to fulfilled.

The committed snapshot records its exact Git commit plus the path and SHA-256 of
every evidence blob in `evidence_manifest`. It reads those bytes from the fixed
commit, so a locally modified tracked file contributes its committed version.
Staged-only and untracked content cannot reduce a gap until it is reviewed,
committed, and the ledger is regenerated. Each manifest entry separately records
the committed blob provenance.

The source contract files still mark every partition `unobserved`. Several later
families have strong repeated evidence, but their own notes explicitly retain
uncovered boundaries. Recurrence's remaining-obligations register goes further:
it states that sampled observations do not discharge any whole partition.

## Status and priority model

Every ledger row has two independent axes:

- `evidence_state` reports whether an observed case is structurally linked to the
  exact operation and partition, or whether only operation-level evidence exists.
- `resolution_status` reports whether the whole described domain has been
  explicitly reviewed and discharged. Every current row is `unresolved`.

Future rows become fulfilled only when their contract status is explicitly
`fulfilled`, `complete`, or `reviewed-complete` and the partition names
`completion_evidence` or `review_evidence`. This prevents case accumulation from
silently closing the queue.

The queue priorities are mechanical and conservative:

1. `P0-establish-committed-primary-evidence`: no committed primary-operation
   evidence for the exact partition. Supporting calls do not close this gate.
   There are 63 rows.
2. `P1-link-and-observe-partition`: primary-operation evidence exists, but no
   observed case is structurally tied to this exact partition. There are 176 rows.
3. `P2-author-feature-for-observed-partition`: an observed partition case exists,
   but it lacks a direct feature case/map link. There are 17 rows.
4. `P3-review-composite-partition-for-fulfillment`: observation and feature links
   exist, but the full domain still needs semantic review. There are 141 rows.

Within a priority, operations with the most missing direct partition links come
first. The first committed-evidence gaps are:

| Operation | Missing direct observations | Total partitions | Immediate scope |
| --- | ---: | ---: | --- |
| `recur.previous-occurrence` | 7 | 9 | establish primary evidence for first/anchored calls, invalid and boundary states, limits |
| `recur.next-occurrence` | 6 | 9 | first/anchored calls, exhaustion, invalid state and cursor reset |
| `recur.parse-and-enumerate` | 6 | 8 | facade call shapes, bounds, invalids and backend differences |
| `recur.set-base-date` | 6 | 10 | reads, lifecycle ordering, anchors and selection boundaries |
| `recur.set-end` | 6 | 9 | reads, replacement order, zones and endpoint comparisons |
| `recur.set-start` | 6 | 9 | reads, replacement order, zones and endpoint comparisons |
| `recur.list-occurrences` | 5 | 10 | establish primary list evidence for bounds, invalids and result modes |
| `recur.parse` | 5 | 11 | promote parse evidence from supporting/lifecycle use to exact partitions |
| `recur.occurrence-at-index` | 3 | 10 | establish primary index, invalid and error-state calls |
| `business.previous-working-date` | 2 | 4 | separate previous movement from its shared next/previous case |

The machine-readable `prioritized_work_queue` contains all 96 operation groups
and the exact next partition IDs. Each obligation also preserves the contract
description as its concrete `next_action`.

Among operations that already have committed primary evidence, a compact high
impact P1 candidate is `calendar.week-number`: all five contract partitions have
calendar observations, but none has an exact partition link in the calendar
feature maps. The finite follow-up must cover the 105 documented week-rule
settings across all 14 Gregorian year types, week-year boundaries, inverse Base
behavior, and public Date/DM6/DM5 override behavior before any partition is
discharged.

## Evidence rules

The generator accepts a direct partition link only when a JSON record places a
known contract partition ID under `partition_id`, `partition_ids`, or `partitions`
and associates it with the same canonical operation. It then requires the linked
case or reference case to appear in an observation record. Exact operation-ID
mentions are retained only as operation-level evidence.

Only blobs from `snapshot_commit` drive `evidence_state`, `feature_state`, and
priority. Pending worktree bytes and untracked evidence are excluded from the
snapshot. This keeps regeneration stable while another batch is under review.

Case IDs are joined across fixtures, observations, maps, and features. Recurrence
reference cases with `group:member` notation are joined to their observed group;
the two semicolon-separated modifier references are joined to their individual
observations. Every evidence reference is a repository path, with a line when the
structured token is directly present.

Run the deterministic review from the repository root:

```text
python3 tools/review/behavior-gap-ledger.py
```

Regenerate after evidence or contracts change:

```text
python3 tools/review/behavior-gap-ledger.py --write
```

The ledger stores SHA-256 hashes for all five contracts, the generator, and a
combined manifest hash for the evidence corpus it read.

## Limits

This audit covers the 397 partitions in `arithmetic.json`, `calendar.json`,
`recurrence.json`, `values.json`, and `zones-business.json` only. The 38-key
`configuration-domains.json` inventory is separate and needs its own key/domain
completion ledger.

The audit does not rerun probes, execute BDD scenarios, validate every saved
literal, or measure source statement/branch coverage. Natural-language scenarios
without a mapped case identifier may be undercounted. Conversely, a map can prove
traceability but not semantic completeness. Private helper coverage is outside
this public behavior-partition ledger.

## Reproducible verification

The coordinator repaired verification to use the ledger's recorded commit rather
than a moving HEAD. `--write` deliberately creates a new snapshot at current HEAD;
ordinary verification recomputes the saved snapshot. Volatile worktree status is
excluded from manifest hashes, so unrelated staged or untracked edits cannot
invalidate the historical evidence. Generator bytes are hashed separately and are
not evidence of behavior. The record still requires regeneration after a generator
change. This repair changes reproducibility, not obligation completion statuses.
