@draft @date-set @reference-dm700
Feature: Replacing one civil or clock field
  An individual-field request starts from an existing valid carrier and changes
  one named field. Zero values remain distinct from omitted values.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And date values are presented from their ordered civil fields as "YYYY-MM-DD HH:MM:SS"
    And valid receivers are read as stored-date text and an ordered six-field record before replacement without a converted-zone read
    And unset and error-bearing receivers are not value-read before replacement
    And after replacement the receiver is read as stored-date text, ordered fields, fixed-local text, and UTC text in that order

  Scenario: Each documented field can be replaced, including zero clock fields
    Given independent receivers equal to "2040-02-29 16:05:09 America/Chicago"
    When I replace the named field in each row
    Then every request completes with status 0 and every error is empty
    And every stored-date result is text, every ordered field result has the six exact fields shown, and fixed-local equals UTC
    And the exact results are:
      | case | initial receiver | exact request | field | replacement | wall result | fields | UTC result |
      | DSET-FIELD-001-YEAR | valid "2040-02-29 16:05:09 America/Chicago" | selector text "y"; arguments [number 2044] | year | 2044 | 2044-02-29 16:05:09 | 2044, 2, 29, 16, 5, 9 | 2044-02-29 22:05:09 |
      | DSET-FIELD-002-MONTH | valid "2040-02-29 16:05:09 America/Chicago" | selector text "m"; arguments [number 1] | month | 1 | 2040-01-29 16:05:09 | 2040, 1, 29, 16, 5, 9 | 2040-01-29 22:05:09 |
      | DSET-FIELD-003-DAY | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [number 1] | day | 1 | 2040-02-01 16:05:09 | 2040, 2, 1, 16, 5, 9 | 2040-02-01 22:05:09 |
      | DSET-FIELD-004-HOUR-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "h"; arguments [number 0] | hour | 0 | 2040-02-29 00:05:09 | 2040, 2, 29, 0, 5, 9 | 2040-02-29 06:05:09 |
      | DSET-FIELD-005-MINUTE-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "mn"; arguments [number 0] | minute | 0 | 2040-02-29 16:00:09 | 2040, 2, 29, 16, 0, 9 | 2040-02-29 22:00:09 |
      | DSET-FIELD-006-SECOND-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "s"; arguments [number 0] | second | 0 | 2040-02-29 16:05:00 | 2040, 2, 29, 16, 5, 0 | 2040-02-29 22:05:00 |

  @observed-compatibility
  Scenario: Field names are accepted without regard to letter case
    Given a receiver equal to "2040-02-29 16:05:09 America/Chicago"
    When I replace uppercase field name "D" with 1
    Then the status is 0 and every error is empty
    And the wall result is "2040-02-01 16:05:09"
    And the UTC result is "2040-02-01 22:05:09"
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-FIELD-020-UPPERCASE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "D"; arguments [number 1] |

  Scenario: An explicit daylight request selects either side of an overlap
    Given independent receivers equal to "2024-11-03 00:30:00 America/New_York"
    When I replace the hour with 1 and the named daylight request
    Then every request completes with status 0 and every error is empty
    And the exact results are:
      | case | initial receiver | exact request | daylight request | wall result | UTC result |
      | DSET-FIELD-028-OVERLAP-STANDARD | valid "2024-11-03 00:30:00 America/New_York" | selector text "h"; arguments [number 1, number 0] | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-FIELD-029-OVERLAP-DAYLIGHT | valid "2024-11-03 00:30:00 America/New_York" | selector text "h"; arguments [number 1, number 1] | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |

  @observed-compatibility @disputed
  Scenario: Omitting the daylight request on a partial change retains the daylight side
    Given a receiver equal to "2024-11-03 00:30:00 America/New_York"
    When I replace the hour with 1 and omit the daylight request
    Then the status is 0 and every error is empty
    And the wall result is "2024-11-03 01:30:00"
    And the UTC result is "2024-11-03 05:30:00"
    And this differs from the documented standard-side default for an omitted request
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-FIELD-027-OVERLAP-DEFAULT | valid "2024-11-03 00:30:00 America/New_York" | selector text "h"; arguments [number 1] |

  @observed-compatibility @disputed
  Scenario: Individual replacements expose malformed field records as observed
    Given independent valid receivers
    When I replace one field with each value below
    Then every request completes with status 0 and every call and observer error is empty
    And each stored field record and UTC presentation is exactly as shown
    And the exact portable outcomes are:
      | case | initial receiver | exact request | field and value | status | call error | stored fields | UTC result |
      | DSET-FIELD-008-MONTH-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "m"; arguments [number 0] | month 0 | 0 | empty | 2040, 0, 29, 16, 5, 9 | 2040-00-29 22:05:09 |
      | DSET-FIELD-009-DAY-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [number 0] | day 0 | 0 | empty | 2040, 2, 0, 16, 5, 9 | 2040-01-31 22:05:09 |
      | DSET-FIELD-010-MONTH-13 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "m"; arguments [number 13] | month 13 | 0 | empty | 2040, 13, 29, 16, 5, 9 | 2040-13-29 22:05:09 |
      | DSET-FIELD-011-DAY-31-COMPAT | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [number 31] | day 31 in February | 0 | empty | 2040, 2, 31, 16, 5, 9 | 2040-03-02 22:05:09 |
      | DSET-FIELD-012-DAY-32 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [number 32] | day 32 | 0 | empty | 2040, 2, 32, 16, 5, 9 | 2040-03-03 22:05:09 |
      | DSET-FIELD-013-HOUR-24 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "h"; arguments [number 24] | hour 24 with nonzero minutes | 0 | empty | 2040, 2, 29, 24, 5, 9 | 2040-03-01 06:05:09 |
      | DSET-FIELD-014-MINUTE-60 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "mn"; arguments [number 60] | minute 60 | 0 | empty | 2040, 2, 29, 16, 60, 9 | 2040-02-29 23:00:09 |
      | DSET-FIELD-015-SECOND-60 | valid "2040-02-29 16:05:09 America/Chicago" | selector text "s"; arguments [number 60] | second 60 | 0 | empty | 2040, 2, 29, 16, 5, 60 | 2040-02-29 22:06:00 |
      | DSET-FIELD-016-NONNUMERIC | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [text "nope"] | day text nope | 0 | empty | 2040, 2, nope, 16, 5, 9 | 2040-01-31 22:05:09 |
      | DSET-FIELD-017-UNDEFINED | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [undefined] | undefined day | 0 | empty | 2040, 2, undefined, 16, 5, 9 | 2040-01-31 22:05:09 |
      | DSET-FIELD-033-ISDST-TWO | valid "2040-02-29 16:05:09 America/New_York" | selector text "d"; arguments [number 1, number 2] | day 1 and daylight value 2 | 0 | empty | 2040, 2, 1, 16, 5, 9 | 2040-02-01 21:05:09 |
      | DSET-FIELD-034-NEGATIVE-DAY | valid "2040-02-29 16:05:09 America/New_York" | selector text "d"; arguments [number -1] | day -1 | 0 | empty | 2040, 2, -1, 16, 5, 9 | 2040-01-30 21:05:09 |

  Scenario: Invalid selectors, arities, receiver states, and gap times fail with an empty carrier
    When I make the invalid individual-field request in each row
    Then the call error before is empty except that the parse-error receiver starts with "[parse] Invalid date string"
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the call error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact call results are:
      | case | initial receiver | exact request | request | status | call error |
      | DSET-FIELD-007-YEAR-ZERO | valid "2040-02-29 16:05:09 America/Chicago" | selector text "y"; arguments [number 0] | year 0 | 1 | [set] Invalid date/timezone |
      | DSET-FIELD-018-OMITTED-VALUE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [] | day with omitted value | 1 | [set] Invalid arguments |
      | DSET-FIELD-019-EXTRA-ARGUMENT | valid "2040-02-29 16:05:09 America/Chicago" | selector text "d"; arguments [number 1, number 0, text "extra"] | day, value, flag, and extra argument | 1 | [set] Invalid arguments |
      | DSET-FIELD-021-UNKNOWN | valid "2040-02-29 16:05:09 America/Chicago" | selector text "bogus"; arguments [number 1] | unknown field bogus | 1 | [set] Invalid field |
      | DSET-FIELD-022-EMPTY-NAME | valid "2040-02-29 16:05:09 America/Chicago" | selector text ""; arguments [number 1] | empty field name | 1 | [set] Invalid field |
      | DSET-FIELD-023-OMITTED-NAME | valid "2040-02-29 16:05:09 America/Chicago" | selector omitted; arguments [] | omitted field name | 1 | [set] Invalid field |
      | DSET-FIELD-024-MULTIPLE-FIELDS | valid "2040-02-29 16:05:09 America/Chicago" | selector text "y"; arguments [number 2044, text "m", number 1] | year 2044 followed by month 1 | 1 | [set] Invalid arguments |
      | DSET-FIELD-025-UNSET-RECEIVER | unset | selector text "d"; arguments [number 1] | day 1 on unset receiver | 1 | empty |
      | DSET-FIELD-026-ERROR-RECEIVER | valid "2040-02-29 16:05:09 Etc/UTC", then parse "not a valid date phrase" | selector text "d"; arguments [number 1] | day 1 on parse-error receiver | 1 | [parse] Invalid date string |
      | DSET-FIELD-030-GAP-DEFAULT | valid "2024-03-10 01:30:00 America/New_York" | selector text "h"; arguments [number 2] | hour 2 in New York gap, flag omitted | 1 | [set] Invalid date/timezone |
      | DSET-FIELD-031-GAP-STANDARD | valid "2024-03-10 01:30:00 America/New_York" | selector text "h"; arguments [number 2, number 0] | hour 2 in New York gap, standard 0 | 1 | [set] Invalid date/timezone |
      | DSET-FIELD-032-GAP-DAYLIGHT | valid "2024-03-10 01:30:00 America/New_York" | selector text "h"; arguments [number 2, number 1] | hour 2 in New York gap, daylight 1 | 1 | [set] Invalid date/timezone |
