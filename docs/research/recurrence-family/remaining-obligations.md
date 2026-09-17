# Remaining recurrence obligations

This is the explicit incomplete-work register required by the completion gate. None of these rows is discharged by a sampled observation. The draft probe covers 36 repeatable cases after this batch; it does not claim any operation, grammar family, modifier family, or edge domain complete. The catalogue below lists every currently identified method partition (105), grammar/context inventory (7), and modifier family (20) from the recurrence contract. It also includes the newly observed bounded exception as a disputed compatibility reproducer, not a portable rule.

| Scope | ID | Remaining obligation |
| --- | --- | --- |
| recur.create | recur.create.01 | Empty new recurrence reports its kind and unset fields. |
| recur.create | recur.create.02 | Initialize with valid text, invalid text, and omitted text. |
| recur.create | recur.create.03 | Create from each supported receiver type. |
| recur.create | recur.create.04 | Change the new value and check the original value separately. |
| recur.create | recur.create.05 | Apply context overrides before parsing; examine whether subsequent context changes propagate. |
| recur.parse | recur.parse.01 | Frequency-only text for every syntax family. |
| recur.parse | recur.parse.02 | Serialized components with each trailing omission and each interior empty position. |
| recur.parse | recur.parse.03 | Date strings and typed dates in each date slot. |
| recur.parse | recur.parse.04 | Explicit arguments replace embedded anchor and bounds. |
| recur.parse | recur.parse.05 | Explicit modifiers replace or append embedded modifiers. |
| recur.parse | recur.parse.06 | Omit modifier argument entirely versus empty text versus absent value; do not shift generic named fields accidentally. |
| recur.parse | recur.parse.07 | Extra serialized fields and extra positional arguments. |
| recur.parse | recur.parse.08 | Invalid frequency, modifier, anchor, start, and end separately. |
| recur.parse | recur.parse.09 | Parse replaces existing recurrence state, including valid-to-invalid-to-valid sequences. |
| recur.parse | recur.parse.10 | RecurRange supplies defaults under a fixed clock. |
| recur.parse | recur.parse.11 | Before/after modifier bounds with an occurrence crossing each endpoint. |
| recur.set-frequency | recur.set-frequency.01 | Read before initialization. |
| recur.set-frequency | recur.set-frequency.02 | Read after numeric and written frequency parsing. |
| recur.set-frequency | recur.set-frequency.03 | Replace a valid frequency after setting anchor, bounds, modifiers, and moving the navigation cursor. |
| recur.set-frequency | recur.set-frequency.04 | Invalid replacement and subsequent recovery. |
| recur.set-frequency | recur.set-frequency.05 | Every frequency grammar partition. |
| recur.set-frequency | recur.set-frequency.06 | Omitted argument, absent argument and empty string are separate requests. |
| recur.set-start | recur.set-start.01 | Read an unset field. |
| recur.set-start | recur.set-start.02 | Set from date text and an equivalent date value. |
| recur.set-start | recur.set-start.03 | Omitted or absent argument requests read; characterize empty text independently. |
| recur.set-start | recur.set-start.04 | Invalid date and wrong value kind. |
| recur.set-start | recur.set-start.05 | Set before and after frequency replacement. |
| recur.set-start | recur.set-start.06 | Set while navigation has progressed and check subsequent navigation. |
| recur.set-start | recur.set-start.07 | Change zone or time in the supplied value and inspect stored result. |
| recur.set-start | recur.set-start.08 | Start equals end; start before end; start after end. |
| recur.set-start | recur.set-start.09 | Occurrence exactly on the stored endpoint and one second outside. |
| recur.set-end | recur.set-end.01 | Read an unset field. |
| recur.set-end | recur.set-end.02 | Set from date text and an equivalent date value. |
| recur.set-end | recur.set-end.03 | Omitted or absent argument requests read; characterize empty text independently. |
| recur.set-end | recur.set-end.04 | Invalid date and wrong value kind. |
| recur.set-end | recur.set-end.05 | Set before and after frequency replacement. |
| recur.set-end | recur.set-end.06 | Set while navigation has progressed and check subsequent navigation. |
| recur.set-end | recur.set-end.07 | Change zone or time in the supplied value and inspect stored result. |
| recur.set-end | recur.set-end.08 | Start equals end; start before end; start after end. |
| recur.set-end | recur.set-end.09 | Occurrence exactly on the stored endpoint and one second outside. |
| recur.set-base-date | recur.set-base-date.01 | Read an unset field. |
| recur.set-base-date | recur.set-base-date.02 | Set from date text and an equivalent date value. |
| recur.set-base-date | recur.set-base-date.03 | Omitted or absent argument requests read; characterize empty text independently. |
| recur.set-base-date | recur.set-base-date.04 | Invalid date and wrong value kind. |
| recur.set-base-date | recur.set-base-date.05 | Set before and after frequency replacement. |
| recur.set-base-date | recur.set-base-date.06 | Set while navigation has progressed and check subsequent navigation. |
| recur.set-base-date | recur.set-base-date.07 | Change zone or time in the supplied value and inspect stored result. |
| recur.set-base-date | recur.set-base-date.08 | Read requested and effective anchors before and after enumeration. |
| recur.set-base-date | recur.set-base-date.09 | A finite selection with no advancing interval ignores an explicit anchor. |
| recur.set-base-date | recur.set-base-date.10 | Anchors within the same selection period and anchors on adjacent period boundaries. |
| recur.set-modifiers | recur.set-modifiers.01 | Read no modifiers and multiple modifiers. |
| recur.set-modifiers | recur.set-modifiers.02 | Every modifier family and its parameter bounds. |
| recur.set-modifiers | recur.set-modifiers.03 | String input versus multiple arguments for the same modifiers. |
| recur.set-modifiers | recur.set-modifiers.04 | Lowercase, uppercase, and mixed case in both input forms. |
| recur.set-modifiers | recur.set-modifiers.05 | Replace existing modifiers; append with leading plus marker; append to empty list. |
| recur.set-modifiers | recur.set-modifiers.06 | Empty text, absent value, plus only, trailing comma, embedded spaces, and an unknown token. |
| recur.set-modifiers | recur.set-modifiers.07 | Ordering of a movement and a filter changes whether an occurrence survives. |
| recur.set-modifiers | recur.set-modifiers.08 | Rejected update leaves or changes old modifiers: inspect rather than assume. |
| recur.set-modifiers | recur.set-modifiers.09 | Update after nth/next/previous and check cursor/reset effects. |
| recur.occurrence-at-index | recur.occurrence-at-index.01 | Index zero, positive, and negative for interval-based recurrence. |
| recur.occurrence-at-index | recur.occurrence-at-index.02 | Finite selection indices just below zero and at/after its length. |
| recur.occurrence-at-index | recur.occurrence-at-index.03 | A selected calendar position that does not exist is absent without a generic parse failure. |
| recur.occurrence-at-index | recur.occurrence-at-index.04 | Mixed positive/negative ranges with variable occurrence counts. |
| recur.occurrence-at-index | recur.occurrence-at-index.05 | Multiple selection fields and their index ordering. |
| recur.occurrence-at-index | recur.occurrence-at-index.06 | Incomplete recurrence; invalid range; invalid anchor/start/end; existing error. |
| recur.occurrence-at-index | recur.occurrence-at-index.07 | No matching occurrence within a finite MaxRecurAttempts. |
| recur.occurrence-at-index | recur.occurrence-at-index.08 | Bounds and modifiers at the indexed event. |
| recur.occurrence-at-index | recur.occurrence-at-index.09 | Missing, empty, fractional, nonnumeric, and very large index inputs use separate bounded probes. |
| recur.occurrence-at-index | recur.occurrence-at-index.10 | Read object error state before/after a returned lookup error. |
| recur.next-occurrence | recur.next-occurrence.01 | First call on a bounded recurrence. |
| recur.next-occurrence | recur.next-occurrence.02 | First call on an anchored recurrence without bounds. |
| recur.next-occurrence | recur.next-occurrence.03 | Repeat calls across a missing calendar position. |
| recur.next-occurrence | recur.next-occurrence.04 | Alternate forward and backward calls. |
| recur.next-occurrence | recur.next-occurrence.05 | Finite selection exhaustion and a repeated call after exhaustion. |
| recur.next-occurrence | recur.next-occurrence.06 | Occurrence exactly at the start/end bound. |
| recur.next-occurrence | recur.next-occurrence.07 | Navigation after field updates, parse replacement, and indexed lookup. |
| recur.next-occurrence | recur.next-occurrence.08 | No-match filter, incomplete recurrence, reversed bounds, and MaxRecurAttempts limit. |
| recur.next-occurrence | recur.next-occurrence.09 | Modified events out of temporal order or multiple candidates moved to the same date. |
| recur.previous-occurrence | recur.previous-occurrence.01 | First call on a bounded recurrence. |
| recur.previous-occurrence | recur.previous-occurrence.02 | First call on an anchored recurrence without bounds. |
| recur.previous-occurrence | recur.previous-occurrence.03 | Repeat calls across a missing calendar position. |
| recur.previous-occurrence | recur.previous-occurrence.04 | Alternate forward and backward calls. |
| recur.previous-occurrence | recur.previous-occurrence.05 | Finite selection exhaustion and a repeated call after exhaustion. |
| recur.previous-occurrence | recur.previous-occurrence.06 | Occurrence exactly at the start/end bound. |
| recur.previous-occurrence | recur.previous-occurrence.07 | Navigation after field updates, parse replacement, and indexed lookup. |
| recur.previous-occurrence | recur.previous-occurrence.08 | No-match filter, incomplete recurrence, reversed bounds, and MaxRecurAttempts limit. |
| recur.previous-occurrence | recur.previous-occurrence.09 | Modified events out of temporal order or multiple candidates moved to the same date. |
| recur.list-occurrences | recur.list-occurrences.01 | Stored bounds only, supplied bounds only, or both. |
| recur.list-occurrences | recur.list-occurrences.02 | One temporary bound absent versus both absent. |
| recur.list-occurrences | recur.list-occurrences.03 | Temporary interval inside, overlapping, or wholly outside stored bounds. |
| recur.list-occurrences | recur.list-occurrences.04 | Exact start/end matches and reversed range. |
| recur.list-occurrences | recur.list-occurrences.05 | Temporary limits do not persist into a second query. |
| recur.list-occurrences | recur.list-occurrences.06 | Empty finite result versus invalid recurrence both have empty list: inspect error channel. |
| recur.list-occurrences | recur.list-occurrences.07 | Original versus modified endpoint comparisons. |
| recur.list-occurrences | recur.list-occurrences.08 | Duplicate modified dates and modified dates whose order changes. |
| recur.list-occurrences | recur.list-occurrences.09 | Enumeration after cursor movement and cursor movement after enumeration. |
| recur.list-occurrences | recur.list-occurrences.10 | Finite maximum date range and finite process budget for all probes. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.01 | Description mode and collection mode for every supported frequency family. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.02 | Each missing/empty/absent override slot. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.03 | Embedded versus separately supplied bounds and anchor. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.04 | Modifier replacement versus append. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.05 | Invalid frequency, flags, and dates; insufficient range or anchor. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.06 | Exact endpoint occurrence under DM5 and DM6 independently. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.07 | Multiple occurrences, no occurrence, duplicate/order behavior. |
| recur.parse-and-enumerate | recur.parse-and-enumerate.08 | Equivalent OO and functional routes only where their declared profiles agree. |
| grammar/context | REC-GRAMMAR-SPLIT | Probe every split with original valid and invalid inputs; distinguish advancing periods from selected calendar fields. |
| grammar/context | REC-GRAMMAR-YMWD | Discharge each structural combination as supported with its field meaning or observed rejection; do not copy the upstream example table. |
| grammar/context | REC-GRAMMAR-SELECT | Cross meaningful forms with month/week/day/hour/minute/second fields; verify valid domains and cartesian combinations. |
| grammar/context | REC-GRAMMAR-DEFAULTS | Determine implicit period and calendar-field meanings using a fixed clock and original probes. |
| grammar/context | REC-GRAMMAR-WRITTEN | Probe each form with and without a year, all languages through independent fixtures, ordinal bounds 1 and 31 plus adjacent invalid values. |
| grammar/context | REC-GRAMMAR-INVALID | Capture rejection, diagnostics and post-failure state under finite process budgets. |
| grammar/context | REC-CONTEXT | Record each independent setting and material interactions; all-range tests must be deliberately bounded. |
| modifier family | PDn | previous chosen weekday, strict; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | PTn | previous chosen weekday, inclusive; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | NDn | next chosen weekday, strict; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | NTn | next chosen weekday, inclusive; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | WDn | chosen weekday in the current week; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | FDn | advance a number of calendar days; parameter: decimal nonnegative count; bounds and zero pending observation |
| modifier family | BDn | retreat a number of calendar days; parameter: decimal nonnegative count; bounds and zero pending observation |
| modifier family | FWn | advance working dates; parameter: decimal nonnegative count; bounds and zero pending observation |
| modifier family | BWn | retreat working dates; parameter: decimal nonnegative count; bounds and zero pending observation |
| modifier family | CWD | nearest different working date with configured tie direction; parameter: none |
| modifier family | CWN | nearest different working date preferring forward ties; parameter: none |
| modifier family | CWP | nearest different working date preferring backward ties; parameter: none |
| modifier family | NWD | working date on or after the candidate; parameter: none |
| modifier family | PWD | working date on or before the candidate; parameter: none |
| modifier family | DWD | nearest working date including the candidate with configured tie direction; parameter: none |
| modifier family | IBD | keep only working dates; parameter: none |
| modifier family | NBD | keep only nonworking dates; parameter: none |
| modifier family | IWn | keep only a selected weekday; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | NWn | discard a selected weekday; parameter: weekday 1..7; exact numbering pending observation |
| modifier family | EASTER | select Easter in the candidate year; parameter: none |

