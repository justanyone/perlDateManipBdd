# Arithmetic and delta reference observations

`cases.json` is the coverage record.  Every record has a stable `case_id`, one
operation ID, exact contract IDs, exact partition IDs, a selected profile, and
all request fields.  The same IDs appear in `observations.json`; this binds a
literal observation to its contract and partition without relying on a broad
scenario title.  The Gherkin draft uses the stable IDs that have a concise
portable expression; the complete research matrix remains in the JSON record.
Binding-specific `kind`, profile, callable shape, and compatibility route data
are research-only fields in that record and are deliberately absent from the
portable feature prose.

Run the evidence batch from the repository root:

```sh
python3 tools/probes/arithmetic-family/run-arithmetic-family.py > docs/research/arithmetic-family/observations.json
```

The runner sets `PERL5LIB=local/date-manip-7.00/lib/perl5`, uses a new temporary
working directory and a new Perl process for each invocation, repeats every case
twice, permits at most four concurrent probes, and limits an invocation to 15
seconds.  It captures the raw return, exception, warnings, stdout, error state,
and Delta before/after state where relevant.  On this batch, all 59 cases had
byte-identical repeated results.  This is `repeatable` research evidence, not a
review approval or a BDD test pass.

The original 59 cases link to all 16 contract operation IDs.  They also link to every
current partition ID except `delta.render-fields.p3`; a link means that an
input was selected for that partition, not that the partition has been
discharged or approved.  Most partitions have only one or a few representative
inputs, so none is complete merely because it is named by a case.

DM6 and the DM5 5.66 compatibility backend packaged with distribution 7.00 use
their separate profile configurations from `reference-profiles.json`.  The
probe now records selected backend identity, distribution version, profile
configuration, configuration return, configuration error, initialization
diagnostics in `setup_warnings`, and call-time `warnings` separately. This
prevents setup messages and configuration failures from being presented as
behavior of the function under test. The
existing reviewed observation file predated that channel split.  A fresh review
compared all 59 old case IDs before this record was updated: raw returns,
exceptions, and captured stdout had zero differences.  The only old-case record
change is diagnostic classification: initialization messages moved from the
single `warnings` array to `setup_warnings`.  That schema correction is not an
approved literal or a change to the observed callable behavior.

The current probe loads only the selected public backend branch. It records
both parse statuses and pre/post operand snapshots for typed arithmetic. The
signed compact and sign-inheritance grammar observations are scalar-text
assertions only; their scalar/list carrier disagreement remains disputed and
is not a portable field-record claim.

The updated record contains 107 repeated cases: the prior 59 plus 20 grammar
production cases, two bounded formatting-matrix cases, and nine typed
calculation cases, plus 17 DST, cross-zone, business-boundary, holiday,
invalid-state, and mutation cases.  The grammar matrix intentionally preserves two failed
candidate forms (`1 year 2:3` and `2 approximate days`) as observations that
need semantic review, rather than treating source vocabulary as a portable
acceptance claim.

Remaining explicit obligations:

- The 20 parser productions have representative compact, expanded, business,
  fractional, and failure observations, but not every compact field count,
  named unit, relative-marker spelling, separator, mixed notation, or each
  option conflict.
- Formatting has observations of all five directive families, but not all
  seven conversion targets, sign and padding combinations, malformed
  width/precision forms, or every standard/business work-schedule conversion.
  All seven single fields, all 28 inclusive source ranges, and precision absent,
  zero, and two are now represented once; that is not their full interaction
  matrix.
- Calculation now has the four typed operand pairings and six date/date modes
  on named portable inputs.  It still lacks OO invalid-object routes,
  approximate selector values 0/1/2, DST and cross-zone cases,
  holiday/workday endpoints, and mixed-mode Delta failures.
- DST observations now include before, at, and after the spring gap and fall
  overlap, a calendar-day versus 24-hour comparison, and one Chicago/New York
  cross-zone difference.  They still lack both explicit overlap preferences,
  other zones, zone conversion APIs, and date/date DST differences in every
  mode.
- Business observations now include all four work-hour endpoints, weekend and
  one original named-holiday carry, a mutating next-business-day call, and an
  invalid object.  They still lack prior/nearest operations, zero and negative
  offsets, unnamed/multiple holidays, different schedules, and mutation after
  every invalid or calculation state.
- Base malformed-list calls return/coerce with warnings in this reference;
  their portability and error policy are disputed pending semantic review.
- `delta.read-input` does not yet run the promised lifecycle sequence after
  `set`, `calc`, `convert`, and a failure on a previously valid object.
  `delta.replace-fields` has not observed the deprecated positional form or
  every field/mode/type combination.  `delta.render-fields.p3` has no probe.
  The case links for `delta.create.p2`, `delta.read-input.p3`, and several
  invalid partitions are especially partial: they do not exercise every state
  transition or invalid form named in their contract.

The feature remains tagged `@draft` until the coordinator reviews the observed
compatibility differences, warning-sensitive malformed inputs, and the stated
gaps.

Coordinator review found and corrected a further observer side effect: querying
an invalid Date value overwrote its parse error. Snapshots now record the error
before reads and skip value reads when a Date already has an error. Calculation
results retain both the error before reading the answer and the error after the
explicit serialized-value query. The spring-gap scenario now distinguishes the
parse error, calculation error, and value-read error. The invalid business-date
case preserves its parse error, absent result, and unchanged invalid state in the
portable scenario. Its native warning is retained in a separately tagged binding
scenario excluded from portable handoff.

After the correction all107 cases repeat. Draft calculations now name current
value/current text/legacy text profiles, date results use readable civil fields,
and operand-pairing rows state their options explicitly. The duplicate exact-mode
row has its own feature ID and a reference alias. Rejected delta parsing asserts
an empty field collection instead of claiming seven empty fields.

`python3 tools/review/arithmetic_literals.py` checks provenance,107 repeatable
records,21 calculation-table literals,65 unique outline row IDs, all20 typed
delta-grammar result/error rows, four named compatibility-format operations, the
binding-warning split, the explicit profile in all four features, and three
invalid state/error sequences. This targeted review does not cover every literal
or close the remaining method/domain/interaction obligations. No draft is promoted
merely because its reference result repeats.
