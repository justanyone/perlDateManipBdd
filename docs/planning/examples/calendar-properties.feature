@draft @calendar
Feature: Query Gregorian calendar properties

  Scenario Outline: Determine leap-year status for case <case>
    When I ask whether Gregorian year <year> is a leap year
    Then the answer is <answer>

    Examples:
      | case     | year | answer |
      | CAL-2000 | 2000 | true   |
      | CAL-2100 | 2100 | false  |
      | CAL-2400 | 2400 | true   |

  @CAL-04
  Scenario: Count days in a leap February
    When I ask for the number of days in month 2 of year 2040
    Then the number of days is 29

  @CAL-05 @CAL-06
  Scenario: Identify the weekday and year ordinal of a leap day
    Given the civil date is "2040-02-29"
    When I inspect its weekday and day number within the year
    Then the weekday is Wednesday
    And the day number within the year is 60

  @CAL-07
  Scenario: A half day in a year ordinal denotes noon
    Given year ordinals start at 1 at midnight on January 1
    When I convert ordinal day 60.5 in year 2040 to civil date and time fields
    Then the civil date and time is "2040-02-29 12:00:00"
