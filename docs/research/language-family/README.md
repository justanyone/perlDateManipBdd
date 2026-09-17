# Canonical language runtime observations

This research corpus covers the 16 canonical language selections in Date::Manip
7.00.  It complements, and does not replace, the existing 45-selector corpus in
`selector-observations.json`.  The fixtures are original phrases composed from
the pinned release's public language documentation and token tables.  No upstream
example, test, dictionary, or parsing algorithm is copied into the portable draft.

Run the two profiles separately from the repository root:

```text
python3 tools/probes/language-family/run-corpus.py dm6 > /tmp/date-manip-language-dm6.json
python3 tools/probes/language-family/run-corpus.py dm5 > /tmp/date-manip-language-dm5.json
```

Each of the 32 cases per profile ran twice in a fresh temporary directory and a
fresh process.  The runner supplies only the recorded locale, zone, Perl hash
ordering, dependency path, and executable path; uses four workers; and imposes a
15-second timeout. The runner records and checks the SHA-256 of `cases.json`.
Each process asserts Date::Manip 7.00, its expected backend version, and, for DM6,
tzdata2026c/tzcode2026c before observing behavior. All 64 rows repeated
byte-for-byte with zero nonzero exits and zero JSON decode failures. The runtime was Perl v5.40.1 on
`x86_64-linux-gnu-thread-multi`; the distribution was Date::Manip 7.00, with DM6
7.00 and DM5 5.66 backends.

Every DM6 UTF-8 row accepted the named leap date, the same date with its localized
Wednesday, and the localized tomorrow term.  Every accepted parse produced
`2040022900:00:00`; `%A|%B` produced the exact localized weekday and month stored
in `dm6-observations.json`.  The four special-preprocessing fixtures also succeeded:
German, Norwegian, and Turkish period forms, and Russian parentheses plus `г.`.

The forced-ASCII rows accepted all selected ASCII alternatives except Russian,
which has no ASCII alternative in this fixture.  Its three ordinary parses and
special-preprocessing parse returned status 1, no value, and
`[parse] Invalid date string`.  Rendering remained localized for all languages,
including non-ASCII output under the forced-ASCII configuration; this is recorded
behavior, not an encoding guarantee inferred from the setting's name. DM6 object
calls map to `date.parse-text`, `date.render-pattern`, and
`config.apply-settings`; DM5 `ParseDate` calls map to
`date.parse-leading-tokens`. The explicit `DateFormat=non-US` setting belongs to
every fixture.

DM5 is kept in a separate observation file because its clock semantics, supported
languages, character handling, diagnostics, and output differ.  Its tomorrow
successes retain the forced clock time (`2040022910:20:30`), unlike DM6's midnight
result. Finnish and Norwegian initialization report `ERROR: Unknown language in
Date::Manip.`. Catalan reaches a legacy undefined-array-reference exception. In
those six rows, `dependent_operations_executed` is false and the probe makes no
parse or render call; it does not manufacture an absent return for an uncalled API.
Several initialized profiles return empty text, shifted dates, mojibake, malformed
interpolation text, or mode-dependent renderings.  These repeatable results remain
compatibility evidence and are not silently promoted to intended portable behavior.
The raw warning arrays are retained, including the DM5 deprecation warning and
legacy regular-expression warnings.
No decoding repair is applied: the Polish U+009C byte-as-character result and the
Russian, Turkish, and Italian malformed renderings remain explicit in the draft
tables, while every raw warning remains in `dm5-observations.json`.

`cases.json` is the executed fixture metadata.  `fixtures-a-h.json` retains the
independently authored candidate review for the first eight languages.  The draft
features under `spec/drafts/languages/` contain manually transcribed literal
results. Date-times in the English features use readable ISO form; compact binding
values remain in research evidence only. `@draft` means these are not approved
contracts or executable BDD passes.

The bounded corpus does not cover every vocabulary entry.  Remaining boundaries
include all unused month, weekday, abbreviation, meridiem, connector, duration,
ordinal, recurrence, direction, relative-date/time, named-time, and separator
tokens; wrong-weekday handling; capitalization and normalization boundaries;
every supported input/output encoding; invalid byte sequences; language changes
before and after encoding changes; mixed-language phrases; every special-rule
placement; every DM5 warning/error class; and independent linguistic review.  The
45 selection strings are covered only by the existing selector corpus, while this
runtime corpus deliberately uses canonical names.

Coordinator review
------------------

`python3 tools/review/language_literals.py` checks 64 recorded requests and 68
draft rows against literal results, exact input strings, setup-failure distinctions,
rendered Unicode/control characters, and warning counts. Tool, fixture, installed
module and archive hashes are recorded. Both corpora were repeated after adding
provenance; all 64 observation records were unchanged. Current-value feature steps
now explicitly use fresh configured values; legacy steps follow the recorded order
(render, optional special parse, full date, weekday date, relative date).

The45-selector corpus now has45 explicit English scenarios for every inventoried
canonical name and alias under the current OO/UTF-8 profile. Each selector is
configured in two fresh processes and exercised with an original localized full
date plus full weekday/month rendering. Every result matches the previously
reviewed canonical-language literal. The selected-language getter preserves the
supplied selector spelling. Tool/input/module hashes and per-attempt isolation
are recorded. `selector-feature-map.json` links all45 cases to public bindings.

This closes only those exact selector spellings in the current OO/UTF-8 profile.
Case variants, invalid selectors, reconfiguration sequences, other encodings and
legacy alias behavior remain distinct obligations. Neither the consistency
reviewer nor the structure checker is an executable BDD harness.
