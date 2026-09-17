# Remembered source-text observations

Sixteen original requests characterize public `Date::Manip::Date::input` in
Date-Manip7.00. The public POD documents source-text retrieval; inspection of
private initialization and parse finalization supplied edge-case ideas. No
private helpers are called, and their structure is not a portable requirement.

Each case runs twice in separate processes and fresh temporary directories with
a clean environment, four workers and a15-second timeout. Configuration comes
from the pinned OO profile and is converted into the public key/value signature.
The initial prototype passed assignment strings incorrectly; it was rejected
because configuration emitted warnings. Only the corrected, warning-free run is
stored. Runtime version and timezone metadata are observed through public calls;
source, fixture and tool hashes accompany the results.

The ordered observer sequence is error, scalar input, error, list input, error,
scalar date value, error. Every input read returns defined text; the list read
returns one element even when that text is empty. No input read changes the error.
Full parsing preserves original whitespace and spelling. A failed full parse
clears remembered input. Successful date-only/time-only parsing, field replacement
and conversion clear it; failed date-only/time-only parsing preserves it. Pattern
success stores its input text. Pattern non-match returns1 with an empty immediate
error; that reference behavior is explicitly disputed.

The feature contains original English public actions and literal outcomes. JSON
notation preserves whitespace, arrays and absent arguments. Date-value text is a
lossless presentation normalization, not the native Perl scalar byte format.
`feature-map.json` links each scenario to the primary and supporting public IDs.
The binding is `Date::Manip::Date::input` in scalar/list context, following the
case's listed public Date actions. Setup uses `new`, `config`, optional `parse`,
`version`, `tz`, `tzdata` and `tzcode`; observers use `err`, `input` and `value`.

Regenerate to a candidate before comparing or replacing stored evidence:

```sh
python3 tools/probes/input-history/run.py > /tmp/input-history-candidate.json
python3 tools/probes/input-history/review.py
python3 tools/review/feature_structure.py spec/drafts/input-history
```

The reviewer checks literal feature request arguments, action returns, both input
carriers, every error assertion, normalized final value, and provenance. It is
not an executable BDD harness. More input-history transitions remain: constructor
parsing, receiver-derived objects, arithmetic/navigation, language preprocessing,
UTF-8/alternate encoding, and additional mutation failures. This batch is not
complete behavior or source coverage and does not lower the project-wide gates.
