@draft @recurrence @modifiers @reference-observed
Feature: Apply one recurrence modifier to a candidate event
  The token text is a user-facing recurrence input. Each row is an independently
  repeatable observation awaiting semantic review.

  Background:
    Given the named recurrence fixture "utc-working-week-2040"
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
