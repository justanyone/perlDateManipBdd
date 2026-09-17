# Fixed-offset family public-call observation

This research batch measures the generated fixed-offset family in separately
installed Date-Manip 7.00 without calling offset helpers directly. It uses
the public `Date::Manip::Date->new_date`, `value`, and `printf` operations.
The draft contract is in
[`spec/drafts/fixed-offsets/fixed-offsets.feature`](../../../spec/drafts/fixed-offsets/fixed-offsets.feature).
It is a draft, not an executable BDD result.

## Evidence and scope

The source-side manifest script reads the installed `Date::Manip::Zones`
mapping only to make an ephemeral reachability list. That mapping, the 408
offset/module pairs, and full observation data stay under `/tmp`; no generated
table is copied into the portable draft or this research record. The checked-in
compact result is [`fixed-offset-result.json`](fixed-offset-result.json). Seven
reviewed public rows without module names are retained in
[`selected-observations.json`](selected-observations.json), with portable case
links in [`feature-map.json`](feature-map.json) and public source bindings in
[`bindings.json`](bindings.json).

For every one of the 408 manifest entries, parsing the original input
`2040-02-29 12:34:56 <offset>` loaded its expected installed offset module.
Two isolated plain runs, each with a fresh working directory for every entry,
were byte-identical. A third, instrumented public-call batch produced the same
behavioral records after ignoring the plain-run-only load-count fields. It had
40 successful parses and 368 observed rejections with the literal error
`[parse] Unable to determine timezone`. Rejections remain in the denominator
and evidence; they are not silently skipped or represented as successful date
values.

Every isolated row records that its target was absent before construction, was
present afterward, and was the only newly loaded offset module. The finalizer
requires one unique coverage-report path per target and exactly 9/9 covered
statements, totaling 3672/3672 across the family. Rejected rows explicitly say
that value observers were not called and omit value fields; they do not encode
skipped reads as absent or empty native returns.

For successful cases, Python's standard-library `datetime` independently
computed the UTC scalar from the literal offset. The probe rejects a run if
that computation differs from the public `value('gmt')` result. The feature
selects zero, positive and negative sign, 30- and 45-minute values, both
14-hour endpoints, and the observed seconds-offset rejection. It deliberately
does not assert module names, generated layout, or a named-zone selection
policy. This is six of the 40 successes and one of the 368 rejections; the other
34 successes and 367 rejections remain research observations, not reviewed
portable expectations.

This proves public reachability of the family only. Module loading is not
behavioral completeness, and the result makes no complete timezone behavior,
whole-library coverage, or final 99%/95% coverage claim.

## Repeatable collection

Date-Manip 7.00 and Devel-Cover 1.52 must first be separately installed in the
ignored `local/` prefixes using the hash-checked commands documented in
[`docs/research/public-call-coverage/README.md`](../public-call-coverage/README.md).
The Date-Manip archive SHA-256 is
`37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c`; the
Devel-Cover archive SHA-256 is
`9d90b44ab602ca373fa221255708de4d19df86026f4d7110bef608846eed44fb`.

Use a new output directory. The phase split keeps the two plain runs isolated
and avoids merging a partial coverage database:

```sh
out=/tmp/fixed-offset-family-run
python3 tools/probes/fixed-offset-family/run.py "$out" initialize
python3 tools/probes/fixed-offset-family/run.py "$out" run-one
python3 tools/probes/fixed-offset-family/run.py "$out" run-two
python3 tools/probes/fixed-offset-family/run.py "$out" coverage
python3 tools/probes/fixed-offset-family/run.py "$out" finalize
```

The driver starts each subprocess from an otherwise empty environment with
only `PATH=/usr/bin:/bin`, `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`, `TZ=Etc/UTC`, and
the profile-specific `PERL5LIB`; it does not inherit `HOME` or `PERL5OPT`.
It checks Date-Manip 7.00 in the Perl probes and Devel-Cover 1.52 plus the
current Perl architecture before coverage. It refuses an existing output or a
replacement phase output. Its `summary.json` records source and script hashes,
hashes for both plain runs, finalized observations, instrumented observations,
selected observations, coverage report, and coverage-database tree, all missing
target rows, exact target statement totals, and parse outcome counts. The compact
checked-in result also pins the external summary hash. The full manifest,
observations, Devel-Cover database, and JSON report are deliberately external
artifacts.

Validate the durable files alone, or include an external run directory to verify
every pinned external artifact:

```sh
python3 tools/probes/fixed-offset-family/review.py
python3 tools/probes/fixed-offset-family/review.py /tmp/fixed-offset-family-run
```

The scripts use only public Date-Manip operations for behavior. The manifest
script is explicitly source-side discovery, so it must never become an adapter
or portable conformance test.
