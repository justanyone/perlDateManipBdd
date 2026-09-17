@draft @arithmetic @calculation
Feature: Calculate typed dates and intervals in named modes
  This draft is based on repeatable reference observations and awaits semantic review.

  Background:
    Given English text, UTC, and the named fixed reference profile
    And a Monday-Friday 09:00-17:00 work schedule with no holidays or events

  @ARITH-OO-DATE-DATE-MODES
  Scenario Outline: Find the interval between two dates in <mode> mode for <case>
    When I calculate the interval from "<left>" to "<right>" in mode "<mode>"
    Then the interval fields are "<result>"

    Examples:
      | case                         | left                | right               | mode     | result          |
      | ARITH-OO-DATE-DATE-EXACT     | 2040-02-28 10:20:30 | 2040-03-01 10:20:30 | exact    | 0:0:0:0:48:0:0  |
      | ARITH-OO-DATE-DATE-SEMI      | 2040-02-28 10:20:30 | 2040-03-01 10:20:30 | semi     | 0:0:0:2:0:0:0   |
      | ARITH-OO-DATE-DATE-APPROX    | 2040-02-28 10:20:30 | 2040-03-01 10:20:30 | approx   | 0:1:-3:6:0:0:0   |
      | ARITH-OO-DATE-DATE-BUSINESS  | 2040-03-01 10:00:00 | 2040-03-04 10:00:00 | business | 0:0:0:1:7:0:0   |
      | ARITH-OO-DATE-DATE-BSEMI     | 2040-03-01 10:00:00 | 2040-03-04 10:00:00 | bsemi    | 0:0:0:1:7:0:0   |
      | ARITH-OO-DATE-DATE-BAPPROX   | 2040-03-01 10:00:00 | 2040-03-04 10:00:00 | bapprox  | 0:0:0:1:7:0:0   |

  @ARITH-OO-OPERAND-PAIRINGS
  Scenario Outline: Calculate one typed operand pairing for <case>
    When I calculate <left-kind> "<left>" with <right-kind> "<right>" using options "<options>"
    Then the result kind is "<result-kind>"
    And the result value is "<result>"

    Examples:
      | case                          | left-kind | left                | right-kind | right                   | options | result-kind | result |
      | ARITH-OO-DATE-DATE-PAIRING-EXACT      | date      | 2040-02-28 10:20:30 | date       | 2040-03-01 10:20:30     | exact | interval | 0:0:0:0:48:0:0   |
      | ARITH-OO-DATE-DELTA-PAIRING   | date      | 2040-02-28 10:20:30 | interval   | 2 days                  | omitted | date | 2040-03-01 10:20:30 |
      | ARITH-OO-DELTA-DATE-PAIRING   | interval  | 2 days              | date       | 2040-02-28 10:20:30     | omitted | date | 2040-03-01 10:20:30 |
      | ARITH-OO-DELTA-DELTA-PAIRING  | interval  | 2 days              | interval   | 3 hours                 | omitted | interval | 0:0:0:2:3:0:0   |
