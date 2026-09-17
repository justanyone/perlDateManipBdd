# Configuration and object-lifecycle reference observations

This family preserves 40 original public requests against Date-Manip 7.00: 35
configuration applications and five configuration/value lifecycle operations.
The cases, probe, runner, and saved observations are unchanged by the portable
draft repair. Every saved case was previously repeated in two isolated processes
with a 15-second timeout and no process failure or exception.

The two portable features now contain one exact row per observation. Each row
names a language-neutral profile and carries a typed request and typed public
result. Empty text, omitted input, absent return, number, boolean, text, and
ordered collection are distinct records; no Gherkin table cell is blank.

Both portable feature files define their complete fixed profile locally. The
`current-object` profile lists all 16 ordered settings from the pinned OO fixture.
The configuration feature also lists all 17 settings in the
`legacy-functional` fixture. Each Background fixes process isolation, temporary
working directory, UTC, C UTF-8 locale, reference behavior version, clock,
language, encoding, date order, week rules, work schedule, and empty
holiday/event state through those literal settings. No definition relies on a
Background from another file.

The profile prose fixes the meanings needed to interpret those settings:
weekday numbers 1 through 7 are Monday through Sunday, US numeric dates are
month/day/year, and workweek endpoints 1 and 5 with workday endpoints 09:00 and
17:00 mean Monday through Friday from 09:00 through 17:00. For
`current-object`, `Week1ofYear=jan4` makes week one the week containing January
4, `DefaultTime=midnight` supplies 00:00:00 when a date omits its time, and the
erase settings start the holiday and event collections empty. For
`legacy-functional`, `Jan1Week1=0` likewise makes week one the week containing
January 4, `TodayIsMidnight=1` anchors today at 00:00:00, and
`EraseHolidays=1` starts the holiday collection empty.

`CFG-DM6-JAN1WEEK1` remains a portable compatibility request: applying the
deprecated setting has an absent apply result, reading it produces empty text,
and a deprecated-setting diagnostic is reported. Its exact Perl warning,
including native module/path context, appears only in
`spec/drafts/configuration/perl-binding.feature`, which carries
`@source-binding`, `@perl-binding`, and `@excluded-from-portable-handoff`.
The native DM5 load warnings likewise remain only in the saved research evidence;
the portable legacy rows describe the initializer request and absent result.

`feature-map.json` maps all 40 portable IDs to their exact feature, operation,
profile, typed request, result, and diagnostic disposition. `bindings.json`
keeps the OO and DM5 public-call mapping in research and identifies the excluded
native diagnostic assertion. Stable `CFG-DM6-*` and `CFG-DM5-*` IDs are treated
as opaque traceability keys; portable prose and profile cells do not expose those
binding names.

The family reviewer parses escaped Gherkin tables and verifies complete rows by
case ID. It rejects blank cells, wrong headers or arity, duplicate/missing cases,
misplaced results, incorrect profile definitions, and mismatch among the case
manifest, observations, feature map, binding map, portable rows, and native
warning row. It also checks the original evidence hashes and all 40 repeated
process results.

Regenerate and verify the draft artifacts without changing the observations:

```sh
python3 tools/probes/configuration-family/make_artifacts.py
python3 tools/review/configuration_literals.py
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" perl tools/runner-trial/parse-features.pl \
  spec/drafts/configuration/configuration.feature \
  spec/drafts/configuration/object-lifecycle.feature \
  spec/drafts/configuration/perl-binding.feature
```

To reproduce the unchanged raw evidence separately:

```sh
python3 tools/probes/configuration-family/run.py > /tmp/configuration-observations.json
cmp /tmp/configuration-observations.json docs/research/configuration-family/observations.json
```

This remains a bounded draft, not a coverage-completion claim. Explicit remaining
domains include valid and invalid boundaries for unselected configuration values,
zero/empty/omitted interactions beyond these cases, longer reset sequences,
ordered and nested configuration files, special-section grammar, every language
selector, parsing/rendering/business/recurrence/zone interactions, more receiver
construction routes, initial parse failure during construction, context sharing,
zone-service access, and error sharing/recovery after successful operations. The
combined context-service case calls only the public calendar/base service and
records availability. It does not claim zone-service coverage, service identity,
or shared-object state.

Coordinator verification independently repeated all40 requests and byte-matched
the saved evidence. Kind-query results name each predicate and record query order;
calendar-context results assert availability only, without inferring identity or
sharing from class names. Exact row/profile checks and all41 parser examples pass.
