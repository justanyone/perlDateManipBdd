# Delta and arithmetic syntax inventory

This inventory turns the Date::Manip 7.00 Delta and calculation documentation into finite probe obligations. It records terms and dispatch rules from the reference source; it does not record observed behavior or portable expected values.

The parser has seven ordered fields: year, month, week, day, hour, minute, and second. Its compact form has one through seven colon-delimited positions, with empty interior positions as an explicit case. Its expanded form has the same seven unit categories in order. It also has named-component, mixed, relative-marker, business-marker, and legacy accuracy-marker productions. Numeric bounds, fractional acceptance, and language tokens remain unobserved.

The formatter contains five families: literal percent, a single field, a converted inclusive field range, a complete delta, and an inclusive delta slice. The seven field codes and all 28 ordered inclusive ranges are explicitly listed in [delta.json](delta.json). The matrices also name sign, padding, width, and precision domains, including the narrower padding set for delta-slice formats.

Calculation obligations distinguish date/date, date/delta, delta/date, and delta/delta calls. Date/date has six named modes. Approximate calls give the subtraction selector three meanings, so selectors zero, one, and two are separate boundary cases. Business schedules, holidays, zones, DST transitions, mixed delta modes, and inverse approximate calculations remain unobserved partitions.

DM6 and DM5 have separate functional dispatch matrices. DM6 `ParseDateDelta` accepts an optional accuracy conversion selector; DM5 accepts exactly one argument. Their `Delta_Format` dispatch differs: DM6 recognizes exact, semi, and approx as a leading mode, while DM5 source recognizes only a leading approx marker. `DateCalc` also has profile-specific argument dispatch and mode vocabularies. The JSON gives each distinction as a source-derived, unobserved probe obligation.

The source locations are Delta.pod, Calc.pod, DM6.pod/DM6.pm, and DM5.pod/DM5.pm from the separately installed Date::Manip 7.00 reference. No upstream examples, implementation, or data have been reproduced here.
