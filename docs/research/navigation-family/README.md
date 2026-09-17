# Previous and next navigation research

This batch characterizes the public `Date::Manip::Date::next`,
`Date::Manip::Date::prev`, `Date::Manip::DM6::Date_GetNext`,
`Date::Manip::DM6::Date_GetPrev`, `Date::Manip::DM5::Date_GetNext`, and
`Date::Manip::DM5::Date_GetPrev` entrypoints. It supplies candidate scenarios for
canonical operations `date.find-next` and `date.find-previous`. It does not call
the private navigation helper.

## Evidence

`cases.json` contains 87 original fixed requests: 37 object calls, 25 current
functional calls, and 25 compatibility functional calls. The split is 54 next
and 33 previous requests. `observations.json` records two byte-comparable runs of
every case. Every attempt used a new Perl process and temporary working directory,
four workers at most, and a 15-second process timeout.

Run the probe from the repository root:

```text
python3 tools/probes/navigation-family/run.py > /tmp/navigation-candidate.json
python3 tools/probes/navigation-family/review.py
```

The environment fixes `PERL5LIB` to `local/date-manip-7.00/lib/perl5`, `TZ` to
`Etc/UTC`, the C UTF-8 locale, `PERL_HASH_SEED=0`, and
`PERL_PERTURB_KEYS=0`. The observed distribution is Date-Manip 7.00, with DM6
backend 7.00, DM5 backend 5.66, tzdata2026c, and tzcode2026c. The observation
envelope includes SHA-256 hashes for the fixture, probe, runner, profile file,
all loaded Date::Manip modules, and the inspected public POD files. PATH is fixed
to /usr/bin:/bin. Failed functional calls omit the return fields: a thrown
exception is not an observed absent return value.

Native exceptions can contain allocated Perl reference addresses. The probe
replaces only such tokens, for example `HASH(0x7f...)`, with `HASH(0xADDR)` before
comparison and storage. It retains the rest of the exception, including path,
line, call text, and stack. The normalization is declared in each observation.

## Sources and contract boundary

The public call shapes come from:

- `Date::Manip::Date` POD under `prev` and `next`, beginning near line 486;
- `Date::Manip::DM6` POD under `Date_GetPrev` and `Date_GetNext`, beginning near
  lines 387 and 401;
- `Date::Manip::DM5` POD under `Date_GetPrev` and `Date_GetNext`, beginning near
  lines 1112 and 1160;
- the public implementations in `Date.pm` near lines 2943 and 2955, `DM6.pm`
  near lines 480 and 512, and `DM5.pm` near lines 2877 and 2942; and
- the canonical binding matrix in `docs/research/contracts/values.json` and
  `docs/research/api/contract-map.json`.

The source implementation was inspected to choose meaningful public cases and to
explain results. No private entrypoint is invoked or specified. Object records map
the constructor, configuration, version, zone-version, navigation, value, and
error calls they actually execute. Functional records map configuration, version,
and their navigation operation.

## Observer protocol

Each valid object receiver is observed in scalar and list contexts before the
navigation call, without a local or GMT conversion read. The probe records the
error immediately before and after the public navigation call. It then observes
scalar, list, local scalar, and GMT scalar values in that order, with error before
and after every read. After a failed call or a call carrying an error, it clears
the final observer error through the public error operation and repeats the value
sequence. This distinguishes a preserved carrier hidden by an error from an empty
carrier.

An unset receiver and a deliberately error-bearing receiver are not value-read
before navigation. The latter is created from the exact initial text in the
fixture, then receives the exact invalid parse text also present in the fixture.
Functional records retain the native scalar/absent return type, exception,
warnings, configuration return, configuration exception, and captured standard
output.

## Observed behavior

For weekday predicates, `curr=0` selects a strict different day, `curr=1` admits
the current matching day, and `curr=2` excludes the exact instant while allowing
a different clock time on the current matching day. The cases cover a matching
Friday, nonmatching Thursday and Sunday, clock replacement, and both navigation
directions.

With no weekday, a three-slot clock predicate may leave leading or trailing fields
absent. Exact clock predicates distinguish strict mode from current-inclusive
mode. Minute-only and second-only predicates advance or retreat at their natural
clock boundary. The corpus also crosses midnight into leap day, retreats onto leap
day, and crosses a year boundary.

