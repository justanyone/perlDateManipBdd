# Calendar fact review

This independent review uses only Python standard-library Gregorian, ISO-week, and UTC calculations. It does not approve contract expectations or call Date::Manip.

## Counts

| Status | Cases |
| --- | ---: |
| compatibility | 28 |
| invalid | 3 |
| reviewed | 190 |
| unreviewed | 10 |

The recorded evidence was captured twice per case. Its input, probe, runner, and fixture hashes match the evidence record.

## Captured channels

| Channel condition | Cases |
| --- | ---: |
| clean | 163 |
| with_warnings | 68 |
| with_exception | 0 |
| with_stdout | 0 |
| with_stderr | 0 |

## Disputed cases

- None.

## Review boundaries

`reviewed` means the result and return carrier match an independently calculated fact. `compatibility` records an observed, repeatable behavior outside that fact's direct scope. `invalid` records intentionally out-of-domain requests. `unreviewed` preserves cases whose API convention or input domain needs separate evidence. Warnings, exceptions, stdout, and stderr are retained per case in the JSON; warnings keep a case from being treated as a clean channel observation.

The three-field Base `check` cases are unreviewed because the observation itself reports uninitialized clock-field warnings. The explicit six-field variants provide the comparable date-validity evidence.
