@draft @calendar @year-day @portable @reference-observed
Feature: Convert an ordinal within a year to civil fields
  Integral ordinals produce a civil date. Fractional ordinals also produce
  clock fields, with ordinal 1.5 at noon on January 1.

  Background:
    Given three civil fields are ordered year, month, day
    And six civil fields are ordered year, month, day, hour, minute, second
    And fractional seconds in these examples are compared as exact decimal values at two decimal places
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

  Scenario Outline: Convert an integral ordinal for <case>
    Given public year-day profile "<profile>"
    When it requests civil fields for year <year> and ordinal <ordinal>
    Then the ordered civil fields are exactly <fields>

    Examples:
      | case                         | profile            | year | ordinal | fields                  |
      | YDC-INV-BASE-COMMON-FIRST    | calendar service   | 2039 | 1       | [2039,1,1]              |
      | YDC-INV-BASE-COMMON-FEB28    | calendar service   | 2039 | 59      | [2039,2,28]             |
      | YDC-INV-BASE-COMMON-MAR1     | calendar service   | 2039 | 60      | [2039,3,1]              |
      | YDC-INV-BASE-LEAP-FEB29      | calendar service   | 2040 | 60      | [2040,2,29]             |
      | YDC-INV-BASE-COMMON-END      | calendar service   | 2039 | 365     | [2039,12,31]            |
      | YDC-INV-BASE-LEAP-END        | calendar service   | 2040 | 366     | [2040,12,31]            |
      | YDC-INV-DM6-COMMON-END       | current functional | 2039 | 365     | [2039,12,31,0,0,0]      |
      | YDC-INV-DM5-COMMON-END       | legacy functional  | 2039 | 365     | [2039,12,31,0,0,0]      |

  Scenario Outline: Convert a fractional ordinal for <case>
    Given public year-day profile "<profile>"
    When it requests civil date-time fields for year <year> and ordinal <ordinal>
    Then the ordered civil date-time fields are exactly <fields>

    Examples:
      | case                              | profile            | year | ordinal           | fields                       |
      | YDC-INV-BASE-FIRST-NOON           | calendar service   | 2040 | 1.5               | [2040,1,1,12,0,0]           |
      | YDC-INV-BASE-SUBSECOND            | calendar service   | 2040 | 60.50000578703704 | [2040,2,29,12,0,0.50]       |
      | YDC-INV-DM6-FRACTION              | current functional | 2040 | 60.5              | [2040,2,29,12,0,0]          |
      | YDC-INV-DM5-FRACTION              | legacy functional  | 2040 | 60.5              | [2040,2,29,12,0,0]          |
      | YDC-INV-DM6-LEAP-LAST-NOON        | current functional | 2040 | 366.5             | [2040,12,31,12,0,0]         |
      | YDC-INV-DM5-LEAP-LAST-NOON        | legacy functional  | 2040 | 366.5             | [2040,12,31,12,0,0]         |

  Scenario: Reject the first ordinal beyond a common legacy year
    Given public year-day profile "legacy functional"
    When it requests civil fields for year 2039 and ordinal 366
    Then the result is an absent civil date value
