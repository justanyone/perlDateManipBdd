@draft @object-lifecycle @reference-dm700
Feature: Object construction chooses a value kind and a configuration context
  Date, duration, and recurrence values can create fresh carriers that either share
  their configuration context or receive an independently configurable copy.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And a date carrier is presented portably by losslessly rendering its six civil fields as "YYYY-MM-DD HH:MM:SS"
    And read-serialized-text returns text while read-ordered-fields returns an ordered field record
    And date fields are year, month, day, hour, minute, second
    And duration fields are year, month, week, day, hour, minute, second
    And valid date, duration, and recurrence source values use these initial texts:
      | kind | initial text |
      | date | 2040-02-29 16:05:09 |
      | duration | 0:0:0:1:2:3:4 |
      | recurrence | 0:0:1:0:0:0:0 |

  Scenario: Each direct constructor parses an initial value
    When I directly construct a date from "2040-02-29 16:05:09"
    And I directly construct a duration from "0:0:0:1:2:3:4"
    And I directly construct a recurrence from "0:0:1:0:0:0:0"
    Then the carrier classes are "date", "duration", and "recurrence"
    And the date's normalized civil date-time is "2040-02-29 16:05:09"
    And the date ordered field record is "2040, 2, 29, 16, 5, 9"
    And the duration serialized text is "0:0:0:1:2:3:4"
    And the duration ordered field record is "0, 0, 0, 1, 2, 3, 4"
    And the recurrence frequency is "0:0:1:0:0:0:0"
    And every error state is empty
    And this is case "OBJ-001-DIRECT-CONSTRUCTORS"

  Scenario: Receiver construction keeps the kind and starts with a fresh carrier
    Given date, duration, and recurrence receivers with the stated initial texts
    When each receiver creates another value without initial text
    Then the date child is a date with serialized text "" and ordered field record containing no fields
    And the date child error is "[value] Object does not contain a date"
    And the duration child is a duration with serialized text "0:0:0:0:0:0:0"
    And the duration child ordered field record is "0, 0, 0, 0, 0, 0, 0"
    And the recurrence child is a recurrence with frequency ""
    And each source retains its original value
    And this is case "OBJ-002-RECEIVER-NEW-EMPTY"

  Scenario: Every receiver kind can use every typed construction shortcut
    Given one valid receiver of each kind
    When each receiver calls the date, duration, and recurrence construction shortcuts without initial text
    Then the resulting classes are:
      | receiver kind | date shortcut | duration shortcut | recurrence shortcut |
      | date          | date          | duration          | recurrence          |
      | duration      | date          | duration          | recurrence          |
      | recurrence    | date          | duration          | recurrence          |
    And this is case "OBJ-003-SHORTCUT-CLASS-MATRIX"

  Scenario: Typed shortcuts parse their supplied initial text
    Given one valid receiver of each kind
    When the date receiver creates a duration from "0:0:0:2:3:4:5"
    And the duration receiver creates a recurrence from "0:0:0:1:0:0:0"
    And the recurrence receiver creates a date from "2040-03-01 05:06:07"
    Then the duration serialized text is "0:0:0:2:3:4:5"
    And the duration ordered field record is "0, 0, 0, 2, 3, 4, 5"
    And the recurrence frequency is "0:0:0:1:0:0:0"
    And the date's normalized civil date-time is "2040-03-01 05:06:07"
    And the date ordered field record is "2040, 3, 1, 5, 6, 7"
    And this is case "OBJ-004-SHORTCUT-INITIAL-VALUES"

  Scenario: A class constructor accepts a source receiver of another kind
    Given one valid receiver of each kind
    When a duration receiver supplies the context for a date constructed from "2040-03-02 06:07:08"
    And a recurrence receiver supplies the context for a duration constructed from "0:0:0:3:4:5:6"
    And a date receiver supplies the context for a recurrence constructed from "0:0:0:1:0:0:0"
    Then the date's normalized civil date-time is "2040-03-02 06:07:08"
    And the duration serialized text is "0:0:0:3:4:5:6"
    And the recurrence frequency is "0:0:0:1:0:0:0"
    And this is case "OBJ-005-CROSS-KIND-CLASS-NEW"

  Scenario: Same-kind receiver construction shares configuration changes
    Given date, duration, and recurrence sources configured with US numeric-date order
    When each source creates a same-kind child without an independent context
    And each child changes numeric-date order to non-US
    Then the source and child numeric-date orders for every kind are both "non-US"
    When each source changes numeric-date order to US
    Then the source and child numeric-date orders for every kind are both "US"
    And every configuration mutation and read has an empty error and no exception
    And this extends configuration case "CFG-CONTEXT-DERIVE"
    And this is case "OBJ-006-CONFIG-SHARED-SAME-KIND"

  Scenario: Typed shortcuts share configuration across all receiver kinds
    Given date, duration, and recurrence sources configured with US numeric-date order
    When each source creates one child of every kind through typed shortcuts
    And the date child changes numeric-date order to non-US
    Then that source and all three children read numeric-date order "non-US"
    And the observed classes for each source are "date, duration, recurrence"
    And every configuration mutation and read has an empty error and no exception
    And this extends configuration case "CFG-CONTEXT-SERVICES"
    And this is case "OBJ-007-CONFIG-SHARED-SHORTCUTS"

  Scenario: Independent-context construction isolates every receiver kind
    Given date, duration, and recurrence sources configured with US numeric-date order
    When each source creates a same-kind value with an independent context and non-US numeric-date order
    Then the initial source and child orders for every kind are "US" and "non-US"
    When each child changes numeric-date order to US
    Then the source and child orders for every kind are both "US"
    When each source changes numeric-date order to non-US
    Then the source and child orders for every kind are "non-US" and "US"
    And every configuration mutation and read has an empty error and no exception
    And this extends configuration case "CFG-CONTEXT-DERIVE"
    And this is case "OBJ-008-CONFIG-ISOLATED-KINDS"

  @reference-binding
  Scenario: Lifecycle method availability follows the public receiver surfaces
    Given one valid receiver of each kind
    When I query public lifecycle method availability
    Then the availability matrix is:
      | receiver   | new | new_config | new_date | new_delta | new_recur | value | set | err | config | get_config | clone | clear | reset |
      | date       | yes | yes        | yes      | yes       | yes       | yes   | yes | yes | yes    | yes        | no    | no    | no    |
      | duration   | yes | yes        | yes      | yes       | yes       | yes   | yes | yes | yes    | yes        | no    | no    | no    |
      | recurrence | yes | yes        | yes      | yes       | yes       | no    | no  | yes | yes    | yes        | no    | no    | no    |
    And this is case "OBJ-018-METHOD-CALLABILITY"

  Scenario: Invalid constructor text leaves typed objects with errors
    When I directly construct a date from "not a valid date phrase", a duration from "not a valid delta phrase", and a recurrence from "not a valid recurrence phrase"
    Then all three typed objects are returned
    And the date error before its getter is "[parse] Invalid date string"
    And the date getter returns "" and changes its error to "[value] Object does not contain a date"
    And the duration error before and after its getter is "[parse] Invalid delta string"
    And the duration getter returns ""
    And the recurrence error before and after its frequency getter is "[parse] Invalid frequency string"
    And the recurrence frequency getter returns ""
    And this is case "OBJ-019-INVALID-CONSTRUCTORS"
