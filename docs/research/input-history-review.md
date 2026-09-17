# Input-history review after provenance repair

This review covers the regenerated Date-Manip 7.00 input-history evidence in
[`docs/research/input-history/`](input-history/). It is research review, not a
BDD execution result or a portable conformance claim.

## Corrected binding and carrier classification

[`bindings.json`](input-history/bindings.json) now maps every operation used by
the batch to its concrete public binding, source/POD location, native return,
and Perl call context. It covers construction, configuration, `input`, `parse`,
`parse_date`, `parse_time`, scalar `parse_format`, `set`, `convert`, `err`, and
`value`.

The Date-Manip POD documents the scalar form of `Date::Manip::Date->input()`.
The collection assertion in the feature records the observed one-element Perl
list-context carrier. It remains explicitly tagged `@observed-compatibility`;
it must not be exported as a separate documented source API without a portable
contract decision.

The original sixteen literal scenarios remain unchanged. `INPUT-CONSTRUCTOR`
adds the basic public `Date::Manip::Date->new($text, [ options ])` route, where
the ordered fixed profile is supplied before the Date-specific initializer
parses the text. Its observed remembered text, scalar/list carrier, error, and
value are frozen as literals in the draft.

## Regenerated evidence

`tools/probes/input-history/run.py` executes every request twice in separate
processes and fresh directories. It compares the raw JSON payloads before it
saves an observation, and retains both process exit codes and stderr values in
each row. The checked-in `observations.json` has 17 records, two zero exits and
empty stderr for each record.

The header now records the Date-Manip 7.00 archive identity, the exact `oo`
fixture sequence separately from its public `get_config` echo, configured
`Etc/UTC` zone, Perl version/architecture/OS, and the exact loaded `Date`,
`Obj`, `TZ`, `Zones`, and `TZ/etutc00` module paths. The loaded `etutc00`
module is the zone-data module actually used for the configured UTC zone, and
the header hashes every recorded loaded module. It also hashes the cases,
profile, bindings, probe, runner, and reviewer inputs.

An independent candidate comparison confirmed that all 16 retained cases have
unchanged request, action-result, error, input carrier, final-value, warning,
exception, and captured-stdout payloads. The constructor case is additional.

## Reviewer result

The reviewer now rejects a missing provenance header field, an incomplete or
unhashed loaded-module set, a module path outside the pinned local installation,
a changed fixture expectation, changed configured zone, absent process channel,
or a malformed native payload hash. It checks the feature literals against all
17 saved requests and observations.

The verified commands were:

```sh
python3 tools/probes/input-history/run.py > /tmp/input-history-candidate-v2.json
python3 tools/probes/input-history/review.py
python3 tools/review/feature_structure.py spec/drafts/input-history
```

They reported identical native payloads within both isolated runs, 17 matching
research scenarios with required provenance, and one structurally valid feature.

## Scope that remains

This bounded batch does not cover receiver-derived construction, failed
constructor parsing, arithmetic/navigation, localized preprocessing, alternate
encodings, or the wider date mutation family. `INPUT-CONVERT` still characterizes
remembered text and the six civil fields only; it does not specify complete
timezone conversion behavior. No whole-library coverage percentage or final
behavior-completeness claim follows from this evidence.

## Coordinator integration corrections

The coordinator replaced two invented operation IDs with canonical `date.create`
and `date.read-input` IDs, retaining constructor/list-context distinctions as
binding variants. The binding map now also names public configuration reads,
zone resolution and metadata calls. The reviewer requires every scenario and
binding ID to exist in the authoritative catalogue.

Constructor-supplied configuration does not execute a separate public `config`
call. Its record now says `configuration_call_executed: 0` and omits a return
field for that uncalled operation. Ordinary setup records the actual call return.
Fresh two-attempt observations preserve all17 prior behavioral payloads, with
only this explicit call metadata changed. The pinned runner parser accepts all
17 scenario declarations. This integration is still draft reference research.
