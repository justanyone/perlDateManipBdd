# API reconciliation evidence

This directory records research-side API accounting for the separately installed
Date-Manip 7.00 reference. It is not a portable handoff and it does not contain
upstream source, test cases, generated timezone data, or frozen behavioral
expectations.

`contract-map.json` is the stable primary schema. Its `declarations` array has
one row for every CSV discovery record. `declaration_id` combines module,
callable, and original discovery line so a later regeneration can identify the
same record. A row records its CSV evidence, reconciled `disposition`, nullable
`portable_operation_id`, and `coverage_route`. The values are deliberately
separate: a private helper has no portable operation even when its family needs
indirect behavioral review.

The `operations` array groups direct public bindings by portable operation ID.
Every operation currently has `inventory-routed; behavioral partitions pending`.
That status is an explicit gap, not a coverage claim. `facade_aliases` accounts
for functional names made callable by the `Date::Manip` backend facade without
pretending they are additional operations. `non_declaration_surface` counts
generated language, offset, and zone modules without copying their data.

`runtime-callability.json` is a separate runtime observation. It records package
load status, direct symbol-table code names, declared symbol callability, export
lists, inheritance lists, and the receiver matrix for `Base`, `Date`, `Delta`,
`Recur`, and `TZ`, plus fresh-process facade probes for default DM6 and selected
DM5. `can()` establishes lookup only; it does not establish a signature, support
promise, or behavior.

`auxiliary-obligations.json` prevents options, grammar, directives, configuration
keys, and generated data surfaces from being collapsed into a function-count
metric. Its status field says whether terms are enumerated, only the source scope
is known, data modules are counted, or the item is excluded tooling. A
source-scope record remains work to do.

## Results for the pinned source

The generated map has 423 declaration identities. Their dispositions are 67
public functional exports, 97 public OO methods, one unexported legacy
compatibility entry, one declared timezone-generation constructor, 220 ordinary
private helpers, and 37 timezone-generation private helpers. The 164 direct
public functional/OO bindings collapse to 96 portable operation IDs. The runtime
probe resolves all 423 declared symbols as direct package code and all 153
expected inherited OO receiver routes.

The dynamic facade has 34 DM6 aliases and 33 DM5 aliases. DM5 lacks the DM6-only
pattern parsing export. These are binding facts and need separate-process
behavioral comparison before any result equivalence is asserted.

## Reproduce

The commands reject a source whose three main version markers do not read 7.00.
They need the unpacked reference at `/tmp/Date-Manip-7.00` or an explicit
`--source` path.

```sh
perl tools/inventory/reconcile_api.pl --check --source /tmp/Date-Manip-7.00
perl tools/inventory/reconcile_api.pl --source /tmp/Date-Manip-7.00
perl tools/inventory/runtime_callability.pl --check --source /tmp/Date-Manip-7.00
perl tools/inventory/runtime_callability.pl --source /tmp/Date-Manip-7.00
jq empty docs/research/api/contract-map.json \
  docs/research/api/runtime-callability.json \
  docs/research/api/auxiliary-obligations.json
```

Loading DM5 emits its own deprecation warning in this release. The runtime probe
does not call a Date-Manip API method; it loads packages and inspects callable
symbols.

## Bounded follow-up work

1. Extract a binding-signature matrix for the 34 DM6 functional exports, then
   compare the 33 DM5 aliases in isolated processes. Cover positional slots,
   scalar/list results, mutable arguments, warnings, and errors.
2. Turn `AUX.CONFIG.*`, `AUX.DATE.*`, and `AUX.DELTA.*` into finite term and
   partition records, beginning with configuration keys and date/delta format
   directives.
3. Turn `AUX.RECUR.*`, `AUX.HOLIDAY-AND-EVENT-GRAMMAR`, and `AUX.ZONE.*` into
   finite grammar/data-selection records. Keep generated data out of the
   portable handoff; use original probe inputs for any selected representatives.
4. Add behavioral partitions and reviewed reference observations for each
   operation only after its input/output shape is recorded. The private-helper
   routes remain an omission detector, not requirements for a future
   implementation to reproduce internals.
