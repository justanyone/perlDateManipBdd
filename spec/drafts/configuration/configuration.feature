@draft @configuration @reference-dm700
Feature: Ordered configuration contexts
  A configuration context has named settings, records diagnostics, and affects later date operations.
  Each case uses the named fixed English UTC fixture and starts in a fresh context.

  Scenario Outline: A setting accepts one observed representative value
    Given the fixed English UTC configuration context
    When I apply the setting "<setting>" with the text "<value>"
    Then reading the setting "<read_name>" yields "<stored>"

    Examples:
      | case_id | setting | value | read_name | stored |
      | CFG-DM6-LANGUAGE | Language | English | language | English |
      | CFG-DM6-FIRSTDAY | FirstDay | 7 | firstday | 7 |
      | CFG-DM6-PRINTABLE | Printable | 2 | printable | 2 |
      | CFG-DM6-DATEFORMAT | DateFormat | US | dateformat | US |
      | CFG-DM6-DEFAULTTIME | DefaultTime | curr | defaulttime | curr |
      | CFG-DM6-PERIODSEP | PeriodTimeSep | 1 | periodtimesep | 1 |
      | CFG-DM6-MMMYYYY | Format_MMMYYYY | last | format_mmmyyyy | last |
      | CFG-DM6-WORKDAY24 | WorkDay24Hr | 1 | workday24hr | 1 |
      | CFG-DM6-TOMORROWFIRST | TomorrowFirst | 0 | tomorrowfirst | 0 |
      | CFG-DM6-ERASE-HOLIDAYS | EraseHolidays |  | eraseholidays |  |
      | CFG-DM6-ERASE-EVENTS | EraseEvents |  | eraseevents |  |
      | CFG-DM6-RECURRANGE | RecurRange | week | recurrange | week |
      | CFG-DM6-POSIX | Use_POSIX_Printf | 1 | use_posix_printf | 1 |

  Scenario: Ordered settings preserve each accepted work-week endpoint
    Given the fixed English UTC configuration context
    When I apply, in order, work-week start "2" and work-week end "6"
    Then reading the two settings yields "2" followed by "6"
    And this is case "CFG-DM6-WORKWEEK"

  Scenario: Reset discards an earlier setting at its position in the sequence
    Given the fixed English UTC configuration context
    When I apply "DateFormat" with text "non-US", then "Defaults" with text "x"
    Then the date-order setting reads "US"
    And this is case "CFG-DM6-DEFAULTS"

  Scenario Outline: Invalid configuration retains the concrete prior value
    Given the fixed English UTC configuration context
    When I apply invalid setting "<setting>" with text "<value>"
    Then the setting remains at the fixture value "<stored>"
    And the diagnostic contains "<diagnostic>"

    Examples:
      | case_id | setting | value | stored | diagnostic |
      | CFG-DM6-ENCODING-INVALID | Encoding | not-an-encoding | ASCII | invalid: Encoding: not-an-encoding |
      | CFG-DM6-WEEK1-INVALID | Week1ofYear | dow9 | jan4 | invalid: Week1ofYear: dow9 |
      | CFG-DM6-WORKDAY-INVALID | WorkDayBeg then WorkDayEnd | 18:00 then 17:00 | 09:00:00 then 17:00:00 | WorkDayBeg not before WorkDayEnd |
      | CFG-DM6-TZ-INVALID | TZ | No/Such_Zone |  | invalid zone in SetDate |

  Scenario: A missing configuration file reports its exact missing path
    Given the fixed English UTC configuration context
    When I apply configuration file path "/tmp/date-manip-no-such-config"
    Then the diagnostic contains "file doesn't exist: /tmp/date-manip-no-such-config"
    And the configuration file setting reads as an empty value
    And this is case "CFG-DM6-CONFIGFILE-MISSING"

  Scenario: Fixed-clock settings retain their enabled marker
    Given the fixed English UTC configuration context
    When I set the reference clock to "2040-02-29-12:34:56" in UTC
    Then the reference-clock setting reads numeric marker "1"
    And this is case "CFG-DM6-SETDATE"

  Scenario: The forced-clock setting retains its enabled marker
    Given the fixed English UTC configuration context
    When I force the clock to "2040-02-29-12:34:56" in UTC
    Then the forced-clock setting reads numeric marker "1"
    And this is case "CFG-DM6-FORCEDATE"

  Scenario Outline: Compatibility-sensitive settings have concrete observed results
    Given the fixed English UTC configuration context
    When I apply setting "<setting>" with text "<value>"
    Then reading setting "<read_name>" yields "<stored>"
    And the diagnostic contains "<diagnostic>"
    And this is case "<case_id>"

    Examples:
      | case_id | setting | value | read_name | stored | diagnostic |
      | CFG-DM6-YYTOYYYY | YYtoYYYY | C## | yytoyyyy | 89 | invalid: YYtoYYYY: c## |
      | CFG-DM6-JAN1WEEK1 | Jan1Week1 | 1 | jan1week1 |  | the jan1week1 Date::Manip config variable is deprecated |

  Scenario: A nonnumeric recurrence-attempt setting reads back as the supplied text
    Given the fixed English UTC configuration context
    When I apply setting "MaxRecurAttempts" with text "no"
    Then reading setting "maxrecurattempts" yields "no"
    And no configuration diagnostic is emitted
    And this is case "CFG-DM6-MAXRECUR-INVALID"

  Scenario Outline: The DM5 compatibility initializer accepts this legacy setting without a direct result
    Given the DM5 compatibility profile with backend version "5.66"
    When I initialize its configuration with legacy setting "<setting>" and text "<value>"
    Then the initializer result is absent
    And this is case "<case_id>"

    Examples:
      | case_id | setting | value |
      | CFG-DM5-IGNOREGLOBAL | IgnoreGlobalCnf |  |
      | CFG-DM5-PATHSEP | PathSep | : |
      | CFG-DM5-GLOBAL-MISSING | GlobalCnf | /tmp/no-global-cnf |
      | CFG-DM5-PERSONAL | PersonalCnf and PersonalCnfPath | empty and empty |
      | CFG-DM5-CONVTZ | ConvTZ | IGNORE |
      | CFG-DM5-INTERNAL | Internal | 1 |
      | CFG-DM5-DELTASIGNS | DeltaSigns | 1 |
      | CFG-DM5-UPDATECURRTZ | UpdateCurrTZ | 1 |
      | CFG-DM5-INTCHARSET | IntCharSet | 0 |
      | CFG-DM5-TODAYMIDNIGHT | TodayIsMidnight | 1 |
