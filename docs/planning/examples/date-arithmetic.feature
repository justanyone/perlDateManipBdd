@draft @arithmetic
Feature: Apply calendar intervals and measure elapsed time

  Background:
    Given the default time zone is "Etc/UTC"

  Scenario Outline: Advance a date by a calendar interval for case <case>
    Given the starting date and time is "<start>" in "Etc/UTC"
    When I advance it by 1 calendar <unit>
    Then the calculation succeeds
    And the resulting date and time in "Etc/UTC" is "<expected>"

    Examples:
      | case     | start               | unit  | expected            |
      | ARITH-01 | 2040-02-28 16:05:09 | day   | 2040-02-29 16:05:09 |
      | ARITH-02 | 2040-01-31 16:05:09 | month | 2040-02-29 16:05:09 |

  @ARITH-03
  Scenario: Measure a two-day UTC separation as an exact interval
    Given the starting date and time is "2040-02-28 16:05:09" in "Etc/UTC"
    And the ending date and time is "2040-03-01 16:05:09" in "Etc/UTC"
    When I measure the separation as an exact elapsed interval
    Then the calculation succeeds
    And the exact interval fields are:
      | years | months | weeks | days | hours | minutes | seconds |
      | 0     | 0      | 0     | 0    | 48    | 0       | 0       |
