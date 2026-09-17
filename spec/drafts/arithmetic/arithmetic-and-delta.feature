@draft @arithmetic @delta
Feature: Calculate civil-field changes and manage intervals
  This draft is based on repeatable reference observations and awaits semantic review.

  Background:
    Given each case starts in a fresh isolated arithmetic configuration:
      | setting             | value                              |
      | language            | English                            |
      | character encoding  | ASCII                              |
      | local time zone     | Etc/UTC                            |
      | reference date-time | 2040-02-28 10:20:30 Etc/UTC        |
      | numeric date order  | month before day                   |
      | omitted time        | midnight                           |
      | first weekday       | Monday                             |
      | first week          | the week containing January 4     |
      | work week           | Monday through Friday              |
      | work hours          | 09:00 through 17:00                |
      | 24-hour workday     | disabled                           |
      | holidays            | none                               |
      | events              | none                               |
    And interval normalization uses these relationships:
      | larger unit                         | smaller-unit value |
      | minute                              | 60 seconds         |
      | hour                                | 60 minutes         |
      | standard day                        | 24 hours           |
      | standard week                       | 7 days             |
      | year for year-month normalization   | 12 months          |
      | year for estimated conversion       | 365.2425 days      |
      | configured business day             | 8 hours            |
      | configured business week            | 5 days             |
    And interval field records use this order:
      | position | field  |
      | 1        | year   |
      | 2        | month  |
      | 3        | week   |
      | 4        | day    |
      | 5        | hour   |
      | 6        | minute |
      | 7        | second |

  @ARITH-DIFF
  Scenario Outline: Find the signed clock difference between two civil timestamps for <case>
    When I subtract civil timestamp "<from>" from civil timestamp "<to>"
    Then the signed hour-minute-second fields are "<result>"

    Examples:
      | case                    | from                | to                  | result |
      | ARITH-DIFF-FORWARD      | 2040-02-28 10:20:30 | 2040-03-01 11:22:33 | 49:2:3 |
      | ARITH-DIFF-REVERSE-LEAP | 2040-03-01 00:00:00 | 2040-02-29 23:59:59 | 0:0:-1 |

  @ARITH-DAYS
  Scenario Outline: Move a civil date by calendar days for <case>
    When I move civil fields "<date>" by <days> calendar days with subtraction "<subtract>"
    Then the civil fields are "<result>"

    Examples:
      | case                         | date                | days | subtract | result              |
      | ARITH-DAYS-FORWARD           | 2040-02-28          | 2    | no       | 2040-03-01          |
      | ARITH-DAYS-SUBTRACT-DATETIME | 2040-03-01 10:20:30 | 1    | yes      | 2040-02-29 10:20:30 |
      | ARITH-DAYS-ZERO              | 2040-12-31          | 0    | no       | 2040-12-31          |

  @ARITH-DATE-DELTA
  Scenario Outline: Apply an interval field record to civil fields for <case>
    When I apply interval fields "<delta>" to civil fields "<date>" with subtraction "<subtract>"
    Then the civil fields are "<result>"

    Examples:
      | case                      | date                | delta          | subtract | result              |
      | ARITH-DELTA-YEAR-MONTH     | 2040-01-31 23:59:59 | 1:1:0:0:0:0:2  | no       | 2041-03-01 00:00:01 |
      | ARITH-DELTA-WEEK-DAY-TIME  | 2040-02-28 10:20:30 | 0:0:1:2:3:4:5  | no       | 2040-03-08 13:24:35 |
      | ARITH-DELTA-MIXED-SUBTRACT | 2040-03-01 00:00:00 | 0:0:0:-1:0:0:1 | yes      | 2040-03-01 23:59:59 |

  @ARITH-DATE-TIME
  Scenario Outline: Apply clock fields to a civil timestamp for <case>
    When I apply hour-minute-second fields "<clock>" to civil timestamp "<date>"
    Then the civil fields are "<result>"

    Examples:
      | case                     | date                | clock    | result              |
      | ARITH-TIME-CARRY         | 2040-02-29 23:59:59 | 0:0:2    | 2040-03-01 00:00:01 |
      | ARITH-TIME-NEGATIVE      | 2040-03-01 00:00:00 | -1:-2:-3 | 2040-02-29 22:57:57 |
      | ARITH-TIME-OUTSIDE-RANGE | 2040-12-31 00:00:00 | 25:61:61 | 2041-01-01 02:02:01 |

  @ARITH-COMBINE-TIMES
  Scenario Outline: Combine signed clock fields for <case>
    When I combine hour-minute-second fields "<left>" and "<right>" with subtraction "<subtract>"
    Then the signed clock fields are "<result>"

    Examples:
      | case                            | left    | right | subtract | result   |
      | ARITH-COMBINE-ADD               | 1:59:59 | 2:2:2 | no       | 4:2:1    |
      | ARITH-COMBINE-SUBTRACT-NEGATIVE | 0:0:0   | 1:2:3 | yes      | -1:-2:-3 |

  @DELTA-CREATE-EMPTY
  Scenario: Create an empty interval
    When I create an interval in this configuration
    Then its seven fields are "0:0:0:0:0:0:0"
    And its stored type is "exact" and its stored mode is "standard"

  @DELTA-PARSE
  Scenario Outline: Parse interval text with its supplied option record for <case>
    When I parse interval text "<text>" with option record "<supplied-options>"
    Then the status is <status>
    And the seven interval fields are "<result>"
    And the observed stored mode is "<stored-mode>" and stored type is "<stored-type>"

    Examples:
      | case                           | text            | supplied-options        | status | result          | stored-mode | stored-type |
      | DELTA-PARSE-COMPACT-1          | 5               | omitted; defaults apply | 0      | 0:0:0:0:0:0:5  | standard    | exact       |
      | DELTA-PARSE-COMPACT-7          | 1:2:3:4:5:6:7   | omitted; defaults apply | 0      | 1:2:3:4:5:6:7  | standard    | approx      |
      | DELTA-PARSE-BUSINESS           | 2 business days | omitted; defaults apply | 0      | 0:0:0:2:0:0:0  | business    | exact       |
      | DELTA-PARSE-FRACTION-ESTIMATED | 1.5 hours       | type=estimated          | 0      | 0:0:0:0:1:30:0 | standard    | estimated   |

  @DELTA-READ-VALUE-NORMAL
  Scenario: Read a valid interval as text and an ordered field record
    Given interval text "1:2:3:4:5:6:7" has been parsed with default options
    When I read its value as text and as an ordered field record
    Then the text is "1:2:3:4:5:6:7"
    And the ordered field record is "1:2:3:4:5:6:7"

  @DELTA-INPUT-WHITESPACE
  Scenario: Retain trimmed successfully parsed input
    When I parse interval text "  2 days  " with default options
    Then the retained input is "2 days"
    And the seven interval fields are "0:0:0:2:0:0:0"

  @DELTA-SET-PARTIAL-NONORM
  Scenario: Replace selected interval fields without normalizing them
    Given an interval parsed from "1 day" with default options
    When I set hour to 25, minute to 61, type to "approx", and normalization to "not normalized"
    Then the status is 0
    And the seven interval fields are "0:0:0:1:25:61:0"
    And its stored type is "approx"

  @DELTA-PRINT-FAMILIES
  Scenario: Render the five interval pattern families with stated patterns
    Given an interval parsed from "1:2:3:4:5:6:7" with default options
    When I render patterns "%%", "%yv", "%hym", "%Dt", and "%Dym"
    Then the rendered values are "%", "1", "10831.89", "+1:2:+3:4:+5:6:7", and "+1:2:+3:4:+5:6"

  @DELTA-FORMAT-DM6
  Scenario: Render compatibility patterns in the current compatibility profile
    When I use render-each-pattern with interval "1:2:3:4:5:6:7", type "approx", decimal places 2, and patterns "%yv" and "%hd" in the current compatibility profile
    Then the ordered rendered texts are "1" and "5.10"
    When I use render-joined-patterns with interval "1:2:3:4:5:6:7", type "approx", decimal places 2, and patterns "%yv" and "%hd" in the current compatibility profile
    Then the joined rendered text is "1 5.10"

  @DELTA-FORMAT-DM5
  Scenario: Render compatibility patterns in the legacy compatibility profile
    When I use render-each-pattern with interval "1:2:3:4:5:6:7", type "approx", decimal places 2, and patterns "%yv" and "%hd" in the legacy compatibility profile
    Then the ordered rendered texts are "1" and "5.10"
    When I use render-joined-patterns with interval "1:2:3:4:5:6:7", type "approx", decimal places 2, and patterns "%yv" and "%hd" in the legacy compatibility profile
    Then the joined rendered text is "1 5.10"

  @DELTA-TYPE-ALL
  Scenario: Query an explicitly semi interval
    Given an interval parsed from "1 day" with type "semi"
    When I query types "exact", "semi", "approx", "estimated", "standard", and "business"
    Then the answers are "no", "yes", "no", "no", "yes", and "no"

  @DELTA-CONVERT-LESS-EXACT
  Scenario: Convert an automatically approximate calendar interval toward the same type
    Given an interval parsed from "1 year 2 days" whose stored type is "approx"
    When I convert it to "approx"
    Then its stored type is "approx"
    And the seven interval fields are "1:0:0:2:0:0:0"

  @DELTA-CMP
  Scenario Outline: Compare two intervals for <case>
    When I compare interval "<left>" with interval "<right>"
    Then the comparison result is <result>

    Examples:
      | case                 | left           | right            | result |
      | DELTA-CMP-ORDER      | 1 hour         | 2 hours          | -1     |
      | DELTA-CMP-MIXED-TYPE | 1 month        | 30 days          | 1      |
      | DELTA-CMP-BUSINESS   | 1 business day | 7 business hours | 1      |

  @ARITH-CALCULATE
  Scenario Outline: Calculate with a concrete operand kind, selector, and mode for <case>
    Given arithmetic profile "<profile>"
    When I calculate <left-kind> "<left>" with <right-kind> "<right>" using subtraction "<subtract>" and mode "<mode>"
    Then the returned value is "<result>"

    Examples:
      | case | profile | left-kind | left                | right-kind | right               | subtract | mode      | result           |
      | ARITH-OO-DATE-DELTA | current-value | date      | 2040-02-28 10:20:30 | interval   | 2 days              | no       | automatic | 2040-03-01 10:20:30 |
      | ARITH-OO-SUBTRACT-BUSINESS | current-value | date      | 2040-03-04 10:00:00 | interval   | 1 business day      | yes      | automatic | 2040-03-02 09:00:00 |
      | ARITH-DM6-DATE-DATE | current-text | date      | 2040-02-28 10:20:30 | date       | 2040-03-01 10:20:30 | no       | exact     | 0:0:0:0:48:0:0   |
      | ARITH-DM5-DATE-DATE | legacy-text | date      | 02/28/2040 10:20:30 | date       | 03/01/2040 10:20:30 | no       | exact     | +0:0:0:2:0:0:0   |

  @DELTA-PARSE-INVALID-ORDER
  Scenario: An out-of-order interval is rejected without a field record
    When I parse interval text "2 days 1 year" with omitted options
    Then the parse status is 1
    And the error text is "[parse] Invalid delta string"
    And its serialized interval text is empty
    And its ordered field collection is empty
    And the stored mode is "standard" and stored type is "exact"
