@portable @observed-reference @week-count @configuration-state
Feature: Week-count state after configuration changes
  Every row gives the complete ordered public request sequence.
  The initial calendar profile starts weeks on Monday and puts January 4 in week one.
  These requests have no reference-clock input.

  Scenario Outline: Preserve counts across a reused calendar service
    When I execute the public request sequence <sequence>
    Then the calendar.weeks-in-year count trace is <count trace>
    And the attempted configuration requests are <configuration requests>
    And the configuration outcome trace is <configuration outcome trace>

    Examples:
      | case | sequence | count trace | configuration requests | configuration outcome trace |
      | WCE-CONFIG-ABA | [{"request":"count configured weeks","typed arguments":[2000]},{"request":"set week-one rule","value":"jan1"},{"request":"count configured weeks","typed arguments":[2000]},{"request":"set week-one rule","value":"jan4"},{"request":"count configured weeks","typed arguments":[2000]}] | [52,53,52] | [{"request":"set week-one rule","value":"jan1"},{"request":"set week-one rule","value":"jan4"}] | ["accepted","accepted"] |
      | WCE-BAD-FIRSTDAY | [{"request":"count configured weeks","typed arguments":[2000]},{"request":"set first weekday","value":8},{"request":"count configured weeks","typed arguments":[2000]}] | [52,52] | [{"request":"set first weekday","value":8}] | ["rejected"] |
      | WCE-BAD-WEEKRULE | [{"request":"count configured weeks","typed arguments":[2000]},{"request":"set week-one rule","value":"jan8"},{"request":"count configured weeks","typed arguments":[2000]}] | [52,52] | [{"request":"set week-one rule","value":"jan8"}] | ["rejected"] |
