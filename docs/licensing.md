# Licensing decision

Reviewed 2026-09-17. This is a practical reading of the cited licenses, not a legal
opinion from counsel. It assumes independently authored tests using an unmodified,
separately installed Date::Manip dependency.

## Decision: keep MIT for this project

An original BDD suite can test every Date::Manip function and use MIT for its own
code and prose. Calling the library does not grant ownership of its implementation;
nor does choosing its Artistic licensing option require MIT tests to become GPL.
The recommended structure is an independent test project, not a relabeled copy
of Date::Manip. No replacement for the repository's existing MIT license is needed.

This conclusion is an interpretation of the grants below, not an upstream statement
specifically approving this project. It does not rely on the general statement that
all Perl modules can be used without conditions, or solely on Perl interpreter
exceptions to GPL linking rules.

## Evidence and upstream license

The [upstream LICENSE at the inspected revision](https://github.com/SBECK-github/Date-Manip/blob/4b9b9d5c802750f0fca04f9168c65d9dc4562d65/LICENSE)
permits redistribution and modification on Perl's terms. The downloaded 7.00
release has the same grant. Its `META.json` declares `perl_5`.
[CPAN's metadata specification](https://metacpan.org/pod/CPAN::Meta::Spec#license)
defines that as GPL version 1 or later, or Artistic License version 1.
[Perl's licensing page](https://dev.perl.org/licenses/) confirms the alternatives.
The corresponding SPDX expression is `Artistic-1.0-Perl OR GPL-1.0-or-later`:
these are alternatives, not simultaneous obligations. Artistic 2.0 is not the
license evidenced here.

The distribution's [README.first](https://github.com/SBECK-github/Date-Manip/blob/4b9b9d5c802750f0fca04f9168c65d9dc4562d65/README.first)
credits Sullivan Beck, copyright 1995–2026. Individual files have varying years;
preserve their actual notices rather than replacing them with a generic range.

## Obligations by distribution choice

| Choice | Required treatment |
| --- | --- |
| Original tests using a separately installed library | Keep MIT for original work. The dependency retains its license. Our attribution is useful provenance, not a claim that merely calling an API requires a notice in every test. |
| Copy upstream files, test fixtures, examples, or substantial documentation | Retain their upstream licensing and file-specific notices. Attribution alone is insufficient to relicense them MIT. Record paths, origin revision, and applicable terms. |
| Distribute a modified upstream library | Fulfill the chosen upstream license's modification/distribution conditions in addition to marking our original files MIT. |
| Ship a bundle, executable, or container containing the dependency | Review the included components and the chosen license's distribution conditions; a root MIT file cannot replace those terms. |

Under [Artistic 1.0](https://dev.perl.org/licenses/artistic.html), section 1 requires
original copyright notices and disclaimers on verbatim source copies. Section 3
requires prominent per-file descriptions and dates of changes and one of its
alternatives; publishing modifications freely is the practical open-source route.
Section 4 gives alternatives for executable distribution, including accompanying
machine-readable source. Section 5 permits aggregation but bars presenting the
package as your own; its charging restrictions also matter if distributing the
package commercially. Section 9 forbids using the copyright holder's name for
endorsement without written permission. Preserve the full applicable license and
disclaimers with any vendored source as repository policy.

If instead choosing [GPL v1](https://dev.perl.org/licenses/gpl1.html) or a permitted
later version, comply with that version's notice, modification, corresponding-source,
and whole-derived-work licensing requirements. A GPL-covered derivative cannot
simply be distributed MIT-only. Keeping our original tests MIT and choosing the
Artistic option for the dependency avoids needing that alternative for this design.

For an actual fork, keep upstream files under their existing dual terms and clearly
mark original MIT additions. If a single uniform license is essential for a combined
derivative, the evidenced upstream dual license is a defensible option; it is not
equivalent to MIT. Do not change upstream licensing without permission.

## Notices maintained here

[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) credits Date::Manip and identifies
the imported skill material. The library itself is not vendored. Therefore this
repository does not pretend that including an upstream license text would relicense
or constitute delivery of its source.

The adapted skills are based on MIT-licensed work by Jesse Vincent. Their copyright
and complete permission/disclaimer text are retained in
[licenses/superpowers-MIT.txt](../licenses/superpowers-MIT.txt). MIT requires this
notice with copies or substantial portions. Our root LICENSE covers original
contributions and does not erase that notice.

Revisit this assessment when copying third-party material, changing dependencies,
modifying the library, or changing the distribution model.
