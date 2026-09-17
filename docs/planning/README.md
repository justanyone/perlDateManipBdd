# Plan: a portable behavioral specification

Status: proposed plan, 2026-09-17. This change adds research, mappings, and example
feature text only. It does not implement a runner, Perl step definitions, or the
complete specification. The initial 24 observations are samples, not a coverage claim.

## Outcome

Create an original, MIT-licensed, English Gherkin specification describing all
user-visible Date::Manip capabilities as language-neutral operations. Then implement
a Perl adapter that demonstrates those features against a pinned Date::Manip
release. A subsequent library in another language will implement the same feature
contracts using its own code, APIs, algorithms, and data sources.

The specification describes results and observable state changes, not how a
particular implementation computes them. A scenario may pass by correctly reporting
an invalid request; “passing test” does not mean every library operation succeeds.

## Planning artifacts

| Artifact | Purpose | Later implementation receives it? |
| --- | --- | --- |
| [Portable contract](portable-contract.md) | Domain types, step vocabulary, serialization and comparison rules | Yes, after review |
| [Gherkin examples](examples/) | Proposed English scenarios with fixed expected values | Yes, after promotion to approved features |
| [Capability and Perl mapping](perl-mapping.md) | Existing entry points, overloads, and planned adapters | No |
| [Declaration inventory](perl-api-inventory.csv) | Every named subroutine found in the pinned release's `lib/` files | No |
| [Boundary catalogue](boundaries.md) | Worklist for enumerating behavior, modes, syntax and interactions | Specification authors; export rewritten portable cases only |
| [Reference observations](observations.md) and [raw results](observations.json) | Evidence for the examples and future oracle procedure | Reviewed results only; no Perl-specific records |
| [Source-separation policy](source-separation.md) | What may cross into the future implementation | Yes |

## Scope decisions proposed by this plan

- Pin CPAN Date::Manip **7.00**, archive SHA-256 from [source provenance](../upstream-source.json),
  as the initial reference. Use DM6 and the OO interface as the primary profile.
  Record Perl, OS, locale, configuration, and bundled timezone-data version.
  Do not test against moving Git HEAD, whose version currently reads 7.01.
- Include the DM5 functional backend as an explicitly versioned compatibility
  profile. A DM6 result must not silently become the expected DM5 result.
- Include every public capability: natural-language parsing in every supported
  language, formatting, calendar utilities, all delta modes, arithmetic, recurrence,
  timezone resolution and customization, business calendars, holidays/events,
  configuration, object/value lifecycle, and errors. Enumerate each option and
  directive, not just each function name.
- Represent Perl-specific overloads through explicit generic operations. Split
  context-sensitive returns into separately named requests; carry remaining tokens
  or changed values in result records instead of requiring Perl references.
- Exclude private functions from test obligations. Test observable public behavior
  without requiring private tests or internal execution coverage. Do not require
  another language to reproduce private functions, caches, regexes, object layouts,
  memory identity, or module/file structure.
- Track build tools and internal timezone-data generation separately. Their
  algorithms and generated source are outside the portable date-library contract.
  Timezone data access and user-defined zones remain in scope. Any other exclusion
  requires a named inventory entry, rationale, and review.
- Preserve intentional observable quirks in a named reference-compatibility profile.
  Suspicious, contradictory, or hazardous results remain visible as disputed cases.
  Do not silently change them to idealized results, or mandate unsafe behavior in
  the default portable profile. A difference needs an explicit disposition.

These are planning defaults, not a claim that all scenarios have been decided.
Questions such as ambiguous-time precedence, mixed-sign duration comparison, and
exact error classification will be resolved through the steps below rather than
left to adapter intuition.

## Work sequence and completion gates

### 1. Establish the reproducible reference

Lock the release and runtime, disable unintended user/system configuration inputs,
fix current time with a deterministic setting, fix language/encoding and timezone,
and snapshot relevant business rules. Store installed timezone-data identifiers and
config sources. Exercise each backend in a separate process. Include a separate
profile for OS-dependent zone discovery and POSIX formatting.

Gate: repeated, isolated probes produce the same results; all fixture defaults are
named, and backend/version changes cannot happen unnoticed.

### 2. Reconcile the full capability inventory

Start with the 423 declaration rows in `perl-api-inventory.csv`. It includes named
subs nested in blocks, not just column-zero declarations: methods such as `set`
and `printf` would otherwise be missed. This is a discovery list, not a parser proof.

Reconcile the list with POD, both export lists, inherited methods, aliases, generated
symbols, and runtime callable discovery. Account for data-only modules and tooling
outside `lib/` using the full source manifests. Assign each public operation a
stable contract ID and list every meaningful argument shape, option, output type,
mutation, side effect and error channel. Record inherited methods per consuming
type, even where implementation is shared.

Build auxiliary inventories for parsing productions, configuration keys, formatting
directives and modifiers, recurrence grammar/modifiers, language tokens, zones and
aliases, and error classes. The 34 DM6 exports are only one view of this API.

Gate: every row has a disposition; every public contract maps to a generic operation;
every named option/directive has boundary obligations. There are no silent exclusions.

### 3. Define portable types and unambiguous vocabulary

