# Zones, business calendar, and events reference observations

This directory is research-only. It pairs original fixture files with public-call
observations from Date::Manip 7.00. The selected 33 cases are a bounded sample
of the 23-operation catalogue; they do not claim complete timezone, calendar,
event, or DM5 coverage.

Run the repeatability check from the repository root:

```sh
python3 tools/probes/zones-business-family/run.py
```

The driver runs each case twice in a new Perl process, uses at most four
processes, and gives each process 15 seconds. It fixes `TZ=Etc/UTC`,
`LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`, and loads the pinned Date::Manip 7.00
reference. DM6/OO use tzdata2026c through the named fixture; DM5 is the 5.66
compatibility backend packaged with that distribution and has its own fixture.
Both fixtures are original project data, not upstream samples.

The retained output shows success values, return codes, state changes, warnings,
and exceptions. Every case is `repeatable`, not `reviewed`; no feature is
approved and no BDD harness has run these drafts.

Every catalogue operation now has a selected observation, which is only a routing
and sample milestone. It does not discharge any operation or partition. The main
gaps remain visible in `coverage.json`: wrapper defaults and error forms,
discovery-method taint behavior, period ranges, all custom-zone spelling variants,
invalid business state, recurrence holidays, event error grammar, and most legacy
shapes. The non-whole-hour Asia/Kathmandu cases demonstrate a +05:45 offset in the
fixed profile, but do not establish support for every historical or unusual offset.
The legacy compatibility conversion and multiple-holiday behavior remain
compatibility observations only.

Coordinator review replaced event-count placeholders with concrete ordered
change-point tables and active-event records. It made period timestamps and
calendar profile differences explicit, added the missing DM6 working-date call,
and corrected the post-erasure holiday result to absent (not empty text).

The saved observations now preserve the actual probe return structure. Earlier
hand-shaped records had rearranged the OO event change rows and omitted setup
channels. The rerun record retains those channels and raw scalar types, with
explicit civil serialization only for Date objects. Probe/runner/fixture hashes
are recorded. Release assertions, OO timezone-data assertion, isolated temporary
working directories, and empty legacy personal-config paths strengthen reference
isolation. All 33 cases repeat twice with no exceptions or process diagnostics.

`python3 tools/review/zones_business_literals.py` checks the saved hashes, exact
OO and functional event-result shapes, the added working-day result, and absent
post-erasure label. English literals remain draft; scalar/list variants, full
period data, defaults, errors, and all listed boundary obligations still require
completion and semantic review. These targeted corrections do not discharge any
whole operation or partition.
