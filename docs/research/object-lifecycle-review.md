# Independent review of the object-lifecycle family

Review date: 2026-09-17

Verdict after repair: **the concrete review findings are resolved**. The batch
remains draft research pending coordinator integration; this verdict does not
promote it to an executable BDD suite.

## Review scope

The review inspected the public-call probe and runner, all 20 stored observation
records, cases, coverage mappings, signature inventory, both feature files, the
complete API contract map, and the relevant public Date-Manip 7.00 POD. It traced
the English statements to their call sequence and raw evidence, checked scalar
and list context, configuration sharing and isolation, error observers, and the
binding-only method-availability boundary.

## Resolved findings

### Portable date presentation and native returns

The research evidence continues to store native Date scalar returns verbatim in
`YYYYMMDDHH:MN:SS` form. The portable features intentionally use the readable
`YYYY-MM-DD HH:MM:SS` form. Their backgrounds now define that value as a
lossless rendering of the six civil fields, and every affected assertion calls
it a normalized civil date-time rather than an exact native scalar return.

This preserves readable, language-neutral expectations without fabricating a
Date-Manip return. The reviewer checks for the normalization definition and
rejects the earlier ambiguous “exact date values” and “date scalar value” text.

### Complete public-call mappings

Every case now uses a canonical primary `operation_id` from
`docs/research/api/contract-map.json`. Each coverage row repeats the case's full,
ordered `contract_ids`, and the reviewer enforces exact equality plus catalogue
membership.

The repaired lists include the previously omitted typed duration and recurrence
constructors, all three explicit parse methods in the error-lifecycle cases,
error/configuration calls, and the Date, Delta, and recurrence component
observers whose results appear in feature assertions. The recurrence catalogue
currently gives its dual-role getter/setter methods `recur.set-*` IDs; the
binding-specific getter partitions retain that distinction.

### Effective independent-context mutations

`OBJ-008-CONFIG-ISOLATED-KINDS` no longer uses a US-to-US no-op. For each Date,
Delta, and Recur receiver it observes:

1. source US and independently configured child non-US;
2. source US and child US after changing the child;
3. source non-US and child US after changing the source.

The final differing pair demonstrates that a later source mutation does not
propagate to the independent child. The raw record includes return definedness
and reference type, errors, and exceptions for both configuration mutations,
plus errors and exceptions around every configuration read.

### Compatibility selector classification

`OBJ-009-DATE-VALUE-CONTEXTS` is tagged `@observed-compatibility`. Its table
separates the documented omitted, `local`, and `gmt` forms from the undocumented
empty and unrecognized `OTHER` forms. All calls remain through the public Date
`value` entrypoint.

### Observer boundaries

The previously bare Date and Delta pre-mutation reads in `OBJ-014` and `OBJ-015`
now record definedness, exact native return, error before and after, and
exception. Date objects returned by recurrence component getters in `OBJ-020`
record the same value-read boundary. Configuration cases `OBJ-006` through
`OBJ-008` now record mutation return metadata and read boundaries.

### Constructor signature inventory

The `new_config` inventory entry now records that parser arguments are accepted
through the same constructor path as `new`, before the final configuration-pair
list. Parser-option partitions remain an honest future coverage obligation.

## Confirmed fidelity

- The repaired runner executed all 20 cases twice in separate temporary working
  directories with the fixed environment, at most four workers, and a 15-second
  timeout. Every pair was byte-identical and returned status 0 with no warning,
  uncaught exception, call stdout, or stderr.
- Independent hashes match the fixture, probe, runner, and installed Date,
  Delta, Recur, and Obj modules recorded in the observation artifact.
- Scalar and list context are imposed by assignment. Cases where pristine
  context matters use separate receivers. `OBJ-002` intentionally reads scalar
  then list on the same empty Date child; `OBJ-010` supplies independent pristine
  receivers.
- `OBJ-006` demonstrates shared same-kind configuration in both directions.
  `OBJ-007` demonstrates sharing from a typed Date child through its source and
  sibling carriers. `OBJ-008` demonstrates independent configuration in both
  mutation directions.
- Invalid constructor and mutation observer sequences match the raw errors.
  The Date getter replaces its parse/set error when the carrier is empty; the
  corresponding Delta and Recur getters retain their recorded parse errors.
- The impossible individual-day mutation remains tagged
  `@observed-compatibility @disputed`; no civil-date validity is inferred from
  Date-Manip's successful status.
- Recurrence modifier and frequency reset effects match the actual setter and
  observer order.
- Unsupported `clone`, `clear`, and `reset` assertions remain confined to the
  `@reference-binding` method-availability scenario and binding partitions.

## Regeneration comparison

The fixture and mapping metadata changed for all records. Raw result payloads
changed only for `OBJ-006`, `OBJ-007`, `OBJ-008`, `OBJ-014`, `OBJ-015`, and
`OBJ-020`, exactly where new boundary fields or the effective isolation sequence
were introduced. Other raw behavior values remained unchanged.

The current repository reviewer validates all repaired conditions and prints:

```text
checked20 repeatable cases,20 unique draft mappings, and selected mutation/absence literals
```

Remaining lifecycle obligations are listed in the family README and are outside
this bounded repair. Converted Date cache mutation remains owned by the separate
parse-cache family.