Review `portable-contract.md` and freeze a versioned glossary. Resolve the distinction
between civil dates, local times, zoned values, instants, calendar intervals, elapsed
durations, and business durations. Define omission, empty text, empty list, absent
value, invalid input, and no-match as different concepts.

Convert positional/overloaded Perl calls into named conceptual requests. Fix units,
index origins, range endpoints, rounding and state transitions. Keep supported
input/output syntaxes as interface behavior, but write their descriptions and
examples independently. Avoid using a compact Perl return string as the universal
portable value type.

Gate: someone can implement the feature steps from the glossary without reading a
Perl call, source algorithm, object field, or undocumented default.

### 4. Design exact cases from partitions and interactions

Use `boundaries.md` to enumerate equivalence classes and before/at/after cases.
For each contract include ordinary success, limits, invalid input, and every
observable option/return variant. Add state sequences where one call affects another.
Test explicit interactions such as DST × arithmetic mode and configuration × parsing.
Use pairwise combinations for the remaining independent dimensions, with a recorded
reason when stronger combinations are unnecessary.

For each case record: case ID, contract ID, input, complete context, expected type,
raw reference behavior, normalized result, evidence, status and profile. A scenario
outline row receives its own stable case ID; a scenario name alone is insufficient.
No finite suite covers every possible input. Completeness means the reviewed
capability/partition inventory is discharged, not mathematical proof of equivalence.

Gate: all partitions have proposed cases and every table cell has a defined meaning.

### 5. Observe, review, and freeze results

Write original reference probes later, using public calls and original inputs.
Run them against the unchanged dependency, capture all output/error/state channels,
then repeat with isolated state. Compare functional and OO routes only where the
mapping says their semantics should agree. Hand-check calendar facts and use
independent published standards/data where relevant; do not treat agreement with a
second library as absolute authority.

Classify each result as documented-and-observed, observed-compatibility, disputed,
environment-dependent, or unsupported. Source reading suggests a branch to probe;
it is not evidence that a proposed input produces a particular result.
Translate verified observations into reviewed literal expectations. The later test
run must not ask Date::Manip to calculate its own expected answer. Changes to frozen
expectations need a reviewed diff and explanation, not automatic snapshot acceptance.

Gate: every promoted example has reference evidence and an agreed semantic meaning;
no missing observation is represented as a success. Suspected bugs have dispositions.

### 6. Author the feature set, then build the Perl adapter

Write `.feature` files first using the grammar demonstrated in `examples/`. Use
`Scenario Outline` + `Examples` for independent input/output cases; use step data
tables for structured requests, holiday calendars and ordered result collections.
Avoid embedding Perl or any other implementation language in feature files.

The proposed runner is **Test::BDD::Cucumber 0.87**, whose downloaded tutorial and
StepContext documentation support both styles of tables. Confirm parsing, outline
row expansion, tags, Unicode, escaping and assertion-failure reporting in an early
runner trial before committing to runner-specific conveniences. Use the common
Gherkin subset rather than assuming every modern Cucumber keyword is supported.
The runner is a separately licensed development dependency (`perl_5`), not a bundled
part of the future implementation.

Only after the contracts are reviewed, implement original Perl steps/adapters. They
translate requests, call the real library, decode outputs, and assert literals. They
must not reimplement calendar algorithms, silently repair errors, reorder observable
results, or discard state changes. Include adapter checks for `undef`/empty/zero,
scalar/list context, output channels, and normalization. Prove assertions can fail.

Gate: the same feature text can drive a second-language adapter; Perl-specific
compatibility tests stay in a separate binding profile.

### 7. Audit coverage and prepare an implementation-only handoff

Report capability, partition, profile, directive, language, configuration and state
coverage separately. Every public operation and supported usage type needs direct
behavioral coverage. Private declarations and internal generation tools are excluded
from test obligations and coverage denominators. Source review can identify public
edge cases without requiring private-function or internal branch execution.
Public skips, unsupported variants and disputed cases remain visible.

Export only approved original features, glossary, abstract protocol, reviewed
expectations and the project's MIT notice. Audit the exact export list as described
in `source-separation.md`. The second-language implementation starts in a fresh
workspace/session with that package, not this research conversation or source tree.

Gate: no upstream implementation, translated algorithm, copied upstream tests,
Perl binding code, or upstream generated datasets are in the handoff.

## Current evidence and limits

Twenty-four original planning observations were run with Perl v5.40.1 and Date::Manip
7.00/DM6. Two fresh-process runs produced identical JSON. The example features use
those results. The full partition catalogue, exhaustive API reconciliation, runner
trial, DM5 observations and complete feature authoring are future work in this plan.
The BDD runner is not installed; these examples have not been executed as features.

Sources: [Gherkin reference](https://cucumber.io/docs/gherkin/reference/),
[Perl BDD tutorial](https://metacpan.org/release/EHUELS/Test-BDD-Cucumber-0.87/view/lib/Test/BDD/Cucumber/Manual/Tutorial.pod),
[step data tables](https://metacpan.org/pod/Test::BDD::Cucumber::StepContext),
[runner release metadata](https://fastapi.metacpan.org/v1/release/Test-BDD-Cucumber).
