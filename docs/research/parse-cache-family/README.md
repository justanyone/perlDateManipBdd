# Parse/value cache characterization

This batch records a sequence-dependent Date-Manip 7.00 compatibility defect
through public methods only. The receiver starts as `2039-12-31 07:08:09` in
`America/New_York`; the process and configured local zone are `Etc/UTC`. That
makes the parsed-zone value (`07:08:09`) visibly different from its local and GMT
representations (`12:08:09`). In the portable feature wording, the public `gmt`
selector is called the GMT carrier.

Thirty original cases compare pristine receivers with prior parsed-zone, local,
and GMT reads before `parse_date`, `parse_time`, and full `parse`. They cover
scalar and six-field list contexts, repeated getters, successful and failed calls,
error clearing, retry without error clearing, and recovery through full parsing.
Every case runs twice in a fresh process and temporary working directory with at
most four workers and a 15-second timeout. The environment contains the pinned
Date-Manip 7.00 installation and fixes `TZ=Etc/UTC`, `LANG=C.UTF-8`, and
`LC_ALL=C.UTF-8`.

Each sequence row records the public action and arguments, result and type, error
immediately before the action, error immediately after it, and any exception.
The process record separately captures stdout, stderr, and warnings. Hashes bind
the saved evidence to the corpus, probe, runner, and shared reference profile.

Run the full isolated batch with:

```sh
python3 tools/probes/parse-cache-family/run.py > /tmp/parse-cache-candidate.json
```

Run the minimal reproducer with:

```sh
PERL5LIB=local/date-manip-7.00/lib/perl5 \
  TZ=Etc/UTC LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  perl tools/probes/parse-cache-family/minimal.pl
```

It prints a current parsed-zone result for `2040-02-29` while the local getter
still prints the earlier `2039-12-31` value.

## Manually reviewed findings

- With no prior converted-value read, successful date-only and time-only parsing
  produces current parsed-zone, local, and GMT values.
- A prior parsed-zone getter does not trigger the defect.
- A prior local or GMT getter in either scalar or list context causes that same
  carrier to remain at the pre-mutation value after successful date-only or
  time-only parsing. Scalar and list reads share the stale carrier. A converted
  carrier that was not read before mutation computes the current value.
- Repeated reads keep returning the stale literal. Reading both converted carriers
  before partial parsing leaves both stale.
- Failed partial parsing preserves the prior receiver behind its error. Clearing
  the error also preserves any already stale carrier. Retrying partial parsing
  without clearing the error resets the receiver first, so date-only parsing uses
  midnight and time-only parsing uses the fixed reference date.
- A successful full `parse` refreshes both converted carriers regardless of prior
  scalar/list reads, and it recovers a stale partial-parse receiver.
- A failed full `parse` does not preserve the prior receiver. While its error is
  present, `value` returns empty text. After error clearing, the parsed-zone scalar
  result is absent without a new error; local and GMT reads each emit eight
  undefined-component warnings and raise an undefined-value exception. A later
  successful full parse recovers the object.

The results are tagged disputed. They characterize the pinned reference and do
not define desirable portable behavior. The English features keep implementation
bindings and source locations out of the scenarios.

## Remaining obligations

This focused batch does not decide whether a portable implementation should expose
converted-value caching at all. It does not cover mutation through `set`, arithmetic,
zone conversion, copying, or configuration changes; those are separate public
operations. It also leaves DST gap/overlap conversion, non-UTC local profiles,
empty and unrecognized value selectors, and releases other than 7.00 for later
compatibility work. No private method, cache layout, or branch is a coverage target.

Coordinator integration review
------------------------------

The probe now captures the actual scalar clear-error return and records warnings
for each action as well as for the sequence. Installed Date and Obj module hashes
are included. The full-parse both-list case now actually reads the parsed-zone
value asserted by its feature. Optional list requests and recovery inputs are
explicit in the English tables. The error-operation mapping is `error.read-state`;
per-case operation IDs list only operations actually called, including setup.

`python3 tools/review/parse_cache_literals.py` checks all30 mapped sequences,
provenance, request/action correspondence,20 stale-carrier literals and two
exception/recovery sequences. It is a targeted research consistency check, not a
BDD runner or semantic approval of the disputed compatibility behavior. Review
candidate output before replacing the saved reference observations.
