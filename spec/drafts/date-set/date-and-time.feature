@draft @date-set @reference-dm700
Feature: Replacing all civil fields or all time fields
  A whole-date request may initialize an empty carrier and preserves an existing
  zone. A time request requires an existing valid date and replaces three fields.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And date values are presented from their ordered civil fields as "YYYY-MM-DD HH:MM:SS"
    And valid receivers are read as stored-date text and an ordered six-field record before replacement without a converted-zone read
    And unset and error-bearing receivers are not value-read before replacement
    And after replacement the receiver is read as stored-date text, ordered fields, fixed-local text, and UTC text in that order

  Scenario: Whole-date replacement initializes, recovers, preserves a zone, and selects overlap sides
    When I replace all six civil fields as described in each row
    Then every request completes with status 0 and every call and observer error is empty
    And every stored-date result is text and every ordered field result has six exact fields
    And the fixed-local result equals the UTC result
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement | daylight request | wall result | UTC result |
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
    And the UTC result is "2041-01-02 08:04:05"
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-DATE-014-ISDST-TWO | valid "2040-02-29 16:05:09 America/New_York" | selector text "date"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5], number 2] |

  Scenario: Invalid whole-date requests clear the previous carrier
    When I make the invalid whole-date request in each row
    Then every call error before is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the call error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
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



  @observed-compatibility @disputed
  Scenario: A text whole-date input ends without a status and leaves no stored date
    Given a valid America/Chicago receiver equal to "2040-02-29 16:05:09"
    When I supply text "2041010203:04:05" where an ordered six-field record is required
    Then the request ends without returning a status
    And its error immediately before and after the request is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact portable outcome is:
      | case | initial receiver | exact request | status | call error before | call error after | stored-date text | ordered fields | error after stored-date read |
      | DSET-DATE-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "date"; arguments [text "2041010203:04:05"] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |

  Scenario: Time replacement changes only the three clock fields
    When I replace all time fields as described in each row
    Then every request completes with status 0 and every call and observer error is empty
    And every stored-date result is text and every ordered field result has six exact fields
    And the fixed-local result equals the UTC result
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement time | daylight request | wall result | UTC result |
      | DSET-TIME-001-VALID | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 3, number 4, number 5]] | 2040-02-29 16:05:09 America/Chicago | 03:04:05 | omitted | 2040-02-29 03:04:05 | 2040-02-29 09:04:05 |
      | DSET-TIME-002-ALL-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 0, number 0, number 0]] | 2040-02-29 16:05:09 America/Chicago | 00:00:00 | omitted | 2040-02-29 00:00:00 | 2040-02-29 06:00:00 |
      | DSET-TIME-004-OVERLAP-STANDARD | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0], number 0] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-TIME-005-OVERLAP-DAYLIGHT | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0], number 1] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |
      | DSET-TIME-009-HOUR-24 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [list [number 24, number 0, number 0]] | 2040-02-29 16:05:09 America/Chicago | 24:00:00 | omitted | 2040-02-29 24:00:00 | 2040-03-01 06:00:00 |

  @observed-compatibility @disputed
  Scenario: Time replacement preserves the receiver's daylight side when omitted and accepts value 2
    When I make the time request in each row
    Then every request completes with status 0 and every error is empty
    And the exact results are:
      | case | initial receiver | exact request | receiver | replacement time | daylight request | wall result | UTC result | disposition |
      | DSET-TIME-003-OVERLAP-DEFAULT | valid "2024-11-03 00:30:00 America/New_York" | selector text "time"; arguments [list [number 1, number 30, number 0]] | 2024-11-03 00:30:00 America/New_York | 01:30:00 | omitted | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 | omitted request retains daylight rather than documented standard default |
      | DSET-TIME-014-ISDST-TWO | valid "2040-02-29 16:05:09 America/New_York" | selector text "time"; arguments [list [number 3, number 4, number 5], number 2] | 2040-02-29 16:05:09 America/New_York | 03:04:05 | invalid numeric 2 | 2040-02-29 03:04:05 | 2040-02-29 08:04:05 | truthy value selects daylight offset |

  Scenario: Invalid time requests reject the input and leave the carrier empty
    When I make the invalid time request in each row
    Then the call error before is empty except that the parse-error receiver starts with "[parse] Invalid date string"
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the call error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
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


  @observed-compatibility @disputed
  Scenario: A text time input ends without a status and leaves no stored date
    Given a valid America/Chicago receiver equal to "2040-02-29 16:05:09"
    When I supply text "03:04:05" where an ordered three-field record is required
    Then the request ends without returning a status
    And its error immediately before and after the request is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact portable outcome is:
      | case | initial receiver | exact request | status | call error before | call error after | stored-date text | ordered fields | error after stored-date read |
      | DSET-TIME-011-SCALAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "time"; arguments [text "03:04:05"] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
