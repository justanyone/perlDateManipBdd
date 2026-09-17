@draft
Feature: Interpret intervals and render date values

  @DELTA-01
  Scenario: Interpret an elapsed interval with hours and minutes
    Given the input language is English
    When I interpret the interval text "2 hours 17 minutes"
    Then interpretation succeeds
    And the interval fields are:
      | years | months | weeks | days | hours | minutes | seconds |
      | 0     | 0      | 0     | 0    | 2     | 17      | 0       |

  @FORMAT-01
  Scenario: Render civil fields with a specified pattern
    Given the date and time is "2040-02-29 16:05:09" in "Etc/UTC"
    And percent Y means four-digit year, percent m means two-digit month, and percent d means two-digit day
    And percent H means two-digit 24-hour hour, percent M means two-digit minute, and percent S means two-digit second
    When I render it with the pattern "%Y-%m-%d %H:%M:%S"
    Then the rendered text is exactly "2040-02-29 16:05:09"
