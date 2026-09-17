@draft @date-set @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve Perl carriers and diagnostics for date field replacement
  These scenarios retain the native public-binding observations that support the
  portable date replacement outcomes. They are not requirements for another language.

  Background:
    Given the pinned Date-Manip 7.00 Perl binding with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And the English ASCII non-US profile with fixed clock "2040-02-28 10:20:30 Etc/UTC"
    And every source case uses its exact request from the portable feature and a fresh receiver

  @DSET-BIND-EXCEPTIONS @observed-compatibility @disputed
  Scenario: Perl exposes the exact runtime exception prefix for each interrupted request
    When the Perl binding executes each mapped source request
    Then the call is interrupted without returning a status and its error before and after is empty
    And it emits no warning
    And its native value observers run in scalar, list, local, and GMT order after the interrupted mutation
    And scalar, local, and GMT return defined empty text, list returns zero values, and the first scalar read sets "[value] Object does not contain a date"
    And the exact binding outcomes are:
      | binding case | source case | initial receiver | exact request | exception prefix |
      | DSET-BIND-EXCEPTION-ZONE-003-OFFSET-TEXT | DSET-ZONE-003-OFFSET-TEXT | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "+05:30"] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZONE-004-OFFSET-LIST | DSET-ZONE-004-OFFSET-LIST | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [list [number 5, number 30, number 0]] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZONE-009-INVALID-ZONE | DSET-ZONE-009-INVALID-ZONE | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "Not/A_Zone"] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZONE-020-TWO-AS-SINGLE-ARG | DSET-ZONE-020-TWO-AS-SINGLE-ARG | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zone"; arguments [number 2] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZDATE-003-OFFSET-LIST | DSET-ZDATE-003-OFFSET-LIST | unset | selector text "zdate"; arguments [list [number -5, number -30, number 0], list [number 2041, number 1, number 2, number 3, number 4, number 5]] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZDATE-010-INVALID-ZONE | DSET-ZDATE-010-INVALID-ZONE | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [text "Not/A_Zone", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-ZDATE-015-OFFSET-TEXT | DSET-ZDATE-015-OFFSET-TEXT | unset | selector text "zdate"; arguments [text "-05:30", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | Can't locate object method \"__zone\" via package \"Date::Manip::Base\" |
      | DSET-BIND-EXCEPTION-DATE-011-SCALAR | DSET-DATE-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [text "2041010203:04:05"] | Can't use string (\"2041010203:04:05\") as an ARRAY ref while \"strict refs\" in use |
      | DSET-BIND-EXCEPTION-TIME-011-SCALAR | DSET-TIME-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [text "03:04:05"] | Can't use string (\"03:04:05\") as an ARRAY ref while \"strict refs\" in use |

  @DSET-BIND-MALFORMED-CARRIERS @observed-compatibility @disputed
  Scenario: Perl preserves native malformed scalar and list carriers after accepted field changes
    When the Perl binding executes each mapped source request
    Then every native status is numeric 0 and every call and observer error is empty
    And the exact carrier outcomes are:
      | binding case | source case | native scalar | native list fields | warning count |
      | DSET-BIND-CARRIER-FIELD-008-MONTH-ZERO | DSET-FIELD-008-MONTH-ZERO | 2040002916:05:09 | 2040, 0, 29, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-009-DAY-ZERO | DSET-FIELD-009-DAY-ZERO | 2040020016:05:09 | 2040, 2, 0, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-010-MONTH-13 | DSET-FIELD-010-MONTH-13 | 2040132916:05:09 | 2040, 13, 29, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-011-DAY-31-COMPAT | DSET-FIELD-011-DAY-31-COMPAT | 2040023116:05:09 | 2040, 2, 31, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-012-DAY-32 | DSET-FIELD-012-DAY-32 | 2040023216:05:09 | 2040, 2, 32, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-013-HOUR-24 | DSET-FIELD-013-HOUR-24 | 2040022924:05:09 | 2040, 2, 29, 24, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-014-MINUTE-60 | DSET-FIELD-014-MINUTE-60 | 2040022916:60:09 | 2040, 2, 29, 16, 60, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-015-SECOND-60 | DSET-FIELD-015-SECOND-60 | 2040022916:05:60 | 2040, 2, 29, 16, 5, 60 | 0 |
      | DSET-BIND-CARRIER-FIELD-016-NONNUMERIC | DSET-FIELD-016-NONNUMERIC | 204002nope16:05:09 | 2040, 2, nope, 16, 5, 9 | 2 |
      | DSET-BIND-CARRIER-FIELD-017-UNDEFINED | DSET-FIELD-017-UNDEFINED | 20400216:05:09 | 2040, 2, undefined, 16, 5, 9 | 10 |
      | DSET-BIND-CARRIER-FIELD-033-ISDST-TWO | DSET-FIELD-033-ISDST-TWO | 2040020116:05:09 | 2040, 2, 1, 16, 5, 9 | 0 |
      | DSET-BIND-CARRIER-FIELD-034-NEGATIVE-DAY | DSET-FIELD-034-NEGATIVE-DAY | 204002-116:05:09 | 2040, 2, -1, 16, 5, 9 | 0 |

  @DSET-BIND-WARNING-CENSUS
  Scenario: Perl warning diagnostics match the complete mapped source-case census
    When all 108 mapped source requests are executed in fresh receivers
    Then the exact nonzero warning outcomes are:
      | binding case | source case | warning count | stable warning prefixes with multiplicity |
      | DSET-BIND-WARNING-DATE-009-SHORT-ARRAY | DSET-DATE-009-SHORT-ARRAY | 3 | 1 time Use of uninitialized value $h in concatenation (.) or string; 1 time Use of uninitialized value $mn in concatenation (.) or string; 1 time Use of uninitialized value $s in concatenation (.) or string |
      | DSET-BIND-WARNING-TIME-010-SHORT-ARRAY | DSET-TIME-010-SHORT-ARRAY | 1 | 1 time Use of uninitialized value $s in concatenation (.) or string |
      | DSET-BIND-WARNING-FIELD-007-YEAR-ZERO | DSET-FIELD-007-YEAR-ZERO | 2 | 1 time Use of uninitialized value $beg in string comparison (cmp); 1 time Use of uninitialized value $end in string comparison (cmp) |
      | DSET-BIND-WARNING-FIELD-016-NONNUMERIC | DSET-FIELD-016-NONNUMERIC | 2 | 2 times Argument "nope" isn't numeric in integer multiplication (*) |
      | DSET-BIND-WARNING-FIELD-017-UNDEFINED | DSET-FIELD-017-UNDEFINED | 10 | 4 times Use of uninitialized value length($d) in integer eq (==); 4 times Use of uninitialized value $d in concatenation (.) or string; 2 times Use of uninitialized value $d in integer multiplication (*) |
      | DSET-BIND-WARNING-FIELD-023-OMITTED-NAME | DSET-FIELD-023-OMITTED-NAME | 1 | 1 time Use of uninitialized value $field in lc |
    And every other mapped source case emits zero warnings

  @DSET-BIND-OBSERVER-CARRIERS
  Scenario: Perl uses the captured native observer contexts and order
    Given valid receivers are observed in scalar then list context before replacement
    And unset and error-bearing receivers are not value-read before replacement
    When each source request finishes or is interrupted
    Then the receiver is observed in scalar, list, local, and GMT order
    And exactly the nine mapped exception cases end with an exception and the other 99 requests do not
    And every native definedness, reference type, list count, value, exception, and error boundary equals the stored source-case observation

  @DSET-BIND-SHORT-LISTS
  Scenario: Perl reports each missing field while validating short date and time lists
    Given independent receivers equal to "2040-02-29 16:05:09 America/Chicago"
    When one receiver gets selector "date" with list [2041, 1, 2]
    And the other gets selector "time" with list [3, 4]
    Then the date call warns once each for undefined hour, minute, and second
    And the time call warns once for an undefined second

  @DSET-BIND-FIELD-WARNINGS
  Scenario: Perl reports binding warnings for year zero and an omitted selector
    Given independent receivers equal to "2040-02-29 16:05:09 America/Chicago"
    When one receiver gets selector "y" with number 0
    And the other gets an omitted selector with no arguments
    Then the year-zero call warns once each for undefined timezone-period beginning and ending bounds
    And the omitted-selector call warns once for an undefined field during case normalization
