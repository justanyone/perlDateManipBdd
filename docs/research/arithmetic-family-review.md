# Arithmetic-family independent review

Reviewed 2026-09-17 against the 107-case observation record, all four draft
features, the three case catalogues, and both probe programs. This review is
read-only except for this file. `python3 tools/review/feature_structure.py
spec/drafts/arithmetic` reported zero structural errors; that check does not
establish input-to-probe correspondence or semantic correctness.

## High-severity findings

1. The probe does not isolate its requested backend. It unconditionally loads
   `Date`, `Delta`, `DM6`, and `DM5` at
   [arithmetic-family.pl](/home/kevin/my_code/perlDateManipBdd/tools/probes/arithmetic-family/arithmetic-family.pl:24), even for an OO-only case. This allows import/setup effects and DM5 deprecation diagnostics to influence a nominally OO or DM6 process, defeating the separate-profile claim in the README. Split backend setup by `case.profile`; load just Date/Delta for OO, DM6 for DM6, and DM5 for DM5. Assert the selected backend/distribution and record its configuration result in the same branch.

2. OO configuration diagnostics are discarded. The `Date->config` call at
   [arithmetic-family.pl](/home/kevin/my_code/perlDateManipBdd/tools/probes/arithmetic-family/arithmetic-family.pl:27) has no captured return/error state, whereas functional `Date_Init` returns are likewise not recorded at lines 40–42. The README says initialization diagnostics are separated, but the evidence contains warning buckets only; the configuration result that could make all later values invalid is absent. Record `configuration_return`, receiver `err`, and timezone/profile facts immediately after each setup operation; stop or classify a case as setup-failed when configuration fails.

3. `oo_calc` silently drops the left operand's parse status. The probe assigns
   `$ls` at [arithmetic-family.pl](/home/kevin/my_code/perlDateManipBdd/tools/probes/arithmetic-family/arithmetic-family.pl:51) but returns only `right_status`. This makes invalid-left and DST-gap evidence ambiguous: a returned object/value may be interpreted without knowing whether the left operand was valid. Return both parse statuses, both pre-calculation snapshots, and both post-calculation snapshots. Add invalid-left, invalid-right, and valid-left/invalid-right cases for every OO operand pairing before presenting invalid behavior as covered.

4. The grammar feature freezes an ambiguous representation as “fields.” For
   `-1 year 2 days`, the raw observation has `value_list` day `-2` but
   `value_scalar` `-1:0:0:2:0:0:0`; the feature asserts the latter at
   [delta-grammar-and-format-matrix.feature](/home/kevin/my_code/perlDateManipBdd/spec/drafts/arithmetic/delta-grammar-and-format-matrix.feature:30). This is not a harmless formatting distinction: the feature names a field record, which should correspond to the list carrier. Mark this case disputed and expose both carriers, or select one explicit portable serialization only after independent semantic review. Do the same carrier check for the normalized signed compact example at line 26.

5. The 28 range rows do not have matching one-pattern observations. The feature
   invokes a single pattern in each example row at
   [delta-grammar-and-format-matrix.feature](/home/kevin/my_code/perlDateManipBdd/spec/drafts/arithmetic/delta-grammar-and-format-matrix.feature:46), but `DELTA-FORMAT-ALL-RANGES` in
   [extended-cases.json](/home/kevin/my_code/perlDateManipBdd/docs/research/arithmetic-family/extended-cases.json:26) made one many-pattern call. `Delta->printf` has context/arity behavior, so the bulk result does not establish each single-pattern request. Either make the feature an exact ordered bulk request, or add 28 single-pattern observations and map each row to its case.

## Medium-severity findings

6. Several feature scenarios have no stable evidence-case mapping. Standalone
   tags such as `@ARITH-DST-GAP` at
   [arithmetic-dst-business-edges.feature](/home/kevin/my_code/perlDateManipBdd/spec/drafts/arithmetic/arithmetic-dst-business-edges.feature:19) do not equal the evidence ID `ARITH-DST-SPRING-AT-GAP`; `@ARITH-DST-EDGES` at line 6 represents five IDs. There is no feature-map artifact. Add a checked map from feature filename, scenario/outline row, exact operands/options, and expected carrier to case ID(s), including the one-to-many DST and business scenarios.

7. The feature suite omits observed error and unsupported routes despite the
   stated definition of done. Examples present in `cases.json` but absent from
   feature drafts include `ARITH-DIFF-SHORT`, `ARITH-DAYS-NONNUMERIC`,
   `ARITH-DELTA-BAD-FIELDS`, `ARITH-TIME-BAD-SHAPE`, `ARITH-COMBINE-BAD`,
   `DELTA-CREATE-BAD`, `DELTA-SET-WHOLE-BUSINESS`, `DELTA-PRINT-BAD`,
   `DELTA-CONVERT-BAD`, `DELTA-CMP-MIXED-MODE`, and `ARITH-DM6-INVALID`.
   The failure grammar rows are included, but no feature labels them observed
   compatibility behavior rather than portable grammar. Add explicit draft
   scenarios with exact status/error/state, or retain them as named unresolved
   dispositions in a coverage matrix. Do not describe the current slice as
   every function/usage/identifiable edge.

8. The README overstates diagnostic separation and undercounts provenance
   requirements. Its claim at
   [README.md](/home/kevin/my_code/perlDateManipBdd/docs/research/arithmetic-family/README.md:35) that setup diagnostics are separately recorded is incomplete because configuration returns/errors and selected-backend identity are absent. Its “all 16 contract operation IDs” language at line 27 is only a linkage count, not a complete-usage statement; retain the later caveat but add a prominent statement that 107 repeated outputs are neither sensitivity evidence nor semantic approval.

9. Feature mode prose does not always expose the actual request option. In
   [arithmetic-and-delta.feature](/home/kevin/my_code/perlDateManipBdd/spec/drafts/arithmetic/arithmetic-and-delta.feature:79), “mode/type/normalization” is supplied for every row, but the corresponding `delta_parse` requests often omit `opts` entirely and rely on backend defaults. Either write “with defaults” for omitted options and use explicit values only where the case sends them, or change cases to pass the stated option record. This matters for compact inputs because observed stored types vary by field count.

## Required follow-up checks

- Re-run all cases after backend-specific setup and compare raw return, warning,
  exception, configuration, and operand-state fields separately.
- Add a mapping validator that fails on an unmapped feature row, mismatched
  operand/date/mode/options, or a feature single-pattern row backed only by a
  many-pattern observation.
- Independently review the signed-field/list-versus-scalar discrepancy before
  promoting any grammar row from repeatable to reviewed.
- Keep unsupported grammar and invalid-object behavior explicitly classified as
  observed compatibility or disputed behavior until a portable decision exists.
