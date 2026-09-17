@draft @arithmetic @dst @business
Feature: Calculate across daylight transitions and business boundaries
  This draft uses the explicit isolated configuration below. Cases with a named
  zone override the local zone. Founders Day is added only where stated.

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

  @ARITH-DST-EDGES
  Scenario Outline: Add one elapsed hour around a daylight transition for <case>
    When I add interval "1 hour" to local date-time "<start>"
    Then the returned local date-time is "<result>"

    Examples:
      | case                            | start                                | result              |
      | ARITH-DST-SPRING-BEFORE-ELAPSED | 2040-03-11 01:30:00 America/Chicago | 2040-03-11 03:30:00    |
      | ARITH-DST-SPRING-AFTER-ELAPSED  | 2040-03-11 03:30:00 America/Chicago | 2040-03-11 04:30:00    |
      | ARITH-DST-FALL-BEFORE-ELAPSED   | 2040-11-04 00:30:00 America/Chicago | 2040-11-04 01:30:00    |
      | ARITH-DST-FALL-AT-OVERLAP       | 2040-11-04 01:30:00 America/Chicago | 2040-11-04 02:30:00    |
      | ARITH-DST-FALL-AFTER-ELAPSED    | 2040-11-04 02:30:00 America/Chicago | 2040-11-04 03:30:00    |

  @ARITH-DST-GAP
  Scenario: Reject a nonexistent spring wall-clock time
    When I add interval "1 hour" to local date-time "2040-03-11 02:00:00 America/Chicago"
    Then parsing the left date reports status 1 and error "[parse] Invalid date in timezone"
    And the returned date value has error "[calc] Date object invalid"
    When I read its serialized date text
    Then the text is empty
    And its error becomes "[value] Object does not contain a date"

  @ARITH-DST-CALENDAR-VERSUS-ELAPSED
  Scenario Outline: Distinguish a calendar day from elapsed hours through the spring transition for <case>
    When I add interval "<interval>" to local date-time "2040-03-10 12:00:00 America/Chicago"
    Then the returned local date-time is "<result>"

    Examples:
      | case                          | interval | result           |
      | ARITH-DST-SPRING-CALENDAR-DAY | 1 day    | 2040-03-11 12:00:00 |
      | ARITH-DST-SPRING-ELAPSED-24H  | 24 hours | 2040-03-11 13:00:00 |

  @ARITH-CROSS-ZONE
  Scenario: Compare equal wall clocks in Chicago and New York
    When I calculate the exact interval from "2040-03-10 12:00:00 America/Chicago" to "2040-03-10 12:00:00 America/New_York"
    Then the interval fields are "0:0:0:0:-1:0:0"

  @ARITH-BUSINESS-ENDPOINTS
  Scenario Outline: Classify a workday hour boundary for <case>
    When I ask whether "<time>" is a business day while checking the time
    Then the answer is <answer>

    Examples:
      | case                    | time                | answer |
      | BUSINESS-HOURS-BEFORE   | 2040-03-01 08:59:59 | no     |
      | BUSINESS-HOURS-AT-START | 2040-03-01 09:00:00 | yes    |
      | BUSINESS-HOURS-AT-END   | 2040-03-01 17:00:00 | yes    |
      | BUSINESS-HOURS-AFTER    | 2040-03-01 17:00:01 | no     |

  @ARITH-BUSINESS-WEEKEND
  Scenario: Carry business hours over a weekend
    When I add interval "2 business hours" to "2040-03-02 16:00:00"
    Then the returned local date-time is "2040-03-05 10:00:00"

  @ARITH-BUSINESS-HOLIDAY
  Scenario: Carry business hours over the named Founders Day holiday
    Given Founders Day is the holiday "2040-03-05"
    When I add interval "2 business hours" to "2040-03-02 16:00:00"
    Then the returned local date-time is "2040-03-06 10:00:00"

  @BUSINESS-NEXT-HOLIDAY-MUTATION
  Scenario: Mutate a date when seeking the next business day across a holiday
    Given Founders Day is the holiday "2040-03-05"
    And the current date-time is "2040-03-02 16:00:00"
    When I move one checked business day forward
    Then the operation returns no value
    And the current date-time is "2040-03-06 16:00:00"

  @BUSINESS-INVALID-OBJECT
  Scenario: Report an invalid date object without mutation
    Given the input "not a date" failed to produce a date
    When I ask whether it is a business day while checking the time
    Then the answer is absent
    And the error remains "[parse] Invalid date string"
    And the receiver remains in the same invalid state without a stored-value query

  @source-binding @perl-binding @reference-binding @excluded-from-portable-handoff
  Scenario: Preserve the native warning for the invalid business-day request
    Given reference case "BUSINESS-INVALID-OBJECT" uses the invalid date from the portable scenario
    When the reference binding performs the same checked business-day request
    Then exactly one native warning contains "Object must contain a valid date"
