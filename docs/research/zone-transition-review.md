# Zone-transition review after evidence repair

The repaired transition-boundary batch remains research-only public-call
evidence for Date-Manip 7.00. It does not claim complete timezone behavior,
branch coverage, or a portable implementation algorithm.

The Date-object conversion binding now uses the canonical contract ID
`zone.convert-value`. The binding and feature maps include all supporting public
calls: base and date construction, configuration, version and zone service,
tzdata/tzcode, zone resolution, parsing, conversion, value scalar/list reads,
rendering, and error reads. No private helper is an entrypoint.

Each direct call boundary is now retained separately. Setup and constructors
record their error/exception boundaries; parse and conversion retain observed
numeric status types, errors, and exceptions; scalar and list `value` reads
have separate error/exception fields; and `printf` has its own error/exception
boundary. The original public outcomes were compared to a fresh candidate and
remain unchanged apart from canonical operation IDs and added evidence fields.

Every `all_periods` feature cell now contains its full ordered literal list.
The seven former references to neighbouring beginning records have been removed.

The runner performs two full isolated passes and saves the canonical payload hash
and equality result. Each full pass still runs every case twice in fresh Perl
processes and directories. Its independent check uses Python standard-library
`zoneinfo`; the saved record includes Python version, search paths,
`/usr/share/zoneinfo/tzdata.zi`, its SHA-256 and `# version 2026c` line, method,
and all 24 checked UTC instants.

Validated commands:

```sh
python3 tools/probes/zone-transition-boundaries/run.py > /tmp/zone-transition-candidate-v4.json
python3 tools/probes/zone-transition-boundaries/review.py
python3 tools/review/feature_structure.py spec/drafts/zone-transition-boundaries
```

The reviewer confirms 67 unique feature IDs, 24 UTC instants, 37 wall-clock
queries, eight enumerations, complete provenance, and all retained public-call
outcomes. The selected domain still excludes other zones/years, invalid calls,
system-zone discovery, custom zones, leap seconds, and wider transition shapes.

## Coordinator literal validation

The coordinator added explicit per-row feature-to-observation comparisons for
all24 UTC points,34 wall-query table rows,3 UTC wall queries in prose and8 period
list rows. Both beginning-period and intersecting-period strings are compared
as complete ordered representations. Every mapped operation ID is checked against
the canonical catalogue, and every installed-module hash is verified. The review
script hash was updated as review metadata; reference observations and execution
tools were not changed. The real pinned parser expands24+43 scenarios without
warnings or parse errors. These checks do not execute BDD step definitions.
