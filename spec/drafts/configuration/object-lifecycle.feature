@draft @portable @configuration @object-lifecycle @reference-dm700
Feature: Typed values expose configuration and error lifecycle
  Named operations expose typed values without prescribing native call context or classes.

  Background:
    Given each case starts in a fresh process and temporary working directory
    And no user, system, or prior-case configuration is inherited
    And the process timezone is UTC with the C UTF-8 locale
    And weekday numbers 1 through 7 mean Monday through Sunday
    And US numeric date order means month, day, then year
    And workweek endpoints 1 and 5 mean Monday through Friday
    And workday endpoints 09:00 and 17:00 bound the workday
    And profile current-object uses reference behavior version 7.00
    And current-object FirstDay 1 starts each week on Monday
    And current-object Week1ofYear jan4 means week one contains January 4
    And current-object DefaultTime midnight supplies 00:00:00 when a date omits its time
    And current-object EraseHolidays 1 and EraseEvents 1 start those collections empty
    And the selected profile has these ordered settings:
      | profile | setting | typed value |
      | current-object | Defaults | text "1" |
      | current-object | ForceDate | text "2040-02-28-10:20:30,Etc/UTC" |
      | current-object | Language | text "English" |
      | current-object | Encoding | text "ASCII" |
      | current-object | DateFormat | text "US" |
      | current-object | Printable | text "0" |
      | current-object | FirstDay | text "1" |
      | current-object | Week1ofYear | text "jan4" |
      | current-object | DefaultTime | text "midnight" |
      | current-object | WorkWeekBeg | text "1" |
      | current-object | WorkWeekEnd | text "5" |
      | current-object | WorkDayBeg | text "09:00" |
      | current-object | WorkDayEnd | text "17:00" |
      | current-object | WorkDay24Hr | text "0" |
      | current-object | EraseHolidays | text "1" |
      | current-object | EraseEvents | text "1" |

  Scenario Outline: Observe one configuration or value lifecycle request
    Given I select profile <profile>
    When I perform typed request <request>
    Then its typed public result is <result>

    Examples:
      | case | profile | request | result |
      | CFG-READ-ARITIES | current-object | {"operation":"read ordered configuration collection","preload":[{"name":"DateFormat","value":{"type":"text","value":"US"}}],"names":["dateformat","DateFormat","no-such-key"]} | {"ordered_values":[{"type":"text","value":""}],"error":{"type":"text","value":""}} |
      | CFG-ERROR-CLEAR | current-object | {"operation":"parse then clear error","input":{"type":"text","value":"not a valid date phrase"},"clear_request":{"type":"number","value":1}} | {"initial_error":{"type":"text","value":""},"status":{"type":"number","value":1},"parse_error":{"type":"text","value":"[parse] Invalid date string"},"clear_result":{"type":"absent"},"final_error":{"type":"text","value":""}} |
      | CFG-OBJECT-KINDS | current-object | {"operation":"read value kinds","value_kinds":["date","duration","recurrence"],"predicate_order":["is date value","is duration value","is recurrence value"]} | {"date":{"is_date_value":true,"is_duration_value":false,"is_recurrence_value":false},"duration":{"is_date_value":false,"is_duration_value":true,"is_recurrence_value":false},"recurrence":{"is_date_value":false,"is_duration_value":false,"is_recurrence_value":true}} |
      | CFG-CONTEXT-DERIVE | current-object | {"operation":"derive configuration context","initial_text":{"type":"omitted"},"numeric_date_order":{"type":"text","value":"non-US"}} | {"source_numeric_date_order":{"type":"text","value":"US"},"derived_numeric_date_order":{"type":"text","value":"non-US"},"derived_kind":"date value"} |
      | CFG-CONTEXT-SERVICES | current-object | {"operation":"read calendar context service availability","value_kinds":["date","duration"]} | {"date_value":{"calendar_context_service_available":true},"duration_value":{"calendar_context_service_available":true}} |
