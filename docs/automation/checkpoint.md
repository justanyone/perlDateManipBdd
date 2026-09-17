# Specification work checkpoint

This file is the human-readable companion to [queue.json](queue.json). It records
the durable state of the planning queue, rather than claiming that its work has run.

## Latest coverage clarification

Public-only means test entrypoints and portable contracts, not an exclusion of
private implementation from analysis or measurement. Inspect private helpers for
public behavior cases and measure library statement/branch execution through
public calls. Do not restore direct private tests. Earlier statements below that
exclude all private execution measurement are superseded. Near-total coverage is
the aim; the user has now explicitly accepted at least99% statement and95% branch
coverage targets. Review every uncovered statement and branch and document
evidenced unreachable or out-of-scope exclusions.

## Current state

- Queue schema: 1
- Workspace baseline: `workspace-setup` is `current`, owned by `root`.
- Completed batches: `reference-setup` and `api-reconciliation`, reviewed by the coordinator.
- Active batches: `spec-interpretation-formatting`, `spec-arithmetic-deltas`, and
  `spec-recurrence`, `spec-zones-business`, and `spec-configuration-objects`.
  Coverage review and harness stages remain `pending`.
- Scope: English, language-neutral specification and reference observations, followed
  by the original Perl BDD harness, step definitions, adapter, and full-suite
  verification. A future non-Perl implementation remains out of scope.

## Active review at continuation

The strict completion gate in [definition-of-done.md](definition-of-done.md)
now applies to public, non-private APIs only following the user's clarification.
Private tests and internal execution/branch coverage requirements are removed.
All later historical references to private coverage are superseded.

Pattern parsing now has 65 repeated requests through OO and DM6, including 50
successful directive rows. Coordinator review repaired empty-text versus absent
returns, complete named-capture assertions, error snapshots before value reads,
and per-attempt temporary directories. `tools/review/pattern_literals.py` checks
provenance, exact table inputs/results, failure statuses, capture maps, exceptions,
and the two setting sequences. Syntax and feature structure checks pass. The
batch remains draft with broader domains explicitly untested; no BDD run or
semantic promotion is claimed.

Language and partial-parsing workers returned repaired 64-record language and
71-case partial-parsing batches; coordinator review is next, before integration.
Their prior paths are stable. Current active assignments are `language_completion`
for NEW object-lifecycle-family paths and `partial_parsing` for NEW parse-cache-family
paths. The latter characterizes a suspected stale value after date/time-only
mutation, including prior getter reads. Check live handles before reassigning.

## Execution setup

The user authorized goal mode, parallel workers selected by task complexity, and
the full specification followed by a verified Perl harness. The active goal is
stored by Codex; this checkpoint is the durable fallback when a session cannot
continue. Do not mark that goal complete merely because automation setup is done.

Local protocol research found that this VS Code session uses a stdio app server
without the managed control socket needed for an external resume client. The
ten-minute watchdog is installed and enabled as a read-only detector. It
cannot promise automatic recovery after quota renewal in this topology. No
second Codex process, billing change, or direct goal-database update is used.
See [watchdog operation and stop commands](watchdog.md). Ten isolated tests pass;
the installed service successfully reported `no_action` for the active goal.

Current independent worker outputs:

- Accepted reference: `tools/reference/`, `docs/reference-environment.md`,
  `reference-profiles.json`. All three profiles repeated successfully; script
  hashes, leap-day facts, and weekday facts were independently checked.
- Accepted monitor: `tools/automation/`, `tests/automation/`, watchdog instructions.
- Accepted entrypoint accounting: `tools/inventory/`, `docs/research/api/`.
  Both enumerator checks pass (423 declarations, 153 OO receiver routes).
  Auxiliary syntax/option obligations link the finite inventories in `docs/research/syntax/`.
  Source support is distinct from runtime coverage; DM5 support is recorded per row.
- Completed worker drafts: `docs/research/contracts/{calendar,values,arithmetic,
  recurrence,zones-business}.json` and companion Markdown. The coordinator
  checked all 96 operation IDs and binding sets against the API map. These contain
  397 unobserved method-partition obligations, not 397 executed cases.
- `configuration-domains.json` records 38 configuration keys and documented
  domains/defaults; runtime-only ambiguities and file-section grammar remain open.
