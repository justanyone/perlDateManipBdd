# Zone, business, holiday, event, and legacy contract catalogue

This research record covers the 24 matching generic operations in the pinned
Date::Manip 7.00 contract map. It is source and documentation accounting only:
there are no probes, literal expected values, features, or harness code.

`zones-business.json` is the normative structured record. It preserves every
mapped binding and gives each operation portable inputs, observable outputs,
and unobserved normal, boundary, invalid, state, and context partitions.

The time-zone receiver accepts canonical zone names/aliases, abbreviations,
offset spellings, DST preferences (`std`, `stdonly`, `dst`, `dstonly`), and
six-field civil values in the combinations documented by its resolver. Its
conversion methods have documented error codes 0 through 4; the customization
methods have their own documented codes. Zone discovery and finite zone data
are environment/data-version dependent, so observations must use an isolated
profile that names the bundled tzdata/tzcode versions.

Business operations depend on an explicit workweek, work-hour, holiday, and
TomorrowFirst configuration. A holiday is an all-day business exclusion; it
may have no label or multiple ordered labels. The documented holiday grammar
is a full date, a yearless append-year date, or a recurrence. Events are
independent of business calculations and have the finite top-level grammar
recorded in JSON: Date, YMD, YM, Recur, and the five documented two-part
forms. Date, recurrence, and delta productions themselves remain assigned to
their respective contract families.

`legacy.erase-holidays` is retained because the map has a DM5 binding, but it
is unexported compatibility surface and has no portable-feature disposition.

All 24 operations and all partitions are `unobserved`. Before features are
authored, create original isolated probes for the listed partitions, run each
twice in fresh processes, and record profile, raw return/warning/error channels,
state changes, and independently reviewed literal outcomes.
