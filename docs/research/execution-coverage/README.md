# Source-call coverage pilot

The user's completion gate requires evidence that every function and usage type
is tested. A declared caller mapping does not prove that a private function ran.
This original research debugger hook records Date::Manip subroutine entry names
without copying implementation text or changing the installed reference.

```sh
python3 tools/research-coverage/run-pilot.py > /tmp/call-coverage-pilot.json
```

Each pilot request runs normally and under the hook, twice each, in clean
environments and temporary directories. Calls contribute to the declaration
report only when both repetitions agree and exit status, stdout and stderr are
byte-identical to the uninstrumented invocation. Provenance hashes include the
hook, driver, probes, input records, declaration inventory and reference fixture.

The initial pilot accepts seven of eight requests and observes125 of423 named
declarations. The remaining298 are unobserved by this pilot, not proven
unreachable. Setup calls are included in the125 and do not establish behavioral
assertions for those functions. Every uncovered declaration remains an obligation.

The DM5 request is excluded because the debugger annotates the deprecation
warning's eval location with its source filename. The ordinary location is
`(eval 42) line 1`; the traced location additionally identifies the probe source
line. This diagnostic difference is retained, not silently normalized into a
passing equivalence claim. Future traced-backend checks need an explicitly
reviewed treatment of debugger-only diagnostic metadata.

This is subroutine-entry research, not the Perl BDD harness. It has no statement,
branch or condition coverage and samples only eight existing probes. Generated
callables, anonymous code, tool scripts and entrypoint variants still need their
separate accounting. Full instrumentation must run the eventual complete suite,
and every uncovered branch needs inspection for an untested edge or documented
unreachability. A high coverage percentage cannot replace expected-result tests.

The pilot record remains on the research side of the source-separation boundary.
Neither it nor the hook is part of the future implementation-only export.