- Active workers: `arithmetic_features` (grammar/field-range/operand expansion),
  `recurrence_features` (grammar, setters, modifiers and limit controls), and
  `configuration_features` (new pattern-parsing family only). Inspect live agent
  status before restarting work. Rendering, configuration and zones/business
  batches await coordinator review.
- Completed worker drafts awaiting review: rendering has 24 repeated invocations
  with exact bulk-request features and per-pattern mappings; configuration has
  40 repeated cases sampling 38 keys with corrected non-mutating snapshots;
  zones/business has 33 repeated cases sampling all 23 operation IDs. None is
  a complete behavioral coverage claim.

Independent read-only audit found exact correspondence with all 423 declaration
rows, mappings for 164 public declaration bindings and 96 generic operation IDs,
and runtime evidence for 153 concrete OO receiver/method combinations. Both export
lists (34 DM6, 33 DM5) are accounted for. This establishes entrypoint accounting,
not complete behavioral coverage: signatures, option partitions, reference
observations and English features still need completion and review.

Current next actions: continue English feature authoring and literal-observation
review against the accepted catalogues. Review arithmetic and recurrence worker
artifacts first, including fixture fidelity, literal results, English step meaning,
and incomplete coverage. The coordinator also owns calendar, parsing, and language
work; pattern parsing, arithmetic expansion, and recurrence expansion workers are active.
Do not re-enumerate finished syntax inventories. Required input/option variants
and unobserved partitions stay visible during feature authoring.

The date inventory covers 61 rendering spellings, 52 pattern directives, 167 text
production spellings, and 7 grammar gates, with a complete DM5 comparison. Delta
inventory covers 20 productions, 5 format families, 7 fields, 28 field ranges,
calculation modes, and dispatch variants. Language/config inventory accounts for
16 languages, 45 selectors, token classes, 38 keys, and file/holiday/event grammar.

Calendar evidence: 231 binding cases each repeated twice in isolated processes.
Independent stdlib review classifies 190 reviewed, 28 compatibility, 3 invalid, and
10 unreviewed incomplete-field calls. Fifty-two English candidate cases are in
`spec/drafts/calendar.feature` and `calendar-validation.feature`, linked by
`docs/research/calendar-feature-map.json` and `calendar-validation-map.json`.
Their literals match 116 original calls; 50 cases have independent fact review,
while 24:00 acceptance and fractional-second rejection retain compatibility review.
They remain draft, and no BDD runner has executed them. The initial Base fixture
warning was fixed by configuring a Date object then retrieving its Base service;
the entire corpus was rerun after that fix.

Coordinator review corrected Base tuple carriers (array references differ from
list returns) and renamed `arithmetic.time-difference` to
`arithmetic.combine-times`, since the method supports both addition and
subtraction. The generator and map use the corrected ID.

Sixteen focused recurrence cases now repeat in isolated processes; seven weekday
facts were independently checked. See
[recurrence observations](../research/observations/recurrence-ambiguities.md).
They expose backend endpoint differences, modifier case/carrier differences,
modifier-induced anchor clearing, and a suspected positional-anchor parse bug.
These remain research observations, not approved portable feature expectations.

`reference-preflight.json` is historical partial evidence. Use
`reference-profiles.json` for the reviewed setup. In particular, DM5 exposes
compatibility API version 5.66 within distribution 7.00 and does not report the
DM6/OO timezone-data identifiers. Its fixed-clock relative-date behavior differs.

The coordinator reviews evidence, installs the monitor, and integrates accepted
outputs. On interruption, inspect these paths and the queue before starting new
workers; existing artifacts may be partial and are not acceptance evidence alone.

## Ordering and parallel work

`reference-setup` precedes `api-reconciliation`. Once both are complete, the five
`feature-families` batches may proceed independently in parallel. `coverage-review`
waits for API reconciliation and every feature-family batch. The approved English
specification then receives internal review before harness setup, adapter work, and
full-suite validation proceed in order.

```text
reference-setup -> api-reconciliation -> feature families -> coverage-review
                                      |-> interpretation-formatting
                                      |-> arithmetic-deltas
                                      |-> recurrence
                                      |-> zones-business
                                      `-> configuration-objects

coverage-review -> internal-spec-review -> perl-harness-setup
                -> perl-adapter-implementation -> perl-validation
