# Portable draft audit

## Scope and method

This audit covers the 52 committed feature files under `spec/drafts/` at commit
`04f60c36dc1842f434e4d881dfa2b7f243a12626` (`Specify public previous and next
navigation behavior`). That snapshot has 307 scenario declarations, including
137 scenario outlines. `spec/drafts/day-ordinal/` entered the branch after this
audit began and is being reviewed separately, so it is outside this report.

The review used the portability rules in `docs/planning/README.md` and
`docs/planning/source-separation.md`. A mechanical scan located implementation
names, return-context words, diagnostics, blank table cells, sentinels, and vague
quantifiers. Each finding below was then checked against the whole scenario and
its effective feature and scenario tags. Literal-input lookup and a matching case
map can establish traceability; neither establishes that the request is fully
specified or that its expected result has the intended portable meaning.

Priority meanings are:

- **P0:** the file cannot enter a portable handoff in its current form.
- **P1:** the request or fixture is ambiguous enough to prevent an independent
  adapter from implementing the same case without research-side knowledge.
- **P2:** a review decision is needed; the current wording is not necessarily
  wrong, but it risks prescribing the reference binding.

## P0 definite defects

### Binding-only failures and warnings lack a handoff exclusion

The following scenarios prescribe Perl exceptions, a private method/package
name, or Perl warning behavior without an effective
`@excluded-from-portable-handoff` tag:

| Path and scenario | Defect | Required repair |
| --- | --- | --- |
| `spec/drafts/date-set/date-and-time.feature:73`, **A scalar whole-date carrier raises a binding exception**; and `:131`, **A scalar time carrier raises a binding exception** | They require an `ARRAY ref` / `strict refs` exception. `@reference-binding` does not exclude a scenario from handoff. | Add `@source-binding @perl-binding @excluded-from-portable-handoff`. If the wrong-shape request is portable, place its normalized failure in a separate portable scenario. |
| `spec/drafts/date-set/zone-and-zoned-date.feature:58`, **Offset and unresolved zone inputs raise a Date-Manip 7.00 binding exception**; and `:112`, **Zoned-date offsets and unresolved names raise the same binding exception** | They require private method `__zone` and package `Date::Manip::Base`. | Keep the exact exception only in an excluded binding scenario. Preserve a separately observed public failure contract only if the adapter has a normalized outcome to assert. |
| `spec/drafts/date-set/individual-fields.feature:65`, **Individual replacements accept malformed or out-of-range field values** | The same scenario mixes portable returned fields with a raw native scalar and warning counts, including undefined-value warnings. | Split the portable value/status observations from the Perl carrier and warning observations; exclude the latter. |
| `spec/drafts/recurrence/grammar-and-boundaries.feature:92`, **A one-attempt impossible February selection raises a runtime exception** | It mandates the Perl diagnostic `Can't use an undefined value as an ARRAY reference`. | Keep the reproducer in an excluded binding scenario. A portable disputed case may assert a typed failure only if that normalized result is independently defined. |
| `spec/drafts/parse-cache/full-parse-reset.feature:37`, **A converted read after clearing a full-parse error raises for &lt;case&gt;** | It requires an undefined-value exception and exactly eight undefined-component warnings. | Split the public parse/error/read sequence from the Perl exception and warning evidence; exclude the binding half. |
| `spec/drafts/arithmetic/arithmetic-dst-business-edges.feature:75`, **Report an invalid date object without mutation** | It includes the exact warning `Object must contain a valid date` in an otherwise portable business-day case. | Keep the absent answer and stored public error in the portable scenario; move the raw warning assertion to an excluded binding scenario. |
| `spec/drafts/configuration/configuration.feature:71`, **Compatibility-sensitive settings have concrete observed results** | Row `CFG-DM6-JAN1WEEK1` requires an exact `Date::Manip` deprecation warning. | Normalize the portable outcome to a deprecated-setting diagnostic and preserve the exact native warning in an excluded binding case. |
| `spec/drafts/languages/dm5-comparisons.feature:8`, **A successful initialization permits concrete legacy language operations**; and `:56`, **Failed initialization prevents dependent operations** | Literal language results are mixed with unescaped-regex and uninitialized-value warning counts, deprecation warnings, and an undefined-array-reference exception. The feature has no binding exclusion. | Split language parse/render results into a portable legacy profile. Move warning counts, warning classes, native exceptions, and raw backend loading behavior to an excluded binding feature. |
| `spec/drafts/navigation/functional-navigation.feature:19`, **Functional profiles navigate weekday and partial-clock predicates**; `:64`, **Invalid source and weekday inputs return defined empty text**; and `:104`, **Extra clock components differ between functional profiles** | These scenarios require the legacy Perl binding's deprecation warning. Nearby native-warning scenarios at lines 82, 94, and 115 are correctly excluded, showing the intended separation. | Remove warning-channel requirements from these public navigation scenarios and map them to the already excluded binding diagnostic case, or split new excluded cases where necessary. |

