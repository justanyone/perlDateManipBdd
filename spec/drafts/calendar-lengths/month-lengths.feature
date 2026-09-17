@portable @calendar-lengths @observed-reference
Feature: Length of each Gregorian month
  Each row is one concrete calendar.days-in-month request with a numeric year and month.
  The profile names describe portable behavioral profiles; research mappings bind them to source calls.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Report every month in representative common and leap years
    Given I use the <profile>
    When I request the length of month <month> in year <year>
    Then the calendar.days-in-month result is <result>

    Examples:
      | case | profile | year | month | result |
      | CL-BASE-M-2039-01 | current calendar arithmetic profile | 2039 | 1 | number 31 |
      | CL-BASE-M-2039-02 | current calendar arithmetic profile | 2039 | 2 | number 28 |
      | CL-BASE-M-2039-03 | current calendar arithmetic profile | 2039 | 3 | number 31 |
      | CL-BASE-M-2039-04 | current calendar arithmetic profile | 2039 | 4 | number 30 |
      | CL-BASE-M-2039-05 | current calendar arithmetic profile | 2039 | 5 | number 31 |
      | CL-BASE-M-2039-06 | current calendar arithmetic profile | 2039 | 6 | number 30 |
      | CL-BASE-M-2039-07 | current calendar arithmetic profile | 2039 | 7 | number 31 |
      | CL-BASE-M-2039-08 | current calendar arithmetic profile | 2039 | 8 | number 31 |
      | CL-BASE-M-2039-09 | current calendar arithmetic profile | 2039 | 9 | number 30 |
      | CL-BASE-M-2039-10 | current calendar arithmetic profile | 2039 | 10 | number 31 |
      | CL-BASE-M-2039-11 | current calendar arithmetic profile | 2039 | 11 | number 30 |
      | CL-BASE-M-2039-12 | current calendar arithmetic profile | 2039 | 12 | number 31 |
      | CL-BASE-M-2040-01 | current calendar arithmetic profile | 2040 | 1 | number 31 |
      | CL-BASE-M-2040-02 | current calendar arithmetic profile | 2040 | 2 | number 29 |
      | CL-BASE-M-2040-03 | current calendar arithmetic profile | 2040 | 3 | number 31 |
      | CL-BASE-M-2040-04 | current calendar arithmetic profile | 2040 | 4 | number 30 |
      | CL-BASE-M-2040-05 | current calendar arithmetic profile | 2040 | 5 | number 31 |
      | CL-BASE-M-2040-06 | current calendar arithmetic profile | 2040 | 6 | number 30 |
      | CL-BASE-M-2040-07 | current calendar arithmetic profile | 2040 | 7 | number 31 |
      | CL-BASE-M-2040-08 | current calendar arithmetic profile | 2040 | 8 | number 31 |
      | CL-BASE-M-2040-09 | current calendar arithmetic profile | 2040 | 9 | number 30 |
      | CL-BASE-M-2040-10 | current calendar arithmetic profile | 2040 | 10 | number 31 |
      | CL-BASE-M-2040-11 | current calendar arithmetic profile | 2040 | 11 | number 30 |
      | CL-BASE-M-2040-12 | current calendar arithmetic profile | 2040 | 12 | number 31 |
      | CL-DM6-M-2039-01 | current functional profile | 2039 | 1 | number 31 |
      | CL-DM6-M-2039-02 | current functional profile | 2039 | 2 | number 28 |
      | CL-DM6-M-2039-03 | current functional profile | 2039 | 3 | number 31 |
      | CL-DM6-M-2039-04 | current functional profile | 2039 | 4 | number 30 |
      | CL-DM6-M-2039-05 | current functional profile | 2039 | 5 | number 31 |
      | CL-DM6-M-2039-06 | current functional profile | 2039 | 6 | number 30 |
      | CL-DM6-M-2039-07 | current functional profile | 2039 | 7 | number 31 |
      | CL-DM6-M-2039-08 | current functional profile | 2039 | 8 | number 31 |
      | CL-DM6-M-2039-09 | current functional profile | 2039 | 9 | number 30 |
      | CL-DM6-M-2039-10 | current functional profile | 2039 | 10 | number 31 |
      | CL-DM6-M-2039-11 | current functional profile | 2039 | 11 | number 30 |
      | CL-DM6-M-2039-12 | current functional profile | 2039 | 12 | number 31 |
      | CL-DM6-M-2040-01 | current functional profile | 2040 | 1 | number 31 |
      | CL-DM6-M-2040-02 | current functional profile | 2040 | 2 | number 29 |
      | CL-DM6-M-2040-03 | current functional profile | 2040 | 3 | number 31 |
      | CL-DM6-M-2040-04 | current functional profile | 2040 | 4 | number 30 |
      | CL-DM6-M-2040-05 | current functional profile | 2040 | 5 | number 31 |
      | CL-DM6-M-2040-06 | current functional profile | 2040 | 6 | number 30 |
      | CL-DM6-M-2040-07 | current functional profile | 2040 | 7 | number 31 |
      | CL-DM6-M-2040-08 | current functional profile | 2040 | 8 | number 31 |
      | CL-DM6-M-2040-09 | current functional profile | 2040 | 9 | number 30 |
      | CL-DM6-M-2040-10 | current functional profile | 2040 | 10 | number 31 |
      | CL-DM6-M-2040-11 | current functional profile | 2040 | 11 | number 30 |
      | CL-DM6-M-2040-12 | current functional profile | 2040 | 12 | number 31 |
      | CL-DM5-M-2039-01 | legacy functional profile | 2039 | 1 | number 31 |
      | CL-DM5-M-2039-02 | legacy functional profile | 2039 | 2 | number 28 |
      | CL-DM5-M-2039-03 | legacy functional profile | 2039 | 3 | number 31 |
      | CL-DM5-M-2039-04 | legacy functional profile | 2039 | 4 | number 30 |
      | CL-DM5-M-2039-05 | legacy functional profile | 2039 | 5 | number 31 |
      | CL-DM5-M-2039-06 | legacy functional profile | 2039 | 6 | number 30 |
      | CL-DM5-M-2039-07 | legacy functional profile | 2039 | 7 | number 31 |
      | CL-DM5-M-2039-08 | legacy functional profile | 2039 | 8 | number 31 |
      | CL-DM5-M-2039-09 | legacy functional profile | 2039 | 9 | number 30 |
      | CL-DM5-M-2039-10 | legacy functional profile | 2039 | 10 | number 31 |
      | CL-DM5-M-2039-11 | legacy functional profile | 2039 | 11 | number 30 |
      | CL-DM5-M-2039-12 | legacy functional profile | 2039 | 12 | number 31 |
      | CL-DM5-M-2040-01 | legacy functional profile | 2040 | 1 | number 31 |
      | CL-DM5-M-2040-02 | legacy functional profile | 2040 | 2 | number 29 |
      | CL-DM5-M-2040-03 | legacy functional profile | 2040 | 3 | number 31 |
      | CL-DM5-M-2040-04 | legacy functional profile | 2040 | 4 | number 30 |
      | CL-DM5-M-2040-05 | legacy functional profile | 2040 | 5 | number 31 |
      | CL-DM5-M-2040-06 | legacy functional profile | 2040 | 6 | number 30 |
      | CL-DM5-M-2040-07 | legacy functional profile | 2040 | 7 | number 31 |
      | CL-DM5-M-2040-08 | legacy functional profile | 2040 | 8 | number 31 |
      | CL-DM5-M-2040-09 | legacy functional profile | 2040 | 9 | number 30 |
      | CL-DM5-M-2040-10 | legacy functional profile | 2040 | 10 | number 31 |
      | CL-DM5-M-2040-11 | legacy functional profile | 2040 | 11 | number 30 |
      | CL-DM5-M-2040-12 | legacy functional profile | 2040 | 12 | number 31 |
