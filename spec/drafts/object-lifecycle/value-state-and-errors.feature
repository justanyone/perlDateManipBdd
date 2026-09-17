@draft @object-lifecycle @value-carrier @reference-dm700
Feature: Value carriers preserve return context, mutation state, and errors
  Scalar and list reads expose distinct representations, while mutations and
  failures remain visible through the receiver's current value and error text.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And a date carrier is presented portably by losslessly rendering its six civil fields as "YYYY-MM-DD HH:MM:SS"
    And valid date, duration, and recurrence source values use these initial texts:
      | kind | initial text |
      | date | 2040-02-29 16:05:09 |
      | duration | 0:0:0:1:2:3:4 |
      | recurrence | 0:0:1:0:0:0:0 |

  @observed-compatibility
  Scenario: Date value selectors preserve scalar and list return forms
    Given separate date values parsed from "2040-02-29 16:05:09 America/New_York"
    When I read each selector in scalar context and list context
    Then the scalar return and list fields have these normalized civil date-times:
      | selector                 | normalized civil date-time | list                     | list count | error | documentation status |
      | omitted                  | 2040-02-29 16:05:09     | 2040, 2, 29, 16, 5, 9    | 6          |       | documented           |
      | empty text               | 2040-02-29 16:05:09     | 2040, 2, 29, 16, 5, 9    | 6          |       | observed compatibility |
      | unrecognized text OTHER  | 2040-02-29 16:05:09     | 2040, 2, 29, 16, 5, 9    | 6          |       | observed compatibility |
      | local                    | 2040-02-29 21:05:09     | 2040, 2, 29, 21, 5, 9    | 6          |       | documented           |
      | gmt                      | 2040-02-29 21:05:09     | 2040, 2, 29, 21, 5, 9    | 6          |       | documented           |
    And this is case "OBJ-009-DATE-VALUE-CONTEXTS"

  Scenario: An unset date distinguishes empty scalar text from an empty list
    Given two newly constructed date values without initial text
    When I read one in scalar context and one in list context
    Then the scalar result is defined empty text ""
    And the list result has count 0
    And each receiver error becomes "[value] Object does not contain a date"
    And this is case "OBJ-010-DATE-VALUE-UNSET"

  Scenario: Duration values expose seven fields in list context
    Given a duration parsed from "0:0:0:1:2:3:4"
    And a newly constructed duration without initial text
    When I read each duration in scalar and list context
    Then the exact duration values are:
      | state | scalar          | list                  | list count | error |
      | valid | 0:0:0:1:2:3:4  | 0, 0, 0, 1, 2, 3, 4 | 7          |       |
      | fresh | 0:0:0:0:0:0:0  | 0, 0, 0, 0, 0, 0, 0 | 7          |       |
    And this is case "OBJ-011-DELTA-VALUE-CONTEXTS"

  Scenario: A failed duration parse leaves empty scalar and list results
    Given two newly constructed duration values
    When each parses "not a valid delta phrase"
    And I read one in scalar context and one in list context
    Then each parse status is 1
    And the scalar result is defined empty text ""
    And the list result has count 0
    And every error before and after a getter is "[parse] Invalid delta string"
    And this is case "OBJ-012-DELTA-VALUE-ERROR"

  Scenario: Recurrence component getters preserve absent values
    Given a recurrence parsed from "0:0:1:0:0:0:0"
    And a newly constructed recurrence without initial text
    When I read their frequency, start, end, specified base, actual base, and modifiers
    Then the parsed frequency is "0:0:1:0:0:0:0" in scalar context
    And its frequency list has one value "0:0:1:0:0:0:0"
    And the fresh frequency is defined empty text ""
    And both starts and both ends are undefined
    And both base pairs contain two undefined values
    And both modifier lists have count 0
    And every error state is empty
    And this is case "OBJ-013-RECUR-CARRIER-GETTERS"

  @observed-compatibility @disputed
  Scenario: Date field replacement distinguishes component and whole-date validation
    Given independent date values equal to "2040-02-29 16:05:09"
    When I replace the day component with 1
    Then the status is 0, the error is empty, and the normalized civil date-time is "2040-02-01 16:05:09"
    When I replace only the day component with 31 on another value
    Then the status is 0, the error is empty, and the normalized civil date-time is "2040-02-31 16:05:09"
    When I replace the whole date with fields "2040, 2, 31, 16, 5, 9" on another value
    Then the status is 1 and the error is "[set] Invalid date argument"
    And its next scalar read is "" with error "[value] Object does not contain a date"
    When I replace an unknown field "bogus" with 1 on another value
    Then the status is 1 and the error is "[set] Invalid field"
    And its next scalar read is "" with error "[value] Object does not contain a date"
    And every pre-mutation date normalized to "2040-02-29 16:05:09" with an empty error before and after its read
    And this is case "OBJ-014-DATE-SET"

  Scenario: Duration replacement preserves success and failure state
    Given independent durations equal to "0:0:0:1:2:3:4"
    When I replace the hour field with 5 on one duration
    Then the status is 0, the error is empty, and the scalar value is "0:0:0:1:5:3:4"
    When I replace the unknown field "bogus" with 9 on the other duration
    Then the status is 1 and the error is "[set] Unknown option: bogus"
    And its next scalar read is ""
    And its error remains "[set] Unknown option: bogus"
    And both pre-mutation scalar values were "0:0:0:1:2:3:4"
    And each pre-mutation read had an empty error before and after it
    And this is case "OBJ-015-DELTA-SET"

  Scenario: Error reads clear state only for a truthy clear request
    Given valid date, duration, and recurrence values
    When the date parses "not a valid date phrase", the duration parses "not a valid delta phrase", and the recurrence parses "not a valid recurrence phrase"
    Then every parse status is 1
    And their errors are respectively "[parse] Invalid date string", "[parse] Invalid delta string", and "[parse] Invalid frequency string"
    When each error is read with the false numeric request 0
    Then the returned text and stored errors are unchanged
    When each error is read with the true numeric request 1
    Then each return is undefined and every stored error is empty
    And this extends configuration case "CFG-ERROR-CLEAR"
    And this is case "OBJ-016-ERR-LIFECYCLE"

  Scenario: A child parse error does not change its source receiver's error
    Given valid date, duration, and recurrence source values with empty errors
    When each source creates a same-kind child
    And the date child parses "not a valid date phrase", the duration child parses "not a valid delta phrase", and the recurrence child parses "not a valid recurrence phrase"
    Then every child status is 1
    And the child errors are respectively "[parse] Invalid date string", "[parse] Invalid delta string", and "[parse] Invalid frequency string"
    And every source error remains empty
    And this extends configuration case "CFG-ERROR-CLEAR"
    And this is case "OBJ-017-ERR-ISOLATION"

  Scenario: Recurrence component setters expose modifier and frequency resets
    Given a newly constructed recurrence
    When I set frequency "0:0:0:1:0:0:0"
    And I set start "2040-03-01 08:00:00", end "2040-03-05 08:00:00", and base "2040-02-29 08:00:00"
    Then those four setter statuses are 0
    And the start normalized civil date-time is "2040-03-01 08:00:00"
    And the end normalized civil date-time is "2040-03-05 08:00:00"
    And the specified-base normalized civil date-time is "2040-02-29 08:00:00"
    And the actual base is undefined
    And every defined component date read has an empty error before and after it and no exception
    When I replace its modifiers with "fd1" and "bd2"
    Then the modifier status is 0 and the frequency is "0:0:0:1:0:0:0"
    And the modifiers are "fd1, bd2"
    And start and end retain their normalized civil date-times
    And specified base and actual base are undefined
    And the error is empty
    When I replace the frequency with "0:0:0:2:0:0:0"
    Then the status is 0 and the frequency is "0:0:0:2:0:0:0"
    And start, end, specified base, and actual base are undefined
    And the modifier list is empty
    And the error is empty
    And this is case "OBJ-020-RECUR-CARRIER-SET"
