@draft @languages @reference-dm700 @dm5-compatibility
Feature: Separate DM5 language compatibility observations
  These literal DM5 5.66 outcomes are kept separate from the DM6 object reference behavior.
  Empty text is an actual defined return; not applicable means no special request belongs to that row.
  Mojibake, malformed interpolation text, and warning counts are preserved as observed compatibility evidence.
  The fixed clock is 2040-02-28 10:20:30 in UTC and named numeric dates use non-US date order.

  Scenario Outline: A successful initialization permits concrete legacy language operations
    Given the DM5 canonical language is "<language>"
    And its legacy character mode is "<mode>"
    And initialization succeeds
    When I render "2040-02-29 16:05:09" with pattern "%A|%B"
    Then the weekday rendering is "<weekday rendering>"
    And the month rendering is "<month rendering>"
    When I parse "<special input>" if that input is applicable
    Then its result is "<special result>"
    When I parse the full date "<full date>" with the leading-token operation
    Then the date-time result is "<full result>"
    When I parse the weekday-bearing date "<weekday date>" with the leading-token operation
    Then the date-time result is "<weekday result>"
    When I parse the relative date "<tomorrow input>" with the leading-token operation
    Then the date-time result is "<tomorrow result>"
    And the warning count is "<warning count>"
    And the additional warning class is "<additional warnings>"
    And this is case "<case>"

    Examples:
      | case                                      | language   | mode          | full date              | weekday date                        | tomorrow input | full result          | weekday result       | tomorrow result      | weekday rendering          | month rendering | special input                  | special result       | warning count | additional warnings                 |
      | LANG-DM5-LEGACY-DEFAULT-danish           | Danish     | default       | 29 Februar 2040        | Onsdag 29 Februar 2040             | imorgen        | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Onsdag                     | Februar         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-danish     | Danish     | international | 29 Februar 2040        | Onsdag 29 Februar 2040             | imorgen        | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Onsdag                     | Februar         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-dutch            | Dutch      | default       | 29 februari 2040       | woensdag 29 februari 2040          | morgen         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | woensdag                   | februari        | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-dutch      | Dutch      | international | 29 februari 2040       | woensdag 29 februari 2040          | morgen         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | woensdag                   | empty text      | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-english          | English    | default       | 29 February 2040       | Wednesday 29 February 2040         | tomorrow       | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Wednesday                  | February        | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-english    | English    | international | 29 February 2040       | Wednesday 29 February 2040         | tomorrow       | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Wednesday                  | February        | not applicable                | not applicable       | 4             | uninitialized month concatenation   |
      | LANG-DM5-LEGACY-DEFAULT-french           | French     | default       | 29 fevrier 2040        | mercredi 29 fevrier 2040           | demain         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | mercredi                   | fevrier         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-french     | French     | international | 29 février 2040        | mercredi 29 février 2040           | demain         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | mercredi                   | février         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-german           | German     | default       | 29 Februar 2040        | Mittwoch 29 Februar 2040           | morgen         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Mittwoch                   | Februar         | Mi. 29. Feb. 2040             | 2040-02-29 00:00:00 | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-german     | German     | international | 29 Februar 2040        | Mittwoch 29 Februar 2040           | morgen         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Mittwoch                   | Februar         | Mi. 29. Feb. 2040             | 2040-02-29 00:00:00 | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-italian          | Italian    | default       | 29 Febbraio 2040       | Mercoledi 29 Febbraio 2040         | domani         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Mercoledi                  | Febbraio        | not applicable                | not applicable       | 36            | unescaped-left-brace regex warnings |
      | LANG-DM5-LEGACY-INTERNATIONAL-italian    | Italian    | international | 29 Febbraio 2040       | Mercoledì 29 Febbraio 2040         | domani         | 2040-02-29 00:00:00 | empty text          | 2040-02-29 10:20:30 | Mercoled${i}               | Febbraio        | not applicable                | not applicable       | 26            | unescaped-left-brace regex warnings |
      | LANG-DM5-LEGACY-DEFAULT-polish           | Polish     | default       | 29 lutego 2040         | sroda 29 lutego 2040               | jutro          | empty text          | empty text          | 2040-03-06 10:20:30 | sroda                      | luty            | not applicable                | not applicable       | 2             | uninitialized addition              |
      | LANG-DM5-LEGACY-INTERNATIONAL-polish     | Polish     | international | 29 lutego 2040         | środa 29 lutego 2040               | jutro          | empty text          | empty text          | 2040-03-06 10:20:30 | U+009C followed by "roda" | luty            | not applicable                | not applicable       | 2             | uninitialized addition              |
      | LANG-DM5-LEGACY-DEFAULT-portuguese       | Portuguese | default       | 29 Fevereiro 2040      | quarta 29 Fevereiro 2040           | amanha         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Quarta                     | Fevereiro       | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-portuguese | Portuguese | international | 29 Fevereiro 2040      | quarta 29 Fevereiro 2040           | amanhã         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Quarta                     | Fevereiro       | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-romanian         | Romanian   | default       | 29 februarie 2040      | miercuri 29 februarie 2040         | miine          | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | miercuri                   | februarie       | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-romanian   | Romanian   | international | 29 februarie 2040      | miercuri 29 februarie 2040         | mîine          | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | miercuri                   | februarie       | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-russian          | Russian    | default       | 29 февраля 2040        | среда 29 февраля 2040              | завтра         | empty text          | empty text          | empty text          | ÓÒÅÄÁ                     | ÆÅ×ÒÁÌÑ         | (среда) 29 февраля 2040 г.   | empty text           | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-russian    | Russian    | international | 29 февраля 2040        | среда 29 февраля 2040              | завтра         | empty text          | empty text          | empty text          | ÓÒÅÄÁ                     | ÆÅ×ÒÁÌØ         | (среда) 29 февраля 2040 г.   | empty text           | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-spanish          | Spanish    | default       | 29 Febrero 2040        | Miercoles 29 Febrero 2040          | manana         | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | Miercoles                  | Febrero         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-spanish    | Spanish    | international | 29 Febrero 2040        | Miércoles 29 Febrero 2040          | mañana         | 2040-02-29 00:00:00 | empty text          | empty text          | Miercoles                  | Febrero         | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-swedish          | Swedish    | default       | 29 Februari 2040       | Onsdag 29 Februari 2040            | i morgon       | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | empty text          | Onsdag                     | Februari        | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-swedish    | Swedish    | international | 29 Februari 2040       | Onsdag 29 Februari 2040            | i morgon       | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | empty text          | Onsdag                     | Februari        | not applicable                | not applicable       | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-DEFAULT-turkish          | Turkish    | default       | 29 subat 2040          | carsamba 29 subat 2040             | yarin          | 2040-02-29 00:00:00 | 2040-02-29 00:00:00 | 2040-02-29 10:20:30 | carsamba                   | subat           | car. 29. sub. 2040            | 2040-02-29 00:00:00 | 1             | deprecation only                    |
      | LANG-DM5-LEGACY-INTERNATIONAL-turkish    | Turkish    | international | 29 şubat 2040          | çarşamba 29 şubat 2040             | yarın          | empty text          | empty text          | empty text          | çarþamba                   | þubat           | çar. 29. şub. 2040            | empty text           | 1             | deprecation only                    |

  Scenario Outline: Failed initialization prevents dependent operations
    Given the DM5 canonical language is "<language>"
    And its legacy character mode is "<mode>"
    When I initialize that language profile
    Then initialization raises "<exception>"
    And no parse or render operation is called
    And the only warning class is "deprecation"
    And this is case "<case>"

    Examples:
      | case                                     | language  | mode          | exception                 |
      | LANG-DM5-LEGACY-DEFAULT-catalan         | Catalan   | default       | undefined array reference |
      | LANG-DM5-LEGACY-INTERNATIONAL-catalan   | Catalan   | international | undefined array reference |
      | LANG-DM5-LEGACY-DEFAULT-finnish         | Finnish   | default       | unknown language          |
      | LANG-DM5-LEGACY-INTERNATIONAL-finnish   | Finnish   | international | unknown language          |
      | LANG-DM5-LEGACY-DEFAULT-norwegian       | Norwegian | default       | unknown language          |
      | LANG-DM5-LEGACY-INTERNATIONAL-norwegian | Norwegian | international | unknown language          |
