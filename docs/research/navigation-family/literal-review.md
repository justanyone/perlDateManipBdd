# Manual literal review

The feature literals were compared by hand with
`docs/research/navigation-family/observations.json` after the final two-run probe.
This review does not approve the candidates for integration; coordinator review is
still required.

## Counts and identity

- The fixture contains 87 unique identifiers.
- The two feature files contain all 87 identifiers exactly once and contain no
  extra `NAV-...` identifier.
- The coverage map has one record for every fixture identifier: 37 OO, 25 DM6,
  and 25 DM5; 54 next and 33 previous.
- All 87 observation rows have exit status zero, valid JSON, and identical output
  across both isolated attempts.

## Literal comparisons

I compared every object table row's initial receiver, direction, ordered typed
arguments, wall result, and GMT result against its request and `raw_return`.
Compact native text such as `2040113018:15:00` is represented in features as the
same six fields, `2040-11-30 18:15:00`. The overlap conversion was checked
separately: wall `2024110301:30:00` corresponds to GMT `2024110306:30:00`.

I compared every functional row's profile, input text, direction, ordered typed
arguments, defined/absent carrier, and result. DM5 rows deliberately omit an
`Etc/UTC` suffix because those exact compatibility inputs are in the fixture.
The DM6 and DM5 success rows were compared separately rather than inferred from
one another.

The invalid object errors match exact case and punctuation:

- `[next] Invalid DOW: 8`
- `[prev] Invalid DOW: Friday`
- `[next] Either DoW or time (or both) required`
- `[prev] invalid time argument`
- `[next] invalid time argument`

For all five, observers are empty while the error remains and the original carrier
reappears after `err(1)`. The unset and parse-error cases remain empty after error
clearing. Both DST-gap calls return numeric `0`, immediately carry
`[set] Invalid date/timezone`, and remain empty after clearing the later value
error.

The two functional absent-return exceptions were reviewed against their full raw
records. Features intentionally assert stable literal prefixes; the research file
retains source path, line, and stack. Warning counts and categories were also
checked: ordinary DM6 rows have none, ordinary DM5 rows have the single module-load
deprecation warning, and omitted-inclusion rows add their observed uninitialized
value warnings.

The installed feature parser accepts both files with six scenarios each and no
warnings. The parser checks syntax only; it is not an executable BDD result.
