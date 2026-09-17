@draft @reference-binding @excluded-from-portable-handoff
Feature: Preserve reference completeness diagnostics

  Scenario Outline: Invalid receivers warn once per completeness query for <case>
    Given the complete setup and ordered requests of source case "<case>"
    When the Perl reference executes those twelve completeness queries
    Then each query returns no value and emits one warning containing "[complete] Object must contain a valid date"
    And no other warning or exception occurs

    Examples:
      | case |
      | COMP-UNSET |
      | COMP-INVALID |
      | COMP-EMPTY |
