# Object lifecycle and value-carrier reference observations

This bounded batch records public lifecycle behavior for Date, Delta, and Recur
receivers. It uses Date-Manip 7.00, tzdata `tzdata2026c`, tzcode `tzcode2026c`,
Perl v5.40.1, and the repository's pinned library. The fixed configuration is
English, ASCII, non-US numeric-date order, UTC, and a local clock of
2040-02-28 10:20:30.

Run the observations from the repository root and write the candidate result to
a temporary file so the reviewed evidence is not replaced implicitly:

```sh
python3 tools/probes/object-lifecycle-family/run.py > /tmp/object-lifecycle-observations.json
cmp /tmp/object-lifecycle-observations.json docs/research/object-lifecycle-family/observations.json
python3 tools/probes/object-lifecycle-family/review.py
```

The runner starts every call in a new temporary working directory with a minimal
environment, permits at most four concurrent processes, applies a 15-second limit,
and executes every case twice. All 20 stored cases returned status 0 and identical
stdout and stderr on both attempts. No probe call emitted a warning or uncaught
exception. The stored fixture SHA-256 is
`e10918faaca166fc0678c856be8c8b418516509546214d27db15b876148fe5c8`.
These are repeatable observations, not approved expectations or executable BDD
results.

The direct and receiver construction cases cover the public `new`, `new_date`,
`new_delta`, `new_recur`, and `new_config` paths for Date, Delta, and Recur
receivers. Same-context construction shares later configuration changes across
all three receiver kinds. `new_config` creates a same-kind carrier whose copied
configuration can change independently. The isolation case first changes the
child from non-US to US, then changes the source from US to non-US, and observes
the distinct final pair `non-US`/`US`. Configuration mutation return definedness
and type, errors, exceptions, and every setting read are retained in the raw
record. The cases extend `CFG-CONTEXT-DERIVE` and `CFG-CONTEXT-SERVICES`; they
do not duplicate the configuration family's single-Date observations.

There is no public `clone`, `clear`, or `reset` method on these three classes in
7.00. Receiver `new` supplies the observed fresh-carrier behavior associated with
copy-like construction. A truthy argument to `err` clears error state. Recur has
no general `value` or `set` method; `frequency`, `start`, `end`, `basedate`, and
`modifiers` are its public state carriers and setters. Replacing a frequency
clears the recorded range, base, and modifiers. The exact method matrix and
source documents are in `signature-inventory.json`.

The value cases retain the distinctions among undefined, defined empty text,
empty list, numeric zero, and successful status zero. Getter records include the
error immediately before and after each read. Every action is skipped if common
profile setup fails, and the raw record then says
`"dependent_calls_executed": false`; no stored case took that path. Invalid
whole-date and unknown-field replacements leave the Date carrier unset. In the
same reference, replacing only its day component with 31 returns success and
stores `2040023116:05:09`; the draft presents that observation without treating
it as a validated civil date.

Date::Manip's native scalar serialization remains verbatim in the research
record as `YYYYMMDDHH:MN:SS`. Portable feature prose losslessly renders the same
six civil fields as `YYYY-MM-DD HH:MM:SS`; feature steps call this the normalized
civil date-time and do not claim that it is the binding's native scalar string.
The empty and unrecognized Date value selectors are public-call observations but
are not documented selector forms, so their feature rows are explicitly marked
observed compatibility behavior.

Public operation mappings use the complete `docs/research/api/contract-map.json`.
Every case and coverage row carries the same ordered contract list, including
typed constructors, explicit Date/Delta/Recur parses, error and configuration
calls, and asserted value/component observers. Every primary `operation_id` is
also a canonical ID in that map. Recurrence component getters use the catalogue's
dual-role `recur.set-*` entries because those public methods are both getters and
setters.

Remaining lifecycle obligations include constructor parser-option combinations,
option-list failures, Base and TZ source receivers, and every omitted/empty/zero
argument distinction. Date `value` still needs truncated values and selector
case variants. Date `set` still needs all zone, zdate, date, time, individual-field,
arity, `isdst`, DST gap/overlap, and validation partitions. Delta `set` still
needs whole-array, mode, type, normalization, conflict, and numeric-boundary
partitions. Recur still needs invalid component setters, modifier string/list and
append forms, unmodified-range flags, calculated actual-base state, and failure
mutation rules. Successful recovery after errors and construction with initial
text plus independent configuration are also open.

The separate parse-cache-family owns Date converted-carrier cache behavior when
`value('local')` or `value('gmt')` is read before `parse_date` or `parse_time`,
including cross-context reads, failures, error clearing, retries, and full-parse
recovery. This lifecycle batch does not claim that boundary. Other public
Date/Delta/Recur methods outside creation, carriers, configuration, and error
state remain in their API families. No private callable is an obligation of this
batch.

Repair review
-------------

Independent review found ambiguous native-versus-portable date wording,
incomplete call mappings, a no-op isolation follow-up, compatibility selectors
without classification, and missing observer boundaries. The repaired probe and
fixtures were run twice again in fresh processes. All20 cases remained
repeatable. Fixture and mapping metadata changed in every record. Raw result
payloads changed only for `OBJ-006`, `OBJ-007`, `OBJ-008`, `OBJ-014`, `OBJ-015`,
and `OBJ-020`: the three configuration cases now retain call/read boundaries,
the isolation case performs real opposing mutations, the two replacement cases
retain pre-read error boundaries, and recurrence Date snapshots retain their own
value-read boundaries. Other behavior values were unchanged. The reviewer now
checks canonical operation IDs, exact case/coverage contract equality, the
strengthened isolation sequence, observer boundaries, portable normalization
wording, compatibility classification, and the binding-only method tag.

Method-availability assertions remain binding-only. The
component-versus-whole-date validation scenario remains disputed. These are
repeatable reviewed research observations and draft feature expectations, not
executable BDD results.

Construction-feature portability repair: serialized text and ordered field records
replace native scalar/list value terminology. The feature explicitly names the
date and duration field orders. For the Perl adapter, read-serialized-text maps
to `value` in scalar context and read-ordered-fields to `value` in list context.
Those native contexts remain research mapping, not required implementation
structure. Existing input/output literals and case IDs are unchanged. The separate
value-state feature still needs its own portability repair.
