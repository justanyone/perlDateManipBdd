# perlDateManipBdd

An independent behavior-driven development (BDD) test suite project for Perl's
Date::Manip library, aiming to cover every function and method.

## Status

This project is in its initial setup stage. Upstream source discovery, licensing
research, and contributor guidance are in place. The test harness and scenarios
have not yet been implemented; there is no test command or coverage claim yet.

## Getting started

Clone the repository and enter the project directory:

```sh
git clone https://github.com/justanyone/perlDateManipBdd.git
cd perlDateManipBdd
```

## Project guidance

- [Plan for the portable BDD specification](docs/planning/README.md), including
  English feature examples, Perl API mappings, boundary analysis, and observed results
- [Upstream source map and complete file inventories](docs/upstream.md)
- [Licensing assessment and redistribution requirements](docs/licensing.md)
- [Repository instructions for Codex](AGENTS.md)
- [Third-party attribution and skill provenance](THIRD_PARTY_NOTICES.md)

Repository skills in `.agents/skills/` support BDD authoring and failure diagnosis.
Their entrypoints and references are loaded only when relevant to the task.

## License and attribution

Original project contributions are licensed under the [MIT License](LICENSE).
Date::Manip is by Sullivan Beck and is separately licensed under the same terms
as Perl 5 (Artistic 1.0 or GPL v1 or later). It is used as an external dependency;
its source is not relicensed MIT. Adapted agent skills retain Jesse Vincent's
[MIT notice](licenses/superpowers-MIT.txt).
