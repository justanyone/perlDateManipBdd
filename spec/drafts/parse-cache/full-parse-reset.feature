@draft @reference-dm700 @observed-compatibility @disputed @parse-cache
Feature: Observe value reads before and after complete parsing
  These scenarios use public parsing, serialized-value, ordered-field, and error
  operations. They describe results and evaluation order without requiring an
  implementation to use a cache.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c"
    And a fresh English ASCII context with US numeric-date order and default time midnight
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And the configured local zone is "Etc/UTC"
    And the receiver was parsed as "2039-12-31 07:08:09 America/New_York"
    And a serialized value is presented as "YYYY-MM-DD HH:MM:SS Zone"
    And ordered fields are presented as [year, month, day, hour, minute, second]
    And every stated error observation occurs immediately after its preceding call
    And every error boundary not stated as nonempty is empty
    And clearing an error produces no application value and leaves the error empty

  Scenario: Complete parsing refreshes all serialized values when none was read first
    When I parse the complete text "2040-02-29 16:05:09 America/New_York"
    Then case "PC-PARSE-PRISTINE" has numeric status 0 and an empty immediate error
    And the parsed-zone serialized value is "2040-02-29 16:05:09 America/New_York"
    And the fixed-local and UTC serialized values are each "2040-02-29 21:05:09 Etc/UTC"
    And every value read has an empty error before and after it
    And the exact public action sequence is "parse complete text \"2040-02-29 16:05:09 America/New_York\"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value"

  Scenario Outline: Complete parsing refreshes a previously read converted representation for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    When I parse the complete text "2040-02-29 16:05:09 America/New_York"
    Then the numeric status is 0 and the immediate error is empty
    And the parsed-zone serialized value is "2040-02-29 16:05:09 America/New_York"
    And the <representation> serialized value is "2040-02-29 21:05:09 Etc/UTC"
    And the <representation> ordered fields are [2040, 2, 29, 21, 5, 9]
    And the <other representation> serialized value is "2040-02-29 21:05:09 Etc/UTC"
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | representation | other representation | exact public action sequence |
      | PC-PARSE-PRE-LOCAL | fixed-local | UTC | read fixed-local serialized value; parse complete text "2040-02-29 16:05:09 America/New_York"; read parsed-zone serialized value; read fixed-local serialized value; read fixed-local ordered fields; read UTC serialized value |
      | PC-PARSE-PRE-GMT | UTC | fixed-local | read UTC serialized value; parse complete text "2040-02-29 16:05:09 America/New_York"; read parsed-zone serialized value; read UTC serialized value; read UTC ordered fields; read fixed-local serialized value |

  Scenario: Complete parsing refreshes values after both converted field records were read
    Given the fixed-local ordered fields were read as [2039, 12, 31, 12, 8, 9]
    And the UTC ordered fields were read as [2039, 12, 31, 12, 8, 9]
    When I parse the complete text "2040-02-29 16:05:09 America/New_York"
    Then case "PC-PARSE-PRE-BOTH-LIST" has numeric status 0 and an empty immediate error
    And the parsed-zone serialized value is "2040-02-29 16:05:09 America/New_York"
    And the fixed-local and UTC serialized values are each "2040-02-29 21:05:09 Etc/UTC"
    And every value read has an empty error before and after it
    And the exact public action sequence is "read fixed-local ordered fields; read UTC ordered fields; parse complete text \"2040-02-29 16:05:09 America/New_York\"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value"

  Scenario: A failed complete parse leaves no parsed-zone value after error clearing
    Given the fixed-local serialized value "2039-12-31 12:08:09 Etc/UTC" was read
    When I parse the complete text "2040-02-30 16:05:09 America/New_York"
    Then case "PC-PARSE-FAIL" has numeric status 1 and immediate error "[parse] Invalid date"
    When I read the parsed-zone serialized value while the error remains
    Then the result is empty text
    And the error before and after that read is "[parse] Invalid date"
    When I clear the error and read the parsed-zone serialized value again
    Then no serialized value is present
    And the error before and after that read is empty
    And the exact public action sequence is "read fixed-local serialized value; parse complete text \"2040-02-30 16:05:09 America/New_York\"; read parsed-zone serialized value; clear error; read parsed-zone serialized value"

  Scenario Outline: A converted read after clearing a complete-parse error fails without a value for <case>
    When I parse the invalid complete text "2040-02-30 16:05:09 America/New_York"
    Then the numeric status is 1 and immediate error is "[parse] Invalid date"
    When I clear the error and request the <representation> serialized value
    Then the request fails without producing a serialized value
    And the error before and after the value request is empty
    When I parse the complete text "2040-03-02 09:10:11 America/New_York"
    Then parsing returns numeric status 0 with an empty immediate error
    And the <representation> serialized value is "2040-03-02 14:10:11 Etc/UTC"
    And the recovery value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | representation | exact public action sequence |
      | PC-PARSE-FAIL-LOCAL-OBSERVER | fixed-local | parse complete text "2040-02-30 16:05:09 America/New_York"; clear error; read fixed-local serialized value; parse complete text "2040-03-02 09:10:11 America/New_York"; read fixed-local serialized value |
      | PC-PARSE-FAIL-GMT-OBSERVER | UTC | parse complete text "2040-02-30 16:05:09 America/New_York"; clear error; read UTC serialized value; parse complete text "2040-03-02 09:10:11 America/New_York"; read UTC serialized value |

  Scenario: A successful complete parse recovers directly from a prior complete-parse error
    Given the UTC serialized value "2039-12-31 12:08:09 Etc/UTC" was read
    And parsing "2040-02-30 16:05:09 America/New_York" returned status 1 with error "[parse] Invalid date"
    When I parse "2040-03-02 09:10:11 America/New_York" without clearing the error
    Then case "PC-PARSE-FAIL-RECOVER" has numeric status 0 and an empty immediate error
    And the parsed-zone serialized value is "2040-03-02 09:10:11 America/New_York"
    And the fixed-local and UTC serialized values are each "2040-03-02 14:10:11 Etc/UTC"
    And every value read after recovery has an empty error before and after it
    And the exact public action sequence is "read UTC serialized value; parse complete text \"2040-02-30 16:05:09 America/New_York\"; parse complete text \"2040-03-02 09:10:11 America/New_York\"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value"
