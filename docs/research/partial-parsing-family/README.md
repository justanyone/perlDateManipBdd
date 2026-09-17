# Partial parsing reference batch

This original batch characterizes the three contracts left open by the broader
date-text corpus: date-only receiver mutation, time-only receiver mutation, and
functional longest-prefix parsing. The probes observed Date-Manip 7.00, the
bundled DM5 5.66 compatibility backend, Perl 5.40.1, tzdata2026c, and
tzcode2026c under the fixed profiles in
`docs/automation/reference-profiles.json`. Runtime versions come from the
public `version` or `DateManipVersion` calls. Fixture version fields are saved
separately as expectations, and the observation header hashes the installed
modules that implement the exercised operations and observers.

The 71 cases run twice, each run in a fresh process and temporary working
directory, with at most four workers and a 15-second process timeout. The process
environment fixes `TZ=Etc/UTC`, `LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`; `PERL5LIB`
contains only the pinned local installation. The probe records stdout, stderr,
warnings, exceptions, status and output types, errors, receiver values, and mutable
carrier state.

For an initialized OO receiver, the saved `initial_request` is the request sent
to `parse`; it is not labeled as an observed receiver value. The probe
deliberately skips a value read before the operation because that read triggers
the separately inventoried cache behavior. After the operation it calls the
public observers in this order: `err()`, scalar `value("local")`, and
`err()` again. On failure it then calls `err(1)`, records that call's absent
return, reads `err()` to confirm it is empty, reads the retained receiver value
in scalar context, and reads `err()` once more. Each return is saved without
converting empty text to an absent value.

Run the evidence capture with:

```sh
python3 tools/probes/partial-parsing-family/run.py > /tmp/partial-parsing-candidate.json
```

The saved observations were reviewed manually against the cases and the public
POD. Date-only success retains an existing clock and uses midnight for an unset
receiver. Time-only success retains an existing civil date and uses the fixed
reference date for an unset receiver. All 16 inventoried complete ISO time forms,
both truncated forms, and all 16 non-ISO numeric/meridiem forms have concrete
rows. Fractions below one second are discarded at the public second-resolution
value, while fractional minutes and hours become whole seconds and minutes.

The functional profiles agree on successful plain text, scalar-reference, whole
token-array, and longest-prefix results. Only token arrays are shortened. No-match
arrays remain unchanged. An empty token array returns empty text in the current
profile but an absent value in the legacy profile. Unsupported references emit the
literal stdout diagnostic `ERROR:  Invalid arguments to ParseDate.` and return
empty text in both profiles. Those two unsupported-reference checks are tagged as
Perl source-binding compatibility and live in
`leading-tokens-perl-binding.feature`; they are excluded from a portable
implementation handoff.

## Reviewed compatibility findings

- A successful partial mutation can appear stale if `value("local")` is read on
  that receiver before `parse_date` or `parse_time`; the probe avoids that
  read-side cache effect. A dedicated lifecycle batch should decide whether this
  compatibility behavior belongs in the portable contract.
- `nospecial` together with `nodelta` still accepts `tomorrow` through
  `parse_date`. This is retained as observed compatibility rather than presented
  as proof that either gate is ineffective for every spelling.
- A `noiso8601` token-array request still accepts `2040-02-29` through another
  parser family and consumes it. The features state the observed result without
  claiming exclusive grammar provenance.
- The legacy backend emits its distribution deprecation warning on every load.
  This binding warning is saved in evidence and is not part of the portable result.

## Precise remaining gaps

This bounded batch does not discharge every text grammar. Date-only `nodelta`
and `noholidays` still lack spellings accepted directly by `parse_date` that can
isolate those gates; holiday names are accepted by the full parser rather than
this date-part method in the checked profile. Date-only zone mutation and DST
gaps/overlaps remain. Time-only zones, 24:00:00,
fractional carry/rounding boundaries, alternate localized separators, special
midnight, and invalid meridiems remain. Functional prefix parsing still needs
multiple-token scalar holders, ambiguous prefixes, every DM6 option with an
exclusive spelling, option arity errors, and list elements containing whitespace.
The pre-read cache interaction also needs its own explicit observation before any
portable disposition.

Integration review
------------------

Independent findings and their resolutions are recorded in
`docs/research/partial-parsing-review.md`. The coordinator's
`python3 tools/review/partial_parsing_literals.py` checks all71 request/feature IDs,
11 provenance hashes,51 date/time outline literals, ten native empty-text failure
returns with error-clear sequencing, and selected functional carrier boundaries.
It is a research consistency check, not an executable BDD suite.

The separately integrated parse-cache-family supplies explicit public observations
for the pre-read cache interaction above. The52-case partial-parsing-edges batch
addresses several listed zone, fractional, gate and carrier gaps but remains under
independent review; no complete family or portable disposition is claimed here.
