@draft @configuration @object-lifecycle @reference-dm700
Feature: Typed values expose configuration and error lifecycle
  A value has a kind, can derive a configuration context, and retains an observable current error.

  Scenario: An invalid parse creates an error that a truthy clear request removes
    Given the fixed English UTC configuration context
    When a date value receives unparseable text "not a valid date phrase"
    Then its parse status is "1"
    And its error text is "[parse] Invalid date string"
    When I clear that error with the numeric request 1
    Then its error text is empty
    And this is case "CFG-ERROR-CLEAR"

  Scenario: Kind checks distinguish date, duration, and recurrence values
    Given a fresh date value, duration value, and recurrence value
    When I query date-kind, duration-kind, and recurrence-kind in that order for each value
    Then their kind triples are "true false false", "false true false", and "false false true"
    And this is case "CFG-OBJECT-KINDS"

  Scenario: A derived date value retains the observed numeric-date order
    Given a date value configured with US numeric-date order
    When I derive another date value with omitted initial text and numeric-date order "non-US"
    Then the source still reads "US" for numeric-date order
    And the derived value reads "non-US" for numeric-date order
    And this is case "CFG-CONTEXT-DERIVE"

  Scenario: Date and duration values expose a base context service
    Given a fresh date value and duration value
    When I request each value's base context service
    Then each reports a base context service
    And this is case "CFG-CONTEXT-SERVICES"

  Scenario: Reading several names preserves an empty result for an invalid name
    Given the fixed English UTC configuration context
    When I request the configuration names "dateformat", "DateFormat", and "no-such-key" together in that order
    Then the observed returned collection is one empty text value
    And the error state remains empty
    And this is case "CFG-READ-ARITIES"
