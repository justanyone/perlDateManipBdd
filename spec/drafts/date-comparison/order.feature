@draft @reference-dm700 @date-comparison
Feature: Compare dates through distinct public behavior profiles

  Background:
    Given a fresh English ASCII parsing context with local zone "Etc/UTC"
    And numeric dates use month/day/year order
    And the fixed clock is "2040-02-28 10:20:30 Etc/UTC"
    And text, field collections and absent values are written in JSON notation
    And comparison results -1, 0 and 1 mean before, equal and after respectively
    And null means no comparison result, distinct from equality

  Scenario Outline: Compare two parsed date objects for <case>
    Given two fresh date objects with the fixed context
    When I parse <left> into the first and <right> into the second
    Then the ordered parse statuses are <statuses>
    And their ordered errors are <errors>
    When I compare the first object with the second without prior value reads
    Then the comparison result is <result>
    And their ordered errors remain <errors>

    Examples:
      | case | left | right | statuses | errors | result |
      | CMP-OO-EQUAL | "2040-02-29 12:00:00" | "2040-02-29 12:00:00" | [0, 0] | ["", ""] | 0 |
      | CMP-OO-SECOND-BEFORE | "2040-02-29 11:59:59" | "2040-02-29 12:00:00" | [0, 0] | ["", ""] | -1 |
      | CMP-OO-SECOND-AFTER | "2040-02-29 12:00:01" | "2040-02-29 12:00:00" | [0, 0] | ["", ""] | 1 |
      | CMP-OO-LEAP | "2040-02-29 23:59:59" | "2040-03-01 00:00:00" | [0, 0] | ["", ""] | -1 |
      | CMP-OO-YEAR | "2039-12-31 23:59:59" | "2040-01-01 00:00:00" | [0, 0] | ["", ""] | -1 |
      | CMP-OO-SAME-INSTANT | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 07:00:00 America/New_York" | [0, 0] | ["", ""] | 0 |
      | CMP-OO-SAME-WALL | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 12:00:00 America/New_York" | [0, 0] | ["", ""] | -1 |
      | CMP-OO-BAD-LEFT | "not a date" | "2040-02-29 12:00:00" | [1, 0] | ["[parse] Invalid date string", ""] | null |
      | CMP-OO-BAD-RIGHT | "2040-02-29 12:00:00" | "not a date" | [0, 1] | ["", "[parse] Invalid date string"] | null |
      | CMP-OO-BOTH-BAD | "invalid first date" | "invalid second date" | [1, 1] | ["[parse] Invalid date string", "[parse] Invalid date string"] | null |
      | CMP-OO-EMPTY-LEFT | "" | "2040-02-29 12:00:00" | [1, 0] | ["[parse] Empty date string", ""] | null |
      | CMP-OO-ABSENT-RIGHT | "2040-02-29 12:00:00" | null | [0, 1] | ["", "[parse] Empty date string"] | null |

  @observed-compatibility @disputed
  Scenario Outline: Preserve current and legacy text comparison outcomes for <case>
    Given the <profile> functional comparison profile
    When I compare date texts <left> and <right>
    Then the comparison result is <result>

    Examples:
      | case | profile | left | right | result |
      | CMP-DM6-EQUAL | current-text | "2040-02-29 12:00:00" | "2040-02-29 12:00:00" | 0 |
      | CMP-DM6-SECOND-BEFORE | current-text | "2040-02-29 11:59:59" | "2040-02-29 12:00:00" | -1 |
      | CMP-DM6-SECOND-AFTER | current-text | "2040-02-29 12:00:01" | "2040-02-29 12:00:00" | 1 |
      | CMP-DM6-LEAP | current-text | "2040-02-29 23:59:59" | "2040-03-01 00:00:00" | -1 |
      | CMP-DM6-YEAR | current-text | "2039-12-31 23:59:59" | "2040-01-01 00:00:00" | -1 |
      | CMP-DM6-SAME-INSTANT | current-text | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 07:00:00 America/New_York" | 0 |
      | CMP-DM6-SAME-WALL | current-text | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 12:00:00 America/New_York" | -1 |
      | CMP-DM6-BAD-LEFT | current-text | "not a date" | "2040-02-29 12:00:00" | null |
      | CMP-DM6-BAD-RIGHT | current-text | "2040-02-29 12:00:00" | "not a date" | null |
      | CMP-DM6-BOTH-BAD | current-text | "invalid first date" | "invalid second date" | null |
      | CMP-DM6-EMPTY-LEFT | current-text | "" | "2040-02-29 12:00:00" | null |
      | CMP-DM6-ABSENT-RIGHT | current-text | "2040-02-29 12:00:00" | null | null |
      | CMP-DM5-EQUAL | legacy-text | "2040-02-29 12:00:00" | "2040-02-29 12:00:00" | 0 |
      | CMP-DM5-SECOND-BEFORE | legacy-text | "2040-02-29 11:59:59" | "2040-02-29 12:00:00" | -1 |
      | CMP-DM5-SECOND-AFTER | legacy-text | "2040-02-29 12:00:01" | "2040-02-29 12:00:00" | 1 |
      | CMP-DM5-LEAP | legacy-text | "2040-02-29 23:59:59" | "2040-03-01 00:00:00" | -1 |
      | CMP-DM5-YEAR | legacy-text | "2039-12-31 23:59:59" | "2040-01-01 00:00:00" | -1 |
      | CMP-DM5-SAME-INSTANT | legacy-text | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 07:00:00 America/New_York" | 0 |
      | CMP-DM5-SAME-WALL | legacy-text | "2040-02-29 12:00:00 Etc/UTC" | "2040-02-29 12:00:00 America/New_York" | 0 |
      | CMP-DM5-BAD-LEFT | legacy-text | "not a date" | "2040-02-29 12:00:00" | -1 |
      | CMP-DM5-BAD-RIGHT | legacy-text | "2040-02-29 12:00:00" | "not a date" | 1 |
      | CMP-DM5-BOTH-BAD | legacy-text | "invalid first date" | "invalid second date" | 0 |
      | CMP-DM5-EMPTY-LEFT | legacy-text | "" | "2040-02-29 12:00:00" | -1 |
      | CMP-DM5-ABSENT-RIGHT | legacy-text | "2040-02-29 12:00:00" | null | 1 |

  @observed-compatibility
  Scenario Outline: Compare ordered six-field collections for <case>
    Given the public calendar-service comparison profile
    When I compare the field collections <left> and <right>
    Then the comparison result is <result>
    And the service error before and after comparison is empty

    Examples:
      | case | left | right | result |
      | CMP-BASE-FIELD0-AFTER | [2040, 2, 29, 12, 34, 56] | [2039, 2, 29, 12, 34, 56] | 1 |
      | CMP-BASE-FIELD0-BEFORE | [2040, 2, 29, 12, 34, 56] | [2041, 2, 29, 12, 34, 56] | -1 |
      | CMP-BASE-FIELD1-AFTER | [2040, 2, 29, 12, 34, 56] | [2040, 1, 29, 12, 34, 56] | 1 |
      | CMP-BASE-FIELD1-BEFORE | [2040, 2, 29, 12, 34, 56] | [2040, 3, 29, 12, 34, 56] | -1 |
      | CMP-BASE-FIELD2-AFTER | [2040, 2, 29, 12, 34, 56] | [2040, 2, 28, 12, 34, 56] | 1 |
      | CMP-BASE-FIELD2-BEFORE | [2040, 2, 29, 12, 34, 56] | [2040, 2, 30, 12, 34, 56] | -1 |
      | CMP-BASE-FIELD3-AFTER | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 11, 34, 56] | 1 |
      | CMP-BASE-FIELD3-BEFORE | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 13, 34, 56] | -1 |
      | CMP-BASE-FIELD4-AFTER | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 12, 33, 56] | 1 |
      | CMP-BASE-FIELD4-BEFORE | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 12, 35, 56] | -1 |
      | CMP-BASE-FIELD5-AFTER | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 12, 34, 55] | 1 |
      | CMP-BASE-FIELD5-BEFORE | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 12, 34, 57] | -1 |
      | CMP-BASE-EQUAL | [2040, 2, 29, 12, 34, 56] | [2040, 2, 29, 12, 34, 56] | 0 |
