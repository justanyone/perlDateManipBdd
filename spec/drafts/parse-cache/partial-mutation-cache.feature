@draft @reference-dm700 @observed-compatibility @disputed @parse-cache
Feature: Observe converted-value reads around successful and failed partial parsing
  These scenarios characterize a reference defect. A portable implementation is
  not expected to reproduce stale values unless it selects this compatibility profile.

  Background:
    Given a fresh English date-time context with local zone "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And the receiver was parsed as "2039-12-31 07:08:09 America/New_York"
    And every stated error observation occurs immediately after its preceding call

  Scenario Outline: A partial parse is current when no converted value was read for <case>
    Given no local or GMT value has been read from the receiver
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone scalar value is "<result>"
    And the local scalar value is "<result>"
    And the GMT scalar value is "<result>"
    And every value read has an empty error before and after it

    Examples:
      | case             | operation         | input      | result                      |
      | PC-DATE-PRISTINE | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC |
      | PC-TIME-PRISTINE | time-only parsing | 16:05:09   | 2039-12-31 16:05:09 Etc/UTC |

  Scenario Outline: A prior parsed-zone read does not stale converted values for <case>
    Given the parsed-zone scalar value was read as "2039-12-31 07:08:09 America/New_York"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone, local, and GMT scalar values are each "<result>"
    And every value read has an empty error before and after it

    Examples:
      | case               | operation         | input      | result                      |
      | PC-DATE-PRE-PARSED | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC |
      | PC-TIME-PRE-PARSED | time-only parsing | 16:05:09   | 2039-12-31 16:05:09 Etc/UTC |

  Scenario Outline: A prior scalar converted read remains stale across contexts for <case>
    Given the <carrier> scalar value was read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone scalar value is "<current>"
    And two repeated <carrier> scalar reads each return stale value "2039-12-31 12:08:09 Etc/UTC"
    And the <carrier> list value is [2039, 12, 31, 12, 8, 9]
    And the previously unread <other carrier> scalar value is "<current>"
    And every value read has an empty error before and after it

    Examples:
      | case                          | operation         | input      | carrier | other carrier | current                     |
      | PC-DATE-PRE-LOCAL-SCALAR      | date-only parsing | 2040-02-29 | local   | GMT           | 2040-02-29 07:08:09 Etc/UTC |
      | PC-DATE-PRE-GMT-SCALAR        | date-only parsing | 2040-02-29 | GMT     | local         | 2040-02-29 07:08:09 Etc/UTC |
      | PC-TIME-PRE-LOCAL-SCALAR      | time-only parsing | 16:05:09   | local   | GMT           | 2039-12-31 16:05:09 Etc/UTC |
      | PC-TIME-PRE-GMT-SCALAR        | time-only parsing | 16:05:09   | GMT     | local         | 2039-12-31 16:05:09 Etc/UTC |

  Scenario Outline: A prior list converted read also stales scalar and list reads for <case>
    Given the <carrier> list value was read as [2039, 12, 31, 12, 8, 9]
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the <carrier> scalar value is stale text "2039-12-31 12:08:09 Etc/UTC"
    And the <carrier> list value remains [2039, 12, 31, 12, 8, 9]
    And every value read has an empty error before and after it

    Examples:
      | case                        | operation         | input      | carrier |
      | PC-DATE-PRE-LOCAL-LIST      | date-only parsing | 2040-02-29 | local   |
      | PC-DATE-PRE-GMT-LIST        | date-only parsing | 2040-02-29 | GMT     |
      | PC-TIME-PRE-LOCAL-LIST      | time-only parsing | 16:05:09   | local   |
      | PC-TIME-PRE-GMT-LIST        | time-only parsing | 16:05:09   | GMT     |

  Scenario Outline: Reading both converted carriers leaves both stale for <case>
    Given local and GMT scalar values were each read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone scalar value is "<current>"
    And the local scalar value remains stale at "2039-12-31 12:08:09 Etc/UTC"
    And the GMT scalar value remains stale at "2039-12-31 12:08:09 Etc/UTC"

    Examples:
      | case             | operation         | input      | current                     |
      | PC-DATE-PRE-BOTH | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC |
      | PC-TIME-PRE-BOTH | time-only parsing | 16:05:09   | 2039-12-31 16:05:09 Etc/UTC |

  Scenario Outline: A failed partial parse keeps its prior value behind the error for <case>
    Given the <carrier> scalar value was read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<invalid input>"
    Then the numeric parse status is 1 and the immediate error is "<error>"
    When I read the <carrier> scalar value while the error remains
    Then the result is empty text
    And the error before and after that read is "<error>"
    When I clear the error
    Then the parsed-zone scalar value is "2039-12-31 07:08:09 America/New_York"
    And the <carrier> scalar value is "2039-12-31 12:08:09 Etc/UTC"

    Examples:
      | case                   | operation         | invalid input | carrier | error                            |
      | PC-DATE-FAIL-PRE-LOCAL | date-only parsing | 2040-02-30    | local   | [parse_date] Invalid date        |
      | PC-TIME-FAIL-PRE-GMT   | time-only parsing | 25:61:70      | GMT     | [parse_time] Invalid time string |

  Scenario Outline: Retrying without clearing the error resets partial-parse defaults for <case>
    Given the <carrier> scalar value was read as "2039-12-31 12:08:09 Etc/UTC"
    And <operation> of "<invalid input>" returned status 1 with error "<error>"
    When I immediately request <operation> of "<valid input>" without clearing the error
    Then that call observes "<error>" before it starts
    And it returns numeric status 0 with an empty immediate error
    And the parsed-zone and <carrier> scalar values are each "<result>"

    Examples:
      | case               | operation         | invalid input | valid input | carrier | error                            | result                      |
      | PC-DATE-FAIL-RESET | date-only parsing | 2040-02-30    | 2040-03-01 | local   | [parse_date] Invalid date        | 2040-03-01 00:00:00 Etc/UTC |
      | PC-TIME-FAIL-RESET | time-only parsing | 25:61:70      | 16:05:09   | GMT     | [parse_time] Invalid time string | 2040-02-28 16:05:09 Etc/UTC |

  Scenario Outline: Clearing the error preserves fields but also preserves a stale converted value for <case>
    Given the <carrier> scalar value was read as "2039-12-31 12:08:09 Etc/UTC"
    And <operation> of "<invalid input>" returned status 1 with error "<error>"
    And I cleared the error
    When I request <operation> of "<valid input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone scalar value is "<current>"
    And the <carrier> scalar value remains stale at "2039-12-31 12:08:09 Etc/UTC"

    Examples:
      | case                            | operation         | invalid input | valid input | carrier | error                            | current                           |
      | PC-DATE-FAIL-CLEAR-THEN-SUCCESS | date-only parsing | 2040-02-30    | 2040-03-01 | local   | [parse_date] Invalid date        | 2040-03-01 07:08:09 Etc/UTC       |
      | PC-TIME-FAIL-CLEAR-THEN-SUCCESS | time-only parsing | 25:61:70      | 16:05:09   | GMT     | [parse_time] Invalid time string | 2039-12-31 16:05:09 Etc/UTC       |

  Scenario Outline: A successful full parse recovers from a stale partial-parse carrier for <case>
    Given the <carrier> scalar value was read as "2039-12-31 12:08:09 Etc/UTC"
    And successful <operation> of "<input>" left that <carrier> read stale at "2039-12-31 12:08:09 Etc/UTC"
    When I parse the complete text "2040-03-02 09:10:11 America/New_York"
    Then the numeric parse status is 0 and the immediate error is empty
    And local and GMT scalar values are each "2040-03-02 14:10:11 Etc/UTC"

    Examples:
      | case                       | operation         | carrier | input |
      | PC-DATE-RECOVER-WITH-PARSE | date-only parsing | local   | 2040-02-29 |
      | PC-TIME-RECOVER-WITH-PARSE | time-only parsing | GMT     | 16:05:09 |
