@draft @reference-dm700 @zone-transition-boundaries
Feature: Period lookup at gaps, overlaps, and a stable zone
  Period records contain their inclusive UTC and wall-clock bounds, numeric
  offset, abbreviation, and daylight-saving flag.

  Background:
    Given the pinned 7.00 reference profile with time-zone data 2026c
    And the configured local zone is "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"

  Scenario Outline: A wall-clock gap has no period for <case>
    Given observation case "<observation>" and named zone "<zone>"
    When I request the wall-clock period for "<wall>" with daylight selector <selector>
    Then no period is returned

    Examples:
      | case | observation | zone | wall | selector |
      | ZTB-NY-SPRING-GAP-WALL-GAP-FIRST | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 02:00:00 | 0 |
      | ZTB-NY-SPRING-GAP-WALL-GAP-LAST | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 02:59:59 | 1 |
      | ZTB-LONDON-SPRING-GAP-WALL-GAP-FIRST | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 01:00:00 | 0 |
      | ZTB-LONDON-SPRING-GAP-WALL-GAP-LAST | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 01:59:59 | 1 |
      | ZTB-LORD-HOWE-SPRING-GAP-WALL-GAP-FIRST | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-07 02:00:00 | 0 |
      | ZTB-LORD-HOWE-SPRING-GAP-WALL-GAP-LAST | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-07 02:29:59 | 1 |
      | ZTB-APIA-SKIPPED-DAY-WALL-GAP-FIRST | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-30 00:00:00 | 0 |
      | ZTB-APIA-SKIPPED-DAY-WALL-GAP-LAST | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-30 23:59:59 | 1 |

  Scenario Outline: A daylight selector chooses either period throughout an overlap for <case>
    Given observation case "<observation>" and named zone "<zone>"
    When I request the wall-clock period for "<wall>" with daylight selector <selector>
    Then the period offset is "<offset>"
    And its abbreviation is "<abbreviation>"
    And its daylight-saving flag is <dst>

    Examples:
      | case | observation | zone | wall | selector | offset | abbreviation | dst |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-STANDARD | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 01:00:00 | 0 | -05:00:00 | EST | 0 |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-DAYLIGHT | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 01:00:00 | 1 | -04:00:00 | EDT | 1 |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-STANDARD | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 01:59:59 | 0 | -05:00:00 | EST | 0 |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-DAYLIGHT | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 01:59:59 | 1 | -04:00:00 | EDT | 1 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-STANDARD | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:00:00 | 0 | +00:00:00 | GMT | 0 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-DAYLIGHT | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:00:00 | 1 | +01:00:00 | BST | 1 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-STANDARD | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:59:59 | 0 | +00:00:00 | GMT | 0 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-DAYLIGHT | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:59:59 | 1 | +01:00:00 | BST | 1 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-STANDARD | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 01:30:00 | 0 | +10:30:00 | +1030 | 0 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-OVERLAP-FIRST-DAYLIGHT | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 01:30:00 | 1 | +11:00:00 | +11 | 1 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-STANDARD | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 01:59:59 | 0 | +10:30:00 | +1030 | 0 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-OVERLAP-LAST-DAYLIGHT | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 01:59:59 | 1 | +11:00:00 | +11 | 1 |

  Scenario Outline: A non-repeated wall-clock boundary second has one period for <case>
    Given observation case "<observation>" and named zone "<zone>"
    When I request the wall-clock period for "<wall>" with daylight selector <selector>
    Then the period offset is "<offset>"
    And its abbreviation is "<abbreviation>"
    And its daylight-saving flag is <dst>

    Examples:
      | case | observation | zone | wall | selector | offset | abbreviation | dst |
      | ZTB-NY-SPRING-GAP-WALL-VALID-BEFORE | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 01:59:59 | 0 | -05:00:00 | EST | 0 |
      | ZTB-NY-SPRING-GAP-WALL-VALID-AFTER | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 03:00:00 | 0 | -04:00:00 | EDT | 1 |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-VALID-BEFORE | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 00:59:59 | 0 | -04:00:00 | EDT | 1 |
      | ZTB-NY-AUTUMN-OVERLAP-WALL-VALID-AFTER | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 02:00:00 | 0 | -05:00:00 | EST | 0 |
      | ZTB-LONDON-SPRING-GAP-WALL-VALID-BEFORE | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 00:59:59 | 0 | +00:00:00 | GMT | 0 |
      | ZTB-LONDON-SPRING-GAP-WALL-VALID-AFTER | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 02:00:00 | 0 | +01:00:00 | BST | 1 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-VALID-BEFORE | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 00:59:59 | 0 | +01:00:00 | BST | 1 |
      | ZTB-LONDON-AUTUMN-OVERLAP-WALL-VALID-AFTER | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 02:00:00 | 0 | +00:00:00 | GMT | 0 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-VALID-BEFORE | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 01:29:59 | 0 | +11:00:00 | +11 | 1 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-WALL-VALID-AFTER | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-04-01 02:00:00 | 0 | +10:30:00 | +1030 | 0 |
      | ZTB-LORD-HOWE-SPRING-GAP-WALL-VALID-BEFORE | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-07 01:59:59 | 0 | +10:30:00 | +1030 | 0 |
      | ZTB-LORD-HOWE-SPRING-GAP-WALL-VALID-AFTER | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-07 02:30:00 | 0 | +11:00:00 | +11 | 1 |
      | ZTB-APIA-SKIPPED-DAY-WALL-VALID-BEFORE | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-29 23:59:59 | 0 | -10:00:00 | -10 | 1 |
      | ZTB-APIA-SKIPPED-DAY-WALL-VALID-AFTER | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-31 00:00:00 | 0 | +14:00:00 | +14 | 1 |

  Scenario Outline: Period enumeration preserves the exact ordered year boundaries for <case>
    Given observation case "<observation>", named zone "<zone>", and UTC year <year>
    When I list periods that begin in that year
    Then the ordered period records are exactly "<beginning>"
    When I list every period that intersects that year
    Then the ordered period records are exactly "<intersecting>"

    Examples:
      | case | observation | zone | year | beginning | intersecting |
      | ZTB-NY-SPRING-GAP-ENUMERATION | ZTB-NY-SPRING-GAP | America/New_York | 2040 | 2040-03-11 07:00:00 UTC/2040-03-11 03:00:00 local/-04:00:00/EDT/1 through 2040-11-04 05:59:59 UTC/2040-11-04 01:59:59 local; 2040-11-04 06:00:00 UTC/2040-11-04 01:00:00 local/-05:00:00/EST/0 through 2041-03-10 06:59:59 UTC/2041-03-10 01:59:59 local | 2039-11-06 06:00:00 UTC/2039-11-06 01:00:00 local/-05:00:00/EST/0 through 2040-03-11 06:59:59 UTC/2040-03-11 01:59:59 local; 2040-03-11 07:00:00 UTC/2040-03-11 03:00:00 local/-04:00:00/EDT/1 through 2040-11-04 05:59:59 UTC/2040-11-04 01:59:59 local; 2040-11-04 06:00:00 UTC/2040-11-04 01:00:00 local/-05:00:00/EST/0 through 2041-03-10 06:59:59 UTC/2041-03-10 01:59:59 local |
      | ZTB-NY-AUTUMN-OVERLAP-ENUMERATION | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040 | 2040-03-11 07:00:00 UTC/2040-03-11 03:00:00 local/-04:00:00/EDT/1 through 2040-11-04 05:59:59 UTC/2040-11-04 01:59:59 local; 2040-11-04 06:00:00 UTC/2040-11-04 01:00:00 local/-05:00:00/EST/0 through 2041-03-10 06:59:59 UTC/2041-03-10 01:59:59 local | 2039-11-06 06:00:00 UTC/2039-11-06 01:00:00 local/-05:00:00/EST/0 through 2040-03-11 06:59:59 UTC/2040-03-11 01:59:59 local; 2040-03-11 07:00:00 UTC/2040-03-11 03:00:00 local/-04:00:00/EDT/1 through 2040-11-04 05:59:59 UTC/2040-11-04 01:59:59 local; 2040-11-04 06:00:00 UTC/2040-11-04 01:00:00 local/-05:00:00/EST/0 through 2041-03-10 06:59:59 UTC/2041-03-10 01:59:59 local |
      | ZTB-LONDON-SPRING-GAP-ENUMERATION | ZTB-LONDON-SPRING-GAP | Europe/London | 2040 | 2040-03-25 01:00:00 UTC/2040-03-25 02:00:00 local/+01:00:00/BST/1 through 2040-10-28 00:59:59 UTC/2040-10-28 01:59:59 local; 2040-10-28 01:00:00 UTC/2040-10-28 01:00:00 local/+00:00:00/GMT/0 through 2041-03-31 00:59:59 UTC/2041-03-31 00:59:59 local | 2039-10-30 01:00:00 UTC/2039-10-30 01:00:00 local/+00:00:00/GMT/0 through 2040-03-25 00:59:59 UTC/2040-03-25 00:59:59 local; 2040-03-25 01:00:00 UTC/2040-03-25 02:00:00 local/+01:00:00/BST/1 through 2040-10-28 00:59:59 UTC/2040-10-28 01:59:59 local; 2040-10-28 01:00:00 UTC/2040-10-28 01:00:00 local/+00:00:00/GMT/0 through 2041-03-31 00:59:59 UTC/2041-03-31 00:59:59 local |
      | ZTB-LONDON-AUTUMN-OVERLAP-ENUMERATION | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040 | 2040-03-25 01:00:00 UTC/2040-03-25 02:00:00 local/+01:00:00/BST/1 through 2040-10-28 00:59:59 UTC/2040-10-28 01:59:59 local; 2040-10-28 01:00:00 UTC/2040-10-28 01:00:00 local/+00:00:00/GMT/0 through 2041-03-31 00:59:59 UTC/2041-03-31 00:59:59 local | 2039-10-30 01:00:00 UTC/2039-10-30 01:00:00 local/+00:00:00/GMT/0 through 2040-03-25 00:59:59 UTC/2040-03-25 00:59:59 local; 2040-03-25 01:00:00 UTC/2040-03-25 02:00:00 local/+01:00:00/BST/1 through 2040-10-28 00:59:59 UTC/2040-10-28 01:59:59 local; 2040-10-28 01:00:00 UTC/2040-10-28 01:00:00 local/+00:00:00/GMT/0 through 2041-03-31 00:59:59 UTC/2041-03-31 00:59:59 local |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-ENUMERATION | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040 | 2040-03-31 15:00:00 UTC/2040-04-01 01:30:00 local/+10:30:00/+1030/0 through 2040-10-06 15:29:59 UTC/2040-10-07 01:59:59 local; 2040-10-06 15:30:00 UTC/2040-10-07 02:30:00 local/+11:00:00/+11/1 through 2041-04-06 14:59:59 UTC/2041-04-07 01:59:59 local | 2039-10-01 15:30:00 UTC/2039-10-02 02:30:00 local/+11:00:00/+11/1 through 2040-03-31 14:59:59 UTC/2040-04-01 01:59:59 local; 2040-03-31 15:00:00 UTC/2040-04-01 01:30:00 local/+10:30:00/+1030/0 through 2040-10-06 15:29:59 UTC/2040-10-07 01:59:59 local; 2040-10-06 15:30:00 UTC/2040-10-07 02:30:00 local/+11:00:00/+11/1 through 2041-04-06 14:59:59 UTC/2041-04-07 01:59:59 local |
      | ZTB-LORD-HOWE-SPRING-GAP-ENUMERATION | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040 | 2040-03-31 15:00:00 UTC/2040-04-01 01:30:00 local/+10:30:00/+1030/0 through 2040-10-06 15:29:59 UTC/2040-10-07 01:59:59 local; 2040-10-06 15:30:00 UTC/2040-10-07 02:30:00 local/+11:00:00/+11/1 through 2041-04-06 14:59:59 UTC/2041-04-07 01:59:59 local | 2039-10-01 15:30:00 UTC/2039-10-02 02:30:00 local/+11:00:00/+11/1 through 2040-03-31 14:59:59 UTC/2040-04-01 01:59:59 local; 2040-03-31 15:00:00 UTC/2040-04-01 01:30:00 local/+10:30:00/+1030/0 through 2040-10-06 15:29:59 UTC/2040-10-07 01:59:59 local; 2040-10-06 15:30:00 UTC/2040-10-07 02:30:00 local/+11:00:00/+11/1 through 2041-04-06 14:59:59 UTC/2041-04-07 01:59:59 local |
      | ZTB-APIA-SKIPPED-DAY-ENUMERATION | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011 | 2011-04-02 14:00:00 UTC/2011-04-02 03:00:00 local/-11:00:00/-11/0 through 2011-09-24 13:59:59 UTC/2011-09-24 02:59:59 local; 2011-09-24 14:00:00 UTC/2011-09-24 04:00:00 local/-10:00:00/-10/1 through 2011-12-30 09:59:59 UTC/2011-12-29 23:59:59 local; 2011-12-30 10:00:00 UTC/2011-12-31 00:00:00 local/+14:00:00/+14/1 through 2012-03-31 13:59:59 UTC/2012-04-01 03:59:59 local | 2010-09-26 11:00:00 UTC/2010-09-26 01:00:00 local/-10:00:00/-10/1 through 2011-04-02 13:59:59 UTC/2011-04-02 03:59:59 local; 2011-04-02 14:00:00 UTC/2011-04-02 03:00:00 local/-11:00:00/-11/0 through 2011-09-24 13:59:59 UTC/2011-09-24 02:59:59 local; 2011-09-24 14:00:00 UTC/2011-09-24 04:00:00 local/-10:00:00/-10/1 through 2011-12-30 09:59:59 UTC/2011-12-29 23:59:59 local; 2011-12-30 10:00:00 UTC/2011-12-31 00:00:00 local/+14:00:00/+14/1 through 2012-03-31 13:59:59 UTC/2012-04-01 03:59:59 local |
      | ZTB-UTC-NO-TRANSITION-ENUMERATION | ZTB-UTC-NO-TRANSITION | Etc/UTC | 2040 | no records | 0001-01-02 00:00:00 UTC/0001-01-02 00:00:00 local/+00:00:00/UTC/0 through 9999-12-31 00:00:00 UTC/9999-12-31 00:00:00 local |

  Scenario: UTC has one stable wall-clock period at the three control instants for ZTB-UTC-WALL-STABLE
    Given observation case "ZTB-UTC-NO-TRANSITION" uses named zone "Etc/UTC"
    When I request wall-clock periods for "2040-03-11 06:59:59", "2040-03-11 07:00:00", and "2040-03-11 07:00:01"
    Then every request returns offset "+00:00:00", abbreviation "UTC", and daylight-saving flag 0
    And each result is the period from "0001-01-02 00:00:00 UTC" through "9999-12-31 00:00:00 UTC"
