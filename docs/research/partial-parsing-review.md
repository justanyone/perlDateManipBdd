# Independent review: partial parsing batch

Reviewed and repaired 2026-09-17 against the public-only `AGENTS.md` scope.
The review covered the 71 original requests, regenerated observations, probe and
runner, public Date-Manip 7.00 POD/source signatures, source bindings, and three
draft feature files.

## Resolved findings

### Native OO failure returns

The previous probe converted the scalar empty-text result of
`Date::Manip::Date->value("local")` to an absent value after ten failed
`parse_date` or `parse_time` calls. The repaired probe preserves empty text
and undef separately. Candidate evidence was written to
`/tmp/partial-parsing-observations.candidate.json` and compared with the frozen
observations before replacement. All previously saved behavioral fields remained
equal except the expected ten `value_after_call` corrections from null to empty
text:

- `PP-DATE-07`, `PP-DATE-08`, `PP-DATE-09`, `PP-DATE-11`,
  `PP-DATE-12`, and `PP-DATE-14`;
- `PP-TIME-GATE-ISO`, `PP-TIME-GATE-OTHER`, `PP-TIME-EMPTY`, and
  `PP-TIME-INVALID`.

Every OO row now identifies scalar value context and the native return type. For
each failed operation the evidence records, in call order:

1. the operation error;
2. the empty scalar value result;
3. the unchanged operation error after that value read;
4. the absent return from `err(1)`;
5. the empty error after clearing;
6. the retained scalar date-time after clearing; and
7. the empty error after that retained-value read.

The failure scenarios state these observable results explicitly. No
list-context value read was made or inferred.

### Fixture data and runtime provenance

`initial_request` now labels the initial parse input as a request echo. The
evidence also records that the pre-operation value read was deliberately skipped
because it belongs to the separate cache batch. Fixture version expectations are
named `fixture_expected_*`; observed versions come from the public OO
`version` and functional `DateManipVersion` calls. The observed backend
versions are 7.00 for OO and DM6 and 5.66 for DM5, with distribution version 7.00
for all rows. The regenerated observation document uses schema version 2 for
this revised field model.

Each row records the loaded entry module path. The evidence header includes
SHA-256 values for the installed Base.pm, Date.pm, DM5.pm, DM6.pm, Obj.pm, TZ.pm,
and Zones.pm files, in addition to the corpus, probe, runner, and profile fixture.
All eleven saved hashes match the current files. OO rows also preserve the
publicly observed tzdata2026c and tzcode2026c values.

### Portable and Perl binding features

The two unsupported mapping-reference cases moved from the portable
`leading-tokens.feature` file to
`leading-tokens-perl-binding.feature`. The latter carries
`@source-binding`, `@perl-binding`, and
`@excluded-from-portable-handoff` tags because the Perl hash-reference type and
exact stdout diagnostic are binding behavior. `bindings.json` names the two
case IDs, feature path, tags, and exclusion reason.

The remaining portable feature text does not expose Perl modules, source
locations, reference types, or implementation algorithms.

### Public observer bindings

`bindings.json` now maps the public setup, observer, and metadata calls used by
the evidence. For OO operations it gives the exact `err`, scalar `value`,
`err(1)`, `version`, `tzdata`, `tzcode`, and `zone` call sequence and
source locations. The functional maps include `Date_Init` and
`DateManipVersion`. All calls remain within the public-only scope.

## Verification

- The regenerated manifest has 71 unique observations: 53 OO, 10 DM6, and 8
  DM5. All are repeatable across two isolated processes and temporary working
  directories.
- Process stderr is empty, all probe exceptions are absent, and stdout is empty
  except for the two binding-only unsupported-reference cases.
- All 71 case IDs occur exactly once across the feature files: 53 date/time
  receiver cases, 16 portable leading-token cases, and 2 Perl binding cases.
  There are no unknown feature IDs. Case requests and the typed result, status,
  error, consumption, remaining-token, and diagnostic literals match the saved
  observations; the newly expanded failure steps match every recorded observer
  return in call order.
- The 10 OO failures return numeric status 1, preserve empty text as a text
  value before clearing, preserve an absent `err(1)` return, and expose the
  retained initial date-time after clearing.
- Functional plain text and scalar references remain unchanged. Token arrays
  alone are shortened, and consumed counts agree with their before/after
  lengths. The DM6 empty array returns empty text; the DM5 empty array returns
  an absent value.
- All eight DM5 rows retain the backend deprecation warning as research-only
  evidence.
- Perl syntax, JSON parsing, saved input and installed-module hashes, feature ID
  correspondence, and whitespace checks pass.

## Disposition

The concrete defects from the independent review are resolved. The repaired
batch is ready for coordinator review as candidate specification evidence; it is
still draft research and has not been presented as an executable BDD suite.
