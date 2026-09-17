@draft @partial-parsing @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Report unsupported Perl reference carriers for leading-date parsing
  These examples preserve a public Perl binding compatibility result. A mapping
  reference and the exact process output channel are outside the portable value
  contract.

  Background:
    Given a fresh English parsing context with local zone "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"

  Scenario Outline: Reject an unsupported Perl mapping reference for <case>
    Given the "<profile>" Perl leading-date binding
    And the input is a mapping reference containing date "2040-02-29"
    When the binding requests a date from that reference with no parser gates
    Then the scalar return is empty text
    And the mapping reference is unchanged
    And standard output is exactly "ERROR:  Invalid arguments to ParseDate." followed by one line feed

    Examples:
      | case                      | profile      |
      | PP-PREFIX-DM6-UNSUPPORTED | current-text |
      | PP-PREFIX-DM5-UNSUPPORTED | legacy-text  |
