# Language and configuration-file syntax inventory

This research-side record covers Date::Manip 7.00 language selection and
configuration-file syntax. It does not carry language vocabulary, upstream
examples, generated data, reference source, or expected outcomes into a
portable implementation package. The machine-readable inventory is
[`language-config.json`](language-config.json).

## Language selection

The release identifies 16 languages and accepts 45 case-insensitive selection
strings when canonical names and aliases are counted. The inventory gives each
language a stable `lang.*` identifier, its functional selection aliases, and a
candidate fixture plan. Every candidate is unobserved: it first needs an
original, independently sourced language-specific token and an isolated probe.
No translated month, weekday, ordinal, or relative-date word is copied here.

Language modules organize parse terms into finite classes: meridiem, connectors,
weekday and month forms, recurrence/duration terms, ordinal forms, relative
date/time terms, named times, and direction/relationship phrases. Three pinned
language modules declare trailing-period preprocessing. The Russian module
declares parenthesis removal and selected-word stripping; its vocabulary is not
recorded here.

## Configuration-file grammar

For the DM6 reference profile, a file is a sequence of blank/comment lines,
assignments, and asterisk-led section markers. Outer whitespace is removed
before classification. An assignment is parsed around `=`; main keys and
section names are case-insensitive, while section entries retain case and main
values follow their individual setting rules. A section stays active until the
next marker. A `ConfigFile` setting loads immediately, so nested loads and
settings have a meaningful order.

The parser distinguishes failure channels that later probes must preserve:
missing or unreadable files warn and continue; an unrecognised main key reports
an error and continues; an unknown section warns and accumulates its content;
and a non-assignment line in a section/file stream is fatal. Inline comments,
empty/embedded-equals behavior, and exact text/return effects remain explicit
probe partitions rather than assumed grammar.

DM5 documents a similar settings-then-sections format but a different loading
model: optional global configuration, optional personal configuration, then
`Date_Init` overrides. Its documentation calls all strings case-insensitive.
The 7.00 DM5 compatibility behavior has not been freshly observed, so this is a
documented difference rather than a normalized portable rule.

## Holidays and events

`*Holidays` lines pair a date expression with an optional label. The DM6
documented shapes are a full date, a yearless date that admits an appended year,
or a recurrence. Definitions preserve order, blank labels still create a
holiday, and several holiday labels may apply to a date. This ordering matters
when a later working-day-relative rule reads already-defined holidays.

`*Events` lines pair an event expression with a name. DM6 documents Date, YMD,
YM, Recur, and five two-part semicolon forms. Time-bearing Date/Recur forms
default to one hour; date-only forms occupy a day. Events do not affect business
calculations. Long durations beyond a year are described as unsupported without
validation, so they remain a known gap.

DM5 additionally documents holiday date-plus/minus-delta forms, an older
identical-recurrence limitation, and three-part event forms. These are retained
as profile-specific research obligations, never silently folded into DM6.

## Reconciliation and remaining work

`Config.pod` has 27 documented configuration-variable headings. The shared
configuration-domain inventory has 38 keys: those 27 plus 11 keys documented
only by the DM5 compatibility profile. This reconciles the heading count exactly
but does not establish runtime coverage. All listed language, parser, section,
diagnostic, order, whitespace, and invalid-input partitions remain unobserved.
