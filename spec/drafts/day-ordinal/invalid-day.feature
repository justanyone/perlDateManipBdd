@observed-reference @invalid-input @localized-day-ordinal
Feature: Out-of-range day ordinal requests
  Invalid-day behavior is explicit because the public documentation does not state an error convention.

  Background:
    Given the current facade uses ASCII encoding and the legacy facade uses its built-in text mode
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US

  Scenario Outline: Days above the civil month range have no ordinal result
    Given the <profile> ordinal facade is configured in English
    When I request localized ordinal text with arguments <arguments>
    Then the observed date.localized-day-ordinal result is <literal result>

    Examples:
      | request | profile | arguments | literal result |
      | DO-DM6-OUT32 | dm6 | [32] | an absent value |
      | DO-DM6-LARGE | dm6 | [100] | an absent value |
      | DO-DM5-OUT32 | dm5 | [32] | an absent value |
      | DO-DM5-LARGE | dm5 | [100] | an absent value |

  @suspected-bug
  Scenario Outline: Non-civil numeric values retain observed compatibility results
    Given the <profile> ordinal facade is configured in English
    When I request localized ordinal text with arguments <arguments>
    Then the observed date.localized-day-ordinal result is <literal result>
    But that result remains disputed rather than defining a valid day-of-month

    Examples:
      | request | profile | arguments | literal result |
      | DO-DM6-ZERO | dm6 | [0] | text "31st" |
      | DO-DM6-NEGATIVE | dm6 | [-1] | text "30th" |
      | DO-DM6-FRACTION | dm6 | [1.5] | text "1st" |
      | DO-DM5-ZERO | dm5 | [0] | text "31st" |
      | DO-DM5-NEGATIVE | dm5 | [-1] | text "30th" |
      | DO-DM5-FRACTION | dm5 | [1.5] | text "1st" |
