@draft @recurrence
Feature: Enumerate bounded recurring dates

  @RECUR-01
  Scenario: A daily recurrence includes a leap day
    Given the default time zone is "Etc/UTC"
    And a recurrence advances by 1 calendar day from "2040-02-28 09:00:00"
    And the recurrence has no date-shifting modifiers
    And its inclusive occurrence bounds are:
      | start               | end                 |
      | 2040-02-28 00:00:00 | 2040-03-01 23:59:59 |
    When I enumerate its occurrences in order
    Then there are exactly 3 occurrences
    And the occurrence date-times in "Etc/UTC" are exactly:
      | position | date and time       |
      | 1        | 2040-02-28 09:00:00 |
      | 2        | 2040-02-29 09:00:00 |
      | 3        | 2040-03-01 09:00:00 |
