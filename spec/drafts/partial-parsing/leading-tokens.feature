@draft @partial-parsing @reference-dm700
Feature: Parse a date from a complete text value or the longest leading token prefix
  The current and legacy profiles name public behavior profiles. Raw module and
  callable bindings are kept outside this portable feature.

  Background:
    Given a fresh English parsing context with local zone "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And omitted clock fields default to midnight

  Scenario Outline: Parse whole plain and scalar-holder text without changing the carrier for <case>
    Given the "<profile>" leading-date profile
    And the input carrier is "<carrier>" containing "2040-02-29"
    When I request a date from the input with no parser gates
    Then the result is text "2040-02-29 00:00:00 Etc/UTC"
    And the input carrier still contains "2040-02-29"
    And standard output is empty

    Examples:
      | case                         | profile      | carrier       |
      | PP-PREFIX-DM6-PLAIN-WHOLE    | current-text | plain text    |
      | PP-PREFIX-DM6-SCALAR-WHOLE   | current-text | scalar holder |
      | PP-PREFIX-DM5-PLAIN-WHOLE    | legacy-text  | plain text    |
      | PP-PREFIX-DM5-SCALAR-WHOLE   | legacy-text  | scalar holder |

  Scenario Outline: Consume the longest successful leading token prefix for <case>
    Given the "<profile>" leading-date profile
    And the ordered input tokens are ["March", "1", "2040", "--verbose"]
    When I request a date from the input with no parser gates
    Then the result is text "2040-03-01 00:00:00 Etc/UTC"
    And exactly 3 input tokens are consumed
    And the remaining ordered tokens are ["--verbose"]
    And standard output is empty

    Examples:
      | case                         | profile      |
      | PP-PREFIX-DM6-ARRAY-LONGEST  | current-text |
      | PP-PREFIX-DM5-ARRAY-LONGEST  | legacy-text  |

  Scenario Outline: Consume a whole one-token collection for <case>
    Given the "<profile>" leading-date profile
    And the ordered input tokens are ["2040-02-29"]
    When I request a date from the input with no parser gates
    Then the result is text "2040-02-29 00:00:00 Etc/UTC"
    And exactly 1 input token is consumed
    And the remaining ordered tokens are []

    Examples:
      | case                       | profile      |
      | PP-PREFIX-DM6-ARRAY-WHOLE  | current-text |
      | PP-PREFIX-DM5-ARRAY-WHOLE  | legacy-text  |

  Scenario Outline: Preserve a token collection when no prefix parses for <case>
    Given the "<profile>" leading-date profile
    And the ordered input tokens are ["not-a-date", "--verbose"]
    When I request a date from the input with no parser gates
    Then the result is empty text
    And exactly 0 input tokens are consumed
    And the remaining ordered tokens are ["not-a-date", "--verbose"]

    Examples:
      | case                      | profile      |
      | PP-PREFIX-DM6-ARRAY-NONE  | current-text |
      | PP-PREFIX-DM5-ARRAY-NONE  | legacy-text  |

  Scenario Outline: Return empty text for an empty plain input for <case>
    Given the "<profile>" leading-date profile
    And the input carrier is plain text containing empty text
    When I request a date from the input with no parser gates
    Then the result is empty text
    And standard output is empty

    Examples:
      | case                      | profile      |
      | PP-PREFIX-DM6-PLAIN-EMPTY | current-text |
      | PP-PREFIX-DM5-PLAIN-EMPTY | legacy-text  |

  @compatibility
  Scenario Outline: Keep each profile's empty token-collection result for <case>
    Given the "<profile>" leading-date profile
    And the ordered input tokens are []
    When I request a date from the input with no parser gates
    Then the result is "<result>"
    And exactly 0 input tokens are consumed
    And the remaining ordered tokens are []

    Examples:
      | case                      | profile      | result       |
      | PP-PREFIX-DM6-ARRAY-EMPTY | current-text | empty text   |
      | PP-PREFIX-DM5-ARRAY-EMPTY | legacy-text  | absent value |

  @PP-PREFIX-DM6-GATE @observed-compatibility
  Scenario: A disabled ISO route can still consume a date accepted by another route
    Given the "current-text" leading-date profile
    And the ordered input tokens are ["2040-02-29", "tail"]
    When I request a date from the input with parser gate "noiso8601"
    Then the result is text "2040-02-29 00:00:00 Etc/UTC"
    And exactly 1 input token is consumed
    And the remaining ordered tokens are ["tail"]

  @PP-PREFIX-DM6-GATE-REJECT
  Scenario: A disabled ISO route preserves tokens when no other route accepts them
    Given the "current-text" leading-date profile
    And the ordered input tokens are ["--02", "tail"]
    When I request a date from the input with parser gate "noiso8601"
    Then the result is empty text
    And exactly 0 input tokens are consumed
    And the remaining ordered tokens are ["--02", "tail"]
