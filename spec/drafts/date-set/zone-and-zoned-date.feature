@draft @date-set @reference-dm700
Feature: Replacing a date carrier's zone or zoned civil date
  A zone replacement keeps the stored wall fields, while a zoned-date replacement
  supplies both the wall fields and their zone. Ambiguous local times may select
  standard or daylight time explicitly.

  Background:
    Given Date-Manip 7.00 with tzdata "tzdata2026c" and tzcode "tzcode2026c"
    And an English ASCII configuration with non-US numeric-date order
    And the fixed local clock "2040-02-28 10:20:30 Etc/UTC"
    And date values are presented from their ordered civil fields as "YYYY-MM-DD HH:MM:SS"
    And a valid receiver is read as stored-date text and an ordered six-field record before replacement
    And unset and error-bearing receivers are not value-read before replacement
    And after replacement the receiver is read as stored-date text, ordered fields, fixed-local text, and UTC text in that order

  Scenario: Documented zone requests preserve wall fields and choose the expected instant
    When I make the named zone request in each row
    Then every request completes with status 0 and every call and observer error is empty
    And the ordered field result has six fields matching the wall result
    And the fixed-local result equals the UTC result because the fixed local zone is UTC
    And the exact results are:
      | case | initial receiver | exact request | receiver | zone request | daylight request | wall result | UTC result |
      | DSET-ZONE-001-EXPLICIT-NAMED | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "America/Los_Angeles"] | 2040-02-29 16:05:09 America/New_York | America/Los_Angeles | omitted | 2040-02-29 16:05:09 | 2040-03-01 00:05:09 |
      | DSET-ZONE-002-OMITTED-LOCAL | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [] | 2040-02-29 16:05:09 America/New_York | fixed local zone | omitted | 2040-02-29 16:05:09 | 2040-02-29 16:05:09 |
      | DSET-ZONE-005-ALIAS | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "EST"] | 2040-02-29 16:05:09 America/New_York | EST alias | omitted | 2040-02-29 16:05:09 | 2040-02-29 21:05:09 |
      | DSET-ZONE-006-ZERO-AS-ISDST | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [number 0] | 2040-02-29 16:05:09 America/New_York | fixed local zone | standard 0 | 2040-02-29 16:05:09 | 2040-02-29 16:05:09 |
      | DSET-ZONE-007-ONE-AS-ISDST | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [number 1] | 2040-02-29 16:05:09 America/New_York | fixed local zone | daylight 1 | 2040-02-29 16:05:09 | 2040-02-29 16:05:09 |
      | DSET-ZONE-013-OVERLAP-DEFAULT | valid "2024-11-03 01:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York"] | 2024-11-03 01:30:00 Etc/UTC | America/New_York | omitted | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-ZONE-014-OVERLAP-STANDARD | valid "2024-11-03 01:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York", number 0] | 2024-11-03 01:30:00 Etc/UTC | America/New_York | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-ZONE-015-OVERLAP-DAYLIGHT | valid "2024-11-03 01:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York", number 1] | 2024-11-03 01:30:00 Etc/UTC | America/New_York | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |

  @observed-compatibility @disputed
  Scenario: Undocumented zone option values are accepted as compatibility behavior
    When I make the zone request in each row
    Then every request completes with status 0 and every call and observer error is empty
    And the exact results are:
      | case | initial receiver | exact request | receiver | zone request | daylight request | wall result | UTC result |
      | DSET-ZONE-008-EMPTY-ZONE | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text ""] | 2040-02-29 16:05:09 America/New_York | empty text treated as fixed local | omitted | 2040-02-29 16:05:09 | 2040-02-29 16:05:09 |
      | DSET-ZONE-019-ISDST-TWO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zone"; arguments [text "America/New_York", number 2] | 2040-02-29 16:05:09 Etc/UTC | America/New_York | invalid numeric 2 | 2040-02-29 16:05:09 | 2040-02-29 21:05:09 |

  Scenario: Zone arity, receiver-state, and gap failures clear or retain state as observed
    When I make the failing zone request in each row
    Then the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the recorded error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact call results are:
      | case | initial receiver | exact request | receiver | request | status | call error before | call error after |
      | DSET-ZONE-010-EXTRA-ARGUMENT | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "America/Chicago", number 0, text "extra"] | valid date | named zone, flag, and extra argument | 1 | empty | [set] Invalid arguments |
      | DSET-ZONE-011-UNSET-RECEIVER | unset | selector text "zone"; arguments [text "America/Chicago"] | unset date | named zone | 1 | empty | empty |
      | DSET-ZONE-012-ERROR-RECEIVER | valid "2040-02-29 16:05:09 Etc/UTC", then parse "not a valid date phrase" | selector text "zone"; arguments [text "America/Chicago"] | parse-error date | named zone | 1 | [parse] Invalid date string | [parse] Invalid date string |
      | DSET-ZONE-016-GAP-DEFAULT | valid "2024-03-10 02:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York"] | 2024-03-10 02:30:00 Etc/UTC | America/New_York, flag omitted | 1 | empty | [set] Invalid date/timezone |
      | DSET-ZONE-017-GAP-STANDARD | valid "2024-03-10 02:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York", number 0] | 2024-03-10 02:30:00 Etc/UTC | America/New_York, standard 0 | 1 | empty | [set] Invalid date/timezone |
      | DSET-ZONE-018-GAP-DAYLIGHT | valid "2024-03-10 02:30:00 Etc/UTC" | selector text "zone"; arguments [text "America/New_York", number 1] | 2024-03-10 02:30:00 Etc/UTC | America/New_York, daylight 1 | 1 | empty | [set] Invalid date/timezone |

  @observed-compatibility @disputed
  Scenario: Offset and unresolved zone inputs end without a status and leave no stored date
    When I make each exact replacement request below
    Then each request ends without returning a status
    And its error immediately before and after the request is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact portable outcomes are:
      | case | initial receiver | exact request | status | call error before | call error after | stored-date text | ordered fields | error after stored-date read |
      | DSET-ZONE-003-OFFSET-TEXT | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "+05:30"] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
      | DSET-ZONE-004-OFFSET-LIST | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [list [number 5, number 30, number 0]] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
      | DSET-ZONE-009-INVALID-ZONE | valid "2040-02-29 16:05:09 America/New_York" | selector text "zone"; arguments [text "Not/A_Zone"] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
      | DSET-ZONE-020-TWO-AS-SINGLE-ARG | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zone"; arguments [number 2] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |

  Scenario: Whole zoned-date requests initialize, replace, recover, and disambiguate
    When I replace the complete zoned date as described in each row
    Then every request completes with status 0 and every call and observer error is empty
    And every stored-date result is text, every ordered field result has six exact fields, and fixed-local equals UTC
    And the exact results are:
      | case | initial receiver | exact request | receiver | zone | replacement | daylight request | wall result | UTC result |
      | DSET-ZDATE-001-LOCAL-UNSET | unset | selector text "zdate"; arguments [list [number 2041, number 1, number 2, number 3, number 4, number 5]] | unset | fixed local zone | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 03:04:05 |
      | DSET-ZDATE-002-NAMED-ZONE | valid "2040-02-29 16:05:09 America/Chicago" | selector text "zdate"; arguments [text "America/Los_Angeles", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | valid America/Chicago date | America/Los_Angeles | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 11:04:05 |
      | DSET-ZDATE-004-OVERLAP-DEFAULT | unset | selector text "zdate"; arguments [text "America/New_York", list [number 2024, number 11, number 3, number 1, number 30, number 0]] | unset | America/New_York | 2024-11-03 01:30:00 | omitted | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-ZDATE-005-OVERLAP-STANDARD | unset | selector text "zdate"; arguments [text "America/New_York", list [number 2024, number 11, number 3, number 1, number 30, number 0], number 0] | unset | America/New_York | 2024-11-03 01:30:00 | standard 0 | 2024-11-03 01:30:00 | 2024-11-03 06:30:00 |
      | DSET-ZDATE-006-OVERLAP-DAYLIGHT | unset | selector text "zdate"; arguments [text "America/New_York", list [number 2024, number 11, number 3, number 1, number 30, number 0], number 1] | unset | America/New_York | 2024-11-03 01:30:00 | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 05:30:00 |
      | DSET-ZDATE-007-LOCAL-OVERLAP-ISDST | unset | selector text "zdate"; arguments [list [number 2024, number 11, number 3, number 1, number 30, number 0], number 1] | unset | fixed local zone | 2024-11-03 01:30:00 | daylight 1 | 2024-11-03 01:30:00 | 2024-11-03 01:30:00 |
      | DSET-ZDATE-014-ERROR-RECOVERY | valid "2040-02-29 16:05:09 Etc/UTC", then parse "not a valid date phrase" | selector text "zdate"; arguments [text "America/Chicago", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | parse-error date | America/Chicago | 2041-01-02 03:04:05 | omitted | 2041-01-02 03:04:05 | 2041-01-02 09:04:05 |

  @observed-compatibility @disputed
  Scenario: A whole zoned-date request accepts daylight value 2 as truthy
    Given a valid UTC receiver equal to "2040-02-29 16:05:09"
    When I replace it with "2041-01-02 03:04:05 America/New_York" and daylight value 2
    Then the status is 0 and every call and observer error is empty
    And the wall result is "2041-01-02 03:04:05"
    And the UTC result is "2041-01-02 08:04:05"
    And the exact request is:
      | case | initial receiver | exact request |
      | DSET-ZDATE-013-ISDST-TWO | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [text "America/New_York", list [number 2041, number 1, number 2, number 3, number 4, number 5], number 2] |

  Scenario: Invalid zoned-date requests leave the carrier empty
    When I make the invalid zoned-date request in each row
    Then every call error before is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the call error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact call results are:
      | case | initial receiver | exact request | request | status | call error |
      | DSET-ZDATE-008-GAP | unset | selector text "zdate"; arguments [text "America/New_York", list [number 2024, number 3, number 10, number 2, number 30, number 0]] | New York gap 2024-03-10 02:30:00 | 1 | [set] Invalid date/timezone |
      | DSET-ZDATE-009-INVALID-DATE | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [text "America/New_York", list [number 2041, number 2, number 29, number 3, number 4, number 5]] | New York 2041-02-29 03:04:05 | 1 | [set] Invalid date argument |
      | DSET-ZDATE-011-OMITTED-DATE | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [] | omitted replacement | 1 | [set] Invalid arguments |
      | DSET-ZDATE-012-EXTRA-ARGUMENT | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [text "America/New_York", list [number 2041, number 1, number 2, number 3, number 4, number 5], number 0, text "extra"] | named zone, replacement, flag, and extra argument | 1 | [set] Invalid arguments |

  @observed-compatibility @disputed
  Scenario: Zoned-date offsets and unresolved names end without a status and leave no stored date
    When I make each exact replacement request below
    Then each request ends without returning a status
    And its error immediately before and after the request is empty
    And the stored-date, fixed-local, and UTC results are empty text and the ordered field result is an empty list
    And the first stored-date read changes the error to "[value] Object does not contain a date"
    And later ordered-field, fixed-local, and UTC reads retain that value error
    And the exact portable outcomes are:
      | case | initial receiver | exact request | status | call error before | call error after | stored-date text | ordered fields | error after stored-date read |
      | DSET-ZDATE-003-OFFSET-LIST | unset | selector text "zdate"; arguments [list [number -5, number -30, number 0], list [number 2041, number 1, number 2, number 3, number 4, number 5]] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
      | DSET-ZDATE-010-INVALID-ZONE | valid "2040-02-29 16:05:09 Etc/UTC" | selector text "zdate"; arguments [text "Not/A_Zone", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
      | DSET-ZDATE-015-OFFSET-TEXT | unset | selector text "zdate"; arguments [text "-05:30", list [number 2041, number 1, number 2, number 3, number 4, number 5]] | not returned | empty | empty | empty text | empty list | [value] Object does not contain a date |