This is a tagging and separation defect, not a request to discard observed bugs.
The disputed behavior and minimal reproducer should remain in research evidence.

### Perl calling context is still part of portable requests

The plan requires context-sensitive returns to become separately named generic
operations. The following portable-eligible text still requires scalar/list
calling context or labels the result by its native Perl carrier:

| Path and affected scenarios | Concrete leakage | Required repair |
| --- | --- | --- |
| `spec/drafts/object-lifecycle/value-state-and-errors.feature:18-69`, the first five scenarios | The feature explicitly requests scalar and list context and distinguishes their Perl return forms. | Define named operations such as **read serialized value**, **read ordered field record**, and **read optional component**. Map those operations to Perl contexts only in research binding metadata. |
| `spec/drafts/object-lifecycle/creation-and-context.feature:17`, `:30`, `:51`, and `:63` | Constructor outcomes are named `scalar value` and `list value`. | Assert serialized text and ordered typed fields instead. |
| `spec/drafts/date-set/date-and-time.feature:6-14`, `spec/drafts/date-set/individual-fields.feature:6-14`, and `spec/drafts/date-set/zone-and-zoned-date.feature:7-15` | Feature-wide setup prescribes scalar/list reads and native scalar preservation. Ordinary success and failure scenarios therefore inherit Perl call-context requirements even when their body looks portable. | Replace the Background with named observer operations and typed result records; keep native scalar fidelity checks in excluded binding scenarios. |
| `spec/drafts/navigation/object-navigation.feature:13-18` | Every scenario inherits reads in scalar/list context and a fixed observer order. | Name the serialized-wall, ordered-field, local, and UTC observer operations. Retain call-context and evaluation-order proof only in binding evidence when order is not itself public behavior. |
| `spec/drafts/navigation/functional-navigation.feature:19`, `:64`, and `:104` | Results are required to be a `defined scalar`, including a table `return type` column. | Use typed `date-time text` or `empty text` results. Record the native scalar carrier in the source binding map. |
| `spec/drafts/arithmetic/arithmetic-and-delta.feature:120` and `:126`, **Render compatibility patterns...** | The same formatting request is asserted in `list result` and `scalar result` forms. | Split it into explicitly named **render each pattern** and **render joined patterns** operations. |
| `spec/drafts/parse-cache/full-parse-reset.feature` and `spec/drafts/parse-cache/partial-mutation-cache.feature` | Both files repeatedly prescribe `scalar value` and `list` reads. | Express the sequences through named serialized-value and field-record reads. Keep the observable stale/current values and error timing unchanged. |
| `spec/drafts/input-history/remembered-text.feature:10` and all collection reads | The Background explicitly says the collection result is Perl list-context compatibility while the same non-excluded feature asserts it. | Keep the documented one-text operation portable. Put the list-context compatibility operation in an excluded binding feature, or define and justify a real language-neutral collection operation. |
| `spec/drafts/fixed-offsets/fixed-offsets.feature:11`, **Preserve the supplied civil fields and expose UTC...** | Expected values are named `parsed-zone scalar` and `UTC scalar`. | Rename them to parsed-zone text and UTC text; retain native-carrier assertions in research. |

