# Complete valid Base week-rule matrix

This batch observes the public `Date::Manip::Base::week_of_year` binding of
`calendar.week-number`. It never calls `_week_of_year` or any other private
helper. The portable feature records only civil inputs, configured week rules,
and literal results. Perl list and array-reference carriers, module paths, and
other binding provenance remain in the reference-only observation.

`matrix-manifest.json` contains the whole documented valid configuration
domain: `FirstDay` 1 through 7 crossed with `Week1ofYear` `jan1` through
`jan7`, `dow1` through `dow7`, and `firstday` (105 settings). Python's standard
`calendar` module selected the earliest years in 2000..2399 for all fourteen
leap/nonleap × January-1-weekday types. Each setting observes Jan 1..7 followed
by Dec 25..31 for every selected year: 20,580 forward week-year/week-number
pairs in total. Seven clearly named settings also observe inverse weeks 1 and 2
for every type (196 public inverse results); those are selected inverse boundary
cases, not a claim that every inverse week number has been exhaustively tested.

The supplied independent review uses `datetime.date` and documented week-rule
definitions, not Date::Manip, to calculate every stored pair and inverse first
date. The draft's compact matrices use the date and year order stated at the
top of the feature, so every literal position is determinate.

Partition coverage in this bounded batch is:

- `calendar.week-number.p1`: selected valid inverse week 1 and week 2 results.
- `calendar.week-number.p2`: every requested calendar-year edge date.
- `calendar.week-number.p3`: all 105 valid Base week-rule settings.
- `calendar.week-number.p4`: not covered; invalid rules, malformed date lists,
  invalid week numbers, and absent fields need their own native-channel batch.
- `calendar.week-number.p5`: not covered; Date, DM6, and DM5 legacy-number
  behavior is intentionally separate from Base's week-year pair.

Regenerate the reference record and verify it:

```sh
python3 tools/probes/week-rules-family/make_manifest.py
python3 tools/probes/week-rules-family/run.py > /tmp/week-rules-candidate.json
python3 tools/probes/week-rules-family/review.py /tmp/week-rules-candidate.json
python3 tools/probes/week-rules-family/make_feature.py /tmp/week-rules-candidate.json
cmp /tmp/week-rules-candidate.json docs/research/week-rules-family/observations.json
```

The runner uses two fresh temporary working directories and a clean environment
with only `/usr/bin:/bin`, C UTF-8 locale variables, `TZ=Etc/UTC`, and the
pinned Date-Manip 7.00 library. It rejects process stderr, compares native JSON
bytes between attempts, records exact runtime and all loaded Date::Manip hashes.
The reviewer also verifies every artifact hash in the candidate.


Coordinator review reproduced the original native payload, then made all fourteen
input years explicit in the feature Background and defined each rule in English.
The reviewer now independently asserts the full 7-by-15 configuration set, all
fourteen leap/January-weekday types, and the exact fourteen requested month/day
pairs. Every expected forward/inverse value is checked against independent
standard-library calendar arithmetic and its own feature row. Research mapping
records public construction/configuration and both native return carriers; the
inverse matrix's leading requested-week label is not an extra returned field.
The pinned parser accepts112 expanded scenarios. Broader week-number partition
resolution remains open, including Date/functional behavior and invalid arguments.
