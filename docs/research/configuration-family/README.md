# Configuration and object-lifecycle reference observations

Run the research batch from the repository root:

```sh
python3 tools/probes/configuration-family/run.py > docs/research/configuration-family/observations.json
```

The runner sets the pinned Date-Manip 7.00 library, UTC and C.UTF-8 environment,
starts a new process for every invocation, repeats each case twice, has a 15-second
limit per invocation, and uses at most four workers. It records returned values,
exceptions, warnings, captured call stdout, object error state, and requested
configuration values. The 40 cases were byte-identical on both runs. This is
repeatable research evidence, not a review approval and not a BDD test result.

The matrix has one narrow case for every one of the 38 documented configuration
keys. `CFG-DM5-*` cases run through the distinct DM5 compatibility backend 5.66
bundled in Date-Manip 7.00; their `null` initializer results and warnings are kept
as observed rather than normalized to the DM6 object route. The remaining cases
cover read arity, error clearing, kind predicates, derived context, and base-service
access. `cases.json` is the exact case-to-contract-and-partition mapping; a case
does not discharge a whole key domain.

The configuration snapshot captures `err` before enumerating configuration names
and never reads an unset date value. The replacement run was first written to
`/tmp/configuration-observations-corrected.json` and compared with the prior record.
The intended changes were removal of observer-created `[value] Object does not
contain a date` errors, use of the corrected `yytoyyyy` read name, and source-line
offsets in warning text. All 40 reruns remained repeatable. Configuration diagnostics
are preserved in the warning channel; `CFG-ERROR-CLEAR` is the clean value-error
lifecycle evidence.

Remaining explicit obligations include every unselected partition in
`docs/research/contracts/configuration-domains.json`: valid and invalid boundaries,
empty/zero/omitted distinctions, sequential reset interactions, ordered and nested
configuration files, every special-section grammar, all language selectors,
parsing/rendering effects, business/recurrence/zone interactions, and configuration
read results for scalar and list-shaped settings. Also open are object construction
for Base/TZ/Date/Delta/Recur, source and cross-kind construction, overrides,
initial parse failure, context sharing versus derived isolation, zone-service access,
and error sharing/recovery after successful operations. The two context-service
operations are not both independently observed: the combined case currently calls
only the base service. No scenario claims any of those coarse partitions are closed.

Coordinator review corrected backend isolation and call fidelity. The probe now
loads only its requested backend, applies the pinned fixture before legacy
initializer requests, and runs with a minimal environment in a fresh temporary
directory. The derived-context request now passes its override through the
supported option-list carrier. Its result changes from `US` to `non-US`; the
previous result described a malformed call, not supported context derivation.
The reset case starts with `non-US` before resetting to `US`. All 40 cases repeated
after these corrections; derivation is the only raw-result change. Warning
channels remain recorded. The base-service sample no longer claims zone-service
coverage without calling it.

Two malformed Examples headers were corrected, and lifecycle steps now name
specific settings, query names, argument omission and the numeric clear request.
`python3 tools/review/configuration_literals.py` checks provenance, 29 table-case
literals/diagnostics and the corrected derivation/reset evidence. The drafts are
still unapproved; remaining configuration domains, state combinations, file
semantics, and receiver variants prevent completion.
