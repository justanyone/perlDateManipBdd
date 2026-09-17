# Current calendar evidence index

[calendar-evidence-index.json](calendar-evidence-index.json) reconciles the recent
leap-year, month-length, year-length, weekday, and configured week-count drafts
with the original calendar partition identifiers. It maps sixteen partitions to
observed public requests; the invalid week-count partition remains unobserved.
Every partition remains unresolved for final conformance.

The original [calendar catalogue](contracts/calendar.json) is a capture-time
snapshot hashed by existing observations. Its `unobserved` labels predate these
batches. The index supplies their current research status without rewriting that
snapshot or pretending that observation hashes came from a later capture.

Each row names actual case IDs and their portable draft files. The default
week-count partition maps only the default configuration; the February partition
maps only February requests. A case may support more than one partition, so the
sum of partition counts is not a count of unique tests. Full family reviewers
remain responsible for checking the native observations and frozen literals.

Rebuild after reviewing a new mapping, or verify the recorded index:

```sh
python3 tools/review/calendar_evidence_index.py --write
python3 tools/review/calendar_evidence_index.py
```

The index verifies source hashes, partition identities, mapped observation
identities and file existence. It does not execute BDD scenarios, approve the
portable export, infer implementation coverage, or close edge-case obligations.
The [gap priorities](calendar-gap-priorities.md) guide the next distinct cases;
each family's remaining-domain record retains outstanding compatibility work.
Other calendar and epoch operations remain outside this incremental index.
