@draft @reference-dm700 @partial-parsing-edges
Feature: Time-only zones, daylight-saving transitions, and fractional boundaries
  Each receiver is fresh, and no value getter is called before time-only parsing.

  Background:
    Given displayed date-times normalize the native six civil fields to "YYYY-MM-DD HH:MM:SS"
    And zone labels describe the supplied context; abbreviation and offset assertions are separate
    And an English ASCII date-time context
    And the process time zone is "Etc/UTC"
    And the configured local zone is "Etc/UTC" unless the scenario overrides it
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"

  Scenario Outline: A complete time can set an explicit zone for <case>
    Given the receiver is "2040-02-29 10:20:30 Etc/UTC"
    When I request time-only parsing of "<text>"
    Then the numeric status is 0 and the immediate error is empty
    And the parsed-zone value is "<result>"
    And the GMT value is "<gmt>"
    And the rendered zone and offset are "<zone>"

    Examples:
      | case                          | text                           | result                                      | gmt                         | zone        |
      | PPE-TIME-ZONE-NAME            | 16:05:09 America/New_York      | 2040-02-29 16:05:09 America/New_York        | 2040-02-29 21:05:09 Etc/UTC | EST\|-0500   |
      | PPE-TIME-ZONE-OFFSET          | 16:05:09-05:00                 | 2040-02-29 16:05:09 fixed offset -05:00     | 2040-02-29 21:05:09 Etc/UTC | -05\|-0500   |
      | PPE-TIME-ZONE-ABBREVIATION    | 16:05:09 EST                   | 2040-02-29 16:05:09 EST                     | 2040-02-29 21:05:09 Etc/UTC | EST\|-0500   |
      | PPE-TIME-ZONE-NONISO          | 4:05 PM America/New_York       | 2040-02-29 16:05:00 America/New_York        | 2040-02-29 21:05:00 Etc/UTC | EST\|-0500   |

  Scenario: A truncated time cannot carry an explicit zone
    Given case "PPE-TIME-ZONE-TRUNCATED" has receiver "2040-02-29 10:20:30 Etc/UTC"
    When I request time-only parsing of "16 America/New_York"
    Then the numeric status is 1 and the immediate error is "[parse_time] Invalid time string"
    And reading the receiver while the error remains returns empty text without replacing that error
    And clearing the error returns no value
    And the error is empty after clearing
    And the next value read returns "2040-02-29 10:20:30 Etc/UTC"
    And the error remains empty after that read

  Scenario Outline: A daylight-saving gap time is rejected for <case>
    Given the receiver is "2040-03-11 01:30:00 America/New_York"
    And the configured local zone is "<local zone>"
    When I request time-only parsing of "<text>"
    Then the numeric status is 1 and the immediate error is "[parse_time] Invalid date in timezone"
    And reading the receiver while the error remains returns empty text without replacing that error
    And clearing the error returns no value
    And the error is empty after clearing
    And the next value read returns "2040-03-11 01:30:00 America/New_York"
    And the error remains empty after that read

    Examples:
      | case                          | local zone       | text                         |
      | PPE-TIME-DST-GAP              | America/New_York | 02:30:00                     |
      | PPE-TIME-DST-GAP-EXPLICIT     | Etc/UTC          | 02:30:00 America/New_York    |

  Scenario Outline: An overlap chooses or validates an offset for <case>
    Given the receiver is "2040-11-04 00:30:00 America/New_York"
    And the configured local zone is "<local zone>"
    When I request time-only parsing of "<text>"
    Then the numeric status is 0 and the immediate error is empty
    And the parsed-zone civil fields are "2040-11-04 01:30:00"
    And the GMT value is "<gmt>"
    And the rendered zone and offset are "<zone>"

    Examples:
      | case                         | text         | local zone | gmt                         | zone      |
      | PPE-TIME-DST-OVERLAP-DEFAULT | 01:30:00     | America/New_York | 2040-11-04 06:30:00 Etc/UTC | EST\|-0500 |
      | PPE-TIME-DST-OVERLAP-EDT     | 01:30:00 EDT | Etc/UTC | 2040-11-04 05:30:00 Etc/UTC | EDT\|-0400 |
      | PPE-TIME-DST-OVERLAP-EST     | 01:30:00 EST | Etc/UTC | 2040-11-04 06:30:00 Etc/UTC | EST\|-0500 |

  Scenario Outline: Fractional seconds are accepted and discarded for <case>
    Given the receiver is "2040-02-28 10:20:30 Etc/UTC"
    When I request time-only parsing of "<text>"
    Then the numeric status is 0 and the immediate error is empty
    And the receiver is "2040-02-28 23:59:59 Etc/UTC"

    Examples:
      | case                         | text               |
      | PPE-TIME-FRAC-SECOND-ZERO    | 23:59:59.0         |
      | PPE-TIME-FRAC-SECOND-NINE    | 23:59:59.9         |
      | PPE-TIME-FRAC-SECOND-MANY    | 23:59:59.999999    |

  Scenario Outline: Fractional minutes and hours stop below the next unit boundary for <case>
    Given the receiver is "2040-02-28 10:20:30 Etc/UTC"
    When I request time-only parsing of "<text>"
    Then the numeric status is 0 and the immediate error is empty
    And the receiver is "<result>"

    Examples:
      | case                              | text          | result                      |
      | PPE-TIME-FRAC-MINUTE-ZERO         | 23:59.0       | 2040-02-28 23:59:00 Etc/UTC |
      | PPE-TIME-FRAC-MINUTE-HALF         | 23:59.5       | 2040-02-28 23:59:30 Etc/UTC |
      | PPE-TIME-FRAC-MINUTE-BELOW-SECOND | 23:59.016666  | 2040-02-28 23:59:00 Etc/UTC |
      | PPE-TIME-FRAC-MINUTE-AT-SECOND    | 23:59.016667  | 2040-02-28 23:59:01 Etc/UTC |
      | PPE-TIME-FRAC-MINUTE-NEAR-CARRY   | 23:59.999999  | 2040-02-28 23:59:59 Etc/UTC |
      | PPE-TIME-FRAC-HOUR-HALF           | 23.5          | 2040-02-28 23:30:00 Etc/UTC |
      | PPE-TIME-FRAC-HOUR-BELOW-MINUTE   | 23.016666     | 2040-02-28 23:00:59 Etc/UTC |
      | PPE-TIME-FRAC-HOUR-AT-MINUTE      | 23.016667     | 2040-02-28 23:01:00 Etc/UTC |
      | PPE-TIME-FRAC-HOUR-NEAR-CARRY     | 23.999999     | 2040-02-28 23:59:59 Etc/UTC |

  @observed-compatibility @disputed
  Scenario: Time-only parsing of 24:00:00 resets the clock without advancing the date
    Given case "PPE-TIME-24-HOUR" has receiver "2040-02-28 10:20:30 Etc/UTC"
    When I request time-only parsing of "24:00:00"
    Then the numeric status is 0 and the immediate error is empty
    And the receiver is "2040-02-28 00:00:00 Etc/UTC"

  Scenario Outline: Invalid fractional boundary text preserves the receiver for <case>
    Given the receiver is "2040-02-28 10:20:30 Etc/UTC"
    When I request time-only parsing of "<text>"
    Then the numeric status is 1 and the immediate error is "[parse_time] Invalid time string"
    And reading the receiver while the error remains returns empty text without replacing that error
    And clearing the error returns no value
    And the error is empty after clearing
    And the next value read returns "2040-02-28 10:20:30 Etc/UTC"
    And the error remains empty after that read

    Examples:
      | case                         | text       |
      | PPE-TIME-FRAC-INVALID-24     | 24:00.1    |
      | PPE-TIME-FRAC-INVALID-DOUBLE | 23:59.1.2  |
