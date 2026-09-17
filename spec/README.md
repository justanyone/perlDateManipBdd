# Portable specification workspace

Only reviewed original English features, the portable glossary/protocol, necessary
small expected-value fixtures, profile metadata, attribution, and the MIT license
may be exported to a future independent implementation. See
[the handoff policy](../docs/planning/source-separation.md).

`drafts/` contains original candidate features under review. They are not an
approved complete specification and have not been run by a BDD harness. The
research-side API mappings, input/probe programs, observations, and review records
remain under `docs/research/` and `tools/`; they are excluded from the handoff.

The calendar draft uses Scenario Outline/Examples for individual requests and a
step table for one ordered collection result. Its literal values come from
original isolated reference calls and must pass independent semantic review before
promotion. The common Gherkin subset is intentional; the Perl runner trial still
must verify expansion, tables, tags, Unicode, escaping, and assertion failures.
