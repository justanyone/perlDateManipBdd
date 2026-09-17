# Date parsing research batch

This original corpus samples all 42 enumerated complete/truncated ISO date
spellings, 35 numeric/separated/joined common-date spellings, and four month-year
spellings. Month-year inputs run with default, first, and last settings. Eight
additional inputs exercise empty text, civil invalidity, leftover text, and mixed
dashes. Each request runs in each of three independently configured processes:
OO, DM6 and DM5. The corpus has 291 binding cases, each run twice.

The portable profile names `current-value`, `current-text`, and `legacy-text`
map respectively to Date::Manip::Date::parse, DM6::ParseDateString and
DM5::ParseDateString. The exact context is the corresponding entry in
`docs/automation/reference-profiles.json`; case overrides are applied afterward.
Month-year `default` means no override: the current profiles use their disabled
month-year option, while legacy parsing has its own month-year behavior and does
not support that option. No grammar-disable options are supplied in this batch.

Run research and review separately:

```sh
python3 tools/probes/parsing-family/run.py > /tmp/parsing-observations.json
python3 tools/review/parsing_literals.py
```

The research command does not replace committed evidence or expectations. Review
changes explicitly before replacing observations. The review command uses saved
evidence only. It checks provenance hashes, 283 manually assigned candidate
literals, failure/result distinction, actual input text, diagnostics, and civil
date validity. Independent standard-library checks establish the ordinal and ISO
week facts used by the inputs. They do not establish every grammar rule.

Eight legacy first/last overrides throw configuration exceptions before a parser
call. They are recorded separately and do not count as rejected date inputs.
Legacy deprecation warnings remain in the raw evidence. No upstream tests,
examples, vocabulary datasets, or implementation were copied into this corpus.

## Results needing semantic disposition

- Default current parsing treats `Feb2040` as February 20, 2040, while the legacy
  parser treats it as February 1, 2040. The disabled month-year option does not
  prevent another accepted grammar from matching that text.
- Legacy `Feb2940` produces February 1, 2940; current parsing produces February
  29, 2040. These remain separately tagged compatibility candidates.
- The inventoried joined `YY MMMD` form, instantiated as `40 Feb29`, is rejected
  by both current routes. The input and grammar obligation remain visible for
  investigation; rejection is not silently declared the intended specification.
- Two standalone digits resolve as a century in the current profiles, but as a
  two-digit year in the legacy profile. Other truncated forms have distinct
  legacy acceptance results. Mixed dashed ISO input also differs by backend.

## Remaining coverage

These are drafts, not an approved specification or executed BDD suite. Links to
syntax and contract partitions identify sampled obligations, not full discharge.
Remaining date-parsing work includes other/special/relative productions; time
and combined grammars; all parser gates and interactions; pattern parsing and
captures; token-prefix carriers/mutation; date-only/time-only receiver state;
all languages and encodings; year-pivot and alternate separator/order boundaries;
ambiguous zones and DST interactions; absent arguments; and detailed public
status/error normalization. The eight configuration exceptions also need portable
configuration-profile disposition before any feature promotion.
