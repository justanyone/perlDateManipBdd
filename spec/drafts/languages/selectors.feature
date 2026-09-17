@draft @languages @reference-dm700
Feature: Public language selectors choose localized parsing and rendering
  Civil date-time results below use the portable readable representation.
  Native return carriers and public source bindings are recorded separately.

  Background:
    Given a fresh date context with local zone "Etc/UTC"
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And the encoding is "UTF-8" and numeric dates use non-US order

  Scenario Outline: Select a language by a canonical name or alias for <case>
    When I configure language selector "<selector>"
    Then the selected language setting is exactly "<selector>"
    When I parse the localized full date "<input>"
    Then parsing succeeds with an empty error
    And the parsed civil date-time is "2040-02-29 00:00:00"
    When I render that date with pattern "%A|%B"
    Then the weekday text is "<weekday>" and the month text is "<month>"
    And the parse, value, and rendering calls emit no warnings or standard output

    Examples:
      | case | selector | language | input | weekday | month |
      | LANG-SELECT-01 | Catalan | Catalan | 29 Febrer 2040 | Dimecres | Febrer |
      | LANG-SELECT-02 | ca | Catalan | 29 Febrer 2040 | Dimecres | Febrer |
      | LANG-SELECT-03 | Danish | Danish | 29 Februar 2040 | Onsdag | Februar |
      | LANG-SELECT-04 | da | Danish | 29 Februar 2040 | Onsdag | Februar |
      | LANG-SELECT-05 | Dutch | Dutch | 29 februari 2040 | woensdag | februari |
      | LANG-SELECT-06 | Nederlands | Dutch | 29 februari 2040 | woensdag | februari |
      | LANG-SELECT-07 | nl | Dutch | 29 februari 2040 | woensdag | februari |
      | LANG-SELECT-08 | English | English | 29 February 2040 | Wednesday | February |
      | LANG-SELECT-09 | en | English | 29 February 2040 | Wednesday | February |
      | LANG-SELECT-10 | en_us | English | 29 February 2040 | Wednesday | February |
      | LANG-SELECT-11 | Finnish | Finnish | 29 helmikuuta 2040 | keskiviikko | helmikuu |
      | LANG-SELECT-12 | fi | Finnish | 29 helmikuuta 2040 | keskiviikko | helmikuu |
      | LANG-SELECT-13 | fi_fi | Finnish | 29 helmikuuta 2040 | keskiviikko | helmikuu |
      | LANG-SELECT-14 | French | French | 29 février 2040 | mercredi | février |
      | LANG-SELECT-15 | fr | French | 29 février 2040 | mercredi | février |
      | LANG-SELECT-16 | fr_fr | French | 29 février 2040 | mercredi | février |
      | LANG-SELECT-17 | German | German | 29 Februar 2040 | Mittwoch | Februar |
      | LANG-SELECT-18 | de | German | 29 Februar 2040 | Mittwoch | Februar |
      | LANG-SELECT-19 | de_de | German | 29 Februar 2040 | Mittwoch | Februar |
      | LANG-SELECT-20 | Italian | Italian | 29 Febbraio 2040 | Mercoledì | Febbraio |
      | LANG-SELECT-21 | it | Italian | 29 Febbraio 2040 | Mercoledì | Febbraio |
      | LANG-SELECT-22 | it_it | Italian | 29 Febbraio 2040 | Mercoledì | Febbraio |
      | LANG-SELECT-23 | Norwegian | Norwegian | 29 februar 2040 | onsdag | februar |
      | LANG-SELECT-24 | nb | Norwegian | 29 februar 2040 | onsdag | februar |
      | LANG-SELECT-25 | nb_no | Norwegian | 29 februar 2040 | onsdag | februar |
      | LANG-SELECT-26 | Polish | Polish | 29 lutego 2040 | środa | luty |
      | LANG-SELECT-27 | pl | Polish | 29 lutego 2040 | środa | luty |
      | LANG-SELECT-28 | pl_pl | Polish | 29 lutego 2040 | środa | luty |
      | LANG-SELECT-29 | Portuguese | Portuguese | 29 Fevereiro 2040 | quarta | Fevereiro |
      | LANG-SELECT-30 | pt | Portuguese | 29 Fevereiro 2040 | quarta | Fevereiro |
      | LANG-SELECT-31 | pt_pt | Portuguese | 29 Fevereiro 2040 | quarta | Fevereiro |
      | LANG-SELECT-32 | Romanian | Romanian | 29 februarie 2040 | miercuri | februarie |
      | LANG-SELECT-33 | ro | Romanian | 29 februarie 2040 | miercuri | februarie |
      | LANG-SELECT-34 | ro_ro | Romanian | 29 februarie 2040 | miercuri | februarie |
      | LANG-SELECT-35 | Russian | Russian | 29 февраля 2040 | среда | февраля |
      | LANG-SELECT-36 | ru | Russian | 29 февраля 2040 | среда | февраля |
      | LANG-SELECT-37 | ru_ru | Russian | 29 февраля 2040 | среда | февраля |
      | LANG-SELECT-38 | Spanish | Spanish | 29 Febrero 2040 | Miércoles | Febrero |
      | LANG-SELECT-39 | es | Spanish | 29 Febrero 2040 | Miércoles | Febrero |
      | LANG-SELECT-40 | es_es | Spanish | 29 Febrero 2040 | Miércoles | Febrero |
      | LANG-SELECT-41 | Swedish | Swedish | 29 Februari 2040 | Onsdag | Februari |
      | LANG-SELECT-42 | sv | Swedish | 29 Februari 2040 | Onsdag | Februari |
      | LANG-SELECT-43 | Turkish | Turkish | 29 şubat 2040 | çarşamba | şubat |
      | LANG-SELECT-44 | tr | Turkish | 29 şubat 2040 | çarşamba | şubat |
      | LANG-SELECT-45 | tr_tr | Turkish | 29 şubat 2040 | çarşamba | şubat |
