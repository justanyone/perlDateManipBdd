# Localized day ordinal reference batch

This original bounded batch characterizes the public `Date_DaySuffix` facade,
inventoried as `date.localized-day-ordinal`, in both functional backends shipped
with Date-Manip 7.00. The current DM6 backend is version 7.00; the bundled DM5
compatibility backend reports version 5.66. No private language or array helper is
called.

The normal matrix requests every civil day-of-month from 1 through 31 in all 16
current canonical languages. The legacy matrix requests the same 31 values for
all 14 languages declared by that backend. Thirteen additional argument forms per
backend cover zero, negative and above-range numbers, a fractional number, an
omitted argument, explicit undefined, empty and nonnumeric text, numeric text,
array and map references, and an ignored extra argument. This produces 925
executed requests and 1,850 public ordinal calls because every request is made
once in scalar context and once in list context. Legacy Catalan configuration
fails before any ordinal call, so it is a separate setup observation rather than
a fabricated missing result.

Each of the 56 observation cases ran twice in a fresh Perl process and temporary
working directory, with at most four workers and a 15-second timeout. The runner
fixes `PATH=/usr/bin:/bin`, `TZ=Etc/UTC`, `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`, Perl hash behavior, and a
`PERL5LIB` containing only the pinned local installation. Each process applies the
complete matching profile from `docs/automation/reference-profiles.json`, replacing
only its Language entry with the case language. The runtime is Perl 5.40.1 on
`x86_64-linux-gnu-thread-multi`. The evidence records the loaded facade and
transitive Date-Manip module paths, facade/backend versions, effective profile,
and hashes for the manifest, probe, runner, shared profiles, and every installed
module below `Date/Manip`.

The probe preserves native carriers. DM6 `Date_Init` success returns defined empty
text; DM5 success returns undefined. A scalar ordinal call returns text or
undefined. Each completed list-context call returns one item containing that same
text or undefined value. Neither documented facade exposes a public error observer
for this operation, so the record says so instead of manufacturing an error.
Warnings, real stdout, exceptions, and process stderr are captured separately for
module load, configuration, scalar calls, and list calls. DM5's load deprecation
warning remains source-binding evidence.

Run a candidate capture and the literal fidelity review with:

```sh
python3 tools/probes/day-ordinal-family/run.py > /tmp/day-ordinal-candidate.json
python3 tools/probes/day-ordinal-family/review.py
```

The reviewer checks every one of the 925 feature rows against the saved public
return, verifies both calling contexts and all hashes, distinguishes the setup
failure, and independently derives all 31 English suffixes, including 11th–13th
and 21st/31st. It is a research consistency check, not an executable BDD suite or
linguistic approval.

## Reviewed outcomes and disputes

- The current backend produces a concrete 31-item ordinal sequence for every one
  of its 16 canonical languages. The portable draft freezes those exact texts; it
  does not infer linguistic rules from the implementation.
- Thirteen legacy languages configure and return all 31 values. Legacy Catalan
  raises an undefined-array-reference exception during exact fixture setup, so no
  `Date_DaySuffix` call is recorded for it. Finnish and Norwegian are current
  languages but are not declared by the legacy backend.
- Several legacy sequences differ from current results. They remain in a dedicated
  compatibility feature. The legacy Italian value for day 30 is `3mo`, between
  `29mo` and `31mo`; it is tagged as a suspected bug rather than adopted as a
  portable spelling. Legacy Russian results retain their trailing spaces exactly.
- Values 32 and 100 return undefined in both backends. The documentation does not
  state the invalid-input convention, so these are explicit observed invalid
  boundaries rather than a claim about every out-of-range numeric value.
- Zero selects the day-31 text, -1 selects day 30, and 1.5 selects day 1 in both
  backends. Those array-index compatibility results are disputed and do not define
  valid day-of-month semantics.
- Omitted, undefined, empty, and nonnumeric scalar arguments select day 31; the
  first two emit an uninitialized-value warning and the latter two emit a
  nonnumeric-value warning. Numeric text `"02"` selects day 2, array and map
  references return undefined, and a second argument is ignored. These are tagged
  Perl-binding-only and excluded from a portable handoff.

## Finite remaining partitions

The exhaustive normal-day matrix is complete only for these canonical language
names and the pinned default encodings. It does not cover the 45 language selector
aliases, language-name case variants, runtime language reconfiguration, every
encoding, invalid byte sequences, or unsupported language setup; those belong to
the language configuration family. Invalid numerics still leave other negative
indexes, 31–32 fractions, very large negative and floating values, numeric formats
such as exponent notation, overloaded or blessed Perl values, and more than one
extra argument. Independent native-speaker review of every localized ordinal is
also outside this mechanical reference observation.

The feature map gives every observation parent and every executed request a stable
ID, literal row, and canonical operation ID. `bindings.json` separately records
the exact public setup, metadata, and operation calls. Portable, legacy,
invalid-observation, suspected-bug, setup-failure, and Perl-binding scenarios are
kept visibly separate.

## Coordinator review

The coordinator repeated all 56 cases with two isolated attempts after the fixed
PATH and setup-return repairs. All observed call outcomes remained identical;
the failed legacy Catalan setup now correctly has no return fields. Every one of
925 row checks includes its language or profile, exact arguments, result, feature
path and observation mapping. Four additional concrete binding examples replace
the generic out-of-range carrier statement. Public operation IDs and effective
configuration are checked against their catalogues. The real pinned Gherkin parser
accepts 930 expanded examples, including the setup failure and four binding cases.
This is parser and reference-evidence verification, not executable BDD completion.
