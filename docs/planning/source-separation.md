# Source separation for a later implementation

The user wants an independent implementation without importing Date::Manip/Perl
source. This research has inspected Date::Manip source, so it is **not** a claim
that the researchers or this conversation are source-unexposed. Keeping files in
different folders alone does not establish a legally certified clean-room process.

## Research-side rules

- Read source to discover interfaces, branches, boundaries and side effects. Record
  API identifiers and locations in the research inventory, not copied source bodies.
- Write original inputs, descriptions and feature wording. Do not translate source
  algorithms into pseudocode or paraphrase upstream tests line by line.
- Determine externally observable results through public calls. Store small original
  input/output observations, with version and context, and review their meaning.
- Keep upstream checkouts, POD, tests, generated language/zone modules, and downloaded
  runner source outside the repository. Do not import their fixture collections.
- Keep future original Perl adapters and source mappings on the research side.
  An adapter is restricted to invoking public APIs and representing results; it
  must not copy the algorithm under test into the specification.
- Review language vocabularies, calendars and timezone data separately. Reimplementing
  behavior does not grant a right to copy entire tables or generated modules. Prefer
  separately sourced, license-reviewed public standards/data and independent fixtures.

## Handoff allowlist

Export only reviewed original `.feature` files, the portable glossary and protocol,
necessary small reviewed expected-value fixtures, a profile/version manifest, and
our MIT notice. Include factual dependency/reference attribution without copying
upstream expression. Keep a manifest and hashes of exactly what was exported.

Exclude this conversation, research notes, Perl mappings, source-line inventory,
upstream prose/code/tests/data, probe programs and Perl step definitions. The raw
observation records contain Perl names, so export only reviewed normalized facts.
Give the implementation author or agent a fresh workspace and fresh context with
the allowlisted package. New questions are answered with new behavioral scenarios,
not by forwarding upstream algorithms. Review the exported text for source-derived
expression before release.

Use an independent, source-unexposed implementation author/session if stronger
separation is needed. Do not claim a reset can make this already-exposed session
independent, or that using a new programming language alone avoids derivation.

## Licensing interpretation

In the US, [17 USC 102(b)](https://www.copyright.gov/title17/92chap1.html#102)
distinguishes ideas, procedures, systems and methods of operation from protected
expression. That supports the intended behavior-focused approach, but does not
resolve every API, compilation, contract, patent or jurisdictional question.
Original wording, independent code, and provenance are practical safeguards, not
a guarantee of legal status. Obtain counsel's review if formal clean-room assurance
is needed. Preserve the existing [licensing assessment](../licensing.md).

The MIT goal applies to our original specification and implementation. It does not
relicense copied material. The proposed Perl runner and Date::Manip remain external
dependencies under their own terms, and are not part of the implementation handoff.
