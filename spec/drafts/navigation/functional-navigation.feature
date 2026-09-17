@draft @navigation @functional @reference-dm700
Feature: Return previous and next occurrences through functional profiles
  Each row runs in a fresh process with English, US month-first numeric-date order,
  Etc/UTC local zone, and reference clock 2040-02-28 10:20:30 Etc/UTC. Weeks start
  Monday and use the January-4 first-week rule; omitted times default to midnight.
  Workdays are Monday through Friday, 09:00 through 17:00, with no holidays.
  The current profile also fixes ASCII encoding, non-printable native values, and
  no events.
  The current functional profile is backend 7.00. The compatibility profile is
  backend 5.66 from distribution 7.00. In exact arguments, null means an absent
  value. Research retains native compact results; this feature losslessly presents
  their six fields as YYYY-MM-DD HH:MM:SS.

  Background:
    Given the current profile configuration returns defined empty text without an exception
    And the compatibility profile configuration returns an absent value without an exception
    And every row loads, configures, calls, and exits independently

  Scenario: Functional profiles navigate weekday and partial-clock predicates
    When I make the functional navigation request in each row
    Then each call returns a text value containing the stated result
    And no call raises an exception
    And the exact requests and results are:
      | case | profile | direction | input text | exact arguments | result |
      | NAV-DM6-NEXT-NUMERIC-CURR0 | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 0] | 2040-11-30 18:15:00 |
      | NAV-DM6-NEXT-NUMERIC-CURR1 | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1] | 2040-11-23 18:15:00 |
      | NAV-DM6-NEXT-NUMERIC-CURR2-LATER | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2, text "19:30:00"] | 2040-11-23 19:30:00 |
      | NAV-DM6-PREV-NUMERIC-CURR0 | current | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 0] | 2040-11-16 18:15:00 |
      | NAV-DM6-PREV-NUMERIC-CURR1 | current | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1] | 2040-11-23 18:15:00 |
      | NAV-DM6-PREV-NUMERIC-CURR2-LATER | current | previous | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 2, text "19:30:00"] | 2040-11-16 19:30:00 |
      | NAV-DM6-NEXT-ABBREVIATED-WEEKDAY | current | next | 2040-11-23 18:15:00 Etc/UTC | [text "Fri", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM6-PREV-FULL-WEEKDAY | current | previous | 2040-11-23 18:15:00 Etc/UTC | [text "Friday", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM6-NEXT-CHAR-WEEKDAY | current | next | 2040-11-23 18:15:00 Etc/UTC | [text "F", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM6-NEXT-NONMATCH | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 7, number 0] | 2040-11-25 18:15:00 |
      | NAV-DM6-NEXT-WEEKDAY-TIME-TEXT | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 4, number 1, text "12:30"] | 2040-11-29 12:30:00 |
      | NAV-DM6-PREV-WEEKDAY-COMPONENTS | current | previous | 2040-11-23 18:15:00 Etc/UTC | [number 4, number 1, number 12, number 30, number 45] | 2040-11-22 12:30:45 |
      | NAV-DM6-NEXT-CLOCK-TEXT-CURR0 | current | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, text "18:15"] | 2040-11-24 18:15:00 |
      | NAV-DM6-NEXT-MINUTE-COMPONENTS | current | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, null, number 15, null] | 2040-11-23 19:15:00 |
      | NAV-DM6-PREV-SECOND-COMPONENTS | current | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 0, null, null, number 9] | 2040-11-23 18:14:09 |
      | NAV-DM6-NEXT-CLOCK-CURR2 | current | next | 2040-11-23 18:15:00 Etc/UTC | [null, number 2, text "18:15"] | 2040-11-23 18:15:00 |
      | NAV-DM6-NEXT-LEAP-MIDNIGHT | current | next | 2040-02-28 23:59:59 Etc/UTC | [null, number 0, number 0, number 0, number 0] | 2040-02-29 00:00:00 |
      | NAV-DM6-PREV-YEAR-WEEKDAY | current | previous | 2040-01-01 00:00:00 Etc/UTC | [number 6, number 0] | 2039-12-31 00:00:00 |
      | NAV-DM5-NEXT-NUMERIC-CURR0 | compatibility | next | 2040-11-23 18:15:00 | [number 5, number 0] | 2040-11-30 18:15:00 |
      | NAV-DM5-NEXT-NUMERIC-CURR1 | compatibility | next | 2040-11-23 18:15:00 | [number 5, number 1] | 2040-11-23 18:15:00 |
      | NAV-DM5-NEXT-NUMERIC-CURR2-LATER | compatibility | next | 2040-11-23 18:15:00 | [number 5, number 2, text "19:30:00"] | 2040-11-23 19:30:00 |
      | NAV-DM5-PREV-NUMERIC-CURR0 | compatibility | previous | 2040-11-23 18:15:00 | [number 5, number 0] | 2040-11-16 18:15:00 |
      | NAV-DM5-PREV-NUMERIC-CURR1 | compatibility | previous | 2040-11-23 18:15:00 | [number 5, number 1] | 2040-11-23 18:15:00 |
      | NAV-DM5-PREV-NUMERIC-CURR2-LATER | compatibility | previous | 2040-11-23 18:15:00 | [number 5, number 2, text "19:30:00"] | 2040-11-16 19:30:00 |
      | NAV-DM5-NEXT-ABBREVIATED-WEEKDAY | compatibility | next | 2040-11-23 18:15:00 | [text "Fri", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM5-PREV-FULL-WEEKDAY | compatibility | previous | 2040-11-23 18:15:00 | [text "Friday", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM5-NEXT-CHAR-WEEKDAY | compatibility | next | 2040-11-23 18:15:00 | [text "F", number 1] | 2040-11-23 18:15:00 |
      | NAV-DM5-NEXT-NONMATCH | compatibility | next | 2040-11-23 18:15:00 | [number 7, number 0] | 2040-11-25 18:15:00 |
      | NAV-DM5-NEXT-WEEKDAY-TIME-TEXT | compatibility | next | 2040-11-23 18:15:00 | [number 4, number 1, text "12:30"] | 2040-11-29 12:30:00 |
      | NAV-DM5-PREV-WEEKDAY-COMPONENTS | compatibility | previous | 2040-11-23 18:15:00 | [number 4, number 1, number 12, number 30, number 45] | 2040-11-22 12:30:45 |
      | NAV-DM5-NEXT-CLOCK-TEXT-CURR0 | compatibility | next | 2040-11-23 18:15:00 | [null, number 0, text "18:15"] | 2040-11-24 18:15:00 |
      | NAV-DM5-NEXT-MINUTE-COMPONENTS | compatibility | next | 2040-11-23 18:15:00 | [null, number 0, null, number 15, null] | 2040-11-23 19:15:00 |
      | NAV-DM5-PREV-SECOND-COMPONENTS | compatibility | previous | 2040-11-23 18:15:00 | [null, number 0, null, null, number 9] | 2040-11-23 18:14:09 |
      | NAV-DM5-NEXT-CLOCK-CURR2 | compatibility | next | 2040-11-23 18:15:00 | [null, number 2, text "18:15"] | 2040-11-23 18:15:00 |
      | NAV-DM5-NEXT-LEAP-MIDNIGHT | compatibility | next | 2040-02-28 23:59:59 | [null, number 0, number 0, number 0, number 0] | 2040-02-29 00:00:00 |
      | NAV-DM5-PREV-YEAR-WEEKDAY | compatibility | previous | 2040-01-01 00:00:00 | [number 6, number 0] | 2039-12-31 00:00:00 |

  Scenario: Invalid source and weekday inputs return empty text
    When I make the invalid functional request in each row
    Then each call returns a text value equal to empty text
    And no call raises an exception
    And the exact requests are:
      | case | profile | direction | input text | exact arguments |
      | NAV-DM6-NEXT-INVALID-DATE | current | next | not a valid date phrase | [number 5, number 1] |
      | NAV-DM6-PREV-DOW-EIGHT | current | previous | 2040-11-23 18:15:00 Etc/UTC | [number 8, number 1] |
      | NAV-DM6-NEXT-UNKNOWN-WEEKDAY | current | next | 2040-11-23 18:15:00 Etc/UTC | [text "Funday", number 1] |
      | NAV-DM6-PREV-MISSING-PREDICATE | current | previous | 2040-11-23 18:15:00 Etc/UTC | [null, number 0] |
      | NAV-DM5-NEXT-INVALID-DATE | compatibility | next | not a valid date phrase | [number 5, number 1] |
      | NAV-DM5-PREV-DOW-EIGHT | compatibility | previous | 2040-11-23 18:15:00 | [number 8, number 1] |
      | NAV-DM5-NEXT-UNKNOWN-WEEKDAY | compatibility | next | 2040-11-23 18:15:00 | [text "Funday", number 1] |
      | NAV-DM5-NEXT-BAD-TIME | compatibility | next | 2040-11-23 18:15:00 | [number 5, number 1, text "25:00"] |

  @reference-binding @excluded-from-portable-handoff @observed-compatibility @disputed
  Scenario: Invalid requests can raise profile-specific native exceptions
    When I make the invalid functional request in each row
    Then the call does not complete and has no returned value
    And the call raises the stated exact exception prefix
    And the exact requests are:
      | case | profile | direction | input text | exact arguments | exact exception prefix |
      | NAV-DM6-NEXT-BAD-TIME | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1, text "25:00"] | Can't use an undefined value as an ARRAY reference |
      | NAV-DM5-PREV-MISSING-PREDICATE | compatibility | previous | 2040-11-23 18:15:00 | [null, number 0] | ERROR: invalid arguments in Date_GetPrev. |
    And the current-profile case emits no warning
    And the compatibility-profile case emits only its deprecation warning

  @reference-binding @excluded-from-portable-handoff @observed-compatibility @disputed
  Scenario: Omitted inclusion mode acts as strict navigation and warns
    When I make the omitted-argument request in each row
    Then each call returns a text value equal to "2040-11-30 18:15:00"
    And no call raises an exception
    And the exact requests and warning counts are:
      | case | profile | direction | input text | exact arguments | warnings |
      | NAV-DM6-NEXT-OMITTED-CURR | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5] | two uninitialized inclusion-mode warnings |
      | NAV-DM5-NEXT-OMITTED-CURR | compatibility | next | 2040-11-23 18:15:00 | [number 5] | one deprecation and one uninitialized inclusion-mode warning |

  @observed-compatibility @disputed
  Scenario: Extra clock components differ between functional profiles
    When I make the extra-argument request in each row
    Then neither call raises an exception
    And the exact profile results are:
      | case | profile | direction | input text | exact arguments | result type | result |
      | NAV-DM6-NEXT-EXTRA-COMPONENT | current | next | 2040-11-23 18:15:00 Etc/UTC | [number 5, number 1, number 12, number 0, number 0, number 9] | text | empty text |
      | NAV-DM5-NEXT-EXTRA-COMPONENT | compatibility | next | 2040-11-23 18:15:00 | [number 5, number 1, number 12, number 0, number 0, number 9] | text | 2040-11-23 12:00:00 |

  @reference-binding @excluded-from-portable-handoff
  Scenario: Compatibility loading emits its exact native deprecation diagnostic
    Given a fresh compatibility process and input date "2040-11-23 18:15:00"
    When binding case "NAV-BIND-DM5-DEPRECATION" requests next with exact arguments [number 5, number 0]
    Then exactly one warning begins "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00"
    And this warning expectation characterizes the Perl binding rather than portable navigation semantics
