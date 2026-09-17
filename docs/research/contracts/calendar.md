# Calendar and epoch contract catalogue

This research-side catalogue reconciles the 16 `calendar.*` and `epoch.*`
operation IDs in `docs/research/api/contract-map.json` to Date::Manip 7.00.
It is an API-boundary record, not a feature specification or an observation set.
No expected literal has been frozen.

The source basis is the public POD and public method/wrapper routing in the
pinned 7.00 distribution: `Base`, `Date`, `DM6`, and `DM5`. The complete
machine-readable contract, including generic input names, call forms, return
shapes, partitions, bindings, and open questions is in `calendar.json`.

| Family | Operations | Principal distinction requiring probes |
| --- | ---: | --- |
| Civil calendar | 13 | Base OO methods accept ordered field lists and add inverses or context rules; DM5/DM6 functions use positional fields. |
| Epoch | 3 | Local-civil seconds, functional current-zone-to-GMT seconds, and object instant seconds have different timezone and mutation semantics. |

## Reconciled call surfaces

The calendar operations cover day-of-year conversion and inverse conversion,
projected-calendar ordinals and inverse conversion, month/year length, leap-year
classification, weekday lookup, ordinal weekday lookup, date/time field checks,
and configurable week calculations. The epoch operations cover Base civil-second
conversion and inverse conversion, functional GMT-referenced conversion, and the
Date-object GMT instant getter/setter.

Base tuple inputs and tuple-valued results use array references in the Perl
binding. This differs from a flattened return list; preserve that distinction in
the adapter while exposing ordinary named fields in the portable contract. For
functional `Date_NthDayOfYear`, the documented result is six ordered fields.
For `Base::week_of_year`, forward lookup has an ordered week-year/week pair and
inverse lookup returns the week's first civil date. The legacy Date/DM5/DM6
week-number calls return a single number in a separate compatibility contract.

## Context and compatibility boundaries

Week operations depend on `FirstDay` and `Week1ofYear`. The Base 7.00 defaults
are Monday (`1`) and the week containing January 4 (`jan4`). Valid documented
week-one rules are `jan1` through `jan7`, `dow1` through `dow7`, and `firstday`.
`Date::Manip::Date::week_of_year` and functional `Date_WeekOfYear` additionally
take a historical first-weekday override. These forms must be observed separately
at a year boundary.

The functional helpers retain compatibility short-year handling through
`YYtoYYYY`; Base APIs do not document the same conversion. DM5's day ordinal
documentation includes year 0000, whereas DM6/Base describe the reference in
terms of year 0001. The catalogue keeps both differences open.

`Date_SecsSince1970GMT` needs a timezone fixture and DST partitions. DM5 documents
an IGNORE conversion mode; DM6 describes a current-zone civil input measured from
GMT. `Date::secs_since_1970_GMT` is a distinct mutating object setter when given
an argument; it needs state and warning-channel observations.

## Research status and next evidence

All 16 operation IDs have a public binding and a normal, boundary, invalid, and
where relevant configuration/state partition. None is reviewed: no probe has yet
established literal outcomes, error conventions, warnings, scalar/list-context
behavior, or DST overlap/gap resolution. The next bounded work is a fresh-process
probe batch under pinned DM6 and DM5 profiles, with fixed zone and clock fixtures,
covering the partitions listed in `calendar.json`.
