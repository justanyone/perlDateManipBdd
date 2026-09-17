@draft
Feature: Transform dates using explicit zone and calendar rules

  @TZ-01 @pinned-zone-data
  Scenario: Convert a UTC date-time to its New York wall time
    Given the reference timezone rules are fixed by the selected profile
    And the date and time is "2040-07-01 12:00:00" in "Etc/UTC"
    When I express that instant in "America/New_York"
    Then the resulting date and time in "America/New_York" is "2040-07-01 08:00:00"

  @EPOCH-01
  Scenario: An instant immediately before the UTC epoch has a negative value
    Given the date and time is "1969-12-31 23:59:59" in "Etc/UTC"
    When I measure elapsed seconds from "1970-01-01 00:00:00" in "Etc/UTC"
    Then the signed number of seconds is -1

  @BUSINESS-01
  Scenario: Advancing one working date skips the weekend and preserves the time
    Given the default time zone is "Etc/UTC"
    And the working calendar contains no holidays
    And the working schedule is:
      | weekday   | opens | closes |
      | Monday    | 09:00 | 17:00  |
      | Tuesday   | 09:00 | 17:00  |
      | Wednesday | 09:00 | 17:00  |
      | Thursday  | 09:00 | 17:00  |
      | Friday    | 09:00 | 17:00  |
    And the starting date and time is "2040-03-02 16:05:09" in "Etc/UTC"
    When I advance by 1 working date while preserving the time of day
    Then the resulting date and time in "Etc/UTC" is "2040-03-05 16:05:09"
