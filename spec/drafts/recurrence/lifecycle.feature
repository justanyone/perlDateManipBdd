@draft @recurrence @reference-observed
Feature: Build and inspect a bounded recurrence
  This draft records pinned-reference observations for coordinator review.
  It uses only recurrence text as input data and does not prescribe an implementation.

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

  @RECUR-CREATE-EMPTY
  Scenario: Create an empty recurrence value
    When I create a recurrence without initial text
    Then it reports recurrence kind
    And its frequency is empty
    And its requested anchor, effective anchor, lower bound, and upper bound are absent
    And its ordered modifier list is empty
    And its object error is empty

  @RECUR-CREATE-DERIVED
  Scenario: Create a recurrence from a date context without changing the source
    Given a date context whose value is "2040-04-13 12:34:56" in "Etc/UTC"
    When I create a recurrence in that context with frequency text "0:0:0:1:0:0:0"
    Then the new value reports recurrence kind
    And its frequency is "0:0:0:1:0:0:0"
    And the source date remains "2040-04-13 12:34:56" in "Etc/UTC"
    And the new value has an empty object error

  @RECUR-PARSE-RECOVER
  Scenario: Replace a parsed recurrence after a rejected parse
    When I parse this serialized recurrence:
      | frequency       | modifiers | requested anchor      | lower bound          | upper bound          |
      | 0:0:0:1:0:0:0   | FD1       | 2040-04-13 12:34:56  | 2040-04-13 00:00:00 | 2040-04-15 23:59:59 |
    Then parsing succeeds
    And indexed events 0 and 1 are respectively "2040-04-14 12:34:56" and "2040-04-15 12:34:56" in "Etc/UTC"
    When I replace it with invalid recurrence text "not a recurrence"
    Then parsing fails with object error "[parse] Invalid frequency string"
    When I replace it with serialized recurrence text "0:0:0:1:0:0:0**2040-04-13 12:34:56*2040-04-13 00:00:00*2040-04-15 23:59:59"
    Then parsing succeeds
    And its ordered modifier list is empty
    And its object error is empty
    And indexed event 0 is "2040-04-13 12:34:56" in "Etc/UTC" with lookup error zero

  @RECUR-FIELD-RESET
  Scenario: Replacing a frequency clears the other stored recurrence fields
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its lower bound is "2040-04-13 00:00:00" in "Etc/UTC"
    And its upper bound is "2040-04-15 23:59:59" in "Etc/UTC"
    And its modifier string is "FD1"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I replace its frequency with "0:0:0:2:0:0:0"
    Then replacing the frequency succeeds
    And its frequency is "0:0:0:2:0:0:0"
    And its requested anchor, lower bound, and upper bound are absent
    And its ordered modifier list is empty
    And its object error is empty
