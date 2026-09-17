@draft @portable @calendar @weekday @reference-dm700
Feature: Every numeric weekday
  These rows freeze one numeric weekday result or one public failure for each original request.
  Arithmetic-input diagnostics are portable categories; native warning and exception text is excluded.

  Background:
    Given each case starts in a fresh process and temporary working directory
    And the timezone is UTC, the language is English, and the locale is C UTF-8
    And the functional profiles use reference clock 2040-02-28 10:20:30 UTC
    And weekday 1 means Monday through weekday 7 meaning Sunday
    And a named civil date has fields year, month, and day
    And the profiles are defined exactly as follows:
      | profile | behavior version | public input shape | full-year domain | default short-year rule | clock setting |
      | calendar-service | 7.00 | one ordered collection of year, month, day | 0001 through 9999 | not applicable | none because weekday arithmetic has no clock input |
      | current-functional | 7.00 | separate month, day, year fields | 0001 through 9999 | 89 | 2040-02-28 10:20:30 UTC |
      | legacy-functional | 5.66 from distribution 7.00 | separate month, day, year fields | 0001 through 9999 | 89 | 2040-02-28 10:20:30 UTC |

  Scenario Outline: Observe one weekday request
    Given I select profile <profile>
    When I request weekdays with <request>
    Then the ordered public outcomes are <result>

    Examples:
      | case | profile | request | result |
      | WD-P1-BASE-1 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":9}]} | {"calls":[{"status":"completed","weekday":1,"diagnostic":"none"}]} |
      | WD-P1-BASE-2 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":10}]} | {"calls":[{"status":"completed","weekday":2,"diagnostic":"none"}]} |
      | WD-P1-BASE-3 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":11}]} | {"calls":[{"status":"completed","weekday":3,"diagnostic":"none"}]} |
      | WD-P1-BASE-4 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":12}]} | {"calls":[{"status":"completed","weekday":4,"diagnostic":"none"}]} |
      | WD-P1-BASE-5 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":13}]} | {"calls":[{"status":"completed","weekday":5,"diagnostic":"none"}]} |
      | WD-P1-BASE-6 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":14}]} | {"calls":[{"status":"completed","weekday":6,"diagnostic":"none"}]} |
      | WD-P1-BASE-7 | calendar-service | {"civil_dates":[{"year":2040,"month":4,"day":15}]} | {"calls":[{"status":"completed","weekday":7,"diagnostic":"none"}]} |
      | WD-P1-DM6-1 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":9}]} | {"calls":[{"status":"completed","weekday":1,"diagnostic":"none"}]} |
      | WD-P1-DM6-2 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":10}]} | {"calls":[{"status":"completed","weekday":2,"diagnostic":"none"}]} |
      | WD-P1-DM6-3 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":11}]} | {"calls":[{"status":"completed","weekday":3,"diagnostic":"none"}]} |
      | WD-P1-DM6-4 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":12}]} | {"calls":[{"status":"completed","weekday":4,"diagnostic":"none"}]} |
      | WD-P1-DM6-5 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":13}]} | {"calls":[{"status":"completed","weekday":5,"diagnostic":"none"}]} |
      | WD-P1-DM6-6 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":14}]} | {"calls":[{"status":"completed","weekday":6,"diagnostic":"none"}]} |
      | WD-P1-DM6-7 | current-functional | {"civil_dates":[{"year":2040,"month":4,"day":15}]} | {"calls":[{"status":"completed","weekday":7,"diagnostic":"none"}]} |
      | WD-P1-DM5-1 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":9}]} | {"calls":[{"status":"completed","weekday":1,"diagnostic":"none"}]} |
      | WD-P1-DM5-2 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":10}]} | {"calls":[{"status":"completed","weekday":2,"diagnostic":"none"}]} |
      | WD-P1-DM5-3 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":11}]} | {"calls":[{"status":"completed","weekday":3,"diagnostic":"none"}]} |
      | WD-P1-DM5-4 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":12}]} | {"calls":[{"status":"completed","weekday":4,"diagnostic":"none"}]} |
      | WD-P1-DM5-5 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":13}]} | {"calls":[{"status":"completed","weekday":5,"diagnostic":"none"}]} |
      | WD-P1-DM5-6 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":14}]} | {"calls":[{"status":"completed","weekday":6,"diagnostic":"none"}]} |
      | WD-P1-DM5-7 | legacy-functional | {"civil_dates":[{"year":2040,"month":4,"day":15}]} | {"calls":[{"status":"completed","weekday":7,"diagnostic":"none"}]} |
