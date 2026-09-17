# Third-party notices

## Date::Manip — external dependency and subject of testing

Author: Sullivan Beck. Distribution notice: Copyright (c) 1995–2026 Sullivan Beck.
All rights reserved. Individual source-file copyright years vary.

Source: <https://github.com/SBECK-github/Date-Manip>

License: the same terms as Perl 5, with the alternatives
`Artistic-1.0-Perl OR GPL-1.0-or-later`. The project intends to use the Artistic
option for its dependency use. Date::Manip remains under its upstream license;
this project's MIT license does not apply to that library.

No Date::Manip implementation or upstream tests are bundled here. Source locations,
revision identifiers, and file-path inventories are recorded in docs/upstream.md.
This is an independent project and does not claim Sullivan Beck's endorsement.
See docs/licensing.md before importing upstream material.

## Superpowers — adapted agent skills

Copyright (c) 2025 Jesse Vincent. Licensed under MIT. The complete original notice
is in [licenses/superpowers-MIT.txt](licenses/superpowers-MIT.txt).

Source: <https://github.com/obra/superpowers>

Pinned revision: `b36e0829c6d0140e93cfef2ca599b1b07d4a7797`.
Retrieved and adapted on 2026-09-17.

| Local file | Upstream source path at that revision | Treatment |
| --- | --- | --- |
| `.agents/skills/date-manip-bdd/SKILL.md` | `skills/test-driven-development/SKILL.md` and `skills/test-driven-development/writing-good-tests.md` | Condensed and adapted for a Perl library characterization suite |
| `.agents/skills/date-manip-debugging/SKILL.md` | `skills/systematic-debugging/SKILL.md` | Condensed and adapted for Date::Manip failures |
| `.agents/skills/date-manip-debugging/references/verification-before-completion.md` | `skills/verification-before-completion/SKILL.md` | Verbatim copy, loaded as an optional reference |

Adaptations replace JavaScript examples and generic workflow mandates with local
testing instructions, remove dependencies on uninstalled skills, and explicitly
allow initially passing characterization tests. No upstream plugin, hooks,
installer, or executable scripts were installed.

## Devel::Cover — external coverage tool

Devel-Cover1.52 is copyright(c)2026 Paul Johnson, licensed under the same
terms as Perl5: `Artistic-1.0-Perl OR GPL-1.0-or-later`, as stated in the
release's `LICENCE` and `META.json`. The project uses it as a separately
installed development dependency; its implementation is not bundled here and
is not relicensed under this project's MIT license.

Source: <https://github.com/pjcj/Devel--Cover>

Pinned archive SHA-256:
`9d90b44ab602ca373fa221255708de4d19df86026f4d7110bef608846eed44fb`.
See [coverage setup](docs/research/public-call-coverage/README.md) for local
installation, version assertions, and the limits of the instrumentation pilot.
