# Public functional `Date_SetTime` observations

This batch maps the two public functional bindings of `date.replace-time`:
`Date::Manip::DM6::Date_SetTime` and the legacy
`Date::Manip::DM5::Date_SetTime`.  The mapping is confirmed by the installed
DM6 and DM5 public POD and by the repository contract map.  No private
function is called by the probe.

The documented request shapes are date text plus three clock fields, or date
text plus clock text in the `HH`, `HH:MN`, or `HH:MN:SS` forms.
`replace-time-portable.feature` freezes the 18 documented-form observations
(nine per profile) as generic request/result behavior. Its stable portable IDs
are mapped one-to-one to reference observation IDs in `portable-case-map.json`.
`replace-time.feature` is entirely source-binding evidence and is excluded from
portable handoff because it records scalar/list carriers, native diagnostics,
and the undocumented `24:00:00`, meridian, extra-component, and two-field
requests.

`observations.json` is two fresh-process observations for each of 26 rows:
13 DM6 and 13 DM5.  It retains scalar and list-context return carriers for
completed calls; a thrown call has no return/items field and carries its
exception separately. It also records captured warnings, call stdout, process exit and stderr, the exact input
ordered profile, runtime, loaded Date::Manip paths, source hashes, archive
hash, and probe artifact hashes.  It is reference evidence, not a BDD run or
an expectation generator.  The DM5 load warning and DM6 malformed-time
exception are preserved in the JSON exactly; they are intentionally described
only as native behavior in the source-binding draft. The reviewer parses both
feature tables, checks all 26 source-binding rows and 18 portable mappings
against exact profile, date input, time arguments, and results, and validates
all recorded artifact and loaded-module SHA-256 hashes.

Regenerate and review it with a clean environment:

```sh
python3 tools/probes/replace-time-family/run.py > /tmp/replace-time-family-candidate.json
python3 tools/probes/replace-time-family/review.py /tmp/replace-time-family-candidate.json
cmp /tmp/replace-time-family-candidate.json docs/research/replace-time-family/observations.json
```

The runner sets only `PATH=/usr/bin:/bin`, `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`,
`TZ=Etc/UTC`, and the pinned `PERL5LIB`; it uses a new temporary working
directory for every invocation.  It rejects output or stderr from the process,
requires two byte-identical native payloads per row, checks the distribution
and backend versions, verifies all loaded Date::Manip modules are below the
pinned prefix, and records their SHA-256 values.  The reviewer checks every
literal return, defined/absent carrier, list behavior, exact exception, exact
warning, and process record.  A zero-argument DM5 `Date_Init()` configuration
listing was deliberately not used as a profile echo: its returned item order
varied across otherwise equivalent fresh processes, so it would make native
payload comparison misleading.

The pinned dependency is Date-Manip-7.00, archive SHA-256
`37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c`.
The observed runtime is Perl v5.40.1 on `x86_64-linux-gnu-thread-multi` for
Linux.  DM6 reports backend version 7.00 and its zone observer reports
`etc/utc`; DM5 reports backend version 5.66 and its zone observer reports
`UTC`.  Both represent the fixed Etc/UTC fixture.

This is a bounded partition, not a claim of complete date parsing or complete
time-zone behavior.  Remaining partitions include the wider date parser
grammar (relative text, alternate numeric order, language forms, and zone
suffixes), DST/local-zone parsing, numeric coercion and non-scalar Perl
carriers, fractional fields, repeated global configuration sequences, and
interactions with other functional date operations.  They remain open because
they require their own public-call observations.
