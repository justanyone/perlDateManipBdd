@draft @object-lifecycle @value-carrier @reference-dm700
Feature: Value carriers preserve value representations, mutation state, and errors
  Text and ordered-field reads expose distinct representations, while mutations and
  failures remain visible through the receiver's current value and error text.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And a date carrier is presented portably by losslessly rendering its six civil fields as "YYYY-MM-DD HH:MM:SS"
    And read-serialized-text returns text while read-ordered-fields returns an ordered field record
    And date fields are year, month, day, hour, minute, second
    And duration fields are year, month, week, day, hour, minute, second
    And frequency text and frequency collection are separately named read operations
    And valid date, duration, and recurrence source values use these initial texts:
      | kind | initial text |
      | date | 2040-02-29 16:05:09 |
      | duration | 0:0:0:1:2:3:4 |
      | recurrence | 0:0:1:0:0:0:0 |

  @observed-compatibility
  Scenario: Date value selectors preserve serialized text and ordered fields
    Given separate date values parsed from "2040-02-29 16:05:09 America/New_York"
    When I use read-serialized-text and read-ordered-fields for each selector
    Then the serialized text and ordered fields have these normalized civil date-times:
      | selector | normalized civil date-time | ordered fields | field count | error | documentation status |
      | omitted | 2040-02-29 16:05:09 | 2040, 2, 29, 16, 5, 9 | 6 | empty text | documented |
      | empty text | 2040-02-29 16:05:09 | 2040, 2, 29, 16, 5, 9 | 6 | empty text | observed compatibility |
      | unrecognized text OTHER | 2040-02-29 16:05:09 | 2040, 2, 29, 16, 5, 9 | 6 | empty text | observed compatibility |
      | local | 2040-02-29 21:05:09 | 2040, 2, 29, 21, 5, 9 | 6 | empty text | documented |
      | gmt | 2040-02-29 21:05:09 | 2040, 2, 29, 21, 5, 9 | 6 | empty text | documented |
    And this is case "OBJ-009-DATE-VALUE-CONTEXTS"

  Scenario: An unset date distinguishes empty text from an empty field record
    Given two newly constructed date values without initial text
    When I use read-serialized-text on one and read-ordered-fields on the other
    Then the serialized-text result is defined empty text ""
    And the ordered field record has count 0
    And each receiver error becomes "[value] Object does not contain a date"
    And this is case "OBJ-010-DATE-VALUE-UNSET"

  Scenario: Duration values expose seven ordered fields
    Given a duration parsed from "0:0:0:1:2:3:4"
    And a newly constructed duration without initial text
    When I use read-serialized-text and read-ordered-fields for each duration
    Then the exact duration values are:
      | state | serialized text | ordered fields | field count | error |
      | valid | 0:0:0:1:2:3:4 | 0, 0, 0, 1, 2, 3, 4 | 7 | empty text |
      | fresh | 0:0:0:0:0:0:0 | 0, 0, 0, 0, 0, 0, 0 | 7 | empty text |
    And this is case "OBJ-011-DELTA-VALUE-CONTEXTS"

  Scenario: A failed duration parse leaves empty text and an empty field record
    Given two newly constructed duration values
    When each parses "not a valid delta phrase"
    And I use read-serialized-text on one and read-ordered-fields on the other
    Then each parse status is 1
    And the serialized-text result is defined empty text ""
    And the ordered field record has count 0
    And every error before and after a getter is "[parse] Invalid delta string"
    And this is case "OBJ-012-DELTA-VALUE-ERROR"

  Scenario: Recurrence component getters preserve absent values
    Given a recurrence parsed from "0:0:1:0:0:0:0"
    And a newly constructed recurrence without initial text
    When I read their frequency text, frequency collection, start, end, specified base, actual base, and modifiers
    Then the parsed frequency is "0:0:1:0:0:0:0" as text
    And its frequency collection has one value "0:0:1:0:0:0:0"
    And the fresh frequency is defined empty text ""
    And both starts and both ends are absent
    And both base pairs contain two absent values
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
    And its next serialized-text read is "" with error "[value] Object does not contain a date"
    When I replace an unknown field "bogus" with 1 on another value
    Then the status is 1 and the error is "[set] Invalid field"
    And its next serialized-text read is "" with error "[value] Object does not contain a date"
    And every pre-mutation date normalized to "2040-02-29 16:05:09" with an empty error before and after its read
    And this is case "OBJ-014-DATE-SET"

  Scenario: Duration replacement preserves success and failure state
    Given independent durations equal to "0:0:0:1:2:3:4"
    When I replace the hour field with 5 on one duration
    Then the status is 0, the error is empty, and the serialized text is "0:0:0:1:5:3:4"
    When I replace the unknown field "bogus" with 9 on the other duration
    Then the status is 1 and the error is "[set] Unknown option: bogus"
    And its next serialized-text read is ""
    And its error remains "[set] Unknown option: bogus"
    And both pre-mutation serialized texts were "0:0:0:1:2:3:4"
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
    Then each return is absent and every stored error is empty
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
    And the actual base is absent
    And every defined component date read has an empty error before and after it and no exception
    When I replace its modifiers with "fd1" and "bd2"
    Then the modifier status is 0 and the frequency is "0:0:0:1:0:0:0"
    And the modifiers are "fd1, bd2"
    And start and end retain their normalized civil date-times
    And specified base and actual base are absent
    And the error is empty
    When I replace the frequency with "0:0:0:2:0:0:0"
    Then the status is 0 and the frequency is "0:0:0:2:0:0:0"
    And start, end, specified base, and actual base are absent
    And the modifier list is empty
    And the error is empty
    And this is case "OBJ-020-RECUR-CARRIER-SET"
