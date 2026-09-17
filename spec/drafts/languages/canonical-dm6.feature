@draft @languages @reference-dm700 @dm6
Feature: Canonical language parsing and rendering in the DM6 object reference profile
  These are reviewed transcriptions of repeatable research observations, not approved portable contracts.
  The clock is 2040-02-28 10:20:30 in UTC and an accepted date without a clock uses midnight.

  Scenario Outline: A localized leap date, its weekday, tomorrow, and localized names agree
    Given the DM6 language is "<language>" and the encoding is "UTF-8"
    And named numeric dates use non-US date order
    And each parse or render request starts with a fresh configured date value
    When I parse the full date "<full date>"
    Then the current date-time is "2040-02-29 00:00:00"
    When I parse the weekday-bearing date "<weekday date>"
    Then the current date-time is "2040-02-29 00:00:00"
    When I parse the relative date "<tomorrow>"
    Then the current date-time is "2040-02-29 00:00:00"
    When I render "2040-02-29 16:05:09" with pattern "%A|%B"
    Then the weekday text is "<weekday rendering>"
    And the month text is "<month rendering>"
    And this is case "<case>"

    Examples:
      | case                         | language   | full date              | weekday date                        | tomorrow | weekday rendering | month rendering |
      | LANG-DM6-UTF8-catalan       | Catalan    | 29 Febrer 2040         | Dimecres 29 Febrer 2040            | demà     | Dimecres          | Febrer          |
      | LANG-DM6-UTF8-danish        | Danish     | 29 Februar 2040        | Onsdag 29 Februar 2040             | imorgen  | Onsdag            | Februar         |
      | LANG-DM6-UTF8-dutch         | Dutch      | 29 februari 2040       | woensdag 29 februari 2040          | morgen   | woensdag          | februari        |
      | LANG-DM6-UTF8-english       | English    | 29 February 2040       | Wednesday 29 February 2040         | tomorrow | Wednesday         | February        |
      | LANG-DM6-UTF8-finnish       | Finnish    | 29 helmikuuta 2040     | keskiviikko 29 helmikuuta 2040     | huomenna | keskiviikko       | helmikuu        |
      | LANG-DM6-UTF8-french        | French     | 29 février 2040        | mercredi 29 février 2040           | demain   | mercredi          | février         |
      | LANG-DM6-UTF8-german        | German     | 29 Februar 2040        | Mittwoch 29 Februar 2040           | morgen   | Mittwoch          | Februar         |
      | LANG-DM6-UTF8-italian       | Italian    | 29 Febbraio 2040       | Mercoledì 29 Febbraio 2040         | domani   | Mercoledì         | Febbraio        |
      | LANG-DM6-UTF8-norwegian     | Norwegian  | 29 februar 2040        | onsdag 29 februar 2040             | i morgen | onsdag            | februar         |
      | LANG-DM6-UTF8-polish        | Polish     | 29 lutego 2040         | środa 29 lutego 2040               | jutro    | środa             | luty            |
      | LANG-DM6-UTF8-portuguese    | Portuguese | 29 Fevereiro 2040      | quarta 29 Fevereiro 2040           | amanhã   | quarta            | Fevereiro       |
      | LANG-DM6-UTF8-romanian      | Romanian   | 29 februarie 2040      | miercuri 29 februarie 2040         | mîine    | miercuri          | februarie       |
      | LANG-DM6-UTF8-russian       | Russian    | 29 февраля 2040        | среда 29 февраля 2040              | завтра   | среда             | февраля         |
      | LANG-DM6-UTF8-spanish       | Spanish    | 29 Febrero 2040        | Miércoles 29 Febrero 2040          | mañana   | Miércoles         | Febrero         |
      | LANG-DM6-UTF8-swedish       | Swedish    | 29 Februari 2040       | Onsdag 29 Februari 2040            | i morgon | Onsdag            | Februari        |
      | LANG-DM6-UTF8-turkish       | Turkish    | 29 şubat 2040          | çarşamba 29 şubat 2040             | yarın    | çarşamba          | şubat           |

  Scenario Outline: Forced ASCII uses the selected ASCII phrase with its observed result
    Given the DM6 language is "<language>" and the encoding is "ASCII"
    And named numeric dates use non-US date order
    And each parse or render request starts with a fresh configured date value
    When I parse the full date "<full date>"
    And I parse the weekday-bearing date "<weekday date>"
    And I parse the relative date "<tomorrow>"
    Then the three literal parse results are "<full result>", "<weekday result>", and "<tomorrow result>"
    And their parse error is "<error>"
    When I render "2040-02-29 16:05:09" with pattern "%A|%B"
    Then the weekday text is "<weekday rendering>"
    And the month text is "<month rendering>"
    And this is case "<case>"

    Examples:
      | case                          | language   | full date          | weekday date                    | tomorrow | full result        | weekday result     | tomorrow result    | error                       | weekday rendering | month rendering |
      | LANG-DM6-ASCII-catalan       | Catalan    | 29 Febrer 2040     | Dimecres 29 Febrer 2040        | dema     | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Dimecres          | Febrer          |
      | LANG-DM6-ASCII-danish        | Danish     | 29 Februar 2040    | Onsdag 29 Februar 2040         | imorgen  | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Onsdag            | Februar         |
      | LANG-DM6-ASCII-dutch         | Dutch      | 29 februari 2040   | woensdag 29 februari 2040      | morgen   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | woensdag          | februari        |
      | LANG-DM6-ASCII-english       | English    | 29 February 2040   | Wednesday 29 February 2040     | tomorrow | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Wednesday         | February        |
      | LANG-DM6-ASCII-finnish       | Finnish    | 29 helmikuuta 2040 | keskiviikko 29 helmikuuta 2040 | huomenna | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | keskiviikko       | helmikuu        |
      | LANG-DM6-ASCII-french        | French     | 29 fevrier 2040    | mercredi 29 fevrier 2040       | demain   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | mercredi          | février         |
      | LANG-DM6-ASCII-german        | German     | 29 Februar 2040    | Mittwoch 29 Februar 2040       | morgen   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Mittwoch          | Februar         |
      | LANG-DM6-ASCII-italian       | Italian    | 29 Febbraio 2040   | Mercoledi 29 Febbraio 2040     | domani   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Mercoledì         | Febbraio        |
      | LANG-DM6-ASCII-norwegian     | Norwegian  | 29 februar 2040    | onsdag 29 februar 2040         | i morgen | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | onsdag            | februar         |
      | LANG-DM6-ASCII-polish        | Polish     | 29 lutego 2040     | sroda 29 lutego 2040           | jutro    | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | środa             | luty            |
      | LANG-DM6-ASCII-portuguese    | Portuguese | 29 Fevereiro 2040  | quarta 29 Fevereiro 2040       | amanha   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | quarta            | Fevereiro       |
      | LANG-DM6-ASCII-romanian      | Romanian   | 29 februarie 2040  | miercuri 29 februarie 2040     | miine    | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | miercuri          | februarie       |
      | LANG-DM6-ASCII-russian       | Russian    | 29 февраля 2040    | среда 29 февраля 2040          | завтра   | no date-time result | no date-time result | no date-time result | [parse] Invalid date string | среда             | февраля         |
      | LANG-DM6-ASCII-spanish       | Spanish    | 29 Febrero 2040    | Miercoles 29 Febrero 2040      | manana   | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Miércoles         | Febrero         |
      | LANG-DM6-ASCII-swedish       | Swedish    | 29 Februari 2040   | Onsdag 29 Februari 2040        | i morgon | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | Onsdag            | Februari        |
      | LANG-DM6-ASCII-turkish       | Turkish    | 29 subat 2040      | carsamba 29 subat 2040         | yarin    | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 |                             | çarşamba          | şubat           |

  Scenario Outline: Declared language preprocessing accepts one concrete phrase
    Given the DM6 language is "<language>" and the encoding is "UTF-8"
    And named numeric dates use non-US date order
    And each parse or render request starts with a fresh configured date value
    When I parse the language-preprocessing phrase "<input>"
    Then the current date-time is "2040-02-29 00:00:00"
    And this is case "<case>"

    Examples:
      | case                     | language  | input                         |
      | LANG-DM6-UTF8-german-PREPROCESS    | German    | Mi. 29. Feb. 2040            |
      | LANG-DM6-UTF8-norwegian-PREPROCESS | Norwegian | on. 29. feb. 2040            |
      | LANG-DM6-UTF8-russian-PREPROCESS   | Russian   | (среда) 29 февраля 2040 г.   |
      | LANG-DM6-UTF8-turkish-PREPROCESS   | Turkish   | çar. 29. şub. 2040           |