Raw scalar/list fidelity remains valuable for the Perl adapter. The defect is
placing that fidelity in text intended to drive a second-language implementation.

### Placeholder sentinels stand in for calls that do not occur

These outlines contain conditional steps whose cells say that the request was not
made. That forces adapter branching and leaves the actual request set implicit:

| Path and scenario | Defect | Required repair |
| --- | --- | --- |
| `spec/drafts/config-files/loading.feature:14-401`, all 18 outlines | Every `functional-current` row fills the always-present date-order query step with `not requested` / `not applicable`. | Split object-profile rows, which perform the query, from functional-profile rows, which do not. Each outline should contain only calls executed by every row. |
| `spec/drafts/languages/dm5-comparisons.feature:8`, **A successful initialization permits concrete legacy language operations** | The step parses a special input “if that input is applicable”; most rows use `not applicable` for both request and result. | Split rows with a special preprocessing request from rows without one. Remove the conditional step and sentinel values. |
| `spec/drafts/parse-cache/full-parse-reset.feature:10`, **Full parsing refreshes values after any successful prior read for &lt;case&gt;** | Cases `PC-PARSE-PRISTINE` and `PC-PARSE-PRE-BOTH-LIST` set the always-present additional-list request to `none` / `not requested`. The word “any” also overstates four enumerated sequences. | Separate cases that perform the additional read from cases that stop after scalar reads, and rename the scenario to “after each listed prior-read sequence.” |

### Empty table cells collapse distinct portable values

The portable contract distinguishes omitted, empty text, empty collection, and
absent value. Blank Gherkin cells do not say which one is intended. The following
tables use blank cells in asserted input or output columns:

| Path and scenario | Ambiguous columns |
| --- | --- |
| `spec/drafts/configuration/configuration.feature:6`, **A setting accepts one observed representative value**; `:39`, **Invalid configuration retains the concrete prior value**; `:71`, **Compatibility-sensitive settings...**; and `:90`, **The DM5 compatibility initializer...** | setting value, stored value, diagnostic, and legacy initializer input |
| `spec/drafts/arithmetic/delta-grammar-and-format-matrix.feature:10`, **Parse one bounded grammar production...** | successful `error` and failed `fields` |
| `spec/drafts/parsing/date-text.feature:249`, **Reject date text...** | the three empty-input `text` cells at lines 291-293 |
| `spec/drafts/languages/canonical-dm6.feature:40`, **Forced ASCII uses the selected ASCII phrase...** | empty successful `error` cells |
| `spec/drafts/object-lifecycle/value-state-and-errors.feature:18` and `:38` | empty `error` cells |
| `spec/drafts/recurrence/modifier-families.feature:72`, **Apply modifier parameter boundary...** | empty successful `error` cells |

Replace each blank with a typed literal such as `empty text`, `absent value`,
`omitted`, or `no diagnostic`. Quoted `""` is also acceptable where the step
vocabulary explicitly defines it as empty text.

## P1 reproducibility defects

### Named fixtures do not have a portable definition available to every feature

Gherkin Backgrounds do not carry across feature files. No committed portable
profile manifest defines all of these names independently of their research
records:

| Reference | Where it is underspecified | Repair |
| --- | --- | --- |
| `the named fixed reference profile` / `the named fixed profile` | `spec/drafts/arithmetic/arithmetic-calculation-modes.feature:6`, `spec/drafts/arithmetic/delta-grammar-and-format-matrix.feature:6`, and prose in `spec/drafts/arithmetic/arithmetic-dst-business-edges.feature:3` | Give the profile a stable ID and define its clock, zone, language, numeric-date order, week rules, omitted-time rule, interval normalization constants, work schedule, holidays, and events in an exported manifest, then reference that ID. Inline any case-specific override. |
| `the fixed English UTC configuration context` | `spec/drafts/configuration/configuration.feature` and `spec/drafts/configuration/object-lifecycle.feature` | Define a shared exported configuration profile, including clock, date order, encoding, week rules, work schedule, holiday/event state, and configuration-file isolation. |
| `utc-working-week-2040` | Defined inline only in `spec/drafts/recurrence/lifecycle.feature:7-18`, but referenced without definition in the other three recurrence features | Put the definition in an exported profile manifest referenced by all four files, or repeat the complete Background. |
| `utc-english-2040` | Defined in prose in `spec/drafts/rendering/native-rendering.feature:3-6`, but used without definition in `spec/drafts/rendering/extended-posix-rendering.feature` | Move the profile to a shared exported manifest or repeat its definition in the extended-rendering Background. |

