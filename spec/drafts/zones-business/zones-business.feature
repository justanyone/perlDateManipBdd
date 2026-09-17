@draft @zones @business @events
Feature: Convert civil times and apply a named business calendar
  This draft awaits coordinator review. The named fixture uses English, UTC, a
  fixed 2040-02-28 10:20:30 clock, US numeric dates, midnight for omitted
  times, Monday-first weeks, and tzdata2026c. Its business calendar is Monday
  through Friday from 09:00 through 17:00. Launch Day and Audit Day share
  2040-03-01; 2040-03-02 is an unnamed closure. The current profile also closes
  2040-01-02 as Observed New Year and 2040-12-31 as Year End Closure.
  On 2040-03-01, All-Day Office Event runs 00:00:00 through 23:59:59,
  One-Hour Briefing runs 10:00:00 through 10:59:59, and Two-Hour Review
  runs 13:00:00 through 14:59:59. The legacy profile contains the March
  closures and the first two events only. All event endpoints here are inclusive.

  Scenario Outline: Convert a named civil time for <case>
    When I convert civil time "<input>" from "<from_zone>" to "<to_zone>"
    Then the conversion result is "<result>"

    Examples:
      | case                  | input               | from_zone        | to_zone       | result              |
      | ZB-ZONE-CANONICAL-DM6 | 2040-03-10 12:00:00 | America/New_York | Europe/London | 2040-03-10 17:00:00 |
      | ZB-ZONE-TZ-NAMED      | 2040-03-10 12:00:00 | America/New_York | Europe/London | 2040-03-10 17:00:00 |

  @ZB-ZONE-TZ-OVERLAP
  Scenario: Resolve both interpretations of a daylight-saving overlap
    When I convert the New York civil time "2040-11-04 01:30:00" to UTC with each daylight choice
    Then the daylight interpretation is "2040-11-04 05:30:00"
    And the standard interpretation is "2040-11-04 06:30:00"

  @ZB-ZONE-TZ-GAP
  Scenario: Reject a civil time in a daylight-saving gap
    When I convert the New York civil time "2040-03-11 02:30:00" to UTC
    Then the conversion reports invalid civil time code 4

  @ZB-ZONE-OO-MUTATES
  Scenario: Change the stored zone of a date value
    Given a stored UTC civil time "2040-03-10 12:00:00"
    When I change its zone to "America/New_York"
    Then the stored civil time is "2040-03-10 07:00:00"
    And the change status is 0 with no stored error

  Scenario Outline: Manage a named zone preference for <case>
    When I apply the zone-preference request "<request>"
    Then the observable zone-preference result is "<result>"

    Examples:
      | case                 | request                                            | result                             |
      | ZB-ZONE-RESOLVE      | select the first matching zone for abbreviation EDT                  | America/New_York                   |
      | ZB-ZONE-ALIAS        | add and then remove office-central for America/Chicago    | America/Chicago while defined; no match after removal |
      | ZB-ZONE-ABBREVIATION | prefer America/New_York for EDT, reject UTC as an EDT zone| success; then code 3 with Etc/UTC |
      | ZB-ZONE-OFFSET       | prefer America/New_York for -0500, then use +99:00       | success; then code 9              |

  @ZB-ZONE-PERIODS
  Scenario: Read gap and overlap period data for New York
    When I request the "America/New_York" period at "2040-03-11 02:30:00" and both daylight and standard interpretations of "2040-11-04 01:30:00"
    Then the gap has no period
    And the daylight interpretation is EDT at UTC-04:00
    And the standard interpretation is EST at UTC-05:00

  @ZB-ZONE-CURRENT
  Scenario: Rediscover the fixed profile zone
    When I discover and then rediscover the current profile zone
    Then both results are "Etc/UTC"

  @ZB-ZONE-CANONICAL-DM5
  Scenario: Retain the selected named-zone compatibility result
    When I convert "2040-03-10 12:00:00" from "America/New_York" to "Europe/London" in the legacy compatibility profile
    Then the profile result is "2040-03-10 12:00:00"

  @ZB-ZONE-INVALID
  Scenario: Report two invalid zone conversion requests
    When I convert "2040-03-10 12:00:00" from "Etc/UTC" to "No/Such_Zone"
    And independently request conversion to UTC with source "Etc/UTC", standard-time preference 0, and extra argument "extra"
    Then the reported codes are 3 and 1

  Scenario Outline: Preserve a non-whole-hour offset through a conversion wrapper for <case>
    When I make the fixed-zone conversion request "<request>" for civil time "2040-03-10 12:00:00"
    Then the result is "<result>" with offset "<offset>"

    Examples:
      | case                         | request                                      | result              | offset |
      | ZB-ZONE-FROM-UTC-NONWHOLE    | from UTC to Asia/Kathmandu                   | 2040-03-10 17:45:00 | +05:45 |
      | ZB-ZONE-TO-LOCAL-NONWHOLE    | from Asia/Kathmandu to the fixed local zone  | 2040-03-10 06:15:00 | +00:00 |
      | ZB-ZONE-FROM-LOCAL-NONWHOLE  | from the fixed local zone to Asia/Kathmandu  | 2040-03-10 17:45:00 | +05:45 |

  @ZB-ZONE-DISCOVERY-METHODS @ZB-ZONE-LIST-PERIODS
  Scenario: Set the profile-controlled zone discovery method and list period starts
    When I use the environment-zone discovery method and rediscover the current zone
    Then the current zone is "Etc/UTC"
    When I separately list period starts in 2040 for "America/New_York" and "Asia/Kathmandu"
    Then New York's ordered period starts are:
      | UTC instant | abbreviation | offset |
      | 2040-03-11 07:00:00 | EDT | -04:00:00 |
      | 2040-11-04 06:00:00 | EST | -05:00:00 |
    And Asia/Kathmandu has no period starts

  @ZB-ZONE-CUSTOM-ALIAS-ERROR
  Scenario: Reset custom zone aliases after an invalid alias target
    When I add office-central for America/Chicago, reject broken-office for an unknown zone, and reset all custom aliases
    Then the add status is 0
    And the invalid-target status is 1
    And office-central has no match after the reset

  Scenario Outline: Expose holiday labels and working-day status for <case>
    Given the business-calendar profile "<profile>"
    When I inspect the business calendar at "<input>"
    Then the labels are "<labels>"
    And the time-checked working-day result is <working>

    Examples:
      | case | profile | input | labels | working |
      | ZB-BUSINESS-HOLIDAYS-OO | current-value | 2040-03-01 10:00:00 | Launch Day, Audit Day | 0       |
      | ZB-BUSINESS-HOLIDAYS-DM6 | current-text | 2040-03-01 10:00:00 | Launch Day, Audit Day | 0       |
      | ZB-BUSINESS-HOLIDAYS-DM5 | legacy-text | 2040-03-01 10:00:00 | Audit Day             | 0       |

  @ZB-BUSINESS-WORK-HOURS
  Scenario: Check the inclusive business-hour boundaries
    When I inspect the times on Monday "2040-03-05": 08:59:59, 09:00:00, 17:00:00, and 17:00:01 with time checking enabled
    Then their working-time results are no, yes, yes, and no

  @ZB-BUSINESS-NEXT-PREV
  Scenario: Move from a closure with next and previous operations
    When I apply zero-offset next and previous time-checked operations to "2040-03-01 10:00:00"
    Then each stored civil time is "2040-03-05 09:00:00"
    And a one-day previous operation from "2040-03-05 10:00:00" stores "2040-02-29 10:00:00"

  @ZB-BUSINESS-NEAREST
  Scenario: Choose a nearest business day over a weekend closure span
    When I apply either nearest-day preference to "2040-03-03 10:00:00"
    Then the stored civil time is "2040-03-05 10:00:00"

  @ZB-BUSINESS-LIST-HOLIDAYS
  Scenario: List the configured holiday dates in a leap year
    When I list holidays for 2040
    Then the midnight dates are "2040-01-02", "2040-03-01", "2040-03-02", and "2040-12-31"

  @ZB-BUSINESS-INVALID-STATE @ZB-BUSINESS-NEXT-HOURS
  Scenario: Keep invalid date state and move an after-hours value to the next opening
    When I check the invalid text "not a date" as a working date
    Then parsing reports status 1 and the working-date result is absent
    And the stored error says "Invalid date string"
    When I move "2040-03-05 17:00:01" by zero time-checked working days
    Then the stored civil time is "2040-03-06 09:00:00"

  @ZB-EVENTS-OO-INSTANT
  Scenario: Read full records of events active at an instant
    Given the current-value calendar profile
    When I request events active at "2040-03-01 10:00:00"
    Then the ordered event records are:
      | start | inclusive end | name |
      | 2040-03-01 00:00:00 | 2040-03-01 23:59:59 | All-Day Office Event |
      | 2040-03-01 10:00:00 | 2040-03-01 10:59:59 | One-Hour Briefing |

  Scenario Outline: Read each event-state change during a whole day for <case>
    Given the calendar profile "<profile>"
    When I request timestamped event-state changes for the whole day "2040-03-01"
    Then the ordered changes are:
      | local timestamp | ordered active names |
      | 2040-03-01 00:00:00 | All-Day Office Event |
      | 2040-03-01 10:00:00 | All-Day Office Event, One-Hour Briefing |
      | 2040-03-01 11:00:00 | All-Day Office Event |
      | 2040-03-01 13:00:00 | All-Day Office Event, Two-Hour Review |
      | 2040-03-01 15:00:00 | All-Day Office Event |

    Examples:
      | case | profile |
      | ZB-EVENTS-OO-DAY | current-value |
      | ZB-EVENTS-DM6-DATES | current-text |

  @ZB-EVENTS-OO-RANGE
  Scenario: Read event-state changes within a specified interval
    Given the current-value calendar profile
    When I request timestamped event-state changes from "2040-03-01 10:00:00" through "2040-03-01 14:00:00"
    Then the ordered changes are:
      | local timestamp | ordered active names |
      | 2040-03-01 10:00:00 | All-Day Office Event, One-Hour Briefing |
      | 2040-03-01 11:00:00 | All-Day Office Event |
      | 2040-03-01 13:00:00 | All-Day Office Event, Two-Hour Review |

  @ZB-LEGACY-ERASE-HOLIDAYS
  Scenario: Erase legacy holiday state
    Given the legacy-text calendar profile
    When I read the holiday label at "2040-03-01 10:00:00"
    Then its label is "Audit Day"
    When I erase all holiday state
    Then the holiday label at "2040-03-01 10:00:00" is absent
    And the time-checked working-day result there is 1
