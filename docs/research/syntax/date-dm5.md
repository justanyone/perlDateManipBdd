# DM5 date syntax comparison

This is a source/POD gate for the bundled Date::Manip 5.66 compatibility backend. It compares every rendering, POSIX, explicit-pattern, and text-grammar row in [date.json](date.json). It records no runtime outcomes.

[date-dm5.json](date-dm5.json) contains the finite row mapping: 35 default-render rows, 13 POSIX rows, one explicit-pattern row, and 20 text-grammar rows. Each maps to `supported`, `different`, or `unsupported`; no blanket DM5-unknown category remains.

DM5 `UnixDate` supports the legacy one-character rendering alphabet shared with DM6 except `%N`. It has no renderer extended `%<...>` grammar. It also has no `Use_POSIX_Printf` setting or POSIX branch, so the 12 DM6 POSIX semantic overrides are unavailable. Its unknown one-character renderer fallback emits the character after percent, which makes `%N` emit `N` and starts `%<...>` by emitting `<`.

DM5 has no public explicit-pattern parser: its exported facade includes `ParseDate`, `ParseDateString`, and `UnixDate`, but not `ParseDateFormat`. The 52 DM6 pattern directives and their regular-expression/capture behavior are therefore explicitly unsupported in the DM5 profile.

The DM5 date parser is public but materially different. Its POD documents compact/dashed ISO combinations with flexible dash treatment, an older collection of partial ISO forms, flexible non-ISO separators, and its own relative forms. It does not define the DM6 finite ISO omission table, second-resolution offsets, truncated ISO-time forms, or configuration-gated `Format_MMMYYYY` behavior. The JSON names each corresponding DM6 row, its DM5 candidate, the status, and source coordinates.

The audit also identifies two formatting differences worth probing: DM5 `%C`/`%u` compose an offset where DM6 default composition uses a zone abbreviation, and their `%l` six-month windows have different endpoint inclusion. These are source findings pending controlled observations.
