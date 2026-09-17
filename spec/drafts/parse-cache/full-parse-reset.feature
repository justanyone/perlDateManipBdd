@draft @reference-dm700 @observed-compatibility @disputed @parse-cache
Feature: Full parsing resets converted values and exposes its failure state
  These scenarios use only public parsing, value, and error operations.

  Background:
    Given a fresh English date-time context with local zone "Etc/UTC"
    And the receiver was parsed as "2039-12-31 07:08:09 America/New_York"
    And every stated error observation occurs immediately after its preceding call

  Scenario Outline: Full parsing refreshes values after any successful prior read for <case>
    Given the prior value reads are "<prior reads>"
    When I parse the complete text "2040-02-29 16:05:09 America/New_York"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone scalar value is "2040-02-29 16:05:09 America/New_York"
    And the local and GMT scalar values are each "2040-02-29 21:05:09 Etc/UTC"
    And the additional list request is "<list request>" with result "<list result>"
    And every value read has an empty error before and after it

    Examples:
      | case                   | prior reads                    | list request | list result |
      | PC-PARSE-PRISTINE      | none                           | none | not requested |
      | PC-PARSE-PRE-LOCAL     | local scalar                   | local | [2040, 2, 29, 21, 5, 9] |
      | PC-PARSE-PRE-GMT       | GMT scalar                     | GMT | [2040, 2, 29, 21, 5, 9] |
      | PC-PARSE-PRE-BOTH-LIST | local list followed by GMT list | none | not requested |

  Scenario: A failed full parse makes the parsed-zone value absent after error clearing
    Given local scalar value "2039-12-31 12:08:09 Etc/UTC" was read
    When I parse the complete text "2040-02-30 16:05:09 America/New_York"
    Then case "PC-PARSE-FAIL" has numeric status 1 and immediate error "[parse] Invalid date"
    When I read the parsed-zone scalar value while the error remains
    Then the result is empty text
    And the error before and after that read is "[parse] Invalid date"
    When I clear the error and read the parsed-zone scalar value again
    Then the result has absent type
    And the error before and after that read is empty

  Scenario Outline: A converted read after clearing a full-parse error raises for <case>
    When I parse the invalid complete text "2040-02-30 16:05:09 America/New_York"
    Then the numeric status is 1 and immediate error is "[parse] Invalid date"
    When I clear the error and request the <carrier> scalar value
    Then the request returns no value and raises an undefined-value exception
    And exactly eight undefined-component warnings are emitted
    And the error before and after the value request is empty
    When I parse the complete text "2040-03-02 09:10:11 America/New_York"
    Then parsing succeeds and the <carrier> scalar value is "2040-03-02 14:10:11 Etc/UTC"

    Examples:
      | case                         | carrier |
      | PC-PARSE-FAIL-LOCAL-OBSERVER | local   |
      | PC-PARSE-FAIL-GMT-OBSERVER   | GMT     |

  Scenario: A successful full parse recovers directly from a prior full-parse error
    Given GMT scalar value "2039-12-31 12:08:09 Etc/UTC" was read
    And parsing "2040-02-30 16:05:09 America/New_York" returned status 1 with error "[parse] Invalid date"
    When I parse "2040-03-02 09:10:11 America/New_York" without clearing the error
    Then case "PC-PARSE-FAIL-RECOVER" has numeric status 0 and an empty immediate error
    And the parsed-zone scalar value is "2040-03-02 09:10:11 America/New_York"
    And local and GMT scalar values are each "2040-03-02 14:10:11 Etc/UTC"
