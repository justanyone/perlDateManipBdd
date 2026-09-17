# Value serialization reference batch

This original bounded batch characterizes the public `Date::Manip::Base` `split`
and `join` services inventoried as `value.split-fields` and
`value.join-fields`. It covers the `date`, `hms`, `offset`, `time`, and `delta`
kinds, the deprecated `business` alias, all three Printable forms, default and
disabled normalization, standard and requested business modes, signed and zero
values, negative values, range boundaries, overflows, invalid kinds, wrong
shapes, nonnumeric fields, empty text, and undefined Perl inputs.

Every Base service comes from the public `base()` method of a newly configured
`Date::Manip::Date` receiver. The probe does not call private field helpers. The
profile is the exact `oo` fixture in `docs/automation/reference-profiles.json`:
English, ASCII, US date order, `Etc/UTC`, the fixed 2040-02-28 reference clock,
and an eight-hour Monday-through-Friday business day. Three requests apply a
declared Printable override after the full fixture. Configuration returns and
errors are recorded separately from operation results.

The 73 requests ran twice per capture in fresh Perl processes and fresh temporary
working directories with at most four workers and a 15-second timeout. The
frozen file was itself reproduced by two complete captures with byte-identical
JSON. The environment contains only the pinned local Date-Manip installation in
`PERL5LIB` and fixes `TZ=Etc/UTC`, `LANG=C.UTF-8`, and `LC_ALL=C.UTF-8`.
Observed metadata is Date-Manip 7.00, Perl 5.40.1,
tzdata2026c, and tzcode2026c. The evidence header hashes the request manifest,
probe, runner, shared profile, and all nine loaded Date::Manip modules involved in the calls.

Each case makes its scalar-context and list-context call on separate newly
configured receivers and Base services. For each call the probe reads the public
Base error before the operation and immediately after it, including after a
caught exception. It captures warnings, actual stdout, exceptions, and process
stderr independently. A completed invalid call that returns Perl `undef` is
stored as JSON null with type `undefined`; the defined empty string returned for
an unknown kind is stored as `""` with type `text`. Exceptions have no return
member. A list-context call has one element for every completed request,
including an undefined element for ordinary failure; it has no result after an
exception. No value observer is needed because these methods return their value
directly.

Run the capture and internal fidelity review with:

```sh
python3 tools/probes/value-serialization-family/run.py > /tmp/value-serialization-candidate.json
python3 tools/probes/value-serialization-family/review.py
```

The review checks hashes, request and feature correspondence, configuration and
observer order, native scalar/list carriers, diagnostic isolation, literal
feature results, and a few independently derived facts. It is a research
consistency check, not an executable BDD suite or semantic approval.

## Reviewed compatibility findings

- The three documented fixed date spellings split into the same six numeric
  fields, and Printable 0, 1, and 2 join those fields into their respective
  literal forms. Date joining performs only shape-level checking: the deliberately
  nonnumeric and out-of-range fields produce `2040134025:61:0x`. This permissive
  documented behavior is isolated as compatibility rather than used as a valid
  civil date.
- Clock fields accept exactly 24:00:00 at the upper edge and reject 24:00:01.
  Offset fields accept both signed 23:59:59 endpoints and reject 24:00:00.
  Mixed-sign elapsed time is normalized by total duration, while mixed-sign UTC
  offset fields are rejected.
- Normalizing 1 hour, 120 minutes, and 90 seconds produces 3:01:30. The explicit
  `nonorm` option and the deprecated positional option preserve 1:120:90.
  Delta fields show the same default-versus-`nonorm` distinction.
- The documented `business` kind alias turns sixteen configured work hours into
  two workdays. In contrast, passing `{mode: business}` with kind `delta` leaves
  the same request in standard mode in this release. The documentation describes
  those routes as equivalent, so the two `delta` mode observations are tagged
  `suspected-bug` and are not portable requirements.
- The documented omitted-field delta text `4:::7` returns an absent value, while
  a four-field suffix `4:5:6:7` succeeds. This documentation discrepancy is also
  retained as a suspected bug.
- An unknown kind returns defined empty text rather than the documented absent
  error value. Those two observations remain disputed. Undefined split text
  produces three Perl uninitialized-value warnings and an absent result. An
  undefined or scalar join carrier raises a Perl array-reference exception before
  a return. These diagnostics live only in the excluded binding feature.

## Scope still open

This partition batch does not enumerate every numeric magnitude or every
combination of sign, normalization, delta mode, and approximation type. It does
not cover NaN or infinity spellings, locale-specific numerals, arbitrary object
or blessed-reference carriers, undefined elements inside otherwise valid field
arrays, fractional values in every delta field, Printable values outside 0–2,
or every deprecated positional false value. It does not decide whether the three
documentation discrepancies should be fixed upstream or emulated. Calendar
validation belongs to date parsing and construction contracts; these Base helpers
only serialize their documented field carriers.

The portable feature drafts contain 58 ordinary requests. Seven deprecated or
permissive results and five documentation-sensitive results are separated in the
compatibility feature. Three Perl warning/exception inputs and 73 concrete scalar/list calling-context
examples are in an explicitly excluded source-binding feature. The
feature map gives every request one stable feature row and one canonical operation
ID; `bindings.json` separately records every public setup, operation, error, and
metadata call.

## Coordinator review

A fresh two-attempt capture after provenance repair retained all 146 native call
outcomes exactly. All loaded module paths are now observed and hashed, including
English language and UTC zone modules. The runner fixes PATH to /usr/bin:/bin.
The reviewer checks exact per-row inputs, kind, options, Printable overrides,
results, native carriers and diagnostic counts; no literal in another row can
satisfy a case. Explicit field-order prose removes the implicit kind convention.
The pinned real parser accepts all four files and expands 146 examples. These
checks validate research and syntax, not an implemented Date::Manip BDD adapter.
