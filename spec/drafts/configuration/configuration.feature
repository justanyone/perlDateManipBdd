@draft @portable @configuration @reference-dm700
Feature: Ordered configuration contexts
  Typed records distinguish omitted values, empty text, absent results, and diagnostics.
  Portable profile names describe behavior independently of a source-language interface.

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
    And profile legacy-functional uses compatibility behavior version 5.66 from distribution 7.00
    And legacy-functional FirstDay 1 starts each week on Monday
    And legacy-functional Jan1Week1 0 means week one contains January 4
    And legacy-functional TodayIsMidnight 1 anchors today at 00:00:00
    And legacy-functional EraseHolidays 1 starts the holiday collection empty
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
      | legacy-functional | IgnoreGlobalCnf | text "1" |
      | legacy-functional | PersonalCnf | empty text |
      | legacy-functional | PersonalCnfPath | empty text |
      | legacy-functional | ForceDate | text "2040-02-28-10:20:30" |
      | legacy-functional | TZ | text "Etc/UTC" |
      | legacy-functional | Language | text "English" |
      | legacy-functional | DateFormat | text "US" |
      | legacy-functional | Internal | text "0" |
      | legacy-functional | FirstDay | text "1" |
      | legacy-functional | Jan1Week1 | text "0" |
      | legacy-functional | WorkWeekBeg | text "1" |
      | legacy-functional | WorkWeekEnd | text "5" |
      | legacy-functional | WorkDayBeg | text "09:00" |
      | legacy-functional | WorkDayEnd | text "17:00" |
      | legacy-functional | WorkDay24Hr | text "0" |
      | legacy-functional | TodayIsMidnight | text "1" |
      | legacy-functional | EraseHolidays | text "1" |

  Scenario Outline: Apply one observed configuration request
    Given I select profile <profile>
    When I apply typed configuration request <request>
    Then its typed public result is <result>
    And its portable diagnostic outcome is <diagnostic>

    Examples:
      | case | profile | request | result | diagnostic |
      | CFG-DM6-DEFAULTS | current-object | {"settings":[{"name":"DateFormat","value":{"type":"text","value":"non-US"}},{"name":"Defaults","value":{"type":"text","value":"x"}}],"read_names":["dateformat"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"dateformat","value":{"type":"text","value":"US"}}]} | no diagnostic |
      | CFG-DM6-CONFIGFILE-MISSING | current-object | {"settings":[{"name":"ConfigFile","value":{"type":"text","value":"/tmp/date-manip-no-such-config"}}],"read_names":["configfile"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"configfile","value":{"type":"text","value":""}}]} | missing-file diagnostic for text "/tmp/date-manip-no-such-config" |
      | CFG-DM6-LANGUAGE | current-object | {"settings":[{"name":"Language","value":{"type":"text","value":"English"}}],"read_names":["language"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"language","value":{"type":"text","value":"English"}}]} | no diagnostic |
      | CFG-DM6-ENCODING-INVALID | current-object | {"settings":[{"name":"Encoding","value":{"type":"text","value":"not-an-encoding"}}],"read_names":["encoding"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"encoding","value":{"type":"text","value":"ASCII"}}]} | invalid-setting diagnostic containing text "invalid: Encoding: not-an-encoding" |
      | CFG-DM6-FIRSTDAY | current-object | {"settings":[{"name":"FirstDay","value":{"type":"text","value":"7"}}],"read_names":["firstday"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"firstday","value":{"type":"text","value":"7"}}]} | no diagnostic |
      | CFG-DM6-WEEK1-INVALID | current-object | {"settings":[{"name":"Week1ofYear","value":{"type":"text","value":"dow9"}}],"read_names":["week1ofyear"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"week1ofyear","value":{"type":"text","value":"jan4"}}]} | invalid-setting diagnostic containing text "invalid: Week1ofYear: dow9" |
      | CFG-DM6-PRINTABLE | current-object | {"settings":[{"name":"Printable","value":{"type":"text","value":"2"}}],"read_names":["printable"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"printable","value":{"type":"text","value":"2"}}]} | no diagnostic |
      | CFG-DM6-DATEFORMAT | current-object | {"settings":[{"name":"DateFormat","value":{"type":"text","value":"US"}}],"read_names":["dateformat"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"dateformat","value":{"type":"text","value":"US"}}]} | no diagnostic |
      | CFG-DM6-YYTOYYYY | current-object | {"settings":[{"name":"YYtoYYYY","value":{"type":"text","value":"C##"}}],"read_names":["yytoyyyy"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"yytoyyyy","value":{"type":"text","value":"89"}}]} | invalid-setting diagnostic containing text "invalid: YYtoYYYY: c##" |
      | CFG-DM6-DEFAULTTIME | current-object | {"settings":[{"name":"DefaultTime","value":{"type":"text","value":"curr"}}],"read_names":["defaulttime"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"defaulttime","value":{"type":"text","value":"curr"}}]} | no diagnostic |
      | CFG-DM6-PERIODSEP | current-object | {"settings":[{"name":"PeriodTimeSep","value":{"type":"text","value":"1"}}],"read_names":["periodtimesep"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"periodtimesep","value":{"type":"text","value":"1"}}]} | no diagnostic |
      | CFG-DM6-MMMYYYY | current-object | {"settings":[{"name":"Format_MMMYYYY","value":{"type":"text","value":"last"}}],"read_names":["format_mmmyyyy"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"format_mmmyyyy","value":{"type":"text","value":"last"}}]} | no diagnostic |
      | CFG-DM6-WORKWEEK | current-object | {"settings":[{"name":"WorkWeekBeg","value":{"type":"text","value":"2"}},{"name":"WorkWeekEnd","value":{"type":"text","value":"6"}}],"read_names":["workweekbeg","workweekend"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"workweekbeg","value":{"type":"text","value":"2"}},{"name":"workweekend","value":{"type":"text","value":"6"}}]} | no diagnostic |
      | CFG-DM6-WORKDAY24 | current-object | {"settings":[{"name":"WorkDay24Hr","value":{"type":"text","value":"1"}}],"read_names":["workday24hr"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"workday24hr","value":{"type":"text","value":"1"}}]} | no diagnostic |
      | CFG-DM6-WORKDAY-INVALID | current-object | {"settings":[{"name":"WorkDayBeg","value":{"type":"text","value":"18:00"}},{"name":"WorkDayEnd","value":{"type":"text","value":"17:00"}}],"read_names":["workdaybeg","workdayend"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"workdaybeg","value":{"type":"text","value":"09:00:00"}},{"name":"workdayend","value":{"type":"text","value":"17:00:00"}}]} | invalid-setting diagnostic containing text "WorkDayBeg not before WorkDayEnd" |
      | CFG-DM6-TOMORROWFIRST | current-object | {"settings":[{"name":"TomorrowFirst","value":{"type":"text","value":"0"}}],"read_names":["tomorrowfirst"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"tomorrowfirst","value":{"type":"text","value":"0"}}]} | no diagnostic |
      | CFG-DM6-ERASE-HOLIDAYS | current-object | {"settings":[{"name":"EraseHolidays","value":{"type":"text","value":""}}],"read_names":["eraseholidays"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"eraseholidays","value":{"type":"text","value":""}}]} | no diagnostic |
      | CFG-DM6-ERASE-EVENTS | current-object | {"settings":[{"name":"EraseEvents","value":{"type":"text","value":""}}],"read_names":["eraseevents"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"eraseevents","value":{"type":"text","value":""}}]} | no diagnostic |
      | CFG-DM6-RECURRANGE | current-object | {"settings":[{"name":"RecurRange","value":{"type":"text","value":"week"}}],"read_names":["recurrange"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"recurrange","value":{"type":"text","value":"week"}}]} | no diagnostic |
      | CFG-DM6-MAXRECUR-INVALID | current-object | {"settings":[{"name":"MaxRecurAttempts","value":{"type":"text","value":"no"}}],"read_names":["maxrecurattempts"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"maxrecurattempts","value":{"type":"text","value":"no"}}]} | no diagnostic |
      | CFG-DM6-SETDATE | current-object | {"settings":[{"name":"SetDate","value":{"type":"text","value":"2040-02-29-12:34:56,Etc/UTC"}}],"read_names":["setdate"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"setdate","value":{"type":"number","value":1}}]} | no diagnostic |
      | CFG-DM6-FORCEDATE | current-object | {"settings":[{"name":"ForceDate","value":{"type":"text","value":"2040-02-29-12:34:56,Etc/UTC"}}],"read_names":["forcedate"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"forcedate","value":{"type":"number","value":1}}]} | no diagnostic |
      | CFG-DM6-POSIX | current-object | {"settings":[{"name":"Use_POSIX_Printf","value":{"type":"text","value":"1"}}],"read_names":["use_posix_printf"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"use_posix_printf","value":{"type":"text","value":"1"}}]} | no diagnostic |
      | CFG-DM6-TZ-INVALID | current-object | {"settings":[{"name":"TZ","value":{"type":"text","value":"No/Such_Zone"}}],"read_names":["tz"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"tz","value":{"type":"text","value":""}}]} | invalid-zone diagnostic containing text "invalid zone in SetDate" |
      | CFG-DM6-JAN1WEEK1 | current-object | {"settings":[{"name":"Jan1Week1","value":{"type":"text","value":"1"}}],"read_names":["jan1week1"]} | {"apply_result":{"type":"absent"},"stored":[{"name":"jan1week1","value":{"type":"text","value":""}}]} | deprecated-setting diagnostic |
      | CFG-DM5-IGNOREGLOBAL | legacy-functional | {"settings":[{"name":"IgnoreGlobalCnf","value":{"type":"text","value":""}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-PATHSEP | legacy-functional | {"settings":[{"name":"PathSep","value":{"type":"text","value":":"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-GLOBAL-MISSING | legacy-functional | {"settings":[{"name":"GlobalCnf","value":{"type":"text","value":"/tmp/no-global-cnf"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-PERSONAL | legacy-functional | {"settings":[{"name":"PersonalCnf","value":{"type":"text","value":""}},{"name":"PersonalCnfPath","value":{"type":"text","value":""}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-CONVTZ | legacy-functional | {"settings":[{"name":"ConvTZ","value":{"type":"text","value":"IGNORE"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-INTERNAL | legacy-functional | {"settings":[{"name":"Internal","value":{"type":"text","value":"1"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-DELTASIGNS | legacy-functional | {"settings":[{"name":"DeltaSigns","value":{"type":"text","value":"1"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-UPDATECURRTZ | legacy-functional | {"settings":[{"name":"UpdateCurrTZ","value":{"type":"text","value":"1"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-INTCHARSET | legacy-functional | {"settings":[{"name":"IntCharSet","value":{"type":"text","value":"0"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
      | CFG-DM5-TODAYMIDNIGHT | legacy-functional | {"settings":[{"name":"TodayIsMidnight","value":{"type":"text","value":"1"}}]} | {"initializer_result":{"type":"absent"}} | no request diagnostic |
