@draft @reference-dm700 @input-history @observed-compatibility
Feature: Remember the source text of a date across public changes

  Background:
    Given a fresh English ASCII context with local zone "Etc/UTC"
    And numeric dates use month/day/year order and omitted clocks use midnight
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And quoted text and argument lists use JSON notation to preserve whitespace and absent values
    And date-value text is the lossless six-field form "YYYY-MM-DD HH:MM:SS"

  Scenario: Read remembered source text for INPUT-FRESH
    Given a newly constructed date without initial text
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"

  Scenario: Read remembered source text for INPUT-VALID
    Given a newly constructed date without initial text
    When I parse the complete date text with arguments ["2040-02-29 16:05:09 Etc/UTC"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is "2040-02-29 16:05:09 Etc/UTC"
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is ["2040-02-29 16:05:09 Etc/UTC"]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-02-29 16:05:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-SPACING
    Given a newly constructed date without initial text
    When I parse the complete date text with arguments ["  February 29, 2040 16:05:09  "]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is "  February 29, 2040 16:05:09  "
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is ["  February 29, 2040 16:05:09  "]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-02-29 16:05:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-EMPTY
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse the complete date text with arguments [""]
    Then the action return is 1
    And the immediate error is "[parse] Empty date string"
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is "[parse] Empty date string"
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is "[parse] Empty date string"
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"

  Scenario: Read remembered source text for INPUT-ABSENT
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse the complete date text with arguments [null]
    Then the action return is 1
    And the immediate error is "[parse] Empty date string"
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is "[parse] Empty date string"
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is "[parse] Empty date string"
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"

  Scenario: Read remembered source text for INPUT-INVALID
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse the complete date text with arguments ["not a calendar date"]
    Then the action return is 1
    And the immediate error is "[parse] Invalid date string"
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is "[parse] Invalid date string"
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is "[parse] Invalid date string"
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"

  Scenario: Read remembered source text for INPUT-REPARSE
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse the complete date text with arguments ["March 1 2040"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is "March 1 2040"
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is ["March 1 2040"]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-03-01 00:00:00"
    And the error is ""

  Scenario: Read remembered source text for INPUT-DATE-ONLY
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I replace the date by parsing with arguments ["2040-03-02"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-03-02 16:05:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-TIME-ONLY
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I replace the time by parsing with arguments ["07:08:09"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-02-29 07:08:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-DATE-FAIL
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I replace the date by parsing with arguments ["not a calendar date"]
    Then the action return is 1
    And the immediate error is "[parse_date] Invalid date string"
    When I read the remembered source text as one text result
    Then the result is "2040-02-29 16:05:09 Etc/UTC"
    And the error is "[parse_date] Invalid date string"
    When I read the remembered source text as a collection
    Then the collection is ["2040-02-29 16:05:09 Etc/UTC"]
    And the error is "[parse_date] Invalid date string"
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[parse_date] Invalid date string"

  Scenario: Read remembered source text for INPUT-TIME-FAIL
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I replace the time by parsing with arguments ["invalid clock"]
    Then the action return is 1
    And the immediate error is "[parse_time] Invalid time string"
    When I read the remembered source text as one text result
    Then the result is "2040-02-29 16:05:09 Etc/UTC"
    And the error is "[parse_time] Invalid time string"
    When I read the remembered source text as a collection
    Then the collection is ["2040-02-29 16:05:09 Etc/UTC"]
    And the error is "[parse_time] Invalid time string"
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[parse_time] Invalid time string"

  Scenario: Read remembered source text for INPUT-PATTERN
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse with the supplied pattern and text with arguments ["%Y/%m/%d", "2040/03/02"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is "2040/03/02"
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is ["2040/03/02"]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-03-02 00:00:00"
    And the error is ""

  @disputed
  Scenario: Read remembered source text for INPUT-PATTERN-FAIL
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse with the supplied pattern and text with arguments ["%Y/%m/%d", "invalid"]
    Then the action return is 1
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"

  Scenario: Read remembered source text for INPUT-SET
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I replace the supplied date field with arguments ["d", 1]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-02-01 16:05:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-CONVERT
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I convert the date to the supplied zone with arguments ["America/New_York"]
    Then the action return is 0
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is "2040-02-29 11:05:09"
    And the error is ""

  Scenario: Read remembered source text for INPUT-CLEAR-ERROR
    Given a date parsed from "2040-02-29 16:05:09 Etc/UTC"
    When I parse the complete date text with arguments ["not a calendar date"]
    Then the action return is 1
    And the immediate error is "[parse] Invalid date string"
    When I clear the error with the supplied true request with arguments [1]
    Then the action return is null
    And the immediate error is ""
    When I read the remembered source text as one text result
    Then the result is ""
    And the error is ""
    When I read the remembered source text as a collection
    Then the collection is [""]
    And the error is ""
    When I subsequently read the date value
    Then the date-value text is ""
    And the error is "[value] Object does not contain a date"
