# Remembered source-text observations

Seventeen original requests characterize public `Date::Manip::Date::input` in
Date-Manip 7.00. The initial sixteen literal requests were retained unchanged;
one constructor-with-text case was added. The public POD documents scalar
source-text retrieval. The one-element Perl list carrier is a real observed
compatibility result, not a second documented return signature, and is labelled
as such in the feature and binding map. No private helpers are called, and
their structure is not a portable requirement.

Each case runs twice in separate processes and fresh temporary directories with
a clean environment, four workers and a15-second timeout. Configuration comes
from the pinned OO profile and is converted into the public key/value signature.
The initial prototype passed assignment strings incorrectly; it was rejected
because configuration emitted warnings. Only the corrected, warning-free run is
stored. The evidence records the exact fixture profile separately from its
public `get_config` echo, the configured zone, Perl/architecture/OS values,
Date-Manip package and timezone versions, loaded Date/Obj/TZ/Zones paths, and
the loaded `Etc/UTC` zone-data module with hashes. Every saved row retains both
process exit codes and stderr channels from its two isolated runs.

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
`bindings.json` gives the concrete Date-Manip module, callable, source/POD
location, native carrier, call context, and documented versus observed-
compatibility classification. Setup uses `new`, `config`, optional `parse`,
`version`, `tz`, `tzdata` and `tzcode`; observers use `err`, `input` and `value`.

Regenerate to a candidate before comparing or replacing stored evidence:

```sh
python3 tools/probes/input-history/run.py > /tmp/input-history-candidate.json
python3 tools/probes/input-history/review.py
python3 tools/review/feature_structure.py spec/drafts/input-history
```

The runner compares each pair of native JSON payloads before it saves them. The
reviewer requires its complete provenance schema and exact hash set, then checks
literal feature request arguments, action returns, both input carriers, every
error assertion, and normalized final value. It is not an executable BDD harness.
More input-history transitions remain: receiver-derived objects,
arithmetic/navigation, language preprocessing, UTF-8/alternate encoding, and
additional mutation failures. This batch is not complete behavior or source
coverage and does not lower the project-wide gates.
