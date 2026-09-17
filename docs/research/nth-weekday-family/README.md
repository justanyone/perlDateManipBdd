# Ordinal weekday occurrence reference observations

This family adds 28 branch-distinct public requests for
`calendar.nth-weekday`. The canonical contract and API inventory identify one
binding: the public calendar service operation taking year, signed occurrence,
weekday, and an optional month. The probe calls that operation directly. Source
review found no private entry point on the direct path, and no private helper is
called.

The matrix was compared with the seven older requests in
`docs/research/inputs/calendar.json`; none of the 28 argument tuples duplicates
them. Six new cases exercise whole-year searches and six exercise month
searches. They cross positive and negative origins, first or last and later
occurrences, both weekday-offset comparisons, existing 53rd year occurrences,
existing fifth month occurrences, omitted and explicitly absent optional month,
leap February, and a 31-day month. Four cases freeze documented-limit no-match
absence in positive and negative month and year searches. Twelve cases preserve
zero and out-of-limit occurrences, weekday 0 and 8, month 0 and 13, and fields
that are all omitted, absent, or nonnumeric.

Every case ran twice in a fresh process and temporary working directory with a
20-second timeout. The runner fixes `PATH=/usr/bin:/bin`, the pinned Date-Manip
7.00 library, UTC, English, the C UTF-8 locale, and Perl hash determinism. The
evidence records Perl v5.40.1 on x86_64 Linux, the exact selected configuration,
the loaded module paths and hashes, the source and POD hashes, and every input
artifact hash. Both attempts were byte-identical for all 28 cases.

Independent Python Gregorian enumeration checks all 16 valid or documented
no-match cases. Twenty observed calls return a three-field value and eight
return an absent value. The eight absent results consist of four documented
no-match requests and four occurrences outside the documented limits. All
calls complete; the three omitted/absent/nonnumeric aggregate requests emit
arithmetic warnings. The portable features retain those permissive results and
use only the generic `arithmetic-input diagnostic` category. Exact warning text,
native scalar/list carriers, and source locations appear only in
`perl-binding.feature`, tagged `@source-binding`, `@perl-binding`, and
`@excluded-from-portable-handoff`.

`feature-map.json` maps every opaque case ID to its exact feature, partition
links, profile, typed request, literal result, independent expectation, and
source branch references. `bindings.json` preserves exact public arguments.
`source-review.json` records the public API/source reconciliation and confirms
zero direct private calls. `coverage-map.json` lists observed and remaining
domains without declaring any partition complete.

Regenerate and verify the derived artifacts from the repository root:

```sh
python3 tools/probes/nth-weekday-family/make_artifacts.py
python3 tools/probes/nth-weekday-family/review.py
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" perl tools/runner-trial/parse-features.pl \
  spec/drafts/nth-weekdays/year-occurrences.feature \
  spec/drafts/nth-weekdays/month-occurrences.feature \
  spec/drafts/nth-weekdays/no-match-boundaries.feature \
  spec/drafts/nth-weekdays/invalid-inputs.feature \
  spec/drafts/nth-weekdays/perl-binding.feature
```

Reproduce the frozen evidence independently:

```sh
python3 tools/probes/nth-weekday-family/run.py > /tmp/nth-weekday-observations.json
cmp /tmp/nth-weekday-observations.json docs/research/nth-weekday-family/observations.json
```

This remains a bounded draft. Explicit remaining domains are supported endpoint
years 0001 and 9999, other weekday/year/month combinations that repeat the
observed branches, common-February successful occurrences, the full cross-product
of individually omitted, absent, empty, and nonnumeric fields, fractional and
extreme numeric values, numeric text variants, reference carriers, and Unicode
numeric text. Exhaustively crossing all weekdays with every occurrence would
repeat the same offset and limit branches and is not part of this batch.
