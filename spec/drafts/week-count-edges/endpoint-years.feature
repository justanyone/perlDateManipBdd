@portable @week-count @observed-reference
Feature: Configured week counts at supported year endpoints
  Week one contains January 4 and weeks begin on Monday.
  The count is a civil Gregorian result and does not depend on a reference clock.

  Scenario Outline: Count weeks at a supported endpoint year
    When I request calendar.weeks-in-year with typed arguments <arguments>
    Then the configured week count is <count>

    Examples:
      | case | arguments | count |
      | WCE-YEAR1 | [1] | 52 |
      | WCE-YEAR9999 | [9999] | 52 |
