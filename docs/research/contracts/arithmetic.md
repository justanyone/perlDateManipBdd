# Arithmetic and delta contract catalogue

This research-side catalogue reconciles the six `arithmetic.*` and ten
`delta.*` operation IDs in the API map to Date::Manip 7.00 public surfaces.
It records call boundaries and finite input grammars, not portable features or
approved expected values. Every partition in [arithmetic.json](arithmetic.json)
is deliberately `unobserved`.

The source basis is the pinned distribution's public POD and wrapper/method
routing in `Calc`, `Delta`, `DM6`, `DM5`, `Date`, `Obj`, and `Base`. The source
was used to identify interfaces and channels; no upstream examples or text were
copied into this catalogue.

| Family | IDs | Reconciled public routes |
| --- | ---: | --- |
| Arithmetic | 6 | DM5/DM6 `DateCalc`; Date and Delta `calc`; Base field-list calculation helpers |
| Delta lifecycle | 5 | object creation, text parsing, field replacement, value/input reads |
| Delta presentation and classification | 5 | OO pattern renderer, functional compatibility renderer, type read, conversion, comparison |

Arithmetic has three typed OO pairings: date/date produces a delta, date/delta
produces a date, and delta/delta produces a delta. Legacy `DateCalc` first
interprets text and therefore adds operand classification, profile-specific
argument dispatch, empty-return and diagnostic channels. The catalogue keeps
those routes separate rather than treating an OO result as proof of legacy
behavior.

Base tuple arguments and tuple results are array references in the Perl binding.
The generic `arithmetic.combine-times` operation covers both addition and
subtraction; its earlier `time-difference` inventory label was too narrow. The
POD's flattened argument notation for this helper differs from its public source
signature, so carrier errors need their own observations.

Delta fields always have the research order year, month, week, day, hour,
minute, second (`y`, `M`, `w`, `d`, `h`, `m`, `s`). Modes are standard and
business; types are exact, semi, approximate, and estimated. These are source
vocabulary terms, not evidence that any particular field value or conversion
result is portable.

`delta.parse-text` contains a bounded grammar record for compact and expanded
text. `delta.render-pattern` likewise enumerates the literal-percent,
single-field, range-as-field, complete-delta, and partial-delta directive
families, including finite field codes and modifier positions. It does not
freeze a rendered example. `delta.render-fields` separately retains the DM5 and
DM6 functional compatibility adapter because it also translates older pattern
forms.

The next prerequisite is an original fresh-process probe batch. It needs fixed
standard and business fixtures, UTC plus a DST-transition zone, both DM6 and
DM5 where bindings exist, and explicit capture of raw return, normalized value,
object error, warnings/stderr, wrapper stdout, input-token consumption, and
before/after object state. Only reviewed literal observations can promote these
catalogue entries into feature work.
