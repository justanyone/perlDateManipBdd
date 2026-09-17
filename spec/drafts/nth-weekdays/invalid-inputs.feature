@draft @portable @calendar @nth-weekday @reference-dm700
Feature: Malformed and out-of-domain ordinal weekday inputs
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
      | NWD-P5-OCCURRENCE-ZERO | calendar-service | {"description":"zero occurrence","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":0},"weekday":{"type":"number","value":3},"month":{"type":"number","value":5}}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":5},{"type":"number","value":1}]}} |
      | NWD-P5-MONTH-OCCURRENCE-PLUS6 | calendar-service | {"description":"month occurrence above positive limit","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":6},"weekday":{"type":"number","value":3},"month":{"type":"number","value":5}}} | {"status":"completed","diagnostic":"none","value":{"type":"absent"}} |
      | NWD-P5-MONTH-OCCURRENCE-MINUS6 | calendar-service | {"description":"month occurrence below negative limit","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":-6},"weekday":{"type":"number","value":5},"month":{"type":"number","value":5}}} | {"status":"completed","diagnostic":"none","value":{"type":"absent"}} |
      | NWD-P5-YEAR-OCCURRENCE-PLUS54 | calendar-service | {"description":"year occurrence above positive limit","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":54},"weekday":{"type":"number","value":2},"month":{"type":"omitted"}}} | {"status":"completed","diagnostic":"none","value":{"type":"absent"}} |
      | NWD-P5-YEAR-OCCURRENCE-MINUS54 | calendar-service | {"description":"year occurrence below negative limit","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":-54},"weekday":{"type":"number","value":2},"month":{"type":"omitted"}}} | {"status":"completed","diagnostic":"none","value":{"type":"absent"}} |
      | NWD-P5-WEEKDAY-ZERO | calendar-service | {"description":"weekday below documented range","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":1},"weekday":{"type":"number","value":0},"month":{"type":"number","value":5}}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":5},{"type":"number","value":5}]}} |
      | NWD-P5-WEEKDAY-EIGHT | calendar-service | {"description":"weekday above documented range","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":1},"weekday":{"type":"number","value":8},"month":{"type":"number","value":5}}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":5},{"type":"number","value":6}]}} |
      | NWD-P5-MONTH-ZERO | calendar-service | {"description":"false month value selects whole-year mode","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":1},"weekday":{"type":"number","value":2},"month":{"type":"number","value":0}}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":1},{"type":"number","value":1}]}} |
      | NWD-P5-MONTH-13 | calendar-service | {"description":"month above documented range","fields":{"year":{"type":"number","value":2041},"occurrence":{"type":"number","value":1},"weekday":{"type":"number","value":2},"month":{"type":"number","value":13}}} | {"status":"completed","diagnostic":"none","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":2041},{"type":"number","value":13},{"type":"number","value":7}]}} |
      | NWD-P5-ALL-OMITTED | calendar-service | {"description":"all required fields omitted","fields":{"year":{"type":"omitted"},"occurrence":{"type":"omitted"},"weekday":{"type":"omitted"},"month":{"type":"omitted"}}} | {"status":"completed","diagnostic":"arithmetic-input diagnostic","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":0},{"type":"number","value":1},{"type":"number","value":1}]}} |
      | NWD-P5-ALL-ABSENT | calendar-service | {"description":"all fields explicitly absent","fields":{"year":{"type":"absent"},"occurrence":{"type":"absent"},"weekday":{"type":"absent"},"month":{"type":"absent"}}} | {"status":"completed","diagnostic":"arithmetic-input diagnostic","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":0},{"type":"number","value":1},{"type":"number","value":1}]}} |
      | NWD-P5-ALL-NONNUMERIC | calendar-service | {"description":"all fields nonnumeric text","fields":{"year":{"type":"text","value":"year"},"occurrence":{"type":"text","value":"occurrence"},"weekday":{"type":"text","value":"weekday"},"month":{"type":"text","value":"month"}}} | {"status":"completed","diagnostic":"arithmetic-input diagnostic","value":{"type":"ordered-date-fields","field_order":["year","month","day"],"fields":[{"type":"number","value":0},{"type":"number","value":1},{"type":"number","value":1}]}} |
