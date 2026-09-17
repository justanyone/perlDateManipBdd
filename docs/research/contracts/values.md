# Value, parsing, navigation, and lifecycle contract catalogue

This research catalogue covers the Date::Manip 7.00 public interfaces mapped to
the `date.`, `time.`, `value.`, `object.`, `context.`, `config.`, `error.`, and
`meta.` operation families. It is a source/POD signature review, not a reference
observation set. Every behavioral partition in [values.json](values.json) remains
`unobserved`; it supplies a bounded probe and feature-authoring worklist.

The operation model is intentionally language-neutral. A facade that returns an
empty serialization, an OO method that returns a status, a mutable supplied token
collection, and a receiver-held error are recorded as separate binding conventions.
Their mapping to a portable outcome has not yet been observed or approved.

| Area | Operation IDs | Main distinctions to preserve |
| --- | --- | --- |
| Parsing | `date.parse-text`, `date.parse-leading-tokens`, `date.parse-date-only`, `time.parse-text`, `date.parse-pattern` | text carrier, grammar gate, omitted field defaults, receiver mutation, prefix consumption, parser failure |
| Rendering and values | `date.render-pattern`, `date.read-input`, `date.read-value`, `date.complete-missing-fields`, `value.join-fields`, `value.split-fields` | representation, scalar/list result form, supplied versus defaulted fields, adapter-only serialization bridges |
| Change and navigation | `date.replace-field`, `date.replace-time`, `date.compare`, `date.find-previous`, `date.find-next`, `date.localized-day-ordinal` | field/type validation, zones and DST, predicate shape, inclusion mode, locale |
| Objects and contexts | `object.create`, `date.create`, `context.create`, `context.base-service`, `context.zone-service`, `object.kind-check` | fresh, shared, and derived context; initialization parse; value-kind matrix |
| Configuration and status | `config.apply-settings`, `config.read-settings`, `error.read-state` | ordered settings, reset/file processing, shared-context effect, query arity, clear/error lifecycle |
| Metadata | `meta.reference-version`, `meta.zone-data-version`, `meta.zone-rule-version` | profile/receiver variant and environment-dependent detail |

## Interface facts that shape later probes

The OO date parser accepts named grammar-disabling option tokens. Date-only parsing
preserves an existing receiver time but starts an unset receiver at midnight;
time-only parsing preserves an existing date and otherwise uses the configured
current date. Pattern parsing distinguishes invalid pattern from non-match and can
return named caller captures. These are documented interface facts, while their
complete status, error, mutation, and normalization behavior remains unobserved.

Previous/next navigation has both weekday and partial-clock predicate forms. In the
OO binding, weekday is `1` through `7`; `curr` has documented modes `0`, `1`, and
`2` for strict, current-inclusive, and exact-instant-excluding navigation. The
clock-only form requires a three-slot array and allows leading absent fields. DM6
also accepts a single time string; DM5 has separate time fields. Their facade
defaults, arbitrary truthy mode values, DST behavior, and invalid-input outcomes
remain unobserved.

The finite OO date-value selectors are omitted/empty (parsed zone), `local`, and
`gmt`; scalar context returns serialized text and list context returns six fields.
Field replacement has OO selectors `zone`, `zdate`, `date`, `time`, `y`, `m`, `d`,
`h`, `mn`, and `s`, with the overloads enumerated in the JSON catalogue. Base
split/join kinds are `date`, `hms`, `offset`, `time`, and `delta`; `business` is a
deprecated alias for business-mode delta handling. Pattern parsing returns only
caller-defined named captures in list context, not positional captures.

Object construction can reuse an existing context or derive a new Base context when
overrides are supplied. A derived configuration starts from the source settings;
later observable setting isolation must be probed. Raw identity and cache layout are
not portable requirements.

Configuration updates are order-sensitive: reset and configuration-file settings
take effect where encountered. Parser-relevant setting families include language,
encoding, numeric date ordering, two-digit year interpretation, omitted-time
selection, period time separators, month/year handling, fixed or advancing reference
time, and POSIX rendering mode. Business, recurrence, and zone-specific settings
remain owned by their corresponding catalogues, with lifecycle interaction cases to
be designed later.

## Deliberately linked work

`docs/research/api/` owns source-level parser productions, formatting directives,
and their individual syntax/option inventory. This catalogue references those
results instead of reproducing source-derived directive details. It also excludes
arithmetic, calendar, epoch, business, events, zones, deltas, and recurrence
operation families assigned to other catalogues.

The reviewed reference profile identifies DM6 and OO backend version 7.00, and the
DM5 compatibility backend as version 5.66 within the same Date-Manip 7.00
distribution. Before any feature or harness work, the remaining bounded tasks are
to probe each listed partition in fresh DM6 and DM5 processes where applicable,
record all return and diagnostic channels, and review literal results into a
portable outcome protocol.