The arithmetic wording is the most serious instance because it has neither a
stable profile ID nor a definition elsewhere in the committed portable tree.

## P2 judgment calls

These items need an explicit disposition rather than an automatic rewrite:

1. `spec/drafts/partial-parsing/leading-tokens.feature:11` and
   `spec/drafts/partial-parsing-edges/leading-token-shapes.feature:76` call one
   carrier a `scalar holder`. If this means a language-neutral mutable text cell,
   define that type in the portable glossary and describe the returned remainder
   or mutation. If it exists only to exercise a Perl scalar reference, move those
   rows to the already excluded binding features.
2. `spec/drafts/parse-cache/full-parse-reset.feature` and
   `spec/drafts/parse-cache/partial-mutation-cache.feature` use `cache` in paths,
   tags, and titles. Their step sequences can remain portable because they assert
   public reads and writes, but the handoff names should describe stale/current
   observable values rather than imply a required cache implementation.
3. `spec/drafts/languages/canonical-dm6.feature` and
   `spec/drafts/languages/dm5-comparisons.feature` put DM6/DM5 in portable prose
   and tags. The plan permits separately versioned current and legacy behavior
   profiles. Prefer those abstract profile names in exported features and retain
   DM6/DM5 bindings in research maps. Stable case IDs may remain if the export
   policy treats IDs as opaque.
4. `standard output is empty` appears in the portable partial-parsing features,
   and configuration-file scenarios also assert standard-output channels. If
   output silence is an intentional cross-language contract, define the output
   channel in the portable protocol. Otherwise keep it as adapter/binding
   evidence.

## Checks that did not produce findings

- All 137 scenario outlines in the audited snapshot have an `Examples` block and
  a case-bearing header. This structural check does not prove that their cases
  cover the semantic partitions.
- Binding-only controls in
  `spec/drafts/completeness/binding-warnings.feature`,
  `spec/drafts/partial-parsing/leading-tokens-perl-binding.feature`,
  `spec/drafts/partial-parsing-edges/perl-binding-warnings.feature`, and
  `spec/drafts/value-serialization/perl-binding.feature` carry an effective
  `@excluded-from-portable-handoff` tag.
- Public pattern directives, recurrence tokens, and accepted input grammar are
  interface behavior and were not classified as implementation leakage merely
  because the reference implementation parses them with regular expressions.
- Exact public error text was not automatically classified as Perl-only. It is a
  portable compatibility candidate when the text comes from a public operation,
  has a stated profile/disposition, and does not expose private package, method,
  call-context, or runtime-exception details.

This was a read-only draft audit. No probes were rerun and no feature semantics
were approved by these structural checks.


## Coordinator dispositions after the snapshot

The navigation family was repaired after this audit: portable object steps now
name serialized wall text, ordered date-time fields, local text and UTC text;
research mapping alone names their Perl calling contexts. Observable read order
is preserved. Ordinary functional scenarios assert text results without the
legacy module-load warning; that diagnostic remains in the explicit excluded
binding case. All87 request/outcome checks and both real-parser checks pass.
Date-set repairs are assigned separately and remain pending. Other findings in
this report remain open until individually verified; this is not export approval.

## Committed parser snapshot after portability repairs

`parser-snapshot.json` records commit997c94ee3c946514ec337e6a51d2649ee3ae553e:
67 committed feature files expanded to2932 cases without parser errors or warnings
using Test::BDD::Cucumber0.87. Each file was read from that Git tree into a temporary
checkout; active worker edits were excluded. Exact feature hashes and parser-wrapper
hash are recorded. This is syntax evidence only, not approval or BDD execution.
