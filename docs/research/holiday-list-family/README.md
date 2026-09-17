# Holiday-list research in progress

This original 18-case probe targets public `Date::Manip::Date->list_holidays`.
It exercises the receiver-year and fixed-current-year defaults, explicit year
overrides, false-valued arguments, an invalid receiver, year boundaries and
malformed years. Three original fixtures distinguish an ordinary holiday list,
an annual February 29 definition, and a calendar with no holidays.

The ordinary fixture deliberately defines dates out of order, two labels for
January 2, and an additional fixed-date label for December 31, 2040. It also
uses the supported configured working-day adjustment (`DWD`) for January 1,
with `TomorrowFirst=0`.
The fixture's recurrence can contribute a date from an adjacent year. Returned
date objects are observed through public `value`, `err`, and `holiday` calls.
The parent receiver's error is recorded before those result observers run.

The fixture pins the complete current reference configuration, including UTC,
the February 28, 2040 clock, English, the workweek and work hours, and erased
prior holiday/event definitions. Each case runs twice in a fresh process and
temporary directory, with a fixed environment and a 20-second timeout. Scalar
and list contexts use separately constructed and configured date receivers.
The list observation records a return count and serialized public observers;
it does not mislabel that count as the native list return value.

Source review covers the public entry at Date.pm lines 4119–4144 and its POD
entry at Date.pod line 127. Internal holiday construction at Date.pm line 4389
was inspected to identify adjacent-year, definition, and parsing cases. No
private function is called directly. Source hashes accompany the capture.

Preliminary findings need exact Gherkin mappings and independent review:

- Ordinary results are sorted and contain one date per holiday day, retaining
  the ordered labels observed through the public holiday query.
- An annual February 29 definition triggers warnings while neighboring common
  years are processed. This is isolated from the warning-free ordinary fixture.
- Invalid years can yield empty lists, malformed rendered date text, or a
  returned object with an error. These are compatibility findings to classify,
  not valid civil-date contracts.

Run the capture without overwriting frozen evidence:

```sh
python3 tools/probes/holiday-list-family/run.py > /tmp/holiday-list.json
```

This batch remains unfinished. Next: verify Gregorian and adjacent-year facts,
write portable English scenarios and excluded native diagnostics, check every
literal against its request and fixture, and enumerate remaining state and
definition-grammar obligations. No partition or BDD execution is complete.
