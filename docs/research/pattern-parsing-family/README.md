# Explicit-pattern parsing observations

This family records 65 original requests against Date-Manip 7.00. Cases `PTN-01`
through `PTN-52` each contain the named token in the pattern itself. `PTN-26` and
`PTN-27` use the independently checked epoch `2214144309`; `PTN-64` and `PTN-65`
retain malformed epoch controls. `PTN-50` contains `%t`, and `PTN-52` contains `%+`.
Cases `PTN-53` through `PTN-63` cover caller captures, the three unavailable syntax
families, duplicate and missing fields, an invalid regular expression, no match,
the `%x` cache sequence, and the POSIX-setting sequence.

Run from the repository root:

```sh
python3 tools/probes/pattern-parsing-family/run.py > /tmp/date-manip-pattern-observations.json
```

Review that candidate against the frozen `observations.json` before intentionally
promoting it. A routine rerun must not overwrite the frozen evidence file.

The runner reads inputs from `cases.json`. For every case it starts two fresh OO
processes and two fresh DM6 facade processes, with at most four workers and a
15-second process limit. Every attempt has its own temporary working directory.
Each process receives only `PATH`, the pinned `PERL5LIB`,
`TZ=Etc/UTC`, `LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`. The OO and facade routes each
apply the complete named fixture before their first parse. OO scalar status and
list-result captures use separate configured objects. A value is read only after
status `0`; exceptions and failures never trigger a value read. The `parse_error`
field is captured immediately after parsing, and `error_after_value_read` is
captured after a successful value read.
Call stdout,
warnings, process stderr, exceptions, configuration, Perl runtime, Date-Manip and
timezone-data versions, and artifact hashes are recorded rather than inferred.

All 65 cases repeated byte-for-byte on both routes. The checked runtime was Perl
5.40.1 on x86_64 Linux, Date-Manip 7.00, tzdata2026c, and tzcode2026c. The installed
module hashes equal the separately unpacked review-source hashes. The observation
document also records the release archive SHA-256 and exact hashes of the manifest,
probe, and runner used for the run.

DM6 raw values retain the native distinction between empty text and an undefined
value. Ordinary facade parse failures return empty text; the invalid-regex case
raises before returning. The draft feature maps every request to a typed UTC local
date-time, empty text, or a distinct object status/pattern-error/exception outcome.
The two capture cases assert the complete returned reference capture map, including
directive-generated fields, and are tagged as reference-binding behavior.
Independent Python
standard-library and GNU `date` checks confirmed that `2214144309` is
2040-02-29 16:05:09 UTC, that 2040-02-29 is Wednesday and day 60, that ISO week
2040-W09 begins on 2040-02-27, and that epoch second 221 is 1970-01-01 00:03:41
UTC. These checks support calendar literals; they do not validate parser syntax.

Four findings remain explicitly disputed compatibility observations:

- `%L-%U-%w` with `2040-09-1` reports an invalid weekday.
- `%n` and renderer-only `%<...>` syntax produce no-match status rather than a
  descriptive invalid-pattern result in these requests.
- After `%x` succeeds under US order, changing to non-US order makes the repeated
  request fail, despite the documented cache statement.
- `%s` and `%o` accept the numeric prefix of `221?` and ignore the trailing `?`.

The invalid regular expression raises the Perl regular-expression exception before
either route returns; the research wrapper records the exception and does not read
a value afterward. No DM5 explicit-pattern API exists. The corpus
does not claim every numeric boundary, language, zone, or regular-expression form;
it discharges the assigned directive and edge requests only.

The feature remains a draft. These cross-checks do not automatically approve it for
promotion; disputed cases require an explicit contract decision.

Coordinator checks: `python3 tools/review/pattern_literals.py` verifies stored
provenance, successful table literals, failure statuses, full capture records,
exception distinctions, and setting-sequence results without invoking Date::Manip.
This research consistency check does not execute the English BDD scenarios.
