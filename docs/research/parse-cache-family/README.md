# Public parse/value-history reference observations

This bounded batch records sequence-dependent Date-Manip 7.00 behavior through
public methods. The receiver starts as `2039-12-31 07:08:09` in
`America/New_York`; the process and configured local zone are `Etc/UTC`. That
makes the parsed-zone value (`07:08:09`) visibly different from its fixed-local
and UTC representations (`12:08:09`). Portable features name a one-value read a
serialized value and a six-value read an ordered field record.

Thirty original cases compare pristine receivers with prior parsed-zone,
fixed-local, and UTC reads before date-only, time-only, and complete parsing.
They cover serialized values, ordered fields, repeated reads, successful and
failed calls, error clearing, retry without error clearing, and recovery through
complete parsing. The features describe the public results and exact evaluation
order. They do not require a cache or any other internal design.

Every case runs twice in a fresh process and temporary working directory with at
most four workers and a 15-second timeout. The environment contains only the
recorded `PATH`, pinned Date-Manip prefix, `TZ=Etc/UTC`, `LANG=C.UTF-8`, and
`LC_ALL=C.UTF-8`. Each sequence action records arguments, errors immediately
before and after, caught exception, completion, and action warnings. A completed
call additionally records `result` and `result_type`, including a
completed absent value. An interrupted call sets `call_completed` false and
records its exception while omitting both return fields because no value was
returned. The process record separately captures stdout and stderr. Hashes bind
the evidence to the corpus, probe, runner, reference profile, and installed Date
and Obj modules.

Run a candidate and compare it without replacing the stored evidence:

```sh
python3 tools/probes/parse-cache-family/run.py > /tmp/parse-cache-candidate.json
cmp /tmp/parse-cache-candidate.json docs/research/parse-cache-family/observations.json
python3 tools/probes/parse-cache-family/review.py
python3 tools/review/feature_structure.py spec/drafts/parse-cache
```

Run the minimal public reproducer with:

```sh
env -i PATH=/usr/bin:/bin TZ=Etc/UTC LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  PERL5LIB=local/date-manip-7.00/lib/perl5 \
  perl tools/probes/parse-cache-family/minimal.pl
```

It prints a current parsed-zone result for `2040-02-29` while the fixed-local
read still returns the earlier `2039-12-31` value.

## Reviewed public findings

- With no prior converted read, successful date-only and time-only parsing
  produces current parsed-zone, fixed-local, and UTC values.
- A prior parsed-zone serialized read does not produce the defect.
- A prior fixed-local or UTC read, whether serialized or ordered fields, causes
  that same representation to retain its pre-mutation value after successful
  date-only or time-only parsing. The other representation remains current.
- Repeated reads keep returning the earlier literal. Reading both converted
  representations before partial parsing leaves both earlier values visible.
- Failed partial parsing preserves the prior receiver behind its error. Clearing
  the error preserves its fields and any earlier converted representation.
  Retrying without clearing resets the receiver first, so date-only parsing uses
  midnight and time-only parsing uses the fixed reference date.
- Successful complete parsing refreshes both converted representations despite
  prior reads and recovers a receiver after the partial-parse behavior.
- Failed complete parsing removes the prior value. While its error remains, a
  parsed-zone read returns empty text. After error clearing, no parsed-zone value
  is present. Fixed-local and UTC reads fail without returning a value; the
  binding-specific diagnostics for those two calls are excluded from the
  portable feature.
- A later successful complete parse recovers the receiver after every tested
  complete-parse failure sequence.

All results remain tagged disputed. They characterize the pinned reference and
do not prescribe desirable behavior for another implementation.

## Source-binding separation and mapping

The two portable features contain all 30 source IDs exactly once. Each row has
an exact, language-neutral public action sequence. The complete-parse variants
with and without an additional ordered-field read are separate scenarios; no
conditional `none` or `not requested` cells remain.

`perl-binding.feature` is tagged
`@source-binding @perl-binding @excluded-from-portable-handoff`. It preserves the
two native scalar calling contexts, stable array-reference exception prefix,
ordered eight-warning sequences, absence of a returned value, native recovery
values, and the census showing zero warnings in the other 28 source cases.
Portable scenarios retain the same public mutation, generic no-value failure,
empty error boundaries, and recovery sequence without requiring Perl diagnostics.

`feature-map.json` preserves the original 30-ID feature lists and adds one
portable mapping per case, four binding-row mappings, and two binding assertions.
Every portable mapping carries the exact canonical public operation IDs recorded
by its observation. `bindings.json` identifies only documented public calls;
private functions are not called or mapped as portable operations.

The family reviewer checks every requested action against the source fixture,
every normalized result and error literal against its own rendered feature row,
all evidence hashes and setup metadata, the operation map, the four excluded
binding rows, exact warning order, and the 28-case zero-warning census. The
current observation schema also proves that all completed calls have return
fields and the two interrupted converted reads do not. A fresh two-attempt
capture changed only the schema/completion metadata and removed the two fabricated
absent-return fields; all pre-existing requests, warnings, errors, exceptions,
and actual completed results compare equal. The stored hashes bind this corrected
capture to the current probe and runner.

## Remaining finite obligations

This batch does not cover mutation through field replacement, arithmetic, zone
conversion, copying, or configuration changes. It also leaves DST gap and
overlap conversion, non-UTC local profiles, empty and unrecognized value
selectors, other call orders, and releases other than 7.00 for separate work.
This bounded batch does not claim every possible read history.

The stored records and draft features remain research characterization pending
project-level approval. Reviewer success is not an executable BDD test result.

Coordinator replay used the fixed `/usr/bin:/bin` PATH rather than inherited
process PATH. The fresh capture preserved all prior actual sequence results.
Every outline now references its exact action-sequence column in an explicit
step, making the recorded order available to the eventual adapter.
