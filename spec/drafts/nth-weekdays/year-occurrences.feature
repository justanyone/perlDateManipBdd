@draft @portable @calendar @nth-weekday @reference-dm700
Feature: Whole-year ordinal weekday occurrences
  Each row freezes an observed ordered three-field value or absent result from one original public request.
  Generic arithmetic diagnostics are portable; native warning text and call contexts are excluded.

  Background:
    Given each case starts in a fresh process and temporary working directory
    And the timezone is UTC, the language is English, and the locale is C UTF-8
    And weekday 1 means Monday through weekday 7 meaning Sunday
    And positive occurrences count forward and negative occurrences count backward
    And profile calendar-service is defined exactly as follows:
      | behavior version | public input shape | year domain | whole-year occurrence domain | month occurrence domain | optional month | clock setting |
      | 7.00 | year, occurrence, weekday, optional month | 0001 through 9999 | 1 through 53 or -1 through -53 | 1 through 5 or -1 through -5 | omitted means whole year | none because calendar arithmetic has no clock input |

  Scenario Outline: Find one ordinal weekday occurrence
    Given I select profile <profile>
    When I request an ordinal weekday with <request>
    Then the public outcome is <result>

    Examples:
      | case | profile | request | result |
      | NWD-P1-YEAR-FIRST-FORWARD | calendar-service | {"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":1},"weekday":{"type":"number","value":1},"month":{"type":"omitted"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":1},{"type":"number","value":7}]}} |
      | NWD-P1-YEAR-LATER-FORWARD-ABSENT-MONTH | calendar-service | {"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":2},"weekday":{"type":"number","value":4},"month":{"type":"absent"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":1},{"type":"number","value":10}]}} |
      | NWD-P1-YEAR-LIMIT53-FORWARD | calendar-service | {"year":{"type":"number","value":2040},"occurrence":{"type":"number","value":53},"weekday":{"type":"number","value":7},"month":{"type":"omitted"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2040},{"type":"number","value":12},{"type":"number","value":30}]}} |
      | NWD-P1-YEAR-LAST-REVERSE | calendar-service | {"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":-1},"weekday":{"type":"number","value":7},"month":{"type":"omitted"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":12},{"type":"number","value":29}]}} |
      | NWD-P1-YEAR-LATER-REVERSE | calendar-service | {"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":-2},"weekday":{"type":"number","value":2},"month":{"type":"omitted"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":12},{"type":"number","value":24}]}} |
      | NWD-P1-YEAR-LIMIT53-REVERSE | calendar-service | {"year":{"type":"number","value":2040},"occurrence":{"type":"number","value":-53},"weekday":{"type":"number","value":1},"month":{"type":"omitted"}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2040},{"type":"number","value":1},{"type":"number","value":2}]}} |
