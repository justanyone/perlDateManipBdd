# Rendering-family reference observations

`cases.json` is the case-to-contract and partition record. `feature-map.json`
maps every draft feature tag to its evidence case and one-based pattern position.
The native baseline contains 32 single-character fields, 18 composites, four
literal forms, and seven extended selector families: 61 finite renderer
spellings or families. Separate POSIX requests cover all 12 documented
reinterpretations and the six forms whose POSIX meanings remain unavailable.

Run the evidence batch from the repository root:

```sh
python3 tools/probes/rendering-family/run-rendering-family.py > docs/research/rendering-family/observations.json
```

The runner creates a temporary directory and a fresh Perl process for every
invocation, runs each case twice, limits work to four concurrent processes, and
times out an invocation after 15 seconds. It fixes `TZ=Etc/UTC`, English, and
`C.UTF-8`, and uses local Date-Manip 7.00. The probe records raw text-result and
ordered-text-result carriers, configuration and parse state where applicable,
warnings, exceptions, and captured call stdout. Newline and tab remain JSON
characters rather than visible placeholders.

All 24 case invocations were byte-identical on their two runs. This is
`repeatable` research evidence, not a reviewed portable assertion or a BDD test
pass. The probe loads only the requested public backend per process, selects the
actual DM6 fixture for DM6 cases, asserts distribution 7.00 and tzdata2026c for
OO/DM6, and records configuration diagnostics. DM5 is configured separately;
its deprecation warning and `%N`/extended-selector fallback texts remain raw
compatibility evidence.

Completed partitions are one ordered baseline request for every native
spelling/family in OO and DM5, POSIX changed and unchanged requests, extended
selector endpoints/out-of-domain fallback, unknown/trailing percent, zone offset,
and zero/one/many requests for OO, DM6, and DM5. Remaining partitions are each
ordinary directive's documented numeric boundaries, language and date-format
alternatives, incomplete/invalid receiver states, facade parse failures, DST
gap/overlap, and non-whole-hour/second offsets. The DM5 observations establish
runtime compatibility results; they do not approve a portable DM5 requirement.

Coordinator authoring review replaced two evidence-record placeholders with
literal results, made text versus ordered-text requests distinct, and specified
empty text versus an empty collection. The POSIX comparison explicitly starts a
fresh context, matching its separate reference invocations. Native and legacy
baseline tables retain all whitespace differences, including legacy `%v` padding
and numeric offsets in its composite forms.

`python3 tools/review/rendering_literals.py` checks provenance hashes, all 24
case/tag mappings, 99 native/legacy table literals, successful reference setup,
and independent UTC epoch and ISO-week facts. This is targeted draft verification,
not proof that every rendering edge is covered. The remaining partitions above
still prevent completion under `docs/automation/definition-of-done.md`.
