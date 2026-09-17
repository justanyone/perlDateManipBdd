@draft @reference-dm700 @zone-transition-boundaries
Feature: Exact instants at contrasting civil-time transitions
  These examples use named zones from the pinned 7.00 reference profile and its
  2026c time-zone data. All input instants are complete UTC date-times.

  Background:
    Given an English ASCII date-time context
    And the configured local zone is "Etc/UTC"
    And numeric dates use month/day/year order
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"

  Scenario Outline: UTC conversion changes civil time at the exact transition second for <case>
    Given observation case "<observation>" uses named zone "<zone>"
    And the UTC date-time is "<utc>"
    When I convert that UTC value to the named zone
    Then the conversion succeeds
    And the civil date-time is "<local>"
    And the offset is "<offset>"
    And the daylight-saving flag is <dst>
    And the abbreviation is "<abbreviation>"
    And absolute period lookup for that UTC value returns the same offset, abbreviation, and daylight-saving flag
    When a fresh date-time parses the same UTC value and is converted to "<zone>"
    Then parsing and conversion each return status 0 with an empty error
    And before conversion its numeric fields equal the UTC date-time fields
    And rendering it with pattern "%Y-%m-%d %H:%M:%S %Z %z" returns "<rendered>"
    And its numeric fields are "<fields>"

    Examples:
      | case | observation | zone | utc | local | offset | dst | abbreviation | rendered | fields |
      | ZTB-NY-SPRING-GAP-UTC-BEFORE | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 06:59:59 Etc/UTC | 2040-03-11 01:59:59 | -05:00:00 | 0 | EST | 2040-03-11 01:59:59 EST -0500 | 2040,3,11,1,59,59 |
      | ZTB-NY-SPRING-GAP-UTC-AT | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 07:00:00 Etc/UTC | 2040-03-11 03:00:00 | -04:00:00 | 1 | EDT | 2040-03-11 03:00:00 EDT -0400 | 2040,3,11,3,0,0 |
      | ZTB-NY-SPRING-GAP-UTC-AFTER | ZTB-NY-SPRING-GAP | America/New_York | 2040-03-11 07:00:01 Etc/UTC | 2040-03-11 03:00:01 | -04:00:00 | 1 | EDT | 2040-03-11 03:00:01 EDT -0400 | 2040,3,11,3,0,1 |
      | ZTB-NY-AUTUMN-OVERLAP-UTC-BEFORE | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 05:59:59 Etc/UTC | 2040-11-04 01:59:59 | -04:00:00 | 1 | EDT | 2040-11-04 01:59:59 EDT -0400 | 2040,11,4,1,59,59 |
      | ZTB-NY-AUTUMN-OVERLAP-UTC-AT | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 06:00:00 Etc/UTC | 2040-11-04 01:00:00 | -05:00:00 | 0 | EST | 2040-11-04 01:00:00 EST -0500 | 2040,11,4,1,0,0 |
      | ZTB-NY-AUTUMN-OVERLAP-UTC-AFTER | ZTB-NY-AUTUMN-OVERLAP | America/New_York | 2040-11-04 06:00:01 Etc/UTC | 2040-11-04 01:00:01 | -05:00:00 | 0 | EST | 2040-11-04 01:00:01 EST -0500 | 2040,11,4,1,0,1 |
      | ZTB-LONDON-SPRING-GAP-UTC-BEFORE | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 00:59:59 Etc/UTC | 2040-03-25 00:59:59 | +00:00:00 | 0 | GMT | 2040-03-25 00:59:59 GMT +0000 | 2040,3,25,0,59,59 |
      | ZTB-LONDON-SPRING-GAP-UTC-AT | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 01:00:00 Etc/UTC | 2040-03-25 02:00:00 | +01:00:00 | 1 | BST | 2040-03-25 02:00:00 BST +0100 | 2040,3,25,2,0,0 |
      | ZTB-LONDON-SPRING-GAP-UTC-AFTER | ZTB-LONDON-SPRING-GAP | Europe/London | 2040-03-25 01:00:01 Etc/UTC | 2040-03-25 02:00:01 | +01:00:00 | 1 | BST | 2040-03-25 02:00:01 BST +0100 | 2040,3,25,2,0,1 |
      | ZTB-LONDON-AUTUMN-OVERLAP-UTC-BEFORE | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 00:59:59 Etc/UTC | 2040-10-28 01:59:59 | +01:00:00 | 1 | BST | 2040-10-28 01:59:59 BST +0100 | 2040,10,28,1,59,59 |
      | ZTB-LONDON-AUTUMN-OVERLAP-UTC-AT | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:00:00 Etc/UTC | 2040-10-28 01:00:00 | +00:00:00 | 0 | GMT | 2040-10-28 01:00:00 GMT +0000 | 2040,10,28,1,0,0 |
      | ZTB-LONDON-AUTUMN-OVERLAP-UTC-AFTER | ZTB-LONDON-AUTUMN-OVERLAP | Europe/London | 2040-10-28 01:00:01 Etc/UTC | 2040-10-28 01:00:01 | +00:00:00 | 0 | GMT | 2040-10-28 01:00:01 GMT +0000 | 2040,10,28,1,0,1 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-UTC-BEFORE | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-03-31 14:59:59 Etc/UTC | 2040-04-01 01:59:59 | +11:00:00 | 1 | +11 | 2040-04-01 01:59:59 +11 +1100 | 2040,4,1,1,59,59 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-UTC-AT | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-03-31 15:00:00 Etc/UTC | 2040-04-01 01:30:00 | +10:30:00 | 0 | +1030 | 2040-04-01 01:30:00 +1030 +1030 | 2040,4,1,1,30,0 |
      | ZTB-LORD-HOWE-AUTUMN-OVERLAP-UTC-AFTER | ZTB-LORD-HOWE-AUTUMN-OVERLAP | Australia/Lord_Howe | 2040-03-31 15:00:01 Etc/UTC | 2040-04-01 01:30:01 | +10:30:00 | 0 | +1030 | 2040-04-01 01:30:01 +1030 +1030 | 2040,4,1,1,30,1 |
      | ZTB-LORD-HOWE-SPRING-GAP-UTC-BEFORE | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-06 15:29:59 Etc/UTC | 2040-10-07 01:59:59 | +10:30:00 | 0 | +1030 | 2040-10-07 01:59:59 +1030 +1030 | 2040,10,7,1,59,59 |
      | ZTB-LORD-HOWE-SPRING-GAP-UTC-AT | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-06 15:30:00 Etc/UTC | 2040-10-07 02:30:00 | +11:00:00 | 1 | +11 | 2040-10-07 02:30:00 +11 +1100 | 2040,10,7,2,30,0 |
      | ZTB-LORD-HOWE-SPRING-GAP-UTC-AFTER | ZTB-LORD-HOWE-SPRING-GAP | Australia/Lord_Howe | 2040-10-06 15:30:01 Etc/UTC | 2040-10-07 02:30:01 | +11:00:00 | 1 | +11 | 2040-10-07 02:30:01 +11 +1100 | 2040,10,7,2,30,1 |
      | ZTB-APIA-SKIPPED-DAY-UTC-BEFORE | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-30 09:59:59 Etc/UTC | 2011-12-29 23:59:59 | -10:00:00 | 1 | -10 | 2011-12-29 23:59:59 -10 -1000 | 2011,12,29,23,59,59 |
      | ZTB-APIA-SKIPPED-DAY-UTC-AT | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-30 10:00:00 Etc/UTC | 2011-12-31 00:00:00 | +14:00:00 | 1 | +14 | 2011-12-31 00:00:00 +14 +1400 | 2011,12,31,0,0,0 |
      | ZTB-APIA-SKIPPED-DAY-UTC-AFTER | ZTB-APIA-SKIPPED-DAY | Pacific/Apia | 2011-12-30 10:00:01 Etc/UTC | 2011-12-31 00:00:01 | +14:00:00 | 1 | +14 | 2011-12-31 00:00:01 +14 +1400 | 2011,12,31,0,0,1 |
      | ZTB-UTC-NO-TRANSITION-UTC-BEFORE | ZTB-UTC-NO-TRANSITION | Etc/UTC | 2040-03-11 06:59:59 Etc/UTC | 2040-03-11 06:59:59 | +00:00:00 | 0 | UTC | 2040-03-11 06:59:59 UTC +0000 | 2040,3,11,6,59,59 |
      | ZTB-UTC-NO-TRANSITION-UTC-AT | ZTB-UTC-NO-TRANSITION | Etc/UTC | 2040-03-11 07:00:00 Etc/UTC | 2040-03-11 07:00:00 | +00:00:00 | 0 | UTC | 2040-03-11 07:00:00 UTC +0000 | 2040,3,11,7,0,0 |
      | ZTB-UTC-NO-TRANSITION-UTC-AFTER | ZTB-UTC-NO-TRANSITION | Etc/UTC | 2040-03-11 07:00:01 Etc/UTC | 2040-03-11 07:00:01 | +00:00:00 | 0 | UTC | 2040-03-11 07:00:01 UTC +0000 | 2040,3,11,7,0,1 |
