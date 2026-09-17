@draft @reference-dm700 @partial-parsing-edges @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve Perl warning channels for partial-parsing edge requests
  These scenarios retain externally visible warnings from the reference Perl
  binding. They are research compatibility evidence and are not portable
  date-time behavior.

  @PPE-BIND-WARN-HOLIDAY
  Scenario: The holiday gate comparison emits its observed Perl warnings
    Given the four-call holiday gate control
    When its four fresh receiver calls are executed
    Then the Perl warning channel contains exactly 12 undefined-component warnings
    And it contains no other warnings

  @PPE-BIND-WARN-UNDEFINED-DM6
  Scenario: The current binding warns for an absent token during prefix search
    Given the current binding absent-leading-token control
    When the current Perl binding parses the token collection
    Then the Perl warning channel contains exactly 2 uninitialized-token warnings
    And it contains no deprecation warning
    And it contains no other warnings

  @PPE-BIND-WARN-UNDEFINED-DM5
  Scenario: The legacy binding adds its deprecation warning
    Given the legacy binding absent-leading-token control
    When the legacy Perl binding parses the token collection
    Then the Perl warning channel contains exactly 2 uninitialized-token warnings
    And it contains exactly 1 binding deprecation warning
    And it contains no other warnings
