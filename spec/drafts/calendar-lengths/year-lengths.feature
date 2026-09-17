@portable @calendar-lengths @observed-reference
Feature: Length of Gregorian years
  Century controls distinguish divisibility by 100 from divisibility by 400.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Report ordinary and century year lengths
    Given I use the <profile>
    When I request the length of year <year>
    Then the calendar.days-in-year result is <result>

    Examples:
      | case | profile | year | result |
      | CL-BASE-Y-1900 | current calendar arithmetic profile | 1900 | number 365 |
      | CL-BASE-Y-2000 | current calendar arithmetic profile | 2000 | number 366 |
      | CL-BASE-Y-2039 | current calendar arithmetic profile | 2039 | number 365 |
      | CL-BASE-Y-2040 | current calendar arithmetic profile | 2040 | number 366 |
      | CL-BASE-Y-2100 | current calendar arithmetic profile | 2100 | number 365 |
      | CL-DM6-Y-1900 | current functional profile | 1900 | number 365 |
      | CL-DM6-Y-2000 | current functional profile | 2000 | number 366 |
      | CL-DM6-Y-2039 | current functional profile | 2039 | number 365 |
      | CL-DM6-Y-2040 | current functional profile | 2040 | number 366 |
      | CL-DM6-Y-2100 | current functional profile | 2100 | number 365 |
      | CL-DM5-Y-1900 | legacy functional profile | 1900 | number 365 |
      | CL-DM5-Y-2000 | legacy functional profile | 2000 | number 366 |
      | CL-DM5-Y-2039 | legacy functional profile | 2039 | number 365 |
      | CL-DM5-Y-2040 | legacy functional profile | 2040 | number 366 |
      | CL-DM5-Y-2100 | legacy functional profile | 2100 | number 365 |
