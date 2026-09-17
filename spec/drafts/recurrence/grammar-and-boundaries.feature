@draft @recurrence @grammar @reference-observed
Feature: Interpret finite recurrence frequency and field inputs
  Each assertion below is a pinned-reference observation awaiting semantic review.

  Background:
    Given the named recurrence fixture "utc-working-week-2040"

  Scenario Outline: Interpret frequency form <case>
    Given a fresh recurrence without an anchor
    When I set its frequency text to "<text>"
    Then setting the frequency succeeds
    And the stored frequency text is "<stored>"
    When I set the requested anchor to "<anchor>" in "Etc/UTC", omitting that operation when the input is "absent"
    And I request indexed event 0
    Then the event is "<event>" in "Etc/UTC" with lookup error zero

    Examples:
      | case                         | text                         | anchor              | stored                       | event               |
      | RECUR-GRAMMAR-DAILY-INTERVAL | 0:0:0:2:0:0:0                | 2040-04-13 12:34:56 | 0:0:0:2:0:0:0                | 2040-04-13 12:34:56 |
      | RECUR-GRAMMAR-MONTHLY-DAY    | 0:1*0:31:0:0:0               | 2040-01-31 12:34:56 | 0:1*0:31:0:0:0               | 2040-01-31 00:00:00 |
      | RECUR-GRAMMAR-WEEKLY-DAY     | 0:0:1*5:0:0:0                | 2040-04-13 12:34:56 | 0:0:1*5:0:0:0                | 2040-04-13 00:00:00 |
      | RECUR-GRAMMAR-FIXED-DATE     | *2040:4:0:13:12:34:56        | absent              | *2040:4:0:13:12:34:56        | 2040-04-13 12:34:56 |
      | RECUR-GRAMMAR-WRITTEN-WEEK   | every Tuesday in June 2040    | absent              | 1*6:1,2,3,4,5:2:0:0:0         | 2040-06-05 00:00:00 |
      | RECUR-GRAMMAR-WRITTEN-ORDINAL| 2nd Tuesday in June 2040      | absent              | 1*6:2:2:0:0:0                 | 2040-06-12 00:00:00 |
      | RECUR-GRAMMAR-WRITTEN-LAST   | last day of every month in 2040 | absent             | 0:1*0:-1:0:0:0                | 2040-01-31 00:00:00 |
      | RECUR-GRAMMAR-WRITTEN-EVERY  | every 2nd day in 2040         | absent              | 0:0:0:2*0:0:0                 | 2040-01-01 00:00:00 |

  Scenario Outline: Reject invalid frequency form <case>
    When I set a recurrence frequency to "<text>"
    Then setting the frequency reports status 1
    And the stored frequency is empty
    And the object error is "<error>"

    Examples:
      | case                         | text                   | error                                      |
      | RECUR-FREQ-INVALID-TOKEN     | 0:0:0:bad:0:0:0        | [frequency] Invalid frequency string       |
      | RECUR-FREQ-INVALID-FIELDS    | 0:0:0:1:0:0            | [frequency] Invalid frequency string       |
      | RECUR-FREQ-INVALID-SPLITS    | 0:0*0:1*0:0:0:0        | [frequency] Invalid frequency string       |
      | RECUR-FREQ-INVALID-WEEKDAY   | 0:0:1*9:0:0:0          | [frequency] Day of week must be 1-7        |

  @RECUR-FREQ-RECOVERY
  Scenario: A valid replacement clears a rejected frequency error
    Given a recurrence whose frequency is "0:0:0:1:0:0:0"
    When I replace its frequency with "0:0:0:bad:0:0:0"
    Then replacement reports status 1
    And the stored frequency is empty
    And the object error is "[frequency] Invalid frequency string"
    When I replace its frequency with "0:0:0:2:0:0:0"
    Then replacement succeeds
    And the stored frequency is "0:0:0:2:0:0:0"
    And the object error is empty

  Scenario Outline: Store an equivalent date field from <carrier> for <case>
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    When I set its <field> to "<input>" using <carrier>
    Then setting the field succeeds
    And the stored <field> is "<stored>" in "Etc/UTC"
    And the object error is empty

    Examples:
      | case                         | field            | carrier    | input               | stored             |
      | RECUR-SETTER-START-TEXT      | lower bound      | date text  | 2040-04-13 00:00:00 | 2040-04-13 00:00:00 |
      | RECUR-SETTER-START-TYPED     | lower bound      | date value | 2040-04-13 00:00:00 | 2040-04-13 00:00:00 |
      | RECUR-SETTER-END-TEXT        | upper bound      | date text  | 2040-04-15 23:59:59 | 2040-04-15 23:59:59 |
      | RECUR-SETTER-END-TYPED       | upper bound      | date value | 2040-04-15 23:59:59 | 2040-04-15 23:59:59 |
      | RECUR-SETTER-BASE-TEXT       | requested anchor | date text  | 2040-04-13 12:34:56 | 2040-04-13 12:34:56 |
      | RECUR-SETTER-BASE-TYPED      | requested anchor | date value | 2040-04-13 12:34:56 | 2040-04-13 12:34:56 |

  Scenario Outline: Reject invalid date field <case>
    Given a recurrence with frequency text "0:0:0:1:0:0:0"
    When I set its <field> to invalid date text "not a date"
    Then setting the field reports status 1
    And the stored <field> is absent
    And the object error is "<error>"

    Examples:
      | case                     | field            | error                       |
      | RECUR-SETTER-START-INVALID| lower bound     | [start] Invalid date string |
      | RECUR-SETTER-END-INVALID  | upper bound     | [end] Invalid date string   |
      | RECUR-SETTER-BASE-INVALID | requested anchor| [base] Invalid date string  |

  @RECUR-RANGE-DAY-DEFAULT
  Scenario: A day-sized default range uses the fixed reference date
    Given the recurrence range setting is "day"
    When I parse daily frequency text "0:0:0:1:0:0:0" without explicit dates
    Then parsing succeeds
    And the stored lower bound is "2040-02-28 00:00:00" in "Etc/UTC"
    And the stored upper bound is "2040-02-28 23:59:59" in "Etc/UTC"
    And enumeration returns exactly "2040-02-28 00:00:00" in "Etc/UTC"

  @RECUR-MAX-ATTEMPTS-EXCEPTION @compatibility @disputed
  Scenario: A one-attempt impossible February selection raises a runtime exception
    Given the maximum recurrence attempts setting is 1
    And a recurrence with frequency text "1*2:0:30:0:0:0" is anchored at "2040-02-01 00:00:00" in "Etc/UTC"
    When I request the next event
    Then execution raises a diagnostic containing "Can't use an undefined value as an ARRAY reference"
    And no lookup error is returned
