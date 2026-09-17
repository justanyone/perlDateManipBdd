# Planning observations and proposed success criteria

These are actual results of original temporary public-API probes against the
downloaded CPAN 7.00 release, using Perl v5.40.1 and DM6. They were repeated in two
fresh Perl processes with identical output. They are not executions of a BDD suite.
The [raw record](observations.json) contains configuration, results and source/probe
hashes. Probe source stayed in `/tmp/date-manip-planning-probe.pl`; it is research
scratch work, not a repository implementation. Future observation tooling must be
versioned and reproducible rather than depending on that temporary path.

The process had `TZ=Etc/UTC`, `LC_ALL=C`; current time was frozen to 2040-02-28
10:20:30 UTC. The functional context used English, US numeric order, native printable
format, Monday/January-4 week rules, Monday–Friday 09:00–17:00 working schedule, and
cleared holidays/events. The non-US parsing probe explicitly changed and restored
numeric ordering. OO parsing used its own configured object. Calls occurred in the
listed order within each run; per-case isolation remains a requirement for the
future evidence pipeline. Broader environment and all default settings must also
be captured before this sample becomes an approved reference fixture.

A subsequent metadata query against the same extracted release reported Linux,
`x86_64-linux-gnu-thread-multi`, `tzdata2026c` and `tzcode2026c`. These identifiers,
together with the release archive hash, define the sample's timezone reference;
they do not authorize updating expected results to a later dataset automatically.

## Observed outputs

Portable values here are decoded/displayed forms of the raw results, not a second
call computing an expectation. The future suite will assert reviewed constants.

| Case | Request | Actual raw result | Proposed portable expectation |
| --- | --- | --- | --- |
| PARSE-01 | Parse `2040-02-29 16:05:09` | `2040022916:05:09` | success, UTC date-time `2040-02-29 16:05:09` |
| PARSE-02 | Parse `2041-02-29 16:05:09` | empty string | failure, no date; proposed category `invalid-date` |
| PARSE-03 | Parse `tomorrow` at fixed clock | `2040022900:00:00` | next civil day at midnight, not +24h preserving clock time |
| PARSE-04 | Parse `05/06/2040`, month-first | `2040050600:00:00` | May 6 at midnight |
| PARSE-05 | Same input, day-first | `2040060500:00:00` | June 5 at midnight |
| PARSE-06 | Parse tokens `2040-02-29`, `16:05:09`, `trailing` | date `2040022916:05:09`; remaining array `["trailing"]` | date-time plus two consumed tokens and one remaining token |
| FORMAT-01 | Format valid date with `%Y-%m-%d %H:%M:%S` | `2040-02-29 16:05:09` | exact text |
| CAL-2000 | Leap-year predicate, 2000 | `1` | true |
| CAL-2100 | Leap-year predicate, 2100 | `0` | false |
| CAL-2400 | Leap-year predicate, 2400 | `1` | true |
| CAL-04 | Days in February 2040 | `29` | integer 29 |
| CAL-05 | Weekday of February 29, 2040 | `3` | Wednesday |
| CAL-06 | Year ordinal of February 29, 2040 | `60` | integer 60 |
| CAL-07 | Ordinal 60.5 of 2040 | `[2040,2,29,12,0,0]` | local fields `2040-02-29 12:00:00` |
| DELTA-01 | Parse `2 hours 17 minutes` | `0:0:0:0:2:17:0` | interval fields: hours=2, minutes=17, other fields=0 |
| ARITH-01 | Feb 28 at 16:05:09 plus one day | `2040022916:05:09`; error slot remains undefined | February 29, same clock time |
| ARITH-02 | Jan 31 at 16:05:09 plus one month | `2040022916:05:09`; error slot remains undefined | February 29, same clock time; observed month-end behavior |
| ARITH-03 | Feb 28 to Mar 1, same time, exact default | `0:0:0:0:48:0:0`; error slot remains undefined | exact interval fields: hours=48, all other fields=0 |
| TZ-01 | July 1 at noon UTC to America/New_York | `2040070108:00:00` | destination wall time 08:00 under pinned reference rules |
| EPOCH-01 | Dec 31, 1969 at 23:59:59 UTC | `-1` | minus one second from UTC epoch |
| BUSINESS-01 | Friday March 2, 2040 at 16:05:09, next workday offset 1 | `2040030516:05:09` | Monday March 5, same clock time |
| RECUR-01 | Daily at 09:00, Feb 28 through Mar 1 inclusive | three dates at 09:00 on Feb 28, Feb 29, Mar 1 | exact ordered occurrence list |
| OO-01 | OO parse of PARSE-01, then scalar/list extraction | parse status `0`; string plus `[2040,2,29,16,5,9]` | success despite false-like status; same typed date-time |
| OO-02 | Same object, then parse of PARSE-02 | parse status `1`; empty value; error present | failure and no valid date value |

The recurrence probe used the reference syntax
`0:0:0:1:0:0:0**2040-02-28 09:00:00*2040-02-28 00:00:00*2040-03-01 23:59:59`
with `ParseRecur` in list context. That syntax stays in the mapping/evidence; the
feature expresses a daily rule, anchor and bounds in English.

## Evidence-to-contract cautions

- The invalid-date category is our proposed semantic label. A functional empty
  result alone cannot distinguish every failure reason; the adapter must not infer
  detailed categories without a supported signal or explicit input-validation rule.
- The successful arithmetic error slot was initially undefined. Test preexisting
  nonzero slots separately before deciding whether the operation clears errors.
- The 48-hour result is not evidence that days and hours are always interchangeable.
  Preserve exact versus calendar arithmetic and add DST cases.
- Future timezone results depend on the pinned dataset. They are reference-version
  facts, not promises that civil authorities will keep the same rules until 2040.
- These are representative samples. No DM5, timezone-transition, localization,
  holiday/event or exhaustive option results have been established by this run.

## Required observation record for the full specification

Each future case records a stable ID; abstract request; full context; exact reference
call and argument/return context; release/runtime/data hashes; before/after state;
typed raw return; error/warning/exception/stdout channels; normalized result;
repeatability evidence; independent checks; disposition and reviewer decision.
Keep source-side implementation identifiers outside the portable export.

Observation is an authoring step. At conformance-test time, compare the adapter's
actual result to the frozen feature/table value. Never calculate both sides by
calling the reference library, or accept an unexplained difference by regenerating
the expected-value files.
