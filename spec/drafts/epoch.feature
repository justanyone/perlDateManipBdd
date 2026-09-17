@draft @epoch
Feature: Convert civil fields and instants to epoch seconds
  The epoch is 1970-01-01 00:00:00 UTC. Seconds are signed integers.
  A civil-fields request treats supplied fields in the stated context; a stored
  instant request uses an already parsed zoned value.

  Background:
    Given English input, time zone "Etc/UTC", and reference clock "2040-02-28 10:20:30"
    And numeric dates use month then day, with midnight for omitted time
    And weeks start on Monday and week one contains January 4
    And working days are Monday through Friday from 09:00 through 17:00 with no holidays or events

  Scenario Outline: Count epoch seconds for <case>
    Given epoch profile "<profile>" and request kind "<request kind>"
    When I request epoch seconds for "<date-time>" in "Etc/UTC"
    Then the exact integer result is <seconds>

    Examples:
      | case | profile | request kind | date-time | seconds |
      | EPOCH-001 | calendar-service | local civil fields | 1970-01-01 00:00:00 | 0 |
      | EPOCH-002 | current-text | local civil fields | 1970-01-01 00:00:00 | 0 |
      | EPOCH-003 | legacy-text | local civil fields | 1970-01-01 00:00:00 | 0 |
      | EPOCH-004 | current-text | UTC civil fields | 1970-01-01 00:00:00 | 0 |
      | EPOCH-005 | legacy-text | UTC civil fields | 1970-01-01 00:00:00 | 0 |
      | EPOCH-006 | current-value | stored instant | 1970-01-01 00:00:00 | 0 |
      | EPOCH-007 | calendar-service | local civil fields | 1969-12-31 23:59:59 | -1 |
      | EPOCH-008 | current-text | local civil fields | 1969-12-31 23:59:59 | -1 |
      | EPOCH-009 | legacy-text | local civil fields | 1969-12-31 23:59:59 | -1 |
      | EPOCH-010 | current-text | UTC civil fields | 1969-12-31 23:59:59 | -1 |
      | EPOCH-011 | legacy-text | UTC civil fields | 1969-12-31 23:59:59 | -1 |
      | EPOCH-012 | current-value | stored instant | 1969-12-31 23:59:59 | -1 |
      | EPOCH-013 | calendar-service | local civil fields | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-014 | current-text | local civil fields | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-015 | legacy-text | local civil fields | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-016 | current-text | UTC civil fields | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-017 | legacy-text | UTC civil fields | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-018 | current-value | stored instant | 2040-02-29 12:34:56 | 2214131696 |
      | EPOCH-019 | calendar-service | local civil fields | 2038-01-19 03:14:08 | 2147483648 |
      | EPOCH-020 | current-text | local civil fields | 2038-01-19 03:14:08 | 2147483648 |
      | EPOCH-021 | legacy-text | local civil fields | 2038-01-19 03:14:08 | 2147483648 |
      | EPOCH-022 | current-text | UTC civil fields | 2038-01-19 03:14:08 | 2147483648 |
      | EPOCH-023 | legacy-text | UTC civil fields | 2038-01-19 03:14:08 | 2147483648 |
      | EPOCH-024 | current-value | stored instant | 2038-01-19 03:14:08 | 2147483648 |

  Scenario Outline: Recover civil fields from epoch seconds for <case>
    When I request UTC civil fields from epoch seconds <seconds>
    Then the resulting civil date-time is "<date-time>"

    Examples:
      | case | seconds | date-time |
      | EPOCH-INVERSE--1 | -1 | 1969-12-31 23:59:59 |
      | EPOCH-INVERSE-0 | 0 | 1970-01-01 00:00:00 |
      | EPOCH-INVERSE-1 | 1 | 1970-01-01 00:00:01 |
      | EPOCH-INVERSE-2147483648 | 2147483648 | 2038-01-19 03:14:08 |

  Scenario Outline: Replace a stored instant using epoch seconds for <case>
    Given a stored date-time "2040-04-13 12:34:56" in "Etc/UTC"
    When I replace its instant with epoch seconds <seconds>
    Then replacement reports success status 0 with an empty error
    And the stored date-time is "<date-time>" in "Etc/UTC"

    Examples:
      | case | seconds | date-time |
      | EPOCH-REPLACE--1 | -1 | 1969-12-31 23:59:59 |
      | EPOCH-REPLACE-0 | 0 | 1970-01-01 00:00:00 |
      | EPOCH-REPLACE-1 | 1 | 1970-01-01 00:00:01 |
      | EPOCH-REPLACE-2147483648 | 2147483648 | 2038-01-19 03:14:08 |
