@observed-compatibility @disputed @week-count
Feature: Week-count behavior outside the supported year domain
  These requests retain selected public outcomes without making their inputs valid years.
  Week one contains January 4 and weeks begin on Monday.

  Scenario Outline: Retain a selected unsupported year-input outcome
    When I request calendar.weeks-in-year with typed arguments <arguments>
    Then the observed configured week count is <count>
    But the input remains outside the portable supported-year domain

    Examples:
      | case | arguments | count |
      | WCE-ZERO | [0] | 52 |
      | WCE-NEGATIVE | [-1] | 52 |
      | WCE-HIGH | [10000] | 52 |
      | WCE-FRACTION | [2000.5] | 52 |
      | WCE-OMITTED | [] | 52 |
      | WCE-ABSENT | [null] | 52 |
      | WCE-EMPTY | [""] | 52 |
      | WCE-TEXT | ["year"] | 52 |
      | WCE-SHORT | ["00"] | 52 |
