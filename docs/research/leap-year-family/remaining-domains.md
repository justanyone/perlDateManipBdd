# Remaining leap-year domains

This register separates the exercised finite partitions from broader claims.

## `calendar.is-leap-year.p1`

Evidence covers every residue in one complete 400-year Gregorian cycle for all
three bindings, plus years `0001`, `0004`, `9996`, and `9999`. Because Gregorian
leap classification repeats every 400 years, there is no unrepresented valid
arithmetic residue. The probe did not invoke every integer from 0001 through
9999 individually; portable approval and adapter execution remain pending.

## `calendar.is-leap-year.p2`

The complete cycle includes 2000, 2100, 2200, and 2300. Separate calls cover
1600, 1900, and 2400. Both the divisible-by-400 and the divisible-by-100 but not
400 branches are represented at lower, current, and following boundaries.
No known Gregorian century branch remains unrepresented. Portable approval
remains pending.

## `calendar.is-leap-year.p3`

Evidence covers omitted and explicitly undefined arguments; empty, one-space,
three-character and four-character nonnumeric text; numeric fraction `2000.5`;
zero; `-4`, `-100`, and `-400`; `10000`; short years `00` and `40`; and short
year setting values `C`, `C19`, `C20`, `C2000`, `0`, and `99` under all three
bindings.

Finite identifiable input-shape obligations still not exercised are:

- signed positive text, leading or trailing whitespace around numeric text,
  scientific notation, and platform representations of infinity or not-a-number;
- additional fractional values around ordinary and century boundaries;
- large positive and negative integers beyond the selected outside values;
- Perl reference carriers such as array, mapping, scalar, and blessed references,
  which would be binding-only compatibility requests;
- rejected short-year configuration syntax, which belongs primarily to the
  configuration operation and is not expanded in this behavior batch.

The short-year suffix `00` is the leap-classification discriminator among the
selected century windows; `40` supplies an ordinary divisible-by-four control.
Other two-digit suffixes remain an input matrix rather than a distinct known
leap-year branch. The public boolean result cannot reveal which four-digit year
was internally chosen when two interpretations have the same leap status.

Timezone, language, and daylight-saving variants are fixed rather than crossed:
the public calculation accepts only a year and has no zone, language, or instant
result. Native scalar/list context is fully represented for every recorded
request, but other language adapters are not implemented in this repository.
