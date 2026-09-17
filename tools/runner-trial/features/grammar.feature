@runner-trial
Feature: Validate the common Gherkin subset before adapter implementation

  Background:
    Given a fresh trial record

  @outline
  Scenario Outline: Preserve each example text for <case>
    When I remember "<text>"
    Then the remembered text is "<expected>"

    Examples:
      | case | text | expected |
      | ASCII | February | February |
      | Unicode | février | février |
      | pipe | EST\|-0500 | EST\|-0500 |

  @table
  Scenario: Read a step data table in order
    When I receive these records:
      | label | value |
      | first | février |
      | second | EST\|-0500 |
    Then the records contain the two expected ordered entries

  @docstring
  Scenario: Preserve multiline data
    When I receive this text:
      """
      first line
      deuxième ligne
      """
    Then the multiline text contains the two expected lines and a final newline

  @deliberate-failure
  Scenario: Reject an incorrect literal
    When I remember "actual"
    Then the remembered text is "incorrect"

  @undefined-step
  Scenario: Reject undefined steps in strict mode
    When no definition exists for this trial step
