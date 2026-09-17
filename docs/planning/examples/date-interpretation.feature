@draft @parsing
Feature: Interpret date input with an explicit context

  Background:
    Given the reference clock is fixed at "2040-02-28 10:20:30" in "Etc/UTC"
    And the input language is English
    And an omitted time means midnight

  Scenario Outline: Interpret date text for case <case>
    Given numeric dates put the month before the day
    When I interpret the date text "<text>"
    Then interpretation succeeds
    And the resulting date and time in "Etc/UTC" is "<expected>"

    Examples:
      | case     | text                | expected            |
      | PARSE-01 | 2040-02-29 16:05:09 | 2040-02-29 16:05:09 |
      | PARSE-03 | tomorrow            | 2040-02-29 00:00:00 |
      | PARSE-04 | 05/06/2040          | 2040-05-06 00:00:00 |

  @PARSE-02
  Scenario: A nonexistent leap day produces no date
    When I interpret the date text "2041-02-29 16:05:09"
    Then interpretation fails
    And there is no resulting date

  @PARSE-05
  Scenario: Numeric ordering is an explicit input rule
    Given numeric dates put the day before the month
    When I interpret the date text "05/06/2040"
    Then interpretation succeeds
    And the resulting date and time in "Etc/UTC" is "2040-06-05 00:00:00"

  @PARSE-06
  Scenario: Interpreting a leading date leaves unmatched tokens available
    Given the input tokens in order are:
      | token      |
      | 2040-02-29 |
      | 16:05:09   |
      | trailing   |
    When I interpret the leading date tokens
    Then interpretation succeeds
    And the resulting date and time in "Etc/UTC" is "2040-02-29 16:05:09"
    And exactly 2 input tokens have been consumed
    And the remaining tokens in order are:
      | token    |
      | trailing |
