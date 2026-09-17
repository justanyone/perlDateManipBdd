@draft @calendar @year-day @portable @reference-observed
Feature: Convert civil fields to an ordinal within their year
  The operation returns day 1 for January 1 and includes the elapsed fraction
  of a day only when clock fields are supplied.

  Background:
    Given three civil fields are ordered year, month, day
    And six civil fields are ordered year, month, day, hour, minute, second
    Given the year-day profile "gregorian-2040" has:
      | setting                 | value                          |
      | calendar                | proleptic Gregorian            |
      | supported year interval | 0001 through 9999              |
      | fixed reference clock   | 2040-02-28 10:20:30 in Etc/UTC |
      | process time zone       | Etc/UTC                        |
      | input language          | English                        |
      | input date order        | month-day-year                 |
      | default clock           | midnight                       |
      | external config files   | ignored                        |

  Scenario Outline: Convert date-only civil fields for <case>
    Given public year-day profile "<profile>"
    When it requests the ordinal within the year for <civil fields>
    Then the numeric ordinal is exactly <ordinal>

    Examples:
      | case                         | profile            | civil fields    | ordinal |
      | YDC-FWD-BASE-COMMON-JAN1     | calendar service   | [2039,1,1]      | 1       |
      | YDC-FWD-BASE-COMMON-MAR1     | calendar service   | [2039,3,1]      | 60      |
      | YDC-FWD-BASE-LEAP-FEB29      | calendar service   | [2040,2,29]     | 60      |
      | YDC-FWD-BASE-LEAP-MAR1       | calendar service   | [2040,3,1]      | 61      |
      | YDC-FWD-BASE-COMMON-END      | calendar service   | [2039,12,31]    | 365     |
      | YDC-FWD-BASE-LEAP-END        | calendar service   | [2040,12,31]    | 366     |
      | YDC-FWD-DM6-LEAP-FEB29       | current functional | [2040,2,29]     | 60      |
      | YDC-FWD-DM5-LEAP-FEB29       | legacy functional  | [2040,2,29]     | 60      |

  Scenario Outline: Include the clock fraction for <case>
    Given public year-day profile "calendar service"
    When it requests the ordinal within the year for <civil fields>
    Then the ordinal rounded to 12 decimal places with ties to even and trailing zeros removed is "<ordinal>"

    Examples:
      | case                         | civil fields                 | ordinal          |
      | YDC-FWD-BASE-NOON            | [2040,2,29,12,0,0]           | 60.5             |
      | YDC-FWD-BASE-HALF-SECOND     | [2040,2,29,12,0,0.5]         | 60.500005787037  |
