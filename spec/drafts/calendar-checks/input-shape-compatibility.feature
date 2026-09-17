@observed-compatibility @disputed @calendar-validation
Feature: Calendar validation input representation compatibility
  These rows preserve public outcomes for representations outside the documented field domain.
  They do not make fractional, whitespace-padded, missing, absent, or extra fields portable valid inputs.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Retain each observed ordered-field compatibility outcome
    When I perform <operation> with typed input <input>
    Then the observed validation outcome is <outcome>
    But the request remains disputed because it contains <reason>

    Examples:
      | case | operation | input | outcome | reason |
      | CC-T-MIDNIGHT-ONE-DIGIT | calendar.validate-time | {"carrier":"ordered-fields","fields":["0","0","0"]} | valid | one-digit text fields |
      | CC-T-NEGATIVE | calendar.validate-time | {"carrier":"ordered-fields","fields":[-1,0,0]} | invalid | signed field |
      | CC-T-FRACTION | calendar.validate-time | {"carrier":"ordered-fields","fields":[1.5,0,0]} | invalid | fractional field |
      | CC-T-WHITESPACE | calendar.validate-time | {"carrier":"ordered-fields","fields":[" 1",0,0]} | invalid | leading whitespace |
      | CC-T-NONNUMERIC | calendar.validate-time | {"carrier":"ordered-fields","fields":["x",0,0]} | invalid | nonnumeric text |
      | CC-T-MISSING-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,30]} | invalid | second field omitted |
      | CC-T-UNDEFINED-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,null,0]} | invalid | minute explicitly absent |
      | CC-T-EXTRA-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,30,15,99]} | valid | one extra field |
      | CC-D-FRACTIONAL-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040.5,1,1,0,0,0]} | valid | fractional year |
      | CC-D-WHITESPACE-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":[" 2040",1,1,0,0,0]} | valid | year text with leading whitespace |
      | CC-D-NONNUMERIC-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":["x",1,1,0,0,0]} | invalid | nonnumeric year |
      | CC-D-MISSING-TIME | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,1]} | invalid | time fields omitted |
      | CC-D-EXTRA-FIELD | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,1,0,0,0,99]} | valid | one extra field |
      | CC-D-UNDEFINED-DAY | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,null,0,0,0]} | invalid | day explicitly absent |
