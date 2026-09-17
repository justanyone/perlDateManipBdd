# Public configured week-count edge research

This batch records 14 original public request sequences for
`calendar.weeks-in-year` through the Date-Manip 7.00 Base binding. It adds the
supported year endpoints 1 and 9999, nine selected unsupported year shapes, one
configuration A-B-A sequence, and one invalid request for each of `FirstDay`
and `Week1ofYear`. The manifest contains 22 executed steps. Week-count steps
are called once in scalar context, again in scalar context, and once in list
context, for 58 native calls in each complete observation set.

Every case uses a new `Date::Manip::Base`, Perl process, and temporary working
directory. The probe applies the pinned `oo` profile in its recorded order with
`ForceDate` explicitly omitted. A direct Base service has no timezone service,
and week counting has no clock input. The evidence retains both the full source
profile and the exact applied entries, so this difference is visible. The
process environment fixes the local Date-Manip library, UTC, C UTF-8, Perl hash
ordering, and `PATH=/usr/bin:/bin`.

Two complete captures were run after the final probe change. Each capture runs
every case twice, giving 28 fresh process attempts and 116 public calls. The two
JSON files were byte-identical. The final metadata-only additions record native
return types, the reference release, and operating system; a normalized
comparison with the preceding capture confirmed that requests, values,
warnings, errors, and standard output did not change.

Under the Monday/January-4 profile, years 1 and 9999 each return 52. Independent
Gregorian checks verify year 1 directly and year 9999 by its 400-year-equivalent
year 1999. For year 2000, an independent week-boundary calculation gives 52
weeks with January 4 in week one and 53 with January 1 in week one, matching the
observed A-B-A trace `52,53,52`.

All selected unsupported year requests return 52. They remain tagged disputed
compatibility behavior rather than valid portable years. Omitted and explicit
undefined years produce 12 warnings on the first scalar call and two on each
cached scalar/list call. Empty and alphabetic text produce three warnings on
the first call and none on cached calls. These exact native warning sequences,
including the repeated-call split, live only in `perl-binding.feature`, tagged
`@excluded-from-portable-handoff`.

Both invalid configuration calls complete with an undefined scalar, one native
warning, and empty public error text before and after. Their following counts
remain 52. Accepted configuration calls also complete with an undefined scalar,
so the portable feature records accepted/rejected outcomes and subsequent count
traces while the binding feature preserves the evidence that distinguishes the
native calls. No result is invented for an unexecuted repeated or list config
call; those cells say `not called`.

`source-review.json` ties the operation to the documented public method and
lists the private logic inspected only to choose cases. The probe never calls a
private function. `feature-map.json` maps all 14 stable case IDs and 22 binding
step IDs to literal rows. `coverage-map.json` keeps the invalid partition open.
Remaining domains include other native carriers and numeric spellings, missing
configuration names or values, other invalid settings, combined FirstDay/rule
changes on reused services, and other releases. The earlier 105-setting valid
matrix remains the broad configuration evidence; this batch does not repeat it.

Reproduce without replacing frozen evidence:

```sh
python3 tools/probes/week-count-edges/run.py > /tmp/week-count-edges-candidate.json
cmp /tmp/week-count-edges-candidate.json docs/research/week-count-edges/observations.json
python3 tools/probes/week-count-edges/review.py
```

The reviewer checks every request, fixture entry, native carrier, warning,
error snapshot, output channel, feature literal, mapping, provenance hash, and
selected independent Gregorian fact. It parses the draft features with the
repository's installed Gherkin parser. This is completed research evidence for
the selected batch, not an approved or passing executable BDD harness.
