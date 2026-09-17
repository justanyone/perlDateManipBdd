@draft @recurrence @modifiers @reference-observed
Feature: Apply one recurrence modifier to a candidate event
  The token text is a user-facing recurrence input. Each row is an independently
  repeatable observation awaiting semantic review.

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
    And a recurrence has frequency text "0:0:0:1:0:0:0"

  Scenario Outline: Apply modifier family <case>
    Given its modifier string is "<modifier>"
    And its requested anchor is "<anchor>" in "Etc/UTC"
    When I ask for indexed event 0
    Then the lookup error is zero
    And the event is "<event>" in "Etc/UTC"

    Examples:
      | case              | anchor              | modifier | event               |
      | RECUR-MOD-PD       | 2040-04-13 12:34:56 | PD1      | 2040-04-09 12:34:56 |
      | RECUR-MOD-PT       | 2040-04-13 12:34:56 | PT5      | 2040-04-13 12:34:56 |
      | RECUR-MOD-ND       | 2040-04-13 12:34:56 | ND1      | 2040-04-16 12:34:56 |
      | RECUR-MOD-NT       | 2040-04-13 12:34:56 | NT5      | 2040-04-13 12:34:56 |
      | RECUR-MOD-WD       | 2040-04-13 12:34:56 | WD1      | 2040-04-09 12:34:56 |
      | RECUR-MOD-FD       | 2040-04-13 12:34:56 | FD1      | 2040-04-14 12:34:56 |
      | RECUR-MOD-BD       | 2040-04-13 12:34:56 | BD1      | 2040-04-12 12:34:56 |
      | RECUR-MOD-FW       | 2040-04-13 12:34:56 | FW1      | 2040-04-16 12:34:56 |
      | RECUR-MOD-BW       | 2040-04-15 12:34:56 | BW1      | 2040-04-13 12:34:56 |
      | RECUR-MOD-CWD      | 2040-04-14 12:34:56 | CWD      | 2040-04-13 12:34:56 |
      | RECUR-MOD-CWN      | 2040-04-14 12:34:56 | CWN      | 2040-04-13 12:34:56 |
      | RECUR-MOD-CWP      | 2040-04-14 12:34:56 | CWP      | 2040-04-13 12:34:56 |
      | RECUR-MOD-NWD      | 2040-04-14 12:34:56 | NWD      | 2040-04-16 12:34:56 |
      | RECUR-MOD-PWD      | 2040-04-14 12:34:56 | PWD      | 2040-04-13 12:34:56 |
      | RECUR-MOD-DWD      | 2040-04-14 12:34:56 | DWD      | 2040-04-13 12:34:56 |
      | RECUR-MOD-IBD      | 2040-04-13 12:34:56 | IBD      | 2040-04-13 12:34:56 |
      | RECUR-MOD-NBD      | 2040-04-14 12:34:56 | NBD      | 2040-04-14 12:34:56 |
      | RECUR-MOD-IW       | 2040-04-13 12:34:56 | IW5      | 2040-04-13 12:34:56 |
      | RECUR-MOD-EASTER   | 2040-04-13 12:34:56 | EASTER   | 2040-04-01 12:34:56 |

  Scenario Outline: Filter an indexed candidate with <case>
    Given its modifier string is "<modifier>"
    And its requested anchor is "<anchor>" in "Etc/UTC"
    When I ask for indexed event 0
    Then the lookup error is zero
    And no event is returned

    Examples:
      | case          | anchor              | modifier |
      | RECUR-MOD-NW  | 2040-04-13 12:34:56 | NW5      |

  @RECUR-MOD-CARRIER-UPPERCASE @compatibility @disputed
  Scenario: Modifier carrier and case can change the outcome
    Given a recurrence with requested anchor "2040-04-13 12:34:56" in "Etc/UTC"
    When I supply one comma-separated uppercase modifier string "FD1,ND2"
    Then the stored modifier list is "fd1", "nd2"
    When I set its requested anchor to "2040-04-13 12:34:56" in "Etc/UTC"
    Then indexed event 0 is "2040-04-17 12:34:56" in "Etc/UTC"
    Given a fresh daily recurrence with requested anchor "2040-04-13 12:34:56" in "Etc/UTC"
    When I supply the same uppercase tokens as two modifier arguments
    Then modifier installation reports status 1
    And the stored modifier list is empty
    When I set its requested anchor to "2040-04-13 12:34:56" in "Etc/UTC"
    Then indexed lookup returns no event with error "Invalid recurrence"

  @RECUR-MOD-CLEARS-ANCHOR @compatibility @disputed
  Scenario: Replacing modifiers after an anchor clears the requested anchor
    Given a daily recurrence whose requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I replace its modifier list with "FD1"
    Then modifier installation succeeds
    And the requested anchor is absent
    And indexed lookup returns no event with error "Incomplete recurrence"

  Scenario Outline: Apply modifier parameter boundary <case>
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its modifier string is "<modifier>"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I ask for indexed event 0
    Then modifier installation reports status <status>
    And the object error is <error>
    And the returned event value is "<event>"
    And the lookup error is "<lookup>"

    Examples:
      | case                    | modifier | status | error                                     | event               | lookup             |
      | RECUR-MOD-PD-ZERO       | PD0      | 1      | text "[modifiers] Invalid modifier: pd0" | absent              | Invalid recurrence |
      | RECUR-MOD-PD-EIGHT      | PD8      | 1      | text "[modifiers] Invalid modifier: pd8" | absent              | Invalid recurrence |
      | RECUR-MOD-FD-ZERO       | FD0      | 0      | empty text                                | 2040-04-13 12:34:56 | 0                  |
      | RECUR-MOD-FW-ZERO       | FW0      | 0      | empty text                                | 2040-04-13 12:34:56 | 0                  |
      | RECUR-MOD-IW-ZERO       | IW0      | 1      | text "[modifiers] Invalid modifier: iw0" | absent              | Invalid recurrence |
      | RECUR-MOD-IW-EIGHT      | IW8      | 1      | text "[modifiers] Invalid modifier: iw8" | absent              | Invalid recurrence |

  Scenario Outline: Modifier order changes a candidate outcome for <case>
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its ordered modifier list is "<modifiers>"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I ask for indexed event 0
    Then the lookup error is zero
    And the returned event value is "<event>"

    Examples:
      | case                          | modifiers | event               |
      | RECUR-MOD-ORDER-MOVE-FILTER   | fd1, ibd  | absent              |
      | RECUR-MOD-ORDER-FILTER-MOVE   | ibd, fd1  | 2040-04-14 12:34:56 |

  @RECUR-MOD-APPEND
  Scenario: Append lower-case modifier arguments to an existing list
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its modifier string is "FD1"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I append modifier argument "nd2"
    Then the stored modifier list is "fd1", "nd2"
    When I restore the requested anchor to "2040-04-13 12:34:56" in "Etc/UTC"
    Then indexed event 0 is "2040-04-17 12:34:56" in "Etc/UTC" with lookup error zero

  @RECUR-MOD-REJECTED-RECOVERY @compatibility @disputed
  Scenario: A rejected modifier update leaves an error until full recurrence replacement
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    And its modifier string is "FD1"
    And its requested anchor is "2040-04-13 12:34:56" in "Etc/UTC"
    When I append modifier argument "nd2"
    And I restore the requested anchor to "2040-04-13 12:34:56" in "Etc/UTC"
    And I request indexed event 0
    And I replace the modifier list with invalid text "unknown"
    Then replacement reports status 1
    And the stored modifier list remains "fd1", "nd2"
    And the object error is "[modifiers] Invalid modifier: unknown"
    When I replace its modifier list with "BD1"
    And I restore the requested anchor to "2040-04-13 12:34:56" in "Etc/UTC"
    Then its object error remains "[modifiers] Invalid modifier: unknown"
    And indexed lookup returns no event with error "Invalid recurrence"
    When I replace the frequency with "0:0:0:1:0:0:0", set modifier "bd1", and restore the requested anchor
    Then the object error is empty
    And indexed event 0 is "2040-04-12 12:34:56" in "Etc/UTC" with lookup error zero
