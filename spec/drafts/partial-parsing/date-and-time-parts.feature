@draft @partial-parsing @reference-dm700
Feature: Change only the date or time part of a date-time value
  Every example starts in a fresh English context. Results use a generic
  date-time value request; implementation bindings are recorded separately.

  Background:
    Given the local time zone is "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And numeric dates use month/day/year order
    And omitted clock fields default to midnight

  Scenario Outline: Change the date part while applying receiver defaults for <case>
    Given the date-time receiver is "<initial>"
    When I request date-only parsing of "<text>" with no parser gates
    Then the numeric status is 0
    And the receiver is local date-time "<result>"
    And the error text is empty

    Examples:
      | case       | initial                     | text          | result                      |
      | PP-DATE-01 | unset                       | 2040-02-29    | 2040-02-29 00:00:00 Etc/UTC |
      | PP-DATE-02 | 2039-12-31 07:08:09 Etc/UTC | 2040-02-29    | 2040-02-29 07:08:09 Etc/UTC |
      | PP-DATE-03 | 2039-12-31 07:08:09 Etc/UTC | March 1 2040  | 2040-03-01 07:08:09 Etc/UTC |
      | PP-DATE-04 | 2039-12-31 07:08:09 Etc/UTC | 2040-02       | 2040-02-01 07:08:09 Etc/UTC |
      | PP-DATE-05 | 2039-12-31 07:08:09 Etc/UTC | Wednesday     | 2040-02-29 07:08:09 Etc/UTC |
      | PP-DATE-06 | 2039-12-31 07:08:09 Etc/UTC | tomorrow      | 2040-02-29 07:08:09 Etc/UTC |
      | PP-DATE-13 | 2039-12-31 07:08:09 Etc/UTC | last day in March 2040 | 2040-03-31 07:08:09 Etc/UTC |

  Scenario Outline: Reject a disabled or invalid date-only request without changing the receiver for <case>
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request date-only parsing of "<text>" with parser gates "<gates>"
    Then the numeric status is 1
    And the error text is "<error>"
    And reading the receiver as date-time text returns empty text while that error is present
    And the error text after that read is "<error>"
    And clearing the error returns no value
    And the error text is empty after clearing
    And a new date-time text read returns "2039-12-31 07:08:09 Etc/UTC"
    And the error text remains empty after that read

    Examples:
      | case       | text          | gates       | error                                  |
      | PP-DATE-07 | --02          | noiso8601   | [parse_date] Invalid date string       |
      | PP-DATE-08 | March 1 2040  | nocommon    | [parse_date] Invalid date string       |
      | PP-DATE-09 | Wednesday     | nodow       | [parse_date] Invalid date string       |
      | PP-DATE-14 | last day in March 2040 | noother | [parse_date] Invalid date string       |
      | PP-DATE-11 | [empty text]  | none        | [parse_date] Empty date string         |
      | PP-DATE-12 | 2040-02-30    | none        | [parse_date] Invalid date              |

  @PP-DATE-10 @observed-compatibility @disputed
  Scenario: Special and relative gates do not prevent the observed tomorrow spelling
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request date-only parsing of "tomorrow" with parser gates "nospecial, nodelta"
    Then the numeric status is 0
    And the receiver is local date-time "2040-02-29 07:08:09 Etc/UTC"
    And the error text is empty

  Scenario Outline: Parse every complete ISO time form for <case>
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request time-only parsing of "<text>" with no parser gates
    Then the numeric status is 0
    And the receiver is local date-time "<result>"
    And the error text is empty

    Examples:
      | case         | form          | text        | result                      |
      | PP-TIME-I01  | HHMNSS        | 160509      | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-I02  | HH:MN:SS      | 16:05:09    | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-I03  | HHMNSS,S+     | 160509,25   | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-I04  | HH:MN:SS,S+   | 16:05:09,25 | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-I05  | HHMN,M+       | 1605,5      | 2039-12-31 16:05:30 Etc/UTC |
      | PP-TIME-I06  | HH:MN,M+      | 16:05,5     | 2039-12-31 16:05:30 Etc/UTC |
      | PP-TIME-I07  | HH,H+         | 16,5        | 2039-12-31 16:30:00 Etc/UTC |
      | PP-TIME-I08  | -MNSS         | -0509       | 2039-12-31 10:05:09 Etc/UTC |
      | PP-TIME-I09  | -MN:SS       | -05:09      | 2039-12-31 10:05:09 Etc/UTC |
      | PP-TIME-I10  | --SS          | --09        | 2039-12-31 10:20:09 Etc/UTC |
      | PP-TIME-I11  | -MNSS,S+      | -0509,25    | 2039-12-31 10:05:09 Etc/UTC |
      | PP-TIME-I12  | -MN:SS,S+     | -05:09,25   | 2039-12-31 10:05:09 Etc/UTC |
      | PP-TIME-I13  | -MN,M+        | -05,5       | 2039-12-31 10:05:30 Etc/UTC |
      | PP-TIME-I14  | --SS,S+       | --09,25     | 2039-12-31 10:20:09 Etc/UTC |
      | PP-TIME-I15  | HHMN          | 1605        | 2039-12-31 16:05:00 Etc/UTC |
      | PP-TIME-I16  | HH:MN         | 16:05       | 2039-12-31 16:05:00 Etc/UTC |

  Scenario Outline: Parse each truncated ISO time form for <case>
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request time-only parsing of "<text>" with no parser gates
    Then the numeric status is 0
    And the receiver is local date-time "<result>"

    Examples:
      | case        | form | text | result                      |
      | PP-TIME-T01 | HH   | 16   | 2039-12-31 16:00:00 Etc/UTC |
      | PP-TIME-T02 | -MN  | -05  | 2039-12-31 10:05:00 Etc/UTC |

  Scenario Outline: Parse non-ISO numeric, meridiem, and fractional time for <case>
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request time-only parsing of "<text>" with parser gates "<gates>"
    Then the numeric status is 0
    And the receiver is local date-time "<result>"

    Examples:
      | case        | form             | text          | gates     | result                      |
      | PP-TIME-O01 | H24:MN:SS        | 23:05:09      | noiso8601 | 2039-12-31 23:05:09 Etc/UTC |
      | PP-TIME-O02 | H12:MN:SS AM     | 4:05:09 PM    | none      | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-O03 | H12:MN:SS        | 4:05:09       | noiso8601 | 2039-12-31 04:05:09 Etc/UTC |
      | PP-TIME-O04 | H24:MN:SS,S+     | 23:05:09.25   | none      | 2039-12-31 23:05:09 Etc/UTC |
      | PP-TIME-O05 | H12:MN:SS,S+ AM  | 4:05:09.25 PM | none      | 2039-12-31 16:05:09 Etc/UTC |
      | PP-TIME-O06 | H12:MN:SS,S+     | 4:05:09.25    | none      | 2039-12-31 04:05:09 Etc/UTC |
      | PP-TIME-O07 | H24:MN,M+        | 23:05.5       | none      | 2039-12-31 23:05:30 Etc/UTC |
      | PP-TIME-O08 | H12:MN,M+ AM     | 4:05.5 PM     | none      | 2039-12-31 16:05:30 Etc/UTC |
      | PP-TIME-O09 | H12:MN,M+        | 4:05.5        | none      | 2039-12-31 04:05:30 Etc/UTC |
      | PP-TIME-O10 | H24,H+           | 23.5          | none      | 2039-12-31 23:30:00 Etc/UTC |
      | PP-TIME-O11 | H12,H+ AM        | 4.5 PM        | none      | 2039-12-31 16:30:00 Etc/UTC |
      | PP-TIME-O12 | H12,H+           | 4.5           | none      | 2039-12-31 04:30:00 Etc/UTC |
      | PP-TIME-O13 | H24:MN           | 23:05         | noiso8601 | 2039-12-31 23:05:00 Etc/UTC |
      | PP-TIME-O14 | H12:MN AM        | 4:05 PM       | none      | 2039-12-31 16:05:00 Etc/UTC |
      | PP-TIME-O15 | H12:MN           | 4:05          | noiso8601 | 2039-12-31 04:05:00 Etc/UTC |
      | PP-TIME-O16 | H12 AM           | 4 PM          | none      | 2039-12-31 16:00:00 Etc/UTC |

  @PP-TIME-DEFAULT
  Scenario: An unset receiver takes its civil date from the fixed reference clock
    Given the date-time receiver is unset
    When I request time-only parsing of "16:05:09" with no parser gates
    Then the numeric status is 0
    And the receiver is local date-time "2040-02-28 16:05:09 Etc/UTC"

  Scenario Outline: Reject a disabled or invalid time without changing the receiver for <case>
    Given the date-time receiver is "2039-12-31 07:08:09 Etc/UTC"
    When I request time-only parsing of "<text>" with parser gates "<gates>"
    Then the numeric status is 1
    And the error text is "<error>"
    And reading the receiver as date-time text returns empty text while that error is present
    And the error text after that read is "<error>"
    And clearing the error returns no value
    And the error text is empty after clearing
    And a new date-time text read returns "2039-12-31 07:08:09 Etc/UTC"
    And the error text remains empty after that read

    Examples:
      | case               | text         | gates       | error                                  |
      | PP-TIME-GATE-ISO   | 160509       | noiso8601   | [parse_time] Invalid time string       |
      | PP-TIME-GATE-OTHER | noon         | noother     | [parse_time] Invalid time string       |
      | PP-TIME-EMPTY      | [empty text] | none        | [parse_time] Empty time string         |
      | PP-TIME-INVALID    | 25:61:70     | none        | [parse_time] Invalid time string       |
