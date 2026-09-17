@draft @recurrence @reference-observed
Feature: Retrieve recurrence events through indexed, navigated, and functional routes

  Background:
    Given the named recurrence fixture "utc-working-week-2040" has:
      | setting                 | value                       |
      | input language          | English                     |
      | time zone               | Etc/UTC                     |
      | reference clock         | 2040-02-28 10:20:30         |
      | numeric date ordering   | month then day              |
      | omitted time            | midnight                    |
      | first day of week       | Monday                      |
      | first week rule         | week containing January 4   |
      | working days            | Monday through Friday       |
      | working hours           | 09:00 through 17:00         |
      | holidays and events     | none                        |

  @RECUR-NTH-MISSING
  Scenario: An absent calendar position has no event without a lookup error
    Given a monthly recurrence selecting calendar day 31 with requested anchor "2040-01-31 12:34:56" in "Etc/UTC"
    When I request indexed events -1, 0, 1, and 2
    Then the returned events in order are:
      | index | event               | lookup error |
      | -1    | 2039-12-31 00:00:00 | 0            |
      | 0     | 2040-01-31 00:00:00 | 0            |
      | 1     | absent              | 0            |
      | 2     | 2040-03-31 00:00:00 | 0            |

  @RECUR-NAV-SKIP
  Scenario: Navigation skips missing monthly positions and changes direction from its cursor
    Given a monthly recurrence selecting calendar day 31 with requested anchor "2040-01-31 12:34:56" in "Etc/UTC"
    And it is bounded from "2040-01-01 00:00:00" through "2040-05-31 23:59:59" in "Etc/UTC"
    When I navigate next, next, next, previous, and previous in that order
    Then the returned events in order are:
      | direction | event               |
      | next      | 2040-01-31 00:00:00 |
      | next      | 2040-03-31 00:00:00 |
      | next      | 2040-05-31 00:00:00 |
      | previous  | 2040-03-31 00:00:00 |
      | previous  | 2040-01-31 00:00:00 |
    Then every lookup error is zero

  @RECUR-DATES-TEMPORARY
  Scenario: Temporary enumeration limits do not change stored bounds
    Given a daily recurrence bounded from "2040-04-13 00:00:00" through "2040-04-16 23:59:59" in "Etc/UTC"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I enumerate only from "2040-04-14 00:00:00" through "2040-04-15 23:59:59"
    Then the events are exactly:
      | position | event               |
      | 1        | 2040-04-14 12:34:56 |
      | 2        | 2040-04-15 12:34:56 |
    When I enumerate again without temporary limits
    Then the events are exactly "2040-04-13 12:34:56", "2040-04-14 12:34:56", "2040-04-15 12:34:56", "2040-04-16 12:34:56"

  @RECUR-DATES-EMPTY
  Scenario: A finite filter can produce an empty collection without an object error
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its modifier string is "NBD"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I enumerate the single day from "2040-04-13 00:00:00" through "2040-04-13 23:59:59"
    Then the event collection is empty
    And the object error is empty

  Scenario Outline: Functional recurrence routes keep their profile-specific endpoint rule for <case>
    Given functional profile "<profile>" has a daily recurrence anchored at "2040-04-13 12:34:56" in "Etc/UTC"
    And its lower endpoint is "2040-04-13 12:34:56"
    When I enumerate through the exact upper endpoint "2040-04-15 12:34:56"
    Then the ordered event collection is exactly "<events>"

    Examples:
      | case                    | profile | events                                                        |
      | RECUR-FUNC-DM5-ENDPOINT | dm5     | 2040-04-13 12:34:56, 2040-04-14 12:34:56                     |
      | RECUR-FUNC-DM6-ENDPOINT | dm6     | 2040-04-13 12:34:56, 2040-04-14 12:34:56, 2040-04-15 12:34:56 |

  Scenario Outline: Functional description mode preserves the normalized recurrence text for <case>
    When functional profile "<profile>" describes frequency text "0:0:0:1:0:0:0"
    Then the description is exactly "0:0:0:1:0:0:0****"

    Examples:
      | case                       | profile |
      | RECUR-FUNC-DM5-DESCRIPTION | dm5     |
      | RECUR-FUNC-DM6-DESCRIPTION | dm6     |

  @RECUR-PARSE-TEXT-SECOND-ARGUMENT @compatibility @disputed
  Scenario: A textual first optional parse argument leaves a contradictory state
    Given frequency text "0:0:0:1:0:0:0"
    When I parse it with "2040-04-13 12:34:56" as the first optional argument following the frequency
    Then parsing reports status 0
    And the object error is "[modifiers] Invalid modifier: 2040-04-13 12:34:56"
    And indexed lookup returns no event with error "Invalid recurrence"
