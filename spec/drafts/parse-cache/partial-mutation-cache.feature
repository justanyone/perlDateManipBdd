@draft @reference-dm700 @observed-compatibility @disputed @parse-cache
Feature: Observe value history around date-only and time-only parsing
  These scenarios characterize a reference defect through public results. A
  portable implementation need not reproduce earlier converted values unless it
  selects this compatibility profile, and it need not use a cache internally.

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

  Scenario Outline: Partial parsing yields current representations when none was read first for <case>
    Given no converted representation has been read from the receiver
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone, fixed-local, and UTC serialized values are each "<result>"
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | input | result | exact public action sequence |
      | PC-DATE-PRISTINE | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC | parse date-only text "2040-02-29"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |
      | PC-TIME-PRISTINE | time-only parsing | 16:05:09 | 2039-12-31 16:05:09 Etc/UTC | parse time-only text "16:05:09"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |

  Scenario Outline: A prior parsed-zone read leaves converted results current for <case>
    Given the parsed-zone serialized value was read as "2039-12-31 07:08:09 America/New_York"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone, fixed-local, and UTC serialized values are each "<result>"
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | input | result | exact public action sequence |
      | PC-DATE-PRE-PARSED | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC | read parsed-zone serialized value; parse date-only text "2040-02-29"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |
      | PC-TIME-PRE-PARSED | time-only parsing | 16:05:09 | 2039-12-31 16:05:09 Etc/UTC | read parsed-zone serialized value; parse time-only text "16:05:09"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |

  Scenario Outline: A previously read converted serialized value remains visible after partial parsing for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone serialized value is "<current>"
    And two repeated <representation> serialized reads each return "2039-12-31 12:08:09 Etc/UTC"
    And the <representation> ordered fields are [2039, 12, 31, 12, 8, 9]
    And the previously unread <other representation> serialized value is "<current>"
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | input | representation | other representation | current | exact public action sequence |
      | PC-DATE-PRE-LOCAL-SCALAR | date-only parsing | 2040-02-29 | fixed-local | UTC | 2040-02-29 07:08:09 Etc/UTC | read fixed-local serialized value; parse date-only text "2040-02-29"; read parsed-zone serialized value; read fixed-local serialized value; read fixed-local serialized value; read fixed-local ordered fields; read UTC serialized value |
      | PC-DATE-PRE-GMT-SCALAR | date-only parsing | 2040-02-29 | UTC | fixed-local | 2040-02-29 07:08:09 Etc/UTC | read UTC serialized value; parse date-only text "2040-02-29"; read parsed-zone serialized value; read UTC serialized value; read UTC serialized value; read UTC ordered fields; read fixed-local serialized value |
      | PC-TIME-PRE-LOCAL-SCALAR | time-only parsing | 16:05:09 | fixed-local | UTC | 2039-12-31 16:05:09 Etc/UTC | read fixed-local serialized value; parse time-only text "16:05:09"; read parsed-zone serialized value; read fixed-local serialized value; read fixed-local serialized value; read fixed-local ordered fields; read UTC serialized value |
      | PC-TIME-PRE-GMT-SCALAR | time-only parsing | 16:05:09 | UTC | fixed-local | 2039-12-31 16:05:09 Etc/UTC | read UTC serialized value; parse time-only text "16:05:09"; read parsed-zone serialized value; read UTC serialized value; read UTC serialized value; read UTC ordered fields; read fixed-local serialized value |

  Scenario Outline: Previously read converted fields remain visible after partial parsing for <case>
    Given the <representation> ordered fields were read as [2039, 12, 31, 12, 8, 9]
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the <representation> serialized value is "2039-12-31 12:08:09 Etc/UTC"
    And the <representation> ordered fields remain [2039, 12, 31, 12, 8, 9]
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | input | representation | exact public action sequence |
      | PC-DATE-PRE-LOCAL-LIST | date-only parsing | 2040-02-29 | fixed-local | read fixed-local ordered fields; parse date-only text "2040-02-29"; read fixed-local serialized value; read fixed-local ordered fields |
      | PC-DATE-PRE-GMT-LIST | date-only parsing | 2040-02-29 | UTC | read UTC ordered fields; parse date-only text "2040-02-29"; read UTC serialized value; read UTC ordered fields |
      | PC-TIME-PRE-LOCAL-LIST | time-only parsing | 16:05:09 | fixed-local | read fixed-local ordered fields; parse time-only text "16:05:09"; read fixed-local serialized value; read fixed-local ordered fields |
      | PC-TIME-PRE-GMT-LIST | time-only parsing | 16:05:09 | UTC | read UTC ordered fields; parse time-only text "16:05:09"; read UTC serialized value; read UTC ordered fields |

  Scenario Outline: Reading both converted representations leaves both earlier values visible for <case>
    Given fixed-local and UTC serialized values were each read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone serialized value is "<current>"
    And the fixed-local serialized value remains "2039-12-31 12:08:09 Etc/UTC"
    And the UTC serialized value remains "2039-12-31 12:08:09 Etc/UTC"
    And every value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | input | current | exact public action sequence |
      | PC-DATE-PRE-BOTH | date-only parsing | 2040-02-29 | 2040-02-29 07:08:09 Etc/UTC | read fixed-local serialized value; read UTC serialized value; parse date-only text "2040-02-29"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |
      | PC-TIME-PRE-BOTH | time-only parsing | 16:05:09 | 2039-12-31 16:05:09 Etc/UTC | read fixed-local serialized value; read UTC serialized value; parse time-only text "16:05:09"; read parsed-zone serialized value; read fixed-local serialized value; read UTC serialized value |

  Scenario Outline: A failed partial parse preserves the prior value behind its error for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    When I request <operation> of "<invalid input>"
    Then the numeric parse status is 1 and the immediate error is "<error>"
    When I read the <representation> serialized value while the error remains
    Then the result is empty text
    And the error before and after that read is "<error>"
    When I clear the error
    Then the parsed-zone serialized value is "2039-12-31 07:08:09 America/New_York"
    And the <representation> serialized value is "2039-12-31 12:08:09 Etc/UTC"
    And every read after clearing has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | invalid input | representation | error | exact public action sequence |
      | PC-DATE-FAIL-PRE-LOCAL | date-only parsing | 2040-02-30 | fixed-local | [parse_date] Invalid date | read fixed-local serialized value; parse date-only text "2040-02-30"; read fixed-local serialized value; clear error; read parsed-zone serialized value; read fixed-local serialized value |
      | PC-TIME-FAIL-PRE-GMT | time-only parsing | 25:61:70 | UTC | [parse_time] Invalid time string | read UTC serialized value; parse time-only text "25:61:70"; read UTC serialized value; clear error; read parsed-zone serialized value; read UTC serialized value |

  Scenario Outline: Retrying without clearing the error resets partial-parse defaults for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    And <operation> of "<invalid input>" returned status 1 with error "<error>"
    When I immediately request <operation> of "<valid input>" without clearing the error
    Then that call observes "<error>" before it starts
    And it returns numeric status 0 with an empty immediate error
    And the parsed-zone and <representation> serialized values are each "<result>"
    And every subsequent value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | invalid input | valid input | representation | error | result | exact public action sequence |
      | PC-DATE-FAIL-RESET | date-only parsing | 2040-02-30 | 2040-03-01 | fixed-local | [parse_date] Invalid date | 2040-03-01 00:00:00 Etc/UTC | read fixed-local serialized value; parse date-only text "2040-02-30"; parse date-only text "2040-03-01"; read parsed-zone serialized value; read fixed-local serialized value |
      | PC-TIME-FAIL-RESET | time-only parsing | 25:61:70 | 16:05:09 | UTC | [parse_time] Invalid time string | 2040-02-28 16:05:09 Etc/UTC | read UTC serialized value; parse time-only text "25:61:70"; parse time-only text "16:05:09"; read parsed-zone serialized value; read UTC serialized value |

  Scenario Outline: Clearing the error preserves fields and an earlier converted value for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    And <operation> of "<invalid input>" returned status 1 with error "<error>"
    And I cleared the error
    When I request <operation> of "<valid input>"
    Then the numeric parse status is 0 and the immediate error is empty
    And the parsed-zone serialized value is "<current>"
    And the <representation> serialized value remains "2039-12-31 12:08:09 Etc/UTC"
    And every subsequent value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | invalid input | valid input | representation | error | current | exact public action sequence |
      | PC-DATE-FAIL-CLEAR-THEN-SUCCESS | date-only parsing | 2040-02-30 | 2040-03-01 | fixed-local | [parse_date] Invalid date | 2040-03-01 07:08:09 Etc/UTC | read fixed-local serialized value; parse date-only text "2040-02-30"; clear error; parse date-only text "2040-03-01"; read parsed-zone serialized value; read fixed-local serialized value |
      | PC-TIME-FAIL-CLEAR-THEN-SUCCESS | time-only parsing | 25:61:70 | 16:05:09 | UTC | [parse_time] Invalid time string | 2039-12-31 16:05:09 Etc/UTC | read UTC serialized value; parse time-only text "25:61:70"; clear error; parse time-only text "16:05:09"; read parsed-zone serialized value; read UTC serialized value |

  Scenario Outline: Complete parsing recovers from an earlier converted partial-parse result for <case>
    Given the <representation> serialized value was read as "2039-12-31 12:08:09 Etc/UTC"
    And successful <operation> of "<input>" left that representation at "2039-12-31 12:08:09 Etc/UTC"
    When I parse the complete text "2040-03-02 09:10:11 America/New_York"
    Then the numeric parse status is 0 and the immediate error is empty
    And fixed-local and UTC serialized values are each "2040-03-02 14:10:11 Etc/UTC"
    And every subsequent value read has an empty error before and after it
    And the exact public action sequence is "<exact public action sequence>"

    Examples:
      | case | operation | representation | input | exact public action sequence |
      | PC-DATE-RECOVER-WITH-PARSE | date-only parsing | fixed-local | 2040-02-29 | read fixed-local serialized value; parse date-only text "2040-02-29"; read fixed-local serialized value; parse complete text "2040-03-02 09:10:11 America/New_York"; read fixed-local serialized value; read UTC serialized value |
      | PC-TIME-RECOVER-WITH-PARSE | time-only parsing | UTC | 16:05:09 | read UTC serialized value; parse time-only text "16:05:09"; read UTC serialized value; parse complete text "2040-03-02 09:10:11 America/New_York"; read fixed-local serialized value; read UTC serialized value |
