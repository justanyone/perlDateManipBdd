@draft @calendar @year-day @compatibility @disputed @reference-observed
Feature: Preserve disputed year-day conversion observations for review
  These observations describe the pinned reference. Impossible civil fields
  and profile-specific defaults are not portable calendar requirements.

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
      | external config files   | ignored                        |

  Scenario Outline: Short-year interpretation remains profile-specific for <case>
    Given public year-day profile "<profile>" has short-year setting "C19"
    When it requests the ordinal within the year for year text "00", month 3, and day 1
    Then the observed numeric ordinal is exactly <ordinal>

    Examples:
      | case                      | profile            | ordinal |
      | YDC-FWD-DM6-SHORT-C19     | current functional | 61      |
      | YDC-FWD-DM5-SHORT-C19     | legacy functional  | 60      |

  Scenario: A nonexistent common-year leap day is not validated by this helper
    Given public year-day profile "calendar service"
    When it requests the ordinal within the year for civil fields [2039,2,29]
    Then the observed numeric ordinal is exactly 60

  Scenario Outline: Out-of-domain inverse inputs expose unchecked fields for <case>
    Given public year-day profile "<profile>"
    When it requests civil fields for year <year> and ordinal <ordinal>
    Then the observed ordered fields are exactly <fields>

    Examples:
      | case                         | profile            | year | ordinal | fields               |
      | YDC-EDGE-BASE-COMMON-366     | calendar service   | 2039 | 366     | [2039,13,1]          |
      | YDC-EDGE-BASE-LEAP-367       | calendar service   | 2040 | 367     | [2040,13,1]          |
      | YDC-EDGE-BASE-ZERO           | calendar service   | 2040 | 0       | [2040,1,0]           |
      | YDC-EDGE-BASE-NEGATIVE       | calendar service   | 2040 | -1      | [2040,1,-1]          |
      | YDC-EDGE-DM6-COMMON-366      | current functional | 2039 | 366     | [2039,13,1,0,0,0]    |

  Scenario: Omitted legacy inputs default through the fixed profile
    Given public year-day profile "legacy functional"
    When it requests civil fields with the year and ordinal both omitted
    Then the observed ordered fields are exactly [2040,1,1,0,0,0]
