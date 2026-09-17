# Broader public-call coverage diagnostic

The retained 965-request corpus measures 7,261 of 11,537 statements (62.9366%)
and 1,192 of 6,376 branch outcomes (18.6951%). These denominators cover 34 loaded
Date::Manip files; 770 installed module files were not loaded. This is a research
probe diagnostic, not executable BDD coverage or whole-library completion.

`broad-result.json` records every request and raw-output hash, pinned capture
sources, the report hash, numeric extraction hash, audit sources, loaded module
hashes, and the complete unloaded-file inventory. `broad-locations.json` lists
every unexecuted criterion and upstream annotation, with numeric hit counts and
source locations but no copied source text. No exclusion has been approved.

All 965 raw JSON result pairs agree under the recorded normalization policy.
890 pairs are byte-identical; 75 differ only in dynamic eval locations in the
known DM5 deprecation warning. All process stderr pairs agree. The audit verifies
each merged run's probe path, working directory, runtime, and completion timestamps.
Original process exit codes were not retained and cannot be independently recovered.

The original collector finished collection and merging but exited during summary
validation. Devel::Cover 1.52 counts both unexecuted unannotated code and executed
annotated code as errors. Its covered, error, and annotation fields overlap.
The old collector incorrectly added those fields as if they were disjoint.
The audit preserves that failed status instead of manufacturing a successful run.

The repaired tooling reports four disjoint execution/annotation states. Two
statements at Obj.pm lines 314 and 316, and branch outcome 1 at line 310, each
executed three times despite upstream annotations. These are explicit annotation
conflicts. Raw execution percentage uses all measured criteria; the tool's own
error-based percentage is reported separately. Numeric extraction from the
merged database independently agrees with the decoded summary counts.

Reproduce the retained-artifact audit, while the external capture remains present:

```sh
python3 tools/coverage-corpus/audit-retained.py \
  /tmp/public-coverage-corpus-broad-root --capture-commit e73fa20 \
  --manifest tools/coverage-corpus/broad-manifest.json > /tmp/broad-audit.json
cmp /tmp/broad-audit.json docs/research/coverage-corpus/broad-result.json
```

This command verifies the capture's probes against the specified Git snapshot.
Later intentional probe edits require checking out that snapshot before replaying
the audit. Historical narrower captures remain unchanged. Further work must review
the uncovered paths, exercise unloaded public capabilities, complete the behavioral
partitions, and measure the actual Perl BDD harness once implemented.