```

## Checkpoint protocol

The coordinator is the sole editor of this file and `queue.json`. Before changing a
batch status, the coordinator verifies its dependency statuses and records the
completed outputs, acceptance evidence, unresolved items, and the next eligible
batches in the change summary. Contributors do not edit queue state; they provide
evidence and proposed updates to the coordinator. The coordinator also checks
source-separation requirements at internal specification review and final validation.

Use only the statuses defined by the queue: `pending`, `in_progress`, `blocked`,
`complete`, and the baseline-only `current`. A blocked batch stays visible with its
blocker and does not permit dependent batches to start. A complete batch keeps its
outputs and acceptance evidence discoverable through its linked planning artifacts.

## Latest review checkpoint

The user reconfirmed scope: complete the specification, then implement and verify
its Perl harness. Arithmetic is undergoing targeted authoring corrections for
unspecified options, patterns, profiles and field types. Configuration is correcting
snapshot reads that themselves created unset-value errors. Rendering returned
13 repeatable invocations with 61 native spellings/families and 12 POSIX override
samples; its evidence and English drafts still await coordinator review.

Recurrence coordinator corrections now capture the actual source date before and
after derived creation, use concrete serialized recovery input, retain before/after
frequency replacement states, and align feature setup order with the probe.
Navigation assertions and functional lower bounds are explicit. All 31 cases
repeated twice in each of two byte-identical review runs. Targeted lifecycle
literal checks and all partition links pass. These are reviewed draft corrections,
not a completed recurrence family or an executed BDD suite. Continue full semantic
review and the listed gaps before promoting any family.

## Parsing corpus checkpoint

Coordinator added 291 isolated date-text binding cases: all 42 inventoried ISO
complete/truncated date spellings, 35 common numeric/separated/joined spellings,
four month-year spellings under three settings, and eight invalid/empty/mixed
inputs, each in OO/DM6/DM5. Two runs per case repeat. There are 283 authored draft
feature rows whose literal results match evidence; eight legacy unsupported
configuration exceptions occur before parsing and remain separate.
`tools/review/parsing_literals.py` verifies all provenance hashes, input/result
correspondence, diagnostics, and independent ordinal/week facts. It reports 223
valid civil results, 60 rejected parses, and zero approved specification cases.

The two parsing feature files remain draft. Joined month/year precedence and the
rejected joined two-digit-year form need semantic disposition. See
`docs/research/parsing-family/README.md` for remaining parsing/language/state work.
Next coordinator task: review completed rendering/configuration/zones batches,
then expand remaining text/time/language grammar and calendar features while the
three current workers proceed in their separate directories. No harness exists.

## User completion requirement and rendering review

The user explicitly requires every function, every usage type, and every
identifiable edge case, whether predicted from logic or source. Read
`docs/automation/definition-of-done.md`; it supersedes weaker interpretations of
sampling, private-function mapping, or earlier tooling exclusions. Queue coverage
acceptance now includes source execution/branch audit and review of exclusions.

Rendering coordinator review replaced evidence-row placeholders with explicit
literals and disambiguated text/list and empty-result wording. The new
`tools/review/rendering_literals.py` verifies 99 table literals, 24 mapped evidence
cases, provenance hashes, and independent epoch/week facts. The rendering family
remains draft with known untested boundaries. Arithmetic, recurrence, and explicit
pattern-parsing workers remain assigned to independent expansions. Next root work
is configuration/zones review and remaining parsing/language/calendar coverage.

## Configuration review checkpoint

Coordinator corrected the configuration probe's legacy fixture omission, reduced
backend loading to the requested module, isolated its environment and working
directory, and fixed the supported new-context option carrier. The derived context
now reads non-US rather than the old malformed-call result US. Reset now starts
with non-US. All 40 cases repeat; only the derived-context raw result changed.
Two outline headers and concrete lifecycle wording were fixed. The new review
script verifies 29 table cases plus derivation/reset; a lightweight draft structure
checker verifies table widths and outline columns. Neither is a BDD runner.

Current independent workers: recurrence expansion, rendering_features performing
an independent arithmetic audit, and configuration_features authoring a new
language-family corpus. Arithmetic returned107 repeated cases including DST and
business boundaries. Pattern parsing returned52 directive samples and10 edge
observations; review remains pending. Next root task is zones/business and pattern
review, then remaining grammar/calendar edges and comprehensive coverage audit.

## Zones/business fidelity checkpoint

Coordinator corrected zones/business drafts to assert exact event records/change
points, period starts, and explicit calendar profiles. Added the DM6 working-date
call previously asserted without evidence. Legacy holiday erasure returns absent,
not empty text. Saved observations now retain actual raw nested result shapes
and setup channels rather than hand-rearranged records. Probe/fixture hashes,
release checks and temporary working directories are recorded. All33 cases repeat;
selected exact event/absence assertions pass tools/review/zones_business_literals.py.
This remains an incomplete draft family.

Independent arithmetic review found backend, setup, operand-status and feature
carrier mismatches. Worker has repaired these and bulk-request mappings; final
option-wording cleanup is active. Recurrence expansion returned69 draft IDs from
36 repeated multi-action probes. Language work is now assigned to
language_completion (sol/high) after the prior worker completed selector checks
but stopped short of language-specific cases. Pattern review remains pending.

## Additional calendar feature checkpoint

Coordinator authored69 further English cases in `spec/drafts/epoch.feature` and
`calendar-positions.feature`, with exact source-side links in
`docs/research/calendar-additional-feature-map.json`. They assert positive and
negative epoch values, the 2038 boundary, inverse conversions and stored-instant
replacement, ordinal queries/inverses including fractional days, absent weekday
occurrences, week-year starts and week counts. Zero occurrence is separately
tagged compatibility. `tools/review/calendar_additional_literals.py` verifies all
69 saved literal correspondences and independent epoch/week facts; structural
checks pass. No new reference execution was needed for this already observed
corpus. All new features remain draft pending complete semantic/coverage review.

Pattern parsing now belongs to `pattern_repair` (sol/high) after coordinator found
uninitialized facade fixtures, placeholder epoch inputs, incorrectly exercised
directives, and mostly missing English cases. `language_completion` continues its
original language-specific runtime batch. Arithmetic fidelity repair returned
corrected option wording; root review/integration remains. Next root work: review
recurrence expansion and arithmetic corrections, then continue unobserved parsing
and object-usage edges and source-level coverage audit.

## Recurrence expansion integration

Coordinator reviewed the expanded recurrence batch and corrected English setup
order for frequency/anchor installation, modifier order, append and recovery.
The steps now include anchor restoration and intervening lookups exactly where
the probe performs them. `tools/review/recurrence_literals.py` checks hashes and
49 table rows plus append/recovery literals against36 repeated multi-action probes.
There are69 mapped draft IDs. Modifier recovery and attempt-limit exceptions
remain disputed; all outstanding grammar/method/modifier obligations are explicit
in `docs/research/recurrence-family/remaining-obligations.md`. No complete family
or executable BDD suite is claimed.

## Arithmetic integration checkpoint

Coordinator integrated the107-case arithmetic draft after independent review and
worker repairs. Additional root fixes preserve invalid-date errors before observer
reads, distinguish calculation errors from subsequent value-read errors, name
profiles/options, normalize date presentation, remove a duplicate outline ID, and
state rejected interval fields as an empty collection. All107 reference cases
repeat. `tools/review/arithmetic_literals.py` checks21 calculation literals,
65unique outline IDs, hashes and3invalid state/error sequences. Feature structure
checks pass. All four arithmetic feature files remain draft with substantial
explicit gaps; this is no complete arithmetic coverage or BDD pass claim.

Next root work: integrate repaired pattern/language outputs once the authoritative
worker handles finish, then add missing date-only/time-only/token-prefix usage
and remaining configuration/object/state/grammar cases. Source execution coverage
and the final complete-spec review still precede conformance harness completion.

Active new batch: partial_parsing (sol/high) owns NEW partial-parsing-family dirs
and spec/drafts/partial-parsing, for date-only/time-only and token-prefix carrier
usage. Language worker is correcting failed-init versus unexecuted-call semantics,
profile vocabulary, duplicate IDs and exact request wording. Pattern repair remains
active. Check live handles before reassigning those paths.

## Public-only scope correction

The user explicitly excluded private functions from the requested suite. Public
API functions, usage variants and observable edge cases remain in scope. Removed
the source-call instrumentation pilot and its private declaration coverage report;
these are no longer needed. Discovery inventories retain private classifications
for boundary documentation only, with no test obligation. Current workers were
notified; public lifecycle and parsing-cache characterization continue. Historical
private-coverage requirements above are superseded by this correction.

## Language integration checkpoint

Coordinator checked64 language runtime records and68 draft rows, corrected legacy
call order and fresh-object wording, and added exact provenance checks. Both
32-record corpora repeated with unchanged observation payloads. The new
`tools/review/language_literals.py` checks Unicode renderings, empty text versus
missing results, inputs, failure setup and warning counts. Broader language
vocabulary/encoding/state boundaries remain open. The45-selector corpus is
preliminary and still needs full isolation/provenance review and English scenarios.

Current independent workers: language_completion owns object-lifecycle-family;
partial_parsing owns parse-cache-family; pattern_repair is independently reviewing
the stable71-case partial-parsing batch. Public-only scope remains authoritative.
No executable BDD harness or completed feature family is claimed.

Worker return after language integration: parse-cache-family now has30 repeated
public sequence cases and draft features. Coordinator review is pending. The
partial_parsing worker moved to NEW partial-parsing-edges paths for the listed
date/time-only gates, zones, fractional boundaries and token-carrier interactions.
Do not edit its active paths. Previously returned partial-parsing and parse-cache
paths are stable for review.

## Parse-cache integration checkpoint

Coordinator corrected the30-case public parse-cache batch: actual clear-error
return capture, per-action warnings, installed-module hashes, precise operation
IDs, explicit recovery inputs and list carriers, and an actual parsed-zone read
for the both-list full-parse assertion. All30 cases repeat. Targeted reviewer
checks20 stale value literals and2exception/recovery sequences. Features remain
disputed reference compatibility, not approved default portable behavior.

Independent partial-parsing review found10empty-text-to-null coercions and
metadata/binding issues. pattern_repair now owns fixes in the original
partial-parsing-family paths; inspect its live handle before editing. The
partial_parsing worker continues NEW partial-parsing-edges, while
language_completion continues object-lifecycle-family. No private coverage work
is authorized or required.

## Current review owners after coverage clarification

Object lifecycle20-case batch returned; root corrected full-catalogue mappings,
provenance and concrete feature wording. Independent read-only review belongs to
partial_parsing (report object-lifecycle-review.md). Its52-case
partial-parsing-edges batch is stable and awaits root review. pattern_repair still
owns original partial-parsing repairs. language_completion now owns NEW
tools/coverage and docs/research/public-call-coverage for instrumentation trial
through public calls, including private implementation measurement. No numeric
coverage gate is claimed accepted and no private test entrypoint is authorized.

## Accepted numeric coverage targets

The user explicitly accepted the proposed specification: public API test calls,
at least99% statement and95% branch coverage including private implementation,
and review of every uncovered statement/branch with documented exclusions.
Earlier notes saying the numbers were unconfirmed are superseded. No current
coverage result is claimed. The instrumentation worker has been notified.

## Partial-parsing integration checkpoint

Integrated71 original partial-parsing requests after independent repair. Ten OO
failure getters now preserve empty text, error-clear sequence is explicit, versions
come from public calls, installed-module hashes are recorded, and unsupported
Perl references are in a separate binding-only feature. Root checker verifies
71IDs,51 date/time outline literals,10failure carriers and11hashes. Drafts remain
unapproved; larger grammar and usage coverage still requires completion.

pattern_repair now reviews the stable52-case partial-parsing-edges batch.
partial_parsing independently reviews the20-case object-lifecycle batch.
language_completion terminated with a model-capacity error during coverage setup;
replacement coverage_setup (terra/high) owns tools/coverage and
docs/research/public-call-coverage, inspecting existing partial work before
continuing. This is an authoritative terminal failure, not a timeout restart.

## Language-selector integration checkpoint

Coordinator replaced preliminary45-selector numeric-only probes with isolated
localized parse/render requests for every inventoried canonical name and alias.
Each repeats twice; outputs agree with the previously reviewed canonical language
literals. Original English selectors.feature and selector-feature-map.json cover
all45. Tool/input/module hashes, actual config return/errors, parse and observer
errors, warnings and stdout are preserved. language_literals.py now checks these
45 rows as well as the earlier64records/68rows. Candidate transition sequences in
the inventory remain unobserved; broader language domains still block completion.

Independent lifecycle review found mapping omissions, ambiguous raw-versus-readable
wording, a no-op isolation check, and compatibility classification gaps.
partial_parsing now owns the lifecycle repair, retaining readable portable dates
with explicit representation semantics. pattern_repair reviews52parsingedges;
coverage_setup continues instrumentation. Respect these owned paths.

## Configuration-file loading checkpoint

Root added36 repeated original file-loading cases throughOOconfig andDM6Date_Init:
18fixtures cover whitespace/comments/case, ordering/includes, missing/empty paths,
malformed lines, quoted/hash values and unknown variables/sections. Public probes
were informed by private reader inspection without calling helpers. Exact JSON
file bodies, ordered settings and literaldate outcomes match draft features via
config_file_literals.py. Partial state after malformed input and laxvalues are
disputed. Legacy files, special sections, permissions and additional domains remain.

Coverage tooling returned stable clean-environment instrumentation with a compact
pilotresult; root review/global dependency notice/integration remains next.
coverage_setup now owns NEW coverage-denominator-audit and tools/coverage-denominator
for legitimate public loading routes for788 unloaded modules. pattern_repair owns
52-case edge repairs; partial_parsing owns lifecycle repairs.

## Public-call coverage instrumentation checkpoint

Integrated the separately installed Devel::Cover1.52 pilot and dependency notice.
Root fresh run reproduced byte-identical public OO/DM6/DM5 outputs and stderr.
Seven summarizer regression tests pass: invalid denominators, absent library rows,
failed calls and output differences are rejected. Raw percentages remain separate
from tool-adjusted percentages; upstream annotations are not approved exclusions.
Only16 of804 modules were loaded. These pilot totals do not measure the full suite.

Returned denominator-audit,20-case lifecycle repair and52-case parsing-edge repair
await coordinator integration. Lifecycle reviewer and feature structure checks pass;
semantic integration is still next. partial_parsing now owns NEW date-set-family
paths. Other workers have returned; check live handles before reassigning them.
The accepted99% statement/95% branch gate and review of every uncovered path remain
unchanged. There is still no executable BDD harness, and the goal remains active.

## Lifecycle integration checkpoint

Integrated20 public lifecycle cases after reviewing all feature statements and the
independent repair report. Targeted evidence checker verifies20 mappings, hashes,
selected exact mutation/error carriers and actual bidirectional isolation; both
feature files have valid lightweight structure. Date presentation explicitly
normalizes civil fields without claiming native scalar bytes. Unsupported methods
remain binding-only, and impossible-date component mutation remains disputed.

partial_parsing owns NEW date-set-family work; coverage_setup owns NEW
fixed-offset-family work targeting408 generated offset routes; pattern_repair
owns NEW zone-transition-boundaries work. Returned52 parsing-edge cases and
denominator audit still await integration. No family completeness or BDD pass
is claimed.

## Generated-module denominator checkpoint

Integrated representative public loading routes after correcting actual receiver
error checks and adding result assertions. Fresh run verified9 generated rows
and plain/instrumented fidelity. TZdata.pod explicitly disclaims public use;
coordinator accepts existing generation-tool scope exclusion, retaining804raw
files and803runtime files in accounting. Finite offset/zone/language route plan
is documented. The whole-runtime coverage denominator is still incomplete.

## Partial-parsing edge integration checkpoint

Integrated52 repaired edge cases after fresh coordinator repeatability comparison.
Corrected implicit holiday definition, default/overlap local-zone setup, initial
overlap clock and native-versus-normalized presentation. New reviewer checks48
outline rows,52 mappings,11 hashes,14 failure sequences,24 scalar/list success
pairs and3 binding-only warning assertions. No BDD-run or coverage claim.

All three worker handles were confirmed running this turn: partial_parsing owns
date-set-family; coverage_setup owns fixed-offset-family; pattern_repair owns
zone-transition-boundaries. Their outputs are not yet integrated. Continue these
partitions and source-coverage gap discovery; complete specification and then
harness remain required.

## Input-history gap checkpoint

A search found no concrete Date::input draft scenarios. Root added16 public
source-text lifecycle cases with original English features and frozen native
observations, each repeated twice. Prototype configuration warnings exposed a
wrong calling shape and were corrected before evidence acceptance. All accepted
runs are warning-free, pinned, isolated, and hash-recorded. Reviewer compares
exact arguments, action returns, scalar/list input values, errors and normalized
final date values. Pattern non-match with empty error is disputed. Remaining
input-history transitions are listed explicitly; no completeness claim.

Live workers were confirmed running: date-set-family, fixed-offset-family, and
zone-transition-boundaries. Continue their independent batches and review before
integration. The full specification, source coverage and Perl harness still need
completion. Previous turn and this turn both made concrete repository progress.

## Verified BDD runner trial

Installed separately licensed Test::BDD::Cucumber0.87 and49 dependencies into
ignored local/bdd-runner. Upstream install initially failed its colour assertion
under inherited NO_COLOR=1; clean colour settings passed532tests,22files, with
only the author POD test skipped. Original trial passes5positive scenarios and
3tag-selected outline rows; wrong literal exits2 and strict undefined step exits1.
Unicode, escaped pipes, data-table order, state isolation and docstring trailing
newline are checked. Exact versions/declaredlicenses and trial evidence recorded
in docs/research/runner-trial. This is not the Date::Manip adapter or suite.

Worker state: date-set still active; fixed-offset408module batch returned and
awaits root review. coverage_setup now repairs input-history provenance/bindings
from independent report. pattern_repair repairs zone-transition row IDs/context
after returning8cases. No workers edit root runner-trial paths.

## Real-parser draft audit

The pinned runner public parser now audits feature syntax. It found19 unsupported
typed-docstring markers in configuration-file drafts. Root changed markers only
to plain triple quotes and updated the36case literal checker; decoded file bytes
and expectations still match. All37tracked features parse:251 declarations,1047
expanded scenarios. Temporary malformed syntax correctly exits1. Snapshot hashes
are in runner-trial/draft-parse-result.json; active worker edits may supersede
their file snapshots. These counts are syntax evidence, not executed BDD cases.

Date-set108case batch returned and awaits independent/root review. partial_parsing
now independently reviews67zone-transition examples; pattern_repair independently
reviews408offset loading evidence; coverage_setup repairs input-history findings.
Keep returned batch paths separate from active repair ownership.

## Completeness-query batch

Root added11 receiver setups with132 public completeness queries. Explicit
English ordered requests preserve omitted/empty/zero/absent/unsupported selectors,
exact booleans, errors and36bindingwarnings. Runs repeat in isolated processes;
reviewer checks every outcome and provenance. Bothfeatures parse under the pinned
runner. Partial mutation/default/configuration interactions remain open.

Date-set repair owned by partial_parsing after finding implicit fixture inputs and
Perl warnings in portable scenarios. Independent zone review returned concrete
binding/error-boundary/provenance issues; root must assign repair before integration.
pattern_repair owns fixed-offset four-finding repair. coverage_setup returned
17case input-history repair; root review/integration next. No completeness claimed.

## Input-history repair integration

Integrated17case input-history evidence with concrete bindings, required runtime,
profile, loaded-module/UTCzone and process provenance. Root replaced invented
constructor/list operation IDs with canonical IDs plus variants and completed
metadata/config/zone bindings. Constructor-only settings no longer pretend to
have a separate config return. Fresh runs preserve17 behavioral payloads; the
reviewer and real parser pass. Remains draft and incomplete for wider transitions.

Current workers retain repairs: coverage_setup zone-transition, partial_parsing
date-set, pattern_repair fixed-offset. None of those batches is integrated yet.

## Date mutation integration

Integrated108 public Date::set cases after concrete-input repairs. Every feature
request matches exact fixture receiver/type/arguments; coordinator strengthened
per-row result/status/error/list/warning comparisons. Two warning-only scenarios
have separate IDs and mappings. Real parser accepts24scenarios across3files.
Disputed field validation and binding exceptions remain explicit. Coverage and
remaining method partitions are not declared complete.

partial_parsing now owns NEW navigation-family public previous/next cases.
coverage_setup still repairs zone-transition; pattern_repair repairs fixed-offset.
Keep those active paths unstaged until their returned evidence is reviewed.

## Fixed-offset integration

Integrated408module public reachability evidence after independent repair.
Root verified external hashes and7durable examples; each outline row now matches
its own native channels, and parsed-zone wording no longer implies localUTC.
Collector proves target newly loaded and unique9/9 criteria,408modules total.
40parse successes/368rejections remain explicit; only7examples are portable drafts.
No final whole-library coverage or behavior-completeness claim.

Zone-transition repair returned stable for root review. coverage_setup now owns
NEW coverage-corpus diagnostic collector and public-case branch-gap analysis.
partial_parsing owns navigation-family; pattern_repair owns value-serialization.

## Zone-transition integration

Integrated67 examples over8 observed zone-boundary cases after independent repair.
Coordinator reviewer now compares all24instant values,37wallqueries and8 ordered
period lists to exact feature literals and verifies canonical IDs/module hashes.
Real parser expands67scenarios. Call boundaries and independent zoneinfo provenance
are retained. Reference outcomes unchanged; only review-script hash refreshed.

Active assignments remain navigation-family, value-serialization-family and
coverage-corpus diagnostics. Full public feature set and final99/95coverage gate
remain incomplete; runner trial is verified but Date::Manip BDD adapter unbuilt.


## Date comparison integration

Added 49 original comparison examples across object, current functional, legacy
functional and public calendar-service bindings. Each frozen literal matches its
own request/evidence row. A separate root rerun (two isolated attempts per case)
matched the committed payload and provenance exactly; the real parser expanded
49 examples without warnings. Invalid legacy operands and equal wall times across
zones remain disputed compatibility behavior. Remaining method partitions are
listed in the family README; no family-completion claim or executable BDD claim.

coverage_setup returned the 30-case source diagnostic for root review and now owns
NEW replace-time-family research. Navigation and value-serialization workers remain
active. Source diagnostic paths are not yet integrated. Next: review returned worker
batches, complete missing public partitions and implement the actual BDD adapter
once the reviewed contract is ready. Final coverage/completeness gates remain open.


## Public-probe coverage diagnostic integration

Root reran all 30 selected cases using isolated plain/instrumented processes and
separate coverage databases. All native stdout pairs matched and stderr was empty.
Merged results reproduced 2231/5802 raw statements and 333/3080 raw branches across
14 loaded files, with 790 unloaded files explicitly retained. This is a diagnostic
subset, not whole-library or BDD-suite coverage. Two statement/one branch upstream
annotations remain unapproved exclusions. The committed result records the root
summary hash. Broader corpus and exact uncovered-path disposition remain required.

Serialization returned 73 cases for review. Its reviewer currently verifies output
presence but needs exact input/options correspondence; compatibility context and
binding examples need review before integration. Root must not treat its internal
check as semantic approval. pattern_repair now owns NEW day-ordinal-family research.


## Value serialization integration

Integrated 73 split/join requests after coordinator repairs. Fresh two-attempt
capture retains all 146 scalar/list call outcomes; provenance now hashes all nine
loaded modules and PATH is fixed. Each of 73 portable/compatibility/binding request
rows is checked against its own exact typed input, kind, options, configuration
and result. Replaced generic carrier prose with 73 concrete binding examples and
stable mapped IDs. Canonical setup/operation IDs checked; field order is explicit.
Real parser expands 146 examples across four files. Suspected documentation bugs
remain disputed, remaining partitions explicit, no family-completion claim.

Navigation returned 87 cases for coordinator review. partial_parsing next owns NEW
behavior-gap-ledger audit to reconcile coarse contract obligations against evidence
and outstanding partitions without treating an operation reference as fulfillment.
coverage_setup owns replace-time and pattern_repair owns day-ordinal. These active
paths remain unstaged until reviewed. Date::Manip executable BDD adapter still open.


## Navigation integration

Integrated 87 public navigation cases after root and independent review. Root
added complete loaded-module provenance, fixed PATH, a per-row request/outcome
checker, exception-completion fidelity (no invented undef return on thrown calls),
concrete deprecation assertion and explicit binding exclusions. A fresh capture
preserved behavior; independent worker reran and byte-matched all repaired records.
The root real-parser command uses the separate local/bdd-runner/lib/perl5 prefix
and accepts six scenarios per file. Python independently confirms 45 returned
weekday predicates. Remaining public partitions remain listed; no completion claim.

coverage_setup now repairs replace-time after root found absent-return-on-exception,
missing actual feature checks, conflicting BAD-DATE Given, and vague binding
exceptions. Do not stage its three paths until repaired. pattern_repair returned
925 day-ordinal requests for root review and now owns NEW portable-draft-audit.
partial_parsing owns behavior-gap-ledger. Both audits are read-only for existing
families. Root next reviews day-ordinal and returned repairs; final executable
adapter, whole-library coverage and all remaining obligations are still open.
