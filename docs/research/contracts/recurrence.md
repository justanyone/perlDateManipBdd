# Recurrence contract research

[recurrence.json](recurrence.json) accounts for all 12 `recur.*` operation IDs,
105 method-level partition obligations, 20 modifier families, and seven grammar
and context inventories. These are original research notes for Date-Manip 7.00,
not frozen expected values or executable features.

The portable model needs separate operations for constructing a recurrence,
reading/changing its fields, obtaining an indexed occurrence, moving its navigation
position, and enumerating a finite range. A missing indexed calendar position is
different from a parse error. Advancing navigation may skip that position. A
request for a recurrence description is different from an occurrence-list request,
even when a functional binding chooses between them through Perl call context.

Bounds, requested/effective anchors, modifier order, and navigation state are
observable. Tests must preserve these distinctions without describing internal
algorithms. The method records link each generic operation to its public binding;
source references remain on this research side.

## Questions that require observation

- The modifier documentation's weekday numbering disagrees with its examples.
  Test every weekday using independently checked calendar facts.
- The documentation describes modifier case sensitivity, while source inspection
  suggests that a single string and multiple arguments receive different handling.
  Exercise those call shapes separately before choosing portable normalization.
- DM5 documents an exclusive upper recurrence bound, whereas the OO documentation
  describes inclusive bounds. Compare exact-endpoint probes in separate processes.
- Distinguish temporary enumeration limits from stored limits, and examine the
  stored state after a query. Do not assume that the word “override” means expansion
  beyond stored bounds.
- Probe duplicate results, modifier-induced ordering changes, mixed-direction
  navigation, error recovery, and cursor behavior after field updates.

These are pending questions, not accepted compatibility rules. Each needs a small
original reproducer, captured return/error/state channels, repeatability evidence,
and semantic review. Potentially unbounded recurrences require process time limits
and explicit enumeration bounds. A timeout remains an unresolved observation.

The structural grammar grid records zero/nonzero calendar-field combinations and
separator positions instead of copying the upstream table of examples. Each
combination must acquire an accepted meaning or observed rejection. Counting the
grid does not discharge it. Likewise, DM5 syntax and modifier support must be
characterized independently rather than inferred from the object interface.
