@draft @reference-dm700 @partial-parsing-edges
Feature: Resolve longest date prefixes across token and scalar carrier shapes
  The current-text and legacy-text profiles name behavior profiles. Their raw
  implementation bindings and binding warnings are recorded separately.

  Background:
    Given displayed date-times normalize the native six civil fields to "YYYY-MM-DD HH:MM:SS"
    And zone labels describe the supplied context; abbreviation and offset assertions are separate
    And a fresh English parsing context with local zone "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And omitted clock fields default to midnight
    And numeric dates use month/day/year order

  Scenario Outline: A token may itself contain the whole date for <case>
    Given the "<profile>" profile receives tokens ["March 1 2040", "tail"]
    When I request a date from the longest leading token prefix
    Then the result is text "2040-03-01 00:00:00 Etc/UTC"
    And exactly 1 token is consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                               | profile      |
      | PPE-PREFIX-DM6-TOKEN-WHOLE-WORDS   | current-text |
      | PPE-PREFIX-DM5-TOKEN-WHOLE-WORDS   | legacy-text  |

  Scenario Outline: Empty tokens can participate in a successful joined prefix for <case>
    Given the "<profile>" profile receives tokens <tokens>
    When I request a date from the longest leading token prefix
    Then the result is text "<result>"
    And exactly <consumed> tokens are consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                        | profile      | tokens                                | consumed | result                      |
      | PPE-PREFIX-DM6-EMPTY-FIRST  | current-text | ["", "2040-02-29", "tail"]         | 2        | 2040-02-29 00:00:00 Etc/UTC |
      | PPE-PREFIX-DM5-EMPTY-FIRST  | legacy-text  | ["", "2040-02-29", "tail"]         | 2        | 2040-02-29 00:00:00 Etc/UTC |
      | PPE-PREFIX-DM6-EMPTY-MIDDLE | current-text | ["March", "", "1", "2040", "tail"] | 4      | 2040-03-01 00:00:00 Etc/UTC |
      | PPE-PREFIX-DM5-EMPTY-MIDDLE | legacy-text  | ["March", "", "1", "2040", "tail"] | 4      | 2040-03-01 00:00:00 Etc/UTC |

  Scenario Outline: The longest valid prefix includes an explicit time for <case>
    Given the "<profile>" profile receives tokens ["March", "1", "2040", "16:05", "tail"]
    When I request a date from the longest leading token prefix
    Then the result is text "2040-03-01 16:05:00 Etc/UTC"
    And exactly 4 tokens are consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                              | profile      |
      | PPE-PREFIX-DM6-DATE-TIME-LONGEST  | current-text |
      | PPE-PREFIX-DM5-DATE-TIME-LONGEST  | legacy-text  |

  Scenario Outline: Ambiguous numeric tokens use the longest accepted interpretation for <case>
    Given the "<profile>" profile receives tokens ["10", "11", "12", "tail"]
    When I request a date from the longest leading token prefix
    Then the result is text "2012-10-11 00:00:00 Etc/UTC"
    And exactly 3 tokens are consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                             | profile      |
      | PPE-PREFIX-DM6-AMBIGUOUS-NUMERIC | current-text |
      | PPE-PREFIX-DM5-AMBIGUOUS-NUMERIC | legacy-text  |

  Scenario Outline: A numeric token is accepted and consumed for <case>
    Given the "<profile>" profile receives numeric token 2040 followed by text token "tail"
    When I request a date from the longest leading token prefix
    Then the result is text "2040-01-01 00:00:00 Etc/UTC"
    And exactly 1 token is consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                         | profile      |
      | PPE-PREFIX-DM6-NUMERIC-TOKEN | current-text |
      | PPE-PREFIX-DM5-NUMERIC-TOKEN | legacy-text  |

  Scenario Outline: Plain and scalar-holder text do not use prefix fallback for <case>
    Given the "<profile>" profile receives <carrier> containing "March 1 2040 tail"
    When I request a date from the carrier
    Then the result is empty text
    And the carrier remains "March 1 2040 tail"

    Examples:
      | case                         | profile      | carrier       |
      | PPE-PREFIX-DM6-SCALAR-SUFFIX | current-text | scalar holder |
      | PPE-PREFIX-DM5-SCALAR-SUFFIX | legacy-text  | scalar holder |
      | PPE-PREFIX-DM6-PLAIN-SUFFIX  | current-text | plain text    |
      | PPE-PREFIX-DM5-PLAIN-SUFFIX  | legacy-text  | plain text    |

  @observed-compatibility @disputed
  Scenario Outline: An absent leading token can be consumed with a following date for <case>
    Given the "<profile>" profile receives tokens [absent, "2040-02-29", "tail"]
    When I request a date from the longest leading token prefix
    Then the result is text "2040-02-29 00:00:00 Etc/UTC"
    And exactly 2 tokens are consumed
    And the remaining tokens are ["tail"]

    Examples:
      | case                           | profile      |
      | PPE-PREFIX-DM6-UNDEFINED-TOKEN | current-text |
      | PPE-PREFIX-DM5-UNDEFINED-TOKEN | legacy-text  |
