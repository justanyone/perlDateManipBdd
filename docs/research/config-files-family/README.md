# Public configuration-file loading

This original bounded batch has18 file/request fixtures exercised through both
OO `config` and DM6 `Date_Init`, for36 isolated cases. Each is repeated twice
in a fresh process and temporary working directory with a four-worker limit and
15-second timeout. Only the named environment is supplied. File names are fixed
relative names inside the temporary directory, so diagnostic paths are stable
without stripping raw warnings. No upstream configuration examples were copied.

Public `Date::Manip::Config` documentation and inspection of the configuration
reader in `TZ_Base.pm` informed boundaries. The probe calls no private method.
Cases cover empty files, blank/comment lines, mixed-case names and CRLF, repeated
settings, call/file precedence, nested inclusion and resumption, multiple files,
missing and empty paths, malformed lines, inline hash text, quoted values,
unknown variables, unknown sections and return to the configuration section.
The shared profile pins Date-Manip7.00, UTC, English, a fixed reference clock,
US date order and midnight. Source/input/tool hashes accompany the observations.

All36 subsequent parses of `04/05/2040` return the reviewed April5 or May4
civil result. These distinct month/day facts independently expose date order.
A malformed line raises after the preceding date-order change has taken effect;
the following file assignment is not applied. Trailing hash text and quotation
marks are preserved in the setting getter, with the observed day/month parsing
behavior. Those cases are disputed compatibility, not prescribed desirable
validation. Missing files and unknown variables/sections issue one warning;
raw diagnostic strings and source locations stay in research evidence.

`spec/drafts/config-files/loading.feature` gives every original file body as a
JSON string, preserving whitespace and CRLF unambiguously, and states ordered
settings, typed error/warning categories, subsequent parses and readable literal
results. `feature-map.json` relates cases to reference profiles/bindings. Object
setting queries are explicit; the functional profile makes no such query.

```sh
python3 tools/probes/config-files-family/run.py > /tmp/config-files-candidate.json
python3 tools/review/config_file_literals.py
```

Review candidate output before replacing the saved observations. The checker
compares every file body, ordered setting and date literal with the recorded
requests/results and verifies hashes; it is not a BDD harness. No portable
expectation is promoted automatically from repeatability.

## Remaining file-loading obligations

This does not close the file grammar family. Remaining cases include the legacy
DM5 personal/global file interfaces, Base/TZ/Delta/Recur receivers, unreadable
files and directories, failed opens, empty/malformed assignments, embedded equals,
missing nested files, repeated/cyclic inclusion, special section continuation,
holiday/event/zone sections and erasure, relative-path behavior from nested files,
UTF-8 and other encodings, and interactions with defaults/reset and later reload.
Native configuration-return conventions and full diagnostic rendering belong in
binding coverage, separately from portable error categories. Coverage metrics
have not been collected for this batch; the final statement/branch gate remains.