The current functional facade accepts numeric, one-character, abbreviated, and
full English weekday forms. It accepts a clock as one text argument or as separate
components and serializes a scalar result. The compatibility facade agrees on the
bounded successful corpus, subject to its module-load deprecation warning.

Five outcomes are explicitly compatibility or disputed behavior:

1. Object navigation into the New York spring-forward gap returns status `0` even
   though its immediate error is `[set] Invalid date/timezone`; the carrier is
   empty afterward and remains empty after error clearing.
2. The current facade raises an undefined-array-reference exception for weekday
   time text `25:00`, while the compatibility facade returns defined empty text.
3. A missing predicate returns defined empty text in the current facade but the
   compatibility facade raises `ERROR: invalid arguments in Date_GetPrev.`
4. Omitting the inclusion argument behaves like strict mode and returns a value,
   while emitting uninitialized-value warnings.
5. An extra clock component returns empty text in the current facade. The
   compatibility facade ignores it and returns the noon occurrence. The object
   method likewise ignores its fourth argument.

Invalid object predicates return status `1`, retain the original valid carrier,
and make value observers empty while the error remains. Clearing the error exposes
the original carrier again. Unset and parse-error receivers instead remain empty.

## Outputs

- `cases.json`: exact language-neutral requests and case identifiers.
- `observations.json`: pinned raw native evidence and run metadata.
- `coverage-map.json`: every case mapped to its canonical operation, public
  binding, feature, and scenario.
- `literal-review.md`: the manual comparison of feature literals with evidence.
- `disputed-behavior.md`: minimal public-call reproducers for disputed outcomes.
- `spec/drafts/navigation/object-navigation.feature`: object mutation, observers,
  invalid states, DST transitions, and arity behavior.
- `spec/drafts/navigation/functional-navigation.feature`: DM6 and DM5 return
  behavior, weekday spellings, clock shapes, failures, and arity behavior.

## Finite remaining obligations

This batch does not claim exhaustive navigation coverage. Remaining bounded
domains are:

- weekday numbers 1, 2, and 3, because this corpus exercises 4 through 7;
- valid one-field object weekday clocks `[H]`, explicit weekday `0` as the absent
  selector, empty clock lists, and nonnumeric clock fields;
- functional `HH` and `HH:MM:SS` single-text clock forms in both directions, plus
  omitted trailing numeric clock components other than the selected examples;
- inclusion values outside 0, 1, and 2, including a negative and a larger truthy
  integer, for both weekday and clock predicates;
- previous navigation through the fall overlap and overlap-side selection where a
  public option can select it;
- southern-hemisphere and non-hour DST transitions, and a non-UTC fixed-offset
  local profile;
- non-English weekday lookup in each facade and ambiguity among localized
  one-character weekday names;
- leap-century boundaries 2000 and 2100 and the supported minimum/maximum year
  edges; and
- native list-context invocation of the functional entrypoints, if the future
  adapter exposes Perl calling context as a binding-specific capability.

These are additional partitions, not defects in the 87 mapped cases.

## Coordinator verification

A new two-attempt capture reproduced all 87 behavior records after complete module
provenance and exception-completion repairs. Only false exception return fields
were removed; changed probe line numbers in stack text are retained in fresh data.
The automated reviewer checks exact arguments, receivers, public operation IDs,
per-row returned values, exception prefixes, invalid receiver and error-clearing
mutation results, warnings and hashes. Two prose-only object cases are checked
against their own scenario blocks. The deprecation binding scenario now has a
concrete request and a separate mapped assertion ID. Reference-binding exception
and warning scenarios are excluded from portable handoff. Final portable promotion
still requires the general source-separation review; all features remain drafts.

An independent worker reran all 87 cases and reproduced the repaired evidence
byte for byte. A separate Python standard-calendar check confirmed the weekday of
45 successful weekday-predicate returns. The coordinator's parser command uses
`PERL5LIB="$PWD/local/bdd-runner/lib/perl5"` with
`tools/runner-trial/parse-features.pl spec/drafts/navigation/*.feature`; both files
contain six accepted scenarios (their data tables carry the 87 requests). The BDD
runner dependency is installed separately from the Date::Manip reference prefix.


Portable wording now names serialized-wall, ordered-field, local-text and UTC-text
observers instead of imposing Perl scalar/list evaluation contexts. Their exact
bindings live in `coverage-map.json`. Ordinary functional scenarios retain all
requests/results while deprecation assertions stay in the excluded binding case.
The observable order and all frozen result literals are unchanged.
