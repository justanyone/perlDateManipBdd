@portable @calendar-validation @observed-reference
Feature: Validate civil date-time fields
  The request is an ordered year, month, day, hour, minute, second collection.
  Validation uses civil Gregorian fields without resolving a time zone.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Classify documented date-time values and boundaries
    When I validate civil date-time fields <fields>
    Then the calendar.validate-date outcome is <outcome>

    Examples:
      | case | fields | outcome |
      | CC-D-ORDINARY | [2039,5,17,9,7,5] | valid |
      | CC-D-LEAP-DAY | [2040,2,29,0,0,0] | valid |
      | CC-D-LOWER-ENDPOINT | [1,1,1,0,0,0] | valid |
      | CC-D-UPPER-ENDPOINT | [9999,12,31,24,0,0] | valid |
      | CC-D-APRIL-END | [2040,4,30,23,59,59] | valid |
      | CC-D-YEAR-ZERO | [0,1,1,0,0,0] | invalid |
      | CC-D-YEAR-10000 | [10000,1,1,0,0,0] | invalid |
      | CC-D-MONTH-ZERO | [2040,0,1,0,0,0] | invalid |
      | CC-D-MONTH-13 | [2040,13,1,0,0,0] | invalid |
      | CC-D-DAY-ZERO | [2040,1,0,0,0,0] | invalid |
      | CC-D-COMMON-FEB29 | [2039,2,29,0,0,0] | invalid |
      | CC-D-APRIL31 | [2040,4,31,0,0,0] | invalid |
      | CC-D-24-SECOND | [2040,1,1,24,0,1] | invalid |
