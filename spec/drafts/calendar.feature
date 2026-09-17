@draft @calendar
Feature: Inspect Gregorian calendar dates
  A civil date is a year, month, and day without a timezone.
  Month and day numbers start at one. Results are exact integers or yes/no values.
  This draft is awaiting reference-evidence review and coverage integration.

  Background:
    Given the calendar follows the proleptic Gregorian rules
    And all supplied years are complete years without century inference

  Scenario Outline: Determine leap-year status for <case>
    When I ask whether year <year> is a leap year
    Then the answer is "<answer>"

    Examples:
      | case            | year | answer |
      | LEAP-CENTURY    | 1900 | no     |
      | LEAP-400-YEAR   | 2000 | yes    |
      | LEAP-ORDINARY   | 2040 | yes    |
      | LEAP-COMMON     | 2041 | no     |
      | LEAP-NEXT-100   | 2100 | no     |
      | LEAP-NEXT-400   | 2400 | yes    |

  Scenario Outline: Count the days in a complete year for <case>
    When I count the calendar days in year <year>
    Then the count is <days>

    Examples:
      | case             | year | days |
      | YEAR-CENTURY     | 1900 | 365  |
      | YEAR-400-YEAR    | 2000 | 366  |
      | YEAR-LEAP        | 2040 | 366  |
      | YEAR-COMMON      | 2041 | 365  |
      | YEAR-NEXT-100    | 2100 | 365  |
      | YEAR-NEXT-400    | 2400 | 366  |

  Scenario Outline: Count the days in a month for <case>
    When I count the calendar days in month <month> of year <year>
    Then the count is <days>

    Examples:
      | case          | year | month | days |
      | MONTH-JAN     | 2040 | 1     | 31   |
      | MONTH-FEB     | 2040 | 2     | 29   |
      | MONTH-MAR     | 2040 | 3     | 31   |
      | MONTH-APR     | 2040 | 4     | 30   |
      | MONTH-MAY     | 2040 | 5     | 31   |
      | MONTH-JUN     | 2040 | 6     | 30   |
      | MONTH-JUL     | 2040 | 7     | 31   |
      | MONTH-AUG     | 2040 | 8     | 31   |
      | MONTH-SEP     | 2040 | 9     | 30   |
      | MONTH-OCT     | 2040 | 10    | 31   |
      | MONTH-NOV     | 2040 | 11    | 30   |
      | MONTH-DEC     | 2040 | 12    | 31   |
      | MONTH-FEB-NON | 2041 | 2     | 28   |

  Scenario Outline: Name a date's weekday for <case>
    When I ask for the weekday of civil date "<date>"
    Then the weekday is "<weekday>"

    Examples:
      | case        | date       | weekday   |
      | WEEKDAY-MON | 2040-04-09 | Monday    |
      | WEEKDAY-TUE | 2040-04-10 | Tuesday   |
      | WEEKDAY-WED | 2040-04-11 | Wednesday |
      | WEEKDAY-THU | 2040-04-12 | Thursday  |
      | WEEKDAY-FRI | 2040-04-13 | Friday    |
      | WEEKDAY-SAT | 2040-04-14 | Saturday  |
      | WEEKDAY-SUN | 2040-04-15 | Sunday    |

  @MONTH-ALL
  Scenario: List every month's length in calendar order
    When I list the month lengths for year 2040
    Then the ordered month lengths are:
      | month | days |
      | 1     | 31   |
      | 2     | 29   |
      | 3     | 31   |
      | 4     | 30   |
      | 5     | 31   |
      | 6     | 30   |
      | 7     | 31   |
      | 8     | 31   |
      | 9     | 30   |
      | 10    | 31   |
      | 11    | 30   |
      | 12    | 31   |
