@draft @navigation @reference-dm700
Feature: Move a stored date to a previous or next weekday or clock occurrence
  These cases use Date-Manip 7.00, tzdata2026c, tzcode2026c, English ASCII,
  US month-first numeric-date order, non-printable native values, Etc/UTC as the
  local zone, and a fixed reference clock of 2040-02-28 10:20:30 Etc/UTC. Weeks
  start Monday and the first week contains January 4. Omitted times default to
  midnight. Workdays are Monday through Friday, 09:00 through 17:00, with no
  holidays or events. Weekdays are numbered Monday 1 through Sunday 7. In the
  exact request column, null means an absent value and a nested bracketed value
  is one list argument. Research retains native compact values; this feature
  losslessly presents the same six fields as YYYY-MM-DD HH:MM:SS.

  Background:
    Given a fresh object date-time context for every row
    And every valid receiver is read first in scalar and list context
    And no converted-zone value is read before navigation
    And after navigation the receiver is read in scalar, list, local, and GMT order
    And every error is observed immediately before and after its associated call

  Scenario: Navigate valid weekday and clock predicates
    When I make the object navigation request in each row
    Then each navigation status is numeric 0
    And each scalar and list observer contains the six fields of the wall result
    And every call and observer error is empty
    And no call raises an exception or emits a warning
    And the exact requests and results are:
      | case | direction | initial receiver | exact arguments | wall result | GMT result |
      | NAV-OO-NEXT-WEEKDAY-MATCH-CURR0 | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 0] | 2040-11-30 18:15:00 | 2040-11-30 18:15:00 |
      | NAV-OO-NEXT-WEEKDAY-MATCH-CURR1 | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-NEXT-WEEKDAY-MATCH-CURR2 | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2] | 2040-11-30 18:15:00 | 2040-11-30 18:15:00 |
      | NAV-OO-NEXT-WEEKDAY-CURR2-LATER | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2, list [number 19, number 30, number 0]] | 2040-11-23 19:30:00 | 2040-11-23 19:30:00 |
      | NAV-OO-PREV-WEEKDAY-MATCH-CURR0 | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 0] | 2040-11-16 18:15:00 | 2040-11-16 18:15:00 |
      | NAV-OO-PREV-WEEKDAY-MATCH-CURR1 | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-PREV-WEEKDAY-MATCH-CURR2 | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2] | 2040-11-16 18:15:00 | 2040-11-16 18:15:00 |
      | NAV-OO-PREV-WEEKDAY-CURR2-EARLIER | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2, list [number 12, number 30, number 0]] | 2040-11-23 12:30:00 | 2040-11-23 12:30:00 |
      | NAV-OO-PREV-WEEKDAY-CURR2-LATER | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2, list [number 19, number 30, number 0]] | 2040-11-16 19:30:00 | 2040-11-16 19:30:00 |
      | NAV-OO-NEXT-WEEKDAY-NONMATCH | next | 2040-11-23 18:15:00 Etc/UTC | [number 7, number 0] | 2040-11-25 18:15:00 | 2040-11-25 18:15:00 |
      | NAV-OO-PREV-WEEKDAY-NONMATCH | previous | 2040-11-23 18:15:00 Etc/UTC | [number 4, number 1] | 2040-11-22 18:15:00 | 2040-11-22 18:15:00 |
      | NAV-OO-NEXT-WEEKDAY-FULL-CLOCK | next | 2040-11-23 18:15:00 Etc/UTC | [number 4, number 1, list [number 12, number 30, number 45]] | 2040-11-29 12:30:45 | 2040-11-29 12:30:45 |
      | NAV-OO-PREV-WEEKDAY-SHORT-CLOCK | previous | 2040-11-23 18:15:00 Etc/UTC | [number 4, number 1, list [number 12, number 30]] | 2040-11-22 12:30:00 | 2040-11-22 12:30:00 |
      | NAV-OO-NEXT-CLOCK-EXACT-CURR0 | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, list [number 18, number 15, null]] | 2040-11-24 18:15:00 | 2040-11-24 18:15:00 |
      | NAV-OO-NEXT-CLOCK-EXACT-CURR1 | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 1, list [number 18, number 15, null]] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-NEXT-CLOCK-EXACT-CURR2 | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 2, list [number 18, number 15, null]] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-PREV-CLOCK-EXACT-CURR0 | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, list [number 18, number 15, null]] | 2040-11-22 18:15:00 | 2040-11-22 18:15:00 |
      | NAV-OO-PREV-CLOCK-EXACT-CURR1 | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 1, list [number 18, number 15, null]] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-NEXT-MINUTE-EXACT-CURR0 | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, list [null, number 15, null]] | 2040-11-23 19:15:00 | 2040-11-23 19:15:00 |
      | NAV-OO-NEXT-MINUTE-EXACT-CURR1 | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 1, list [null, number 15, null]] | 2040-11-23 18:15:00 | 2040-11-23 18:15:00 |
      | NAV-OO-PREV-SECOND-CURR0 | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, list [null, null, number 9]] | 2040-11-23 18:14:09 | 2040-11-23 18:14:09 |
      | NAV-OO-NEXT-HOUR-PASSED | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 1, list [number 18, null, null]] | 2040-11-24 18:00:00 | 2040-11-24 18:00:00 |
      | NAV-OO-NEXT-LEAP-MIDNIGHT | next | 2040-02-28 23:59:59 Etc/UTC | [null, number 0, list [number 0, number 0, number 0]] | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |
      | NAV-OO-PREV-LEAP-MIDNIGHT | previous | 2040-03-01 00:00:00 Etc/UTC | [null, number 0, list [number 0, number 0, number 0]] | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |
      | NAV-OO-NEXT-YEAR-WEEKDAY | next | 2039-12-31 23:59:59 Etc/UTC | [number 7, number 0] | 2040-01-01 23:59:59 | 2040-01-01 23:59:59 |
      | NAV-OO-NEXT-DST-OVERLAP | next | 2024-11-03 00:30:00 America/New_York | [null, number 0, list [number 1, number 30, number 0]] | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |

  Scenario: Invalid predicates report failure while preserving a valid carrier
    When I make the invalid object navigation request in each row
    Then every status is numeric 1 and no call raises an exception or warning
    And the immediate error equals the stated call error
    And scalar, list, local, and GMT observers expose empty text or an empty list while that error remains
    When I clear the error after those observers
    Then error clearing returns an absent value and leaves the error empty
    And the scalar and GMT values again equal "2040-11-23 18:15:00"
    And the exact requests are:
      | case | direction | initial receiver | exact arguments | call error |
      | NAV-OO-NEXT-DOW-EIGHT | next | 2040-11-23 18:15:00 Etc/UTC | [number 8, number 1] | [next] Invalid DOW: 8 |
      | NAV-OO-PREV-STRING-WEEKDAY | previous | 2040-11-23 18:15:00 Etc/UTC | [text "Friday", number 1] | [prev] Invalid DOW: Friday |
      | NAV-OO-NEXT-MISSING-PREDICATE | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 0] | [next] Either DoW or time (or both) required |
      | NAV-OO-PREV-SHORT-CLOCK | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, list [number 18, number 15]] | [prev] invalid time argument |
      | NAV-OO-NEXT-BAD-CLOCK | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 0, list [number 25]] | [next] invalid time argument |

  Scenario: An unset or error-bearing receiver cannot navigate
    When I make the object navigation request in each row
    Then every status is numeric 1 and no call raises an exception or warning
    And the immediate error equals the stated call error
    And all four value observers expose an empty carrier
    And the first scalar observer sets error "[value] Object does not contain a date"
    And clearing that observer error still leaves an empty carrier
    And the exact requests are:
      | case | direction | receiver preparation | exact arguments | call error |
      | NAV-OO-NEXT-UNSET | next | a new unset date receiver | [number 5, number 1] | empty |
      | NAV-OO-PREV-ERROR | previous | parse "not a valid date phrase" into a receiver initially equal to "2040-02-29 16:05:09 Etc/UTC" | [number 5, number 1] | [parse] Invalid date string |

  @observed-compatibility @disputed
  Scenario: A navigation into the New York spring gap reports success after losing the carrier
    When I make the object navigation request in each row
    Then every numeric status is 0 despite immediate error "[set] Invalid date/timezone"
    And no call raises an exception or warning
    And the scalar, list, local, and GMT observers expose an empty carrier
    And the first scalar observer changes the error to "[value] Object does not contain a date"
    And clearing that error still leaves an empty carrier
    And the exact requests are:
      | case | direction | initial receiver | exact arguments |
      | NAV-OO-NEXT-DST-GAP | next | 2024-03-10 01:30:00 America/New_York | [null, number 0, list [number 2, number 30, number 0]] |
      | NAV-OO-PREV-DST-GAP | previous | 2024-03-10 03:30:00 America/New_York | [null, number 0, list [number 2, number 30, number 0]] |

  @observed-compatibility @disputed @reference-binding @excluded-from-portable-handoff
  Scenario: Omitted inclusion mode is treated as strict and emits native warnings
    Given the receiver is "2040-11-23 18:15:00 Etc/UTC"
    When case "NAV-OO-NEXT-OMITTED-CURR" requests next with exact arguments [number 5]
    Then the numeric status is 0 and the result is "2040-11-30 18:15:00"
    And every call and observer error is empty
    And no exception occurs
    And exactly two uninitialized inclusion-mode warnings identify the reference binding

  @observed-compatibility @disputed
  Scenario: An extra object argument is ignored
    Given the receiver is "2040-11-23 18:15:00 Etc/UTC"
    When case "NAV-OO-NEXT-EXTRA-ARGUMENT" requests next with exact arguments [number 5, number 1, list [number 12, number 0, number 0], text "extra"]
    Then the numeric status is 0 and the result is "2040-11-23 12:00:00"
    And every call and observer error is empty
    And no exception or warning occurs
