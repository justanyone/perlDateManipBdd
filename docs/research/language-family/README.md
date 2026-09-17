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

The legacy source binding is kept in a separate observation file because its
clock semantics, supported languages, character handling, diagnostics, and
output differ. Its tomorrow
successes retain the forced clock time (`2040022910:20:30`), unlike DM6's midnight
result. Finnish and Norwegian initialization report `ERROR: Unknown language in
Date::Manip.`. Catalan reaches a legacy undefined-array-reference exception. In
those six rows, `dependent_operations_executed` is false and the probe makes no
parse or render call; it does not manufacture an absent return for an uncalled API.
Several initialized profiles return empty text, shifted dates, mojibake, malformed
interpolation text, or mode-dependent renderings.  These repeatable results remain
compatibility evidence and are not silently promoted to intended portable behavior.
The raw warning arrays are retained, including the legacy binding's deprecation
warning and legacy regular-expression warnings.
No decoding repair is applied: the Polish U+009C byte-as-character result and the
Russian, Turkish, and Italian malformed renderings remain explicit in the draft
tables, while every raw warning remains in `dm5-observations.json`.

`cases.json` is the executed fixture metadata.  `fixtures-a-h.json` retains the
independently authored candidate review for the first eight languages.  The draft
features under `spec/drafts/languages/` contain manually transcribed literal
results. Date-times in the English features use readable ISO form; compact binding
values remain in research evidence only. `@draft` means these are not approved
contracts or executable BDD passes.

## Portable profile and source-binding separation

The portable runtime features call the two behavior profiles
`current-language-profile` and `legacy-language-profile`. Stable `LANG-DM6-*`
and `LANG-DM5-*` case IDs remain opaque research identifiers. Source backend,
module, callable, native carrier, warning, and exception details are recorded in
`portability-map.json` and the excluded `perl-binding.feature`.

All 32 legacy source observations remain represented. Twenty initialized rows
execute render plus the three ordinary parses. Six initialized rows additionally
execute a real special preprocessing parse. Six initialization-failure rows
assert only that no configured profile is produced and no dependent parse or
render runs. There are no `not applicable` placeholders.

The excluded binding feature preserves all 32 native warning counts and classes,
the six interrupted setup calls and their native exception prefixes, and the
exact backend call order. An interrupted setup has no returned status; the
capture omits the return field instead of serializing an unassigned wrapper
variable. The portable failure rows retain the public initialization
failure and absence of dependent calls without prescribing a Perl exception.
The disputed Polish control character and Russian, Turkish, and Italian strings
remain literal portable observations.

The current-profile ASCII table uses `empty text` for every successful empty
error. It distinguishes that value from the Russian failure's
`[parse] Invalid date string` diagnostic.

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

`python3 tools/review/language_literals.py` checks 64 recorded requests, 68
portable runtime rows, 38 excluded binding rows, and 45 selector rows. It compares
each row with its own literal inputs, results, setup distinction, render value,
warning census, binding exception, contract mapping, and executed call sequence.
It also verifies every stored tool, fixture, installed-module, and archive hash.
After the portability repair, a return-fidelity correction added an explicit
`call_completed` flag to legacy initialization, omitted `status` from the six
interrupted calls, and retained explicit `status: null` for all 26 completed
initializations. The runner `PATH` is now fixed to `/usr/bin:/bin`. Fresh
two-attempt corpora changed only those fields and the probe/runner hashes; every
parse, render, warning, exception, environment, and process result was unchanged.

The actual pinned feature parser is run separately with:

```text
env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  PERL5LIB=local/bdd-runner/lib/perl5 \
  perl tools/runner-trial/parse-features.pl spec/drafts/languages/*.feature
```

The 45-selector corpus now has 45 explicit English scenarios for every inventoried
canonical name and alias under the current OO/UTF-8 profile. Each selector is
configured in two fresh processes and exercised with an original localized full
date plus full weekday/month rendering. Every result matches the previously
reviewed canonical-language literal. The selected-language getter preserves the
supplied selector spelling. Tool/input/module hashes and per-attempt isolation
are recorded. `selector-feature-map.json` links all 45 cases to public bindings.

This closes only those exact selector spellings in the current OO/UTF-8 profile.
Case variants, invalid selectors, reconfiguration sequences, other encodings and
legacy alias behavior remain distinct obligations. Neither the consistency
reviewer nor the structure checker is an executable BDD harness.

Coordinator verification independently replayed both backends; each32-case corpus
ran twice and byte-matched the final evidence. Exact comparison to previous committed
records preserves every behavior after restoring only historical setup placeholders
and ignoring updated probe/runner hashes. Six failed initializations are interrupted
without status returns;26 completed initializations retain their actual absent
status. No unchanged parse/render result was relabeled as a success.
