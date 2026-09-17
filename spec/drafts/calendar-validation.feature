@draft @calendar
Feature: Validate complete civil fields without timezone resolution
  These requests validate supplied fields and do not parse text or resolve a zone.
  Civil years range from 1 through 9999. No field is inferred from a reference clock.

  Background:
    Given the calendar follows the proleptic Gregorian rules
    And validation uses the supplied civil fields without timezone conversion

  Scenario Outline: Validate a complete date and clock for <case>
    Given the civil fields are:
      | year   | month   | day   | hour   | minute   | second   |
      | <year> | <month> | <day> | <hour> | <minute> | <second> |
    When I validate the complete civil date and clock
    Then the answer is "<answer>"

    Examples:
      | case              | year  | month | day | hour | minute | second | answer |
      | VALID-LEAP-LATE   | 2040  | 2     | 29  | 23   | 59     | 59     | yes    |
      | VALID-LEAP        | 2040  | 2     | 29  | 0    | 0      | 0      | yes    |
      | INVALID-LEAP      | 2041  | 2     | 29  | 0    | 0      | 0      | no     |
      | INVALID-YEAR-ZERO | 0     | 1     | 1   | 0    | 0      | 0      | no     |
      | VALID-YEAR-FIRST  | 1     | 1     | 1   | 0    | 0      | 0      | yes    |
      | VALID-YEAR-LAST   | 9999  | 12    | 31  | 0    | 0      | 0      | yes    |
      | INVALID-YEAR-HIGH | 10000 | 1     | 1   | 0    | 0      | 0      | no     |
      | INVALID-MONTH-LOW | 2040  | 0     | 1   | 0    | 0      | 0      | no     |
      | INVALID-MONTH-HIGH| 2040  | 13    | 1   | 0    | 0      | 0      | no     |
      | INVALID-APRIL-DAY | 2040  | 4     | 31  | 0    | 0      | 0      | no     |
      | INVALID-DAY-ZERO  | 2040  | 2     | 0   | 0    | 0      | 0      | no     |

  @reference_behavior
  Scenario Outline: Validate a whole-second clock including the end-of-day form for <case>
    Given the clock fields are:
      | hour   | minute   | second   |
      | <hour> | <minute> | <second> |
    When I validate the whole-second clock fields
    Then the answer is "<answer>"

    Examples:
      | case                  | hour | minute | second | answer |
      | CLOCK-MIDNIGHT        | 0    | 0      | 0      | yes    |
      | CLOCK-LAST-SECOND     | 23   | 59     | 59     | yes    |
      | CLOCK-END-OF-DAY      | 24   | 0      | 0      | yes    |
      | CLOCK-AFTER-END       | 24   | 0      | 1      | no     |
      | CLOCK-NEGATIVE-HOUR   | -1   | 0      | 0      | no     |
      | CLOCK-MINUTE-OVERFLOW | 12   | 60     | 0      | no     |
      | CLOCK-SECOND-OVERFLOW | 12   | 0      | 60     | no     |
      | CLOCK-FRACTION        | 12   | 0      | 0.5    | no     |
