# Review record: week-number edges

Reviewed 2026-09-17 against Date-Manip 7.00, Perl v5.40.1, the public POD and
implementations for `Date::Manip::Base::week_of_year`,
`Date::Manip::Date::week_of_year`, and the DM6/DM5 `Date_WeekOfYear` exports.

The 236-case manifest and saved observation order correspond exactly. All 438
native scalar/list week calls and 17 configuration attempts repeat across two
isolated attempts per request. Process stderr and captured call stdout are empty.
Seven Base carrier/arity requests
raise in both contexts, and neither observation invents a return field. Every
completed Base inverse call retains its array-reference carrier in scalar context
and its one-element list carrier in list context. Every completed Base forward
call retains the final scalar item and full two-element list separately. Every
facade list call returns exactly one item matching its scalar call.

The review independently calculates the selected date's documented week number
for all 84 explicit valid facade overrides, rather than using Date-Manip as its
expectation source. It also checks Python standard-library ISO results for
2040-01-01 and the supported year-1/year-9999 boundaries, plus the two inverse
year-boundary dates. Those controls agree with the frozen literals.

All 17 configuration attempts complete. Sixteen invalid/absent values emit the
observed diagnostics, preserve `FirstDay=1` and `Week1ofYear=jan4`, and retain
the `[2039,52]` control pair. Uppercase `JAN4` is accepted without a diagnostic
and remains observable through `get_config`.

The portable feature map contains 232 unique case IDs. The binding-only map
contains all 236 unique IDs and is explicitly excluded from the portable
handoff. The p4/p5 coverage map accounts for every observation while preserving
the finite-domain limits listed in the README. All artifact and loaded-module
hashes pass. The real Test::BDD::Cucumber parser expands the three feature files
to 52, 180, and 236 cases respectively with no error or warning.

The reviewer parses escaped Gherkin table pipes and checks each complete row by
case ID. It rejects duplicate or missing IDs, missing or extra columns, and a
correct outcome or native diagnostic copied into another request's row. Portable
rows also match their language-neutral profile, rule, configured weekday,
request text, outcome, and classification; binding rows match their exact native
profile, family, request JSON, and context/diagnostic JSON.

Disposition: ready for coordinator review as a complete bounded p4/p5 draft and
reference corpus. It is not an executed BDD suite, a semantic promotion, or a
claim that unbounded invalid inputs have been exhausted.
