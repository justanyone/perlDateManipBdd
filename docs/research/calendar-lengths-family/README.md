# Calendar month and year lengths: Date-Manip 7.00 observations

This bounded family records 171 original public requests for the canonical
operations `calendar.days-in-month` and `calendar.days-in-year`. It covers all
twelve months in common year 2039 and leap year 2040 through the Base, current
functional, and legacy functional routes. Year requests include 1900, 2000,
2039, 2040, and 2100, so both ordinary and century leap rules are exercised.

The public source bindings are exact and have no inventory aliases:

- `Date::Manip::Base->days_in_month(year, month)` and `days_in_year(year)`
- `Date::Manip::DM6::Date_DaysInMonth(month, year)` and `Date_DaysInYear(year)`
- `Date::Manip::DM5::Date_DaysInMonth(month, year)` and `Date_DaysInYear(year)`

The valid portable layer freezes numeric month/year lengths, the documented
Base ordered twelve-month form, and configured legacy short-year results. The
compatibility feature retains every other tested public outcome without making
invalid inputs valid. Perl scalar/list context, warnings, exceptions, and the
Base `err` clear/read sequence live only in the excluded binding feature. The
functional facades expose no documented error observer, so the probe records
that no observer was called rather than fabricating an absent observer value.
Notably, short year `00` is direct arithmetic in Base and DM6, while DM5 applies
`YYtoYYYY`: `C19` selects 1900 and `C20` selects 2000. Five selected malformed
legacy years raise exceptions and therefore have no return field; completed
undefined returns would remain explicit if observed.

`cases.json` is the exact input manifest. `observations.json` contains two
byte-identical attempts per case, each in a fresh process and temporary working
directory with `PATH=/usr/bin:/bin`, fixed locale/zone/hash settings, pinned
fixture metadata, runtime versions, loaded module paths, and SHA-256 hashes for
the manifest, probe, runner, fixture, and installed Date-Manip modules.
`feature-map.json` maps every request to one generic feature row and one binding
row. `bindings.json` keeps Perl call names out of the portable behavior files.

To reproduce without overwriting the frozen evidence:

```sh
python3 tools/probes/calendar-lengths-family/run.py > /tmp/calendar-lengths-observations.json
python3 tools/probes/calendar-lengths-family/review.py
```

The review script verifies every input/result/diagnostic row, native return
presence, setup state, public error-observer sequence, provenance hash, and
selected Gregorian facts independently. It also parses every feature with the
repository's installed `Test::BDD::Cucumber::Parser`. These are research checks,
not passing executable BDD scenarios.

Remaining bounded domains are other proleptic years, additional numeric and
`C`/`C####` short-year windows, Perl references/overloads/NaN/infinities, and
other Date-Manip or runtime versions. Leap-year classification as its own public
operation belongs to `calendar.is-leap-year`, outside this family.
