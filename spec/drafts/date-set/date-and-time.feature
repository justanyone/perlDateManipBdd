@draft @date-set @reference-dm700
Feature: Replacing all civil fields or all time fields
  A whole-date request may initialize an empty carrier and preserves an existing
  zone. A time request requires an existing valid date and replaces three fields.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And native date scalars remain verbatim in research evidence
    And portable dates losslessly render six returned fields as "YYYY-MM-DD HH:MM:SS"
    And valid receivers are read in scalar and list contexts before replacement without a converted-zone read
    And unset and error-bearing receivers are not value-read before replacement
    And after replacement the receiver is read in scalar, list, local, and GMT order

  Scenario: Whole-date replacement initializes, recovers, preserves a zone, and selects overlap sides
    When I replace all six civil fields as described in each row
    Then every status is 0, every call and observer error is empty, and no exception or warning occurs
    And every scalar is defined and every list has six exact fields
    And the local result equals the GMT result
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement | daylight request | wall result | GMT result |
      | DSET-DATE-001-RETAIN-ZONE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5]] | 2040-02-29 16:05:09 America/Chicago | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 09:04:05 |
      | DSET-DATE-002-UNSET-LOCAL | unset | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5]] | unset | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 03:04:05 |
      | DSET-DATE-003-ERROR-RECOVERY | valid "2040-02-29 16:05:09 Etc/UTC", then parse "not a valid date phrase" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5]] | parse-error date | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 03:04:05 |
      | DSET-DATE-004-OVERLAP-DEFAULT | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2024, number 11, number 3, number 1, number 30, number 0]] | valid America/New_York date | 2024-11-03 01:30:00 | omitted | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-DATE-005-OVERLAP-STANDARD | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2024, number 11, number 3, number 1, number 30, number 0], number 0] | valid America/New_York date | 2024-11-03 01:30:00 | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-DATE-006-OVERLAP-DAYLIGHT | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2024, number 11, number 3, number 1, number 30, number 0], number 1] | valid America/New_York date | 2024-11-03 01:30:00 | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |
      | DSET-DATE-018-HOUR-24-MIDNIGHT | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 24, number 0, number 0]] | valid UTC date | 2041-01-02 24:00:00 | omitted | 2041-01-02 24:00:00 | 2041-01-03 00:00:00 |

  @observed-compatibility @disputed
  Scenario: Whole-date replacement accepts daylight value 2 as truthy
    Given a valid America/New_York receiver
    When I replace all fields with "2041-01-02 03:04:05" and daylight value 2
    Then the status is 0 and every error is empty
    And the wall result is "2041-01-02 03:04:05"
    And the GMT result is "2041-01-02 08:04:05"
    And no exception or warning occurs
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-DATE-014-ISDST-TWO | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5], number 2] |

  Scenario: Invalid whole-date requests clear the previous carrier
    When I make the invalid whole-date request in each row
    Then every call error before is empty
    And the scalar, local, and GMT results are defined empty text and the list result is an empty list
    And the first scalar observer changes the call error to "[value] Object does not contain a date"
    And later list, local, and GMT observers retain that value error
    And the exact call results are:
      | case | initial receiver | exact request | replacement shape or value | status | call error |
      | DSET-DATE-007-GAP | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2024, number 3, number 10, number 2, number 30, number 0]] | 2024-03-10 02:30:00 in America/New_York | 1 | [set] Invalid date/timezone |
      | DSET-DATE-008-INVALID-DATE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [list [number 2041, number 2, number 29, number 3, number 4, number 5]] | 2041-02-29 03:04:05 | 1 | [set] Invalid date argument |
      | DSET-DATE-009-SHORT-ARRAY | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [list [number 2041, number 1, number 2]] | only year, month, and day fields | 1 | [set] Invalid date argument |
      | DSET-DATE-010-LONG-ARRAY | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5, number 6]] | seven fields | 1 | [set] Invalid date/timezone |
      | DSET-DATE-012-OMITTED-DATE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [] | replacement omitted | 1 | [set] Invalid arguments |
      | DSET-DATE-013-EXTRA-ARGUMENT | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5], number 0, text "extra"] | replacement, flag, and extra argument | 1 | [set] Invalid arguments |
      | DSET-DATE-015-YEAR-ZERO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "date"; arguments [list [number 0, number 1, number 2, number 3, number 4, number 5]] | year 0 | 1 | [set] Invalid date argument |
      | DSET-DATE-016-MONTH-ZERO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "date"; arguments [list [number 2041, number 0, number 2, number 3, number 4, number 5]] | month 0 | 1 | [set] Invalid date argument |
      | DSET-DATE-017-DAY-ZERO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "date"; arguments [list [number 2041, number 1, number 0, number 3, number 4, number 5]] | day 0 | 1 | [set] Invalid date argument |
      | DSET-DATE-019-HOUR-24-NONZERO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 24, number 1, number 0]] | hour 24 with minute 1 | 1 | [set] Invalid date argument |
    And no exception occurs

  @reference-binding @excluded-from-portable-handoff @DSET-BIND-SHORT-LISTS
  Scenario: Perl reports each missing field while validating short date and time lists
    Given independent receivers equal to "2040-02-29 16:05:09 America/Chicago"
    When one receiver gets selector "date" with list [2041, 1, 2]
    And the other gets selector "time" with list [3, 4]
    Then the date call warns once each for undefined hour, minute, and second
    And the time call warns once for an undefined second
    And these warning expectations characterize the Perl binding rather than portable date semantics

  @reference-binding @observed-compatibility @disputed
  Scenario: A scalar whole-date carrier raises a binding exception
    Given a valid America/Chicago receiver equal to "2040-02-29 16:05:09"
    When I supply scalar text "2041010203:04:05" where six fields are required
    Then the call status is undefined and its error stays empty
    And the exception begins "Can't use string (\"2041010203:04:05\") as an ARRAY ref while \"strict refs\" in use"
    And the interrupted mutation leaves defined empty scalar, local, and GMT text and an empty list
    And the first scalar observer changes the error to "[value] Object does not contain a date"
    And later list, local, and GMT observers retain that value error
    And no warning occurs
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-DATE-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [text "2041010203:04:05"] |

  Scenario: Time replacement changes only the three clock fields
    When I replace all time fields as described in each row
    Then every status is 0, every call and observer error is empty, and no exception or warning occurs
    And every scalar is defined and every list has six exact fields
    And the local result equals the GMT result
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement time | daylight request | wall result | GMT result |
      | DSET-TIME-001-VALID | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 3, number 4, number 5]] | 2040-02-29 16:05:09 America/Chicago | 03:04:05 | omitted | 2040-02-29 03:04:05 | 2040-02-29 09:04:05 |
      | DSET-TIME-002-ALL-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 0, number 0, number 0]] | 2040-02-29 16:05:09 America/Chicago | 00:00:00 | omitted | 2040-02-29 00:00:00 | 2040-02-29 06:00:00 |
      | DSET-TIME-004-OVERLAP-STANDARD | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0], number 0] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-TIME-005-OVERLAP-DAYLIGHT | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0], number 1] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |
      | DSET-TIME-009-HOUR-24 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 24, number 0, number 0]] | 2040-02-29 16:05:09 America/Chicago | 24:00:00 | omitted | 2040-02-29 24:00:00 | 2040-03-01 06:00:00 |

  @observed-compatibility @disputed
  Scenario: Time replacement preserves the receiver's daylight side when omitted and accepts value 2
    When I make the time request in each row
    Then every status is 0, every error is empty, and no exception or warning occurs
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement time | daylight request | wall result | GMT result | disposition |
      | DSET-TIME-003-OVERLAP-DEFAULT | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0]] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | omitted | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 | omitted request retains daylight rather than documented standard default |
      | DSET-TIME-014-ISDST-TWO | valid "2040-02-29 16:05:09 America/New_York" | selector text "time"; arguments [list [number 3, number 4, number 5], number 2] | 2040-02-29 16:05:09 America/New_York | 03:04:05 | invalid numeric 2 | 2040-02-29 03:04:05 | 2040-02-29 08:04:05 | truthy value selects daylight offset |

  Scenario: Invalid time requests reject the input and leave the carrier empty
    When I make the invalid time request in each row
    Then the call error before is empty except that the parse-error receiver starts with "[parse] Invalid date string"
    And the scalar, local, and GMT results are defined empty text and the list result is an empty list
    And the first scalar observer changes the call error to "[value] Object does not contain a date"
    And later list, local, and GMT observers retain that value error
    And the exact call results are:
      | case | initial receiver | exact request | receiver or request | status | call error |
      | DSET-TIME-006-GAP-DEFAULT | valid "2024-03-10 01:30:00 America/New_York" | selector text "time"; arguments [list [number 2, number 30, number 0]] | New York gap time, flag omitted | 1 | [set] Invalid date/timezone |
      | DSET-TIME-007-GAP-STANDARD | valid "2024-03-10 01:30:00 America/New_York" | selector text "time"; arguments [list [number 2, number 30, number 0], number 0] | New York gap time, standard 0 | 1 | [set] Invalid date/timezone |
      | DSET-TIME-008-GAP-DAYLIGHT | valid "2024-03-10 01:30:00 America/New_York" | selector text "time"; arguments [list [number 2, number 30, number 0], number 1] | New York gap time, daylight 1 | 1 | [set] Invalid date/timezone |
      | DSET-TIME-010-SHORT-ARRAY | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 3, number 4]] | only hour and minute fields | 1 | [set] Invalid time argument |
      | DSET-TIME-012-OMITTED-TIME | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [] | replacement omitted | 1 | [set] Invalid arguments |
      | DSET-TIME-013-EXTRA-ARGUMENT | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 3, number 4, number 5], number 0, text "extra"] | replacement, flag, and extra argument | 1 | [set] Invalid arguments |
      | DSET-TIME-015-UNSET-RECEIVER | unset | selector text "time"; arguments [list [number 3, number 4, number 5]] | unset receiver | 1 | empty |
      | DSET-TIME-016-ERROR-RECEIVER | valid "2040-02-29 16:05:09 Etc/UTC", then parse "not a valid date phrase" | selector text "time"; arguments [list [number 3, number 4, number 5]] | parse-error receiver | 1 | [parse] Invalid date string |
      | DSET-TIME-017-MINUTE-60 | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "time"; arguments [list [number 23, number 60, number 0]] | minute 60 | 1 | [set] Invalid time argument |
      | DSET-TIME-018-SECOND-60 | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "time"; arguments [list [number 23, number 0, number 60]] | second 60 | 1 | [set] Invalid time argument |
      | DSET-TIME-019-HOUR-24-NONZERO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "time"; arguments [list [number 24, number 1, number 0]] | hour 24 with minute 1 | 1 | [set] Invalid time argument |
      | DSET-TIME-020-NEGATIVE-HOUR | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "time"; arguments [list [number -1, number 0, number 0]] | hour -1 | 1 | [set] Invalid time argument |
    And no exception occurs

  @reference-binding @observed-compatibility @disputed
  Scenario: A scalar time carrier raises a binding exception
    Given a valid America/Chicago receiver equal to "2040-02-29 16:05:09"
    When I supply scalar text "03:04:05" where three fields are required
    Then the call status is undefined and its error stays empty
    And the exception begins "Can't use string (\"03:04:05\") as an ARRAY ref while \"strict refs\" in use"
    And the interrupted mutation leaves defined empty scalar, local, and GMT text and an empty list
    And the first scalar observer changes the error to "[value] Object does not contain a date"
    And later list, local, and GMT observers retain that value error
    And no warning occurs
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-TIME-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [text "03:04:05"] |
