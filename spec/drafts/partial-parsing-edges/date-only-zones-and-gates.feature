@draft @reference-dm700 @partial-parsing-edges
Feature: Date-only option reachability, zones, and daylight-saving transitions
  All requests use public date parsing operations. Each receiver is fresh, and no
  value getter is called before the operation under test.

  Background:
    Given displayed date-times normalize the native six civil fields to "YYYY-MM-DD HH:MM:SS"
    And zone labels describe the supplied context; abbreviation and offset assertions are separate
    And an English ASCII date-time context
    And the fixed reference date-time is "2040-02-28 10:20:30"
    And the configured local zone is "Etc/UTC" unless the scenario overrides it
    And numeric dates use month/day/year order

  @observed-compatibility @disputed
  Scenario Outline: A selected delta or holiday spelling is full-parser-only for <case>
    Given the full parser and date-only parser each start with "2039-12-31 07:08:09 Etc/UTC"
    And when testing "Founders Day", the only configured holiday is February 29 named "Founders Day"
    And "<text>" is enabled in the full parser by the configured context
    When each parser receives "<text>" with and without gate "<gate>" in fresh receivers
    Then the ungated full parser succeeds with "<full result>"
    And the gated full parser returns status 1 with error "[parse] Invalid date string"
    And reading that gated full-parser receiver returns empty text and changes the error to "[value] Object does not contain a date"
    And clearing that error returns no value and leaves the error empty
    And the next receiver read returns empty text and sets error "[value] Object does not contain a date"
    But both date-only requests return status 1 with error "[parse_date] Invalid date string"
    And reading either date-only receiver returns empty text without replacing that error
    And clearing either error returns no value and leaves the error empty
    And the next read from either date-only receiver returns "2039-12-31 07:08:09 Etc/UTC"
    And the error remains empty after each retained-value read

    Examples:
      | case                       | text         | gate       | full result                  |
      | PPE-DATE-GATE-NODELTA      | 2 days ago   | nodelta    | 2040-02-26 10:20:30 Etc/UTC |
      | PPE-DATE-GATE-NOHOLIDAYS   | Founders Day | noholidays | 2040-02-29 00:00:00 Etc/UTC |

  Scenario: Date-only parsing replaces the prior parsed zone with the configured local zone
    Given case "PPE-DATE-ZONE-RESET" has receiver "2039-12-31 07:08:09 America/New_York"
    And the configured local zone is "Etc/UTC"
    When I request date-only parsing of "2040-02-29"
    Then the numeric status is 0 and the immediate error is empty
    And the parsed-zone value is "2040-02-29 07:08:09 Etc/UTC"
    And the GMT value is "2040-02-29 07:08:09 Etc/UTC"
    And the rendered zone is "UTC" with offset "+0000"

  Scenario Outline: Date-only parsing rejects a selected explicit zone suffix for <case>
    Given the receiver is "2039-12-31 07:08:09 America/New_York"
    When I request date-only parsing of "<text>"
    Then the numeric status is 1 and the immediate error is "[parse_date] Invalid date string"
    And a value read while the error remains returns empty text without replacing that error
    And clearing the error returns no value
    And the error is empty after clearing
    And the next value read returns "2039-12-31 07:08:09 America/New_York"
    And the error remains empty after that read

    Examples:
      | case                 | text                              |
      | PPE-DATE-ZONE-NAME   | 2040-02-29 America/New_York       |
      | PPE-DATE-ZONE-OFFSET | 2040-02-29 -05:00                 |

  Scenario Outline: A retained clock is checked against the configured local DST period for <case>
    Given the configured local zone is "America/New_York"
    And the receiver is "<initial>"
    When I request date-only parsing of "<date>"
    Then the numeric status is 0 and the immediate error is empty
    And the parsed-zone value is "<result>"
    And the GMT value is "<gmt>"
    And the rendered zone and offset are "<zone>"

    Examples:
      | case                    | initial                                      | date       | result                                   | gmt                       | zone      |
      | PPE-DATE-DST-BEFORE-GAP | 2040-03-10 01:30:00 America/New_York         | 2040-03-11 | 2040-03-11 01:30:00 America/New_York      | 2040-03-11 06:30:00 Etc/UTC | EST\|-0500 |
      | PPE-DATE-DST-AFTER-GAP  | 2040-03-10 03:30:00 America/New_York         | 2040-03-11 | 2040-03-11 03:30:00 America/New_York      | 2040-03-11 07:30:00 Etc/UTC | EDT\|-0400 |
      | PPE-DATE-DST-OVERLAP    | 2040-11-03 01:30:00 America/New_York         | 2040-11-04 | 2040-11-04 01:30:00 America/New_York      | 2040-11-04 06:30:00 Etc/UTC | EST\|-0500 |

  Scenario: Date-only parsing rejects a retained clock in a daylight-saving gap
    Given case "PPE-DATE-DST-GAP" uses configured local zone "America/New_York"
    And the receiver is "2040-03-10 02:30:00 America/New_York"
    When I request date-only parsing of "2040-03-11"
    Then the numeric status is 1 and the immediate error is "[parse_date] Invalid date in timezone"
    And a value read while the error remains returns empty text without replacing that error
    And clearing the error returns no value
    And the error is empty after clearing
    And the next value read returns "2040-03-10 02:30:00 America/New_York"
    And the error remains empty after that read
