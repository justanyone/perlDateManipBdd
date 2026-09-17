@portable @calendar-validation @observed-reference
Feature: Validate civil clock fields
  The request is an ordered hour, minute, second collection.
  Validation is independent of time zone and daylight-saving transitions.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Classify documented clock values and boundaries
    When I validate civil clock fields <fields>
    Then the calendar.validate-time outcome is <outcome>

    Examples:
      | case | fields | outcome |
      | CC-T-MIDNIGHT-NUMERIC | [0,0,0] | valid |
      | CC-T-MIDNIGHT-PADDED | ["00","00","00"] | valid |
      | CC-T-LAST-SECOND | [23,59,59] | valid |
      | CC-T-24-EXACT | [24,0,0] | valid |
      | CC-T-24-MINUTE | [24,1,0] | invalid |
      | CC-T-HOUR-25 | [25,0,0] | invalid |
      | CC-T-MINUTE-60 | [12,60,0] | invalid |
      | CC-T-SECOND-60 | [12,0,60] | invalid |
