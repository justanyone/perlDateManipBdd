@portable @localized-day-ordinal
Feature: Localized day-of-month ordinal text
  Each row is one concrete date.localized-day-ordinal request.
  The day is a numeric day-of-month value, and the result is literal localized text.

  Background:
    Given the current ordinal profile uses the selected canonical language and ASCII encoding
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US

  Scenario Outline: Render every normal day boundary in every current language
    Given the selected language is <language>
    When I request localized ordinal text for day-of-month <day>
    Then the date.localized-day-ordinal result is <literal result>

    Examples:
      | request | language | day | literal result |
      | DO-DM6-CATALAN-DAYS-D01 | Catalan | 1 | text "1er" |
      | DO-DM6-CATALAN-DAYS-D02 | Catalan | 2 | text "2n" |
      | DO-DM6-CATALAN-DAYS-D03 | Catalan | 3 | text "3r" |
      | DO-DM6-CATALAN-DAYS-D04 | Catalan | 4 | text "4t" |
      | DO-DM6-CATALAN-DAYS-D05 | Catalan | 5 | text "5è" |
      | DO-DM6-CATALAN-DAYS-D06 | Catalan | 6 | text "6è" |
      | DO-DM6-CATALAN-DAYS-D07 | Catalan | 7 | text "7è" |
      | DO-DM6-CATALAN-DAYS-D08 | Catalan | 8 | text "8è" |
      | DO-DM6-CATALAN-DAYS-D09 | Catalan | 9 | text "9è" |
      | DO-DM6-CATALAN-DAYS-D10 | Catalan | 10 | text "10è" |
      | DO-DM6-CATALAN-DAYS-D11 | Catalan | 11 | text "11è" |
      | DO-DM6-CATALAN-DAYS-D12 | Catalan | 12 | text "12è" |
      | DO-DM6-CATALAN-DAYS-D13 | Catalan | 13 | text "13è" |
      | DO-DM6-CATALAN-DAYS-D14 | Catalan | 14 | text "14è" |
      | DO-DM6-CATALAN-DAYS-D15 | Catalan | 15 | text "15è" |
      | DO-DM6-CATALAN-DAYS-D16 | Catalan | 16 | text "16è" |
      | DO-DM6-CATALAN-DAYS-D17 | Catalan | 17 | text "17è" |
      | DO-DM6-CATALAN-DAYS-D18 | Catalan | 18 | text "18è" |
      | DO-DM6-CATALAN-DAYS-D19 | Catalan | 19 | text "19è" |
      | DO-DM6-CATALAN-DAYS-D20 | Catalan | 20 | text "20è" |
      | DO-DM6-CATALAN-DAYS-D21 | Catalan | 21 | text "21è" |
      | DO-DM6-CATALAN-DAYS-D22 | Catalan | 22 | text "22è" |
      | DO-DM6-CATALAN-DAYS-D23 | Catalan | 23 | text "23è" |
      | DO-DM6-CATALAN-DAYS-D24 | Catalan | 24 | text "24è" |
      | DO-DM6-CATALAN-DAYS-D25 | Catalan | 25 | text "25è" |
      | DO-DM6-CATALAN-DAYS-D26 | Catalan | 26 | text "26è" |
      | DO-DM6-CATALAN-DAYS-D27 | Catalan | 27 | text "27è" |
      | DO-DM6-CATALAN-DAYS-D28 | Catalan | 28 | text "28è" |
      | DO-DM6-CATALAN-DAYS-D29 | Catalan | 29 | text "29è" |
      | DO-DM6-CATALAN-DAYS-D30 | Catalan | 30 | text "30è" |
      | DO-DM6-CATALAN-DAYS-D31 | Catalan | 31 | text "31è" |
      | DO-DM6-DANISH-DAYS-D01 | Danish | 1 | text "1." |
      | DO-DM6-DANISH-DAYS-D02 | Danish | 2 | text "2." |
      | DO-DM6-DANISH-DAYS-D03 | Danish | 3 | text "3." |
      | DO-DM6-DANISH-DAYS-D04 | Danish | 4 | text "4." |
      | DO-DM6-DANISH-DAYS-D05 | Danish | 5 | text "5." |
      | DO-DM6-DANISH-DAYS-D06 | Danish | 6 | text "6." |
      | DO-DM6-DANISH-DAYS-D07 | Danish | 7 | text "7." |
      | DO-DM6-DANISH-DAYS-D08 | Danish | 8 | text "8." |
      | DO-DM6-DANISH-DAYS-D09 | Danish | 9 | text "9." |
      | DO-DM6-DANISH-DAYS-D10 | Danish | 10 | text "10." |
      | DO-DM6-DANISH-DAYS-D11 | Danish | 11 | text "11." |
      | DO-DM6-DANISH-DAYS-D12 | Danish | 12 | text "12." |
      | DO-DM6-DANISH-DAYS-D13 | Danish | 13 | text "13." |
      | DO-DM6-DANISH-DAYS-D14 | Danish | 14 | text "14." |
      | DO-DM6-DANISH-DAYS-D15 | Danish | 15 | text "15." |
      | DO-DM6-DANISH-DAYS-D16 | Danish | 16 | text "16." |
      | DO-DM6-DANISH-DAYS-D17 | Danish | 17 | text "17." |
      | DO-DM6-DANISH-DAYS-D18 | Danish | 18 | text "18." |
      | DO-DM6-DANISH-DAYS-D19 | Danish | 19 | text "19." |
      | DO-DM6-DANISH-DAYS-D20 | Danish | 20 | text "20." |
      | DO-DM6-DANISH-DAYS-D21 | Danish | 21 | text "21." |
      | DO-DM6-DANISH-DAYS-D22 | Danish | 22 | text "22." |
      | DO-DM6-DANISH-DAYS-D23 | Danish | 23 | text "23." |
      | DO-DM6-DANISH-DAYS-D24 | Danish | 24 | text "24." |
      | DO-DM6-DANISH-DAYS-D25 | Danish | 25 | text "25." |
      | DO-DM6-DANISH-DAYS-D26 | Danish | 26 | text "26." |
      | DO-DM6-DANISH-DAYS-D27 | Danish | 27 | text "27." |
      | DO-DM6-DANISH-DAYS-D28 | Danish | 28 | text "28." |
      | DO-DM6-DANISH-DAYS-D29 | Danish | 29 | text "29." |
      | DO-DM6-DANISH-DAYS-D30 | Danish | 30 | text "30." |
      | DO-DM6-DANISH-DAYS-D31 | Danish | 31 | text "31." |
      | DO-DM6-DUTCH-DAYS-D01 | Dutch | 1 | text "1ste" |
      | DO-DM6-DUTCH-DAYS-D02 | Dutch | 2 | text "2de" |
      | DO-DM6-DUTCH-DAYS-D03 | Dutch | 3 | text "3de" |
      | DO-DM6-DUTCH-DAYS-D04 | Dutch | 4 | text "4de" |
      | DO-DM6-DUTCH-DAYS-D05 | Dutch | 5 | text "5de" |
      | DO-DM6-DUTCH-DAYS-D06 | Dutch | 6 | text "6de" |
      | DO-DM6-DUTCH-DAYS-D07 | Dutch | 7 | text "7de" |
      | DO-DM6-DUTCH-DAYS-D08 | Dutch | 8 | text "8ste" |
      | DO-DM6-DUTCH-DAYS-D09 | Dutch | 9 | text "9de" |
      | DO-DM6-DUTCH-DAYS-D10 | Dutch | 10 | text "10de" |
      | DO-DM6-DUTCH-DAYS-D11 | Dutch | 11 | text "11de" |
      | DO-DM6-DUTCH-DAYS-D12 | Dutch | 12 | text "12de" |
      | DO-DM6-DUTCH-DAYS-D13 | Dutch | 13 | text "13de" |
      | DO-DM6-DUTCH-DAYS-D14 | Dutch | 14 | text "14de" |
      | DO-DM6-DUTCH-DAYS-D15 | Dutch | 15 | text "15de" |
      | DO-DM6-DUTCH-DAYS-D16 | Dutch | 16 | text "16de" |
      | DO-DM6-DUTCH-DAYS-D17 | Dutch | 17 | text "17de" |
      | DO-DM6-DUTCH-DAYS-D18 | Dutch | 18 | text "18de" |
      | DO-DM6-DUTCH-DAYS-D19 | Dutch | 19 | text "19de" |
      | DO-DM6-DUTCH-DAYS-D20 | Dutch | 20 | text "20ste" |
      | DO-DM6-DUTCH-DAYS-D21 | Dutch | 21 | text "21ste" |
      | DO-DM6-DUTCH-DAYS-D22 | Dutch | 22 | text "22ste" |
      | DO-DM6-DUTCH-DAYS-D23 | Dutch | 23 | text "23ste" |
      | DO-DM6-DUTCH-DAYS-D24 | Dutch | 24 | text "24ste" |
      | DO-DM6-DUTCH-DAYS-D25 | Dutch | 25 | text "25ste" |
      | DO-DM6-DUTCH-DAYS-D26 | Dutch | 26 | text "26ste" |
      | DO-DM6-DUTCH-DAYS-D27 | Dutch | 27 | text "27ste" |
      | DO-DM6-DUTCH-DAYS-D28 | Dutch | 28 | text "28ste" |
      | DO-DM6-DUTCH-DAYS-D29 | Dutch | 29 | text "29ste" |
      | DO-DM6-DUTCH-DAYS-D30 | Dutch | 30 | text "30ste" |
      | DO-DM6-DUTCH-DAYS-D31 | Dutch | 31 | text "31ste" |
      | DO-DM6-ENGLISH-DAYS-D01 | English | 1 | text "1st" |
      | DO-DM6-ENGLISH-DAYS-D02 | English | 2 | text "2nd" |
      | DO-DM6-ENGLISH-DAYS-D03 | English | 3 | text "3rd" |
      | DO-DM6-ENGLISH-DAYS-D04 | English | 4 | text "4th" |
      | DO-DM6-ENGLISH-DAYS-D05 | English | 5 | text "5th" |
      | DO-DM6-ENGLISH-DAYS-D06 | English | 6 | text "6th" |
      | DO-DM6-ENGLISH-DAYS-D07 | English | 7 | text "7th" |
      | DO-DM6-ENGLISH-DAYS-D08 | English | 8 | text "8th" |
      | DO-DM6-ENGLISH-DAYS-D09 | English | 9 | text "9th" |
      | DO-DM6-ENGLISH-DAYS-D10 | English | 10 | text "10th" |
      | DO-DM6-ENGLISH-DAYS-D11 | English | 11 | text "11th" |
      | DO-DM6-ENGLISH-DAYS-D12 | English | 12 | text "12th" |
      | DO-DM6-ENGLISH-DAYS-D13 | English | 13 | text "13th" |
      | DO-DM6-ENGLISH-DAYS-D14 | English | 14 | text "14th" |
      | DO-DM6-ENGLISH-DAYS-D15 | English | 15 | text "15th" |
      | DO-DM6-ENGLISH-DAYS-D16 | English | 16 | text "16th" |
      | DO-DM6-ENGLISH-DAYS-D17 | English | 17 | text "17th" |
      | DO-DM6-ENGLISH-DAYS-D18 | English | 18 | text "18th" |
      | DO-DM6-ENGLISH-DAYS-D19 | English | 19 | text "19th" |
      | DO-DM6-ENGLISH-DAYS-D20 | English | 20 | text "20th" |
      | DO-DM6-ENGLISH-DAYS-D21 | English | 21 | text "21st" |
      | DO-DM6-ENGLISH-DAYS-D22 | English | 22 | text "22nd" |
      | DO-DM6-ENGLISH-DAYS-D23 | English | 23 | text "23rd" |
      | DO-DM6-ENGLISH-DAYS-D24 | English | 24 | text "24th" |
      | DO-DM6-ENGLISH-DAYS-D25 | English | 25 | text "25th" |
      | DO-DM6-ENGLISH-DAYS-D26 | English | 26 | text "26th" |
      | DO-DM6-ENGLISH-DAYS-D27 | English | 27 | text "27th" |
      | DO-DM6-ENGLISH-DAYS-D28 | English | 28 | text "28th" |
      | DO-DM6-ENGLISH-DAYS-D29 | English | 29 | text "29th" |
      | DO-DM6-ENGLISH-DAYS-D30 | English | 30 | text "30th" |
      | DO-DM6-ENGLISH-DAYS-D31 | English | 31 | text "31st" |
      | DO-DM6-FINNISH-DAYS-D01 | Finnish | 1 | text "1." |
      | DO-DM6-FINNISH-DAYS-D02 | Finnish | 2 | text "2." |
      | DO-DM6-FINNISH-DAYS-D03 | Finnish | 3 | text "3." |
      | DO-DM6-FINNISH-DAYS-D04 | Finnish | 4 | text "4." |
      | DO-DM6-FINNISH-DAYS-D05 | Finnish | 5 | text "5." |
      | DO-DM6-FINNISH-DAYS-D06 | Finnish | 6 | text "6." |
      | DO-DM6-FINNISH-DAYS-D07 | Finnish | 7 | text "7." |
      | DO-DM6-FINNISH-DAYS-D08 | Finnish | 8 | text "8." |
      | DO-DM6-FINNISH-DAYS-D09 | Finnish | 9 | text "9." |
      | DO-DM6-FINNISH-DAYS-D10 | Finnish | 10 | text "10." |
      | DO-DM6-FINNISH-DAYS-D11 | Finnish | 11 | text "11." |
      | DO-DM6-FINNISH-DAYS-D12 | Finnish | 12 | text "12." |
      | DO-DM6-FINNISH-DAYS-D13 | Finnish | 13 | text "13." |
      | DO-DM6-FINNISH-DAYS-D14 | Finnish | 14 | text "14." |
      | DO-DM6-FINNISH-DAYS-D15 | Finnish | 15 | text "15." |
      | DO-DM6-FINNISH-DAYS-D16 | Finnish | 16 | text "16." |
      | DO-DM6-FINNISH-DAYS-D17 | Finnish | 17 | text "17." |
      | DO-DM6-FINNISH-DAYS-D18 | Finnish | 18 | text "18." |
      | DO-DM6-FINNISH-DAYS-D19 | Finnish | 19 | text "19." |
      | DO-DM6-FINNISH-DAYS-D20 | Finnish | 20 | text "20." |
      | DO-DM6-FINNISH-DAYS-D21 | Finnish | 21 | text "21." |
      | DO-DM6-FINNISH-DAYS-D22 | Finnish | 22 | text "22." |
      | DO-DM6-FINNISH-DAYS-D23 | Finnish | 23 | text "23." |
      | DO-DM6-FINNISH-DAYS-D24 | Finnish | 24 | text "24." |
      | DO-DM6-FINNISH-DAYS-D25 | Finnish | 25 | text "25." |
      | DO-DM6-FINNISH-DAYS-D26 | Finnish | 26 | text "26." |
      | DO-DM6-FINNISH-DAYS-D27 | Finnish | 27 | text "27." |
      | DO-DM6-FINNISH-DAYS-D28 | Finnish | 28 | text "28." |
      | DO-DM6-FINNISH-DAYS-D29 | Finnish | 29 | text "29." |
      | DO-DM6-FINNISH-DAYS-D30 | Finnish | 30 | text "30." |
      | DO-DM6-FINNISH-DAYS-D31 | Finnish | 31 | text "31." |
      | DO-DM6-FRENCH-DAYS-D01 | French | 1 | text "1er" |
      | DO-DM6-FRENCH-DAYS-D02 | French | 2 | text "2e" |
      | DO-DM6-FRENCH-DAYS-D03 | French | 3 | text "3e" |
      | DO-DM6-FRENCH-DAYS-D04 | French | 4 | text "4e" |
      | DO-DM6-FRENCH-DAYS-D05 | French | 5 | text "5e" |
      | DO-DM6-FRENCH-DAYS-D06 | French | 6 | text "6e" |
      | DO-DM6-FRENCH-DAYS-D07 | French | 7 | text "7e" |
      | DO-DM6-FRENCH-DAYS-D08 | French | 8 | text "8e" |
      | DO-DM6-FRENCH-DAYS-D09 | French | 9 | text "9e" |
      | DO-DM6-FRENCH-DAYS-D10 | French | 10 | text "10e" |
      | DO-DM6-FRENCH-DAYS-D11 | French | 11 | text "11e" |
      | DO-DM6-FRENCH-DAYS-D12 | French | 12 | text "12e" |
      | DO-DM6-FRENCH-DAYS-D13 | French | 13 | text "13e" |
      | DO-DM6-FRENCH-DAYS-D14 | French | 14 | text "14e" |
      | DO-DM6-FRENCH-DAYS-D15 | French | 15 | text "15e" |
      | DO-DM6-FRENCH-DAYS-D16 | French | 16 | text "16e" |
      | DO-DM6-FRENCH-DAYS-D17 | French | 17 | text "17e" |
      | DO-DM6-FRENCH-DAYS-D18 | French | 18 | text "18e" |
      | DO-DM6-FRENCH-DAYS-D19 | French | 19 | text "19e" |
      | DO-DM6-FRENCH-DAYS-D20 | French | 20 | text "20e" |
      | DO-DM6-FRENCH-DAYS-D21 | French | 21 | text "21e" |
      | DO-DM6-FRENCH-DAYS-D22 | French | 22 | text "22e" |
      | DO-DM6-FRENCH-DAYS-D23 | French | 23 | text "23e" |
      | DO-DM6-FRENCH-DAYS-D24 | French | 24 | text "24e" |
      | DO-DM6-FRENCH-DAYS-D25 | French | 25 | text "25e" |
      | DO-DM6-FRENCH-DAYS-D26 | French | 26 | text "26e" |
      | DO-DM6-FRENCH-DAYS-D27 | French | 27 | text "27e" |
      | DO-DM6-FRENCH-DAYS-D28 | French | 28 | text "28e" |
      | DO-DM6-FRENCH-DAYS-D29 | French | 29 | text "29e" |
      | DO-DM6-FRENCH-DAYS-D30 | French | 30 | text "30e" |
      | DO-DM6-FRENCH-DAYS-D31 | French | 31 | text "31e" |
      | DO-DM6-GERMAN-DAYS-D01 | German | 1 | text "1." |
      | DO-DM6-GERMAN-DAYS-D02 | German | 2 | text "2." |
      | DO-DM6-GERMAN-DAYS-D03 | German | 3 | text "3." |
      | DO-DM6-GERMAN-DAYS-D04 | German | 4 | text "4." |
      | DO-DM6-GERMAN-DAYS-D05 | German | 5 | text "5." |
      | DO-DM6-GERMAN-DAYS-D06 | German | 6 | text "6." |
      | DO-DM6-GERMAN-DAYS-D07 | German | 7 | text "7." |
      | DO-DM6-GERMAN-DAYS-D08 | German | 8 | text "8." |
      | DO-DM6-GERMAN-DAYS-D09 | German | 9 | text "9." |
      | DO-DM6-GERMAN-DAYS-D10 | German | 10 | text "10." |
      | DO-DM6-GERMAN-DAYS-D11 | German | 11 | text "11." |
      | DO-DM6-GERMAN-DAYS-D12 | German | 12 | text "12." |
      | DO-DM6-GERMAN-DAYS-D13 | German | 13 | text "13." |
      | DO-DM6-GERMAN-DAYS-D14 | German | 14 | text "14." |
      | DO-DM6-GERMAN-DAYS-D15 | German | 15 | text "15." |
      | DO-DM6-GERMAN-DAYS-D16 | German | 16 | text "16." |
      | DO-DM6-GERMAN-DAYS-D17 | German | 17 | text "17." |
      | DO-DM6-GERMAN-DAYS-D18 | German | 18 | text "18." |
      | DO-DM6-GERMAN-DAYS-D19 | German | 19 | text "19." |
      | DO-DM6-GERMAN-DAYS-D20 | German | 20 | text "20." |
      | DO-DM6-GERMAN-DAYS-D21 | German | 21 | text "21." |
      | DO-DM6-GERMAN-DAYS-D22 | German | 22 | text "22." |
      | DO-DM6-GERMAN-DAYS-D23 | German | 23 | text "23." |
      | DO-DM6-GERMAN-DAYS-D24 | German | 24 | text "24." |
      | DO-DM6-GERMAN-DAYS-D25 | German | 25 | text "25." |
      | DO-DM6-GERMAN-DAYS-D26 | German | 26 | text "26." |
      | DO-DM6-GERMAN-DAYS-D27 | German | 27 | text "27." |
      | DO-DM6-GERMAN-DAYS-D28 | German | 28 | text "28." |
      | DO-DM6-GERMAN-DAYS-D29 | German | 29 | text "29." |
      | DO-DM6-GERMAN-DAYS-D30 | German | 30 | text "30." |
      | DO-DM6-GERMAN-DAYS-D31 | German | 31 | text "31." |
      | DO-DM6-ITALIAN-DAYS-D01 | Italian | 1 | text "1o" |
      | DO-DM6-ITALIAN-DAYS-D02 | Italian | 2 | text "2o" |
      | DO-DM6-ITALIAN-DAYS-D03 | Italian | 3 | text "3o" |
      | DO-DM6-ITALIAN-DAYS-D04 | Italian | 4 | text "4o" |
      | DO-DM6-ITALIAN-DAYS-D05 | Italian | 5 | text "5o" |
      | DO-DM6-ITALIAN-DAYS-D06 | Italian | 6 | text "6o" |
      | DO-DM6-ITALIAN-DAYS-D07 | Italian | 7 | text "7o" |
      | DO-DM6-ITALIAN-DAYS-D08 | Italian | 8 | text "8o" |
      | DO-DM6-ITALIAN-DAYS-D09 | Italian | 9 | text "9o" |
      | DO-DM6-ITALIAN-DAYS-D10 | Italian | 10 | text "10o" |
      | DO-DM6-ITALIAN-DAYS-D11 | Italian | 11 | text "11o" |
      | DO-DM6-ITALIAN-DAYS-D12 | Italian | 12 | text "12o" |
      | DO-DM6-ITALIAN-DAYS-D13 | Italian | 13 | text "13o" |
      | DO-DM6-ITALIAN-DAYS-D14 | Italian | 14 | text "14o" |
      | DO-DM6-ITALIAN-DAYS-D15 | Italian | 15 | text "15o" |
      | DO-DM6-ITALIAN-DAYS-D16 | Italian | 16 | text "16o" |
      | DO-DM6-ITALIAN-DAYS-D17 | Italian | 17 | text "17o" |
      | DO-DM6-ITALIAN-DAYS-D18 | Italian | 18 | text "18o" |
      | DO-DM6-ITALIAN-DAYS-D19 | Italian | 19 | text "19o" |
      | DO-DM6-ITALIAN-DAYS-D20 | Italian | 20 | text "20o" |
      | DO-DM6-ITALIAN-DAYS-D21 | Italian | 21 | text "21o" |
      | DO-DM6-ITALIAN-DAYS-D22 | Italian | 22 | text "22o" |
      | DO-DM6-ITALIAN-DAYS-D23 | Italian | 23 | text "23o" |
      | DO-DM6-ITALIAN-DAYS-D24 | Italian | 24 | text "24o" |
      | DO-DM6-ITALIAN-DAYS-D25 | Italian | 25 | text "25o" |
      | DO-DM6-ITALIAN-DAYS-D26 | Italian | 26 | text "26o" |
      | DO-DM6-ITALIAN-DAYS-D27 | Italian | 27 | text "27o" |
      | DO-DM6-ITALIAN-DAYS-D28 | Italian | 28 | text "28o" |
      | DO-DM6-ITALIAN-DAYS-D29 | Italian | 29 | text "29o" |
      | DO-DM6-ITALIAN-DAYS-D30 | Italian | 30 | text "30o" |
      | DO-DM6-ITALIAN-DAYS-D31 | Italian | 31 | text "31o" |
      | DO-DM6-NORWEGIAN-DAYS-D01 | Norwegian | 1 | text "første" |
      | DO-DM6-NORWEGIAN-DAYS-D02 | Norwegian | 2 | text "andre" |
      | DO-DM6-NORWEGIAN-DAYS-D03 | Norwegian | 3 | text "tredje" |
      | DO-DM6-NORWEGIAN-DAYS-D04 | Norwegian | 4 | text "fjerde" |
      | DO-DM6-NORWEGIAN-DAYS-D05 | Norwegian | 5 | text "femte" |
      | DO-DM6-NORWEGIAN-DAYS-D06 | Norwegian | 6 | text "sjette" |
      | DO-DM6-NORWEGIAN-DAYS-D07 | Norwegian | 7 | text "syvende" |
      | DO-DM6-NORWEGIAN-DAYS-D08 | Norwegian | 8 | text "åttende" |
      | DO-DM6-NORWEGIAN-DAYS-D09 | Norwegian | 9 | text "niende" |
      | DO-DM6-NORWEGIAN-DAYS-D10 | Norwegian | 10 | text "tiende" |
      | DO-DM6-NORWEGIAN-DAYS-D11 | Norwegian | 11 | text "ellevte" |
      | DO-DM6-NORWEGIAN-DAYS-D12 | Norwegian | 12 | text "tolvte" |
      | DO-DM6-NORWEGIAN-DAYS-D13 | Norwegian | 13 | text "trettende" |
      | DO-DM6-NORWEGIAN-DAYS-D14 | Norwegian | 14 | text "fjortende" |
      | DO-DM6-NORWEGIAN-DAYS-D15 | Norwegian | 15 | text "femtende" |
      | DO-DM6-NORWEGIAN-DAYS-D16 | Norwegian | 16 | text "sekstende" |
      | DO-DM6-NORWEGIAN-DAYS-D17 | Norwegian | 17 | text "syttende" |
      | DO-DM6-NORWEGIAN-DAYS-D18 | Norwegian | 18 | text "attende" |
      | DO-DM6-NORWEGIAN-DAYS-D19 | Norwegian | 19 | text "nittende" |
      | DO-DM6-NORWEGIAN-DAYS-D20 | Norwegian | 20 | text "tjuende" |
      | DO-DM6-NORWEGIAN-DAYS-D21 | Norwegian | 21 | text "tjueførste" |
      | DO-DM6-NORWEGIAN-DAYS-D22 | Norwegian | 22 | text "tjueandre" |
      | DO-DM6-NORWEGIAN-DAYS-D23 | Norwegian | 23 | text "tjuetredje" |
      | DO-DM6-NORWEGIAN-DAYS-D24 | Norwegian | 24 | text "tjuefjerde" |
      | DO-DM6-NORWEGIAN-DAYS-D25 | Norwegian | 25 | text "tjuefemte" |
      | DO-DM6-NORWEGIAN-DAYS-D26 | Norwegian | 26 | text "tjuesjette" |
      | DO-DM6-NORWEGIAN-DAYS-D27 | Norwegian | 27 | text "tjuesyvende" |
      | DO-DM6-NORWEGIAN-DAYS-D28 | Norwegian | 28 | text "tjueåttende" |
      | DO-DM6-NORWEGIAN-DAYS-D29 | Norwegian | 29 | text "tjueniende" |
      | DO-DM6-NORWEGIAN-DAYS-D30 | Norwegian | 30 | text "trettiende" |
      | DO-DM6-NORWEGIAN-DAYS-D31 | Norwegian | 31 | text "trettiførste" |
      | DO-DM6-POLISH-DAYS-D01 | Polish | 1 | text "1." |
      | DO-DM6-POLISH-DAYS-D02 | Polish | 2 | text "2." |
      | DO-DM6-POLISH-DAYS-D03 | Polish | 3 | text "3." |
      | DO-DM6-POLISH-DAYS-D04 | Polish | 4 | text "4." |
      | DO-DM6-POLISH-DAYS-D05 | Polish | 5 | text "5." |
      | DO-DM6-POLISH-DAYS-D06 | Polish | 6 | text "6." |
      | DO-DM6-POLISH-DAYS-D07 | Polish | 7 | text "7." |
      | DO-DM6-POLISH-DAYS-D08 | Polish | 8 | text "8." |
      | DO-DM6-POLISH-DAYS-D09 | Polish | 9 | text "9." |
      | DO-DM6-POLISH-DAYS-D10 | Polish | 10 | text "10." |
      | DO-DM6-POLISH-DAYS-D11 | Polish | 11 | text "11." |
      | DO-DM6-POLISH-DAYS-D12 | Polish | 12 | text "12." |
      | DO-DM6-POLISH-DAYS-D13 | Polish | 13 | text "13." |
      | DO-DM6-POLISH-DAYS-D14 | Polish | 14 | text "14." |
      | DO-DM6-POLISH-DAYS-D15 | Polish | 15 | text "15." |
      | DO-DM6-POLISH-DAYS-D16 | Polish | 16 | text "16." |
      | DO-DM6-POLISH-DAYS-D17 | Polish | 17 | text "17." |
      | DO-DM6-POLISH-DAYS-D18 | Polish | 18 | text "18." |
      | DO-DM6-POLISH-DAYS-D19 | Polish | 19 | text "19." |
      | DO-DM6-POLISH-DAYS-D20 | Polish | 20 | text "20." |
      | DO-DM6-POLISH-DAYS-D21 | Polish | 21 | text "21." |
      | DO-DM6-POLISH-DAYS-D22 | Polish | 22 | text "22." |
      | DO-DM6-POLISH-DAYS-D23 | Polish | 23 | text "23." |
      | DO-DM6-POLISH-DAYS-D24 | Polish | 24 | text "24." |
      | DO-DM6-POLISH-DAYS-D25 | Polish | 25 | text "25." |
      | DO-DM6-POLISH-DAYS-D26 | Polish | 26 | text "26." |
      | DO-DM6-POLISH-DAYS-D27 | Polish | 27 | text "27." |
      | DO-DM6-POLISH-DAYS-D28 | Polish | 28 | text "28." |
      | DO-DM6-POLISH-DAYS-D29 | Polish | 29 | text "29." |
      | DO-DM6-POLISH-DAYS-D30 | Polish | 30 | text "30." |
      | DO-DM6-POLISH-DAYS-D31 | Polish | 31 | text "31." |
      | DO-DM6-PORTUGUESE-DAYS-D01 | Portuguese | 1 | text "1º" |
      | DO-DM6-PORTUGUESE-DAYS-D02 | Portuguese | 2 | text "2º" |
      | DO-DM6-PORTUGUESE-DAYS-D03 | Portuguese | 3 | text "3º" |
      | DO-DM6-PORTUGUESE-DAYS-D04 | Portuguese | 4 | text "4º" |
      | DO-DM6-PORTUGUESE-DAYS-D05 | Portuguese | 5 | text "5º" |
      | DO-DM6-PORTUGUESE-DAYS-D06 | Portuguese | 6 | text "6º" |
      | DO-DM6-PORTUGUESE-DAYS-D07 | Portuguese | 7 | text "7º" |
      | DO-DM6-PORTUGUESE-DAYS-D08 | Portuguese | 8 | text "8º" |
      | DO-DM6-PORTUGUESE-DAYS-D09 | Portuguese | 9 | text "9º" |
      | DO-DM6-PORTUGUESE-DAYS-D10 | Portuguese | 10 | text "10º" |
      | DO-DM6-PORTUGUESE-DAYS-D11 | Portuguese | 11 | text "11º" |
      | DO-DM6-PORTUGUESE-DAYS-D12 | Portuguese | 12 | text "12º" |
      | DO-DM6-PORTUGUESE-DAYS-D13 | Portuguese | 13 | text "13º" |
      | DO-DM6-PORTUGUESE-DAYS-D14 | Portuguese | 14 | text "14º" |
      | DO-DM6-PORTUGUESE-DAYS-D15 | Portuguese | 15 | text "15º" |
      | DO-DM6-PORTUGUESE-DAYS-D16 | Portuguese | 16 | text "16º" |
      | DO-DM6-PORTUGUESE-DAYS-D17 | Portuguese | 17 | text "17º" |
      | DO-DM6-PORTUGUESE-DAYS-D18 | Portuguese | 18 | text "18º" |
      | DO-DM6-PORTUGUESE-DAYS-D19 | Portuguese | 19 | text "19º" |
      | DO-DM6-PORTUGUESE-DAYS-D20 | Portuguese | 20 | text "20º" |
      | DO-DM6-PORTUGUESE-DAYS-D21 | Portuguese | 21 | text "21º" |
      | DO-DM6-PORTUGUESE-DAYS-D22 | Portuguese | 22 | text "22º" |
      | DO-DM6-PORTUGUESE-DAYS-D23 | Portuguese | 23 | text "23º" |
      | DO-DM6-PORTUGUESE-DAYS-D24 | Portuguese | 24 | text "24º" |
      | DO-DM6-PORTUGUESE-DAYS-D25 | Portuguese | 25 | text "25º" |
      | DO-DM6-PORTUGUESE-DAYS-D26 | Portuguese | 26 | text "26º" |
      | DO-DM6-PORTUGUESE-DAYS-D27 | Portuguese | 27 | text "27º" |
      | DO-DM6-PORTUGUESE-DAYS-D28 | Portuguese | 28 | text "28º" |
      | DO-DM6-PORTUGUESE-DAYS-D29 | Portuguese | 29 | text "29º" |
      | DO-DM6-PORTUGUESE-DAYS-D30 | Portuguese | 30 | text "30º" |
      | DO-DM6-PORTUGUESE-DAYS-D31 | Portuguese | 31 | text "31º" |
      | DO-DM6-ROMANIAN-DAYS-D01 | Romanian | 1 | text "a 1-a" |
      | DO-DM6-ROMANIAN-DAYS-D02 | Romanian | 2 | text "a 2-a" |
      | DO-DM6-ROMANIAN-DAYS-D03 | Romanian | 3 | text "a 3-a" |
      | DO-DM6-ROMANIAN-DAYS-D04 | Romanian | 4 | text "a 4-a" |
      | DO-DM6-ROMANIAN-DAYS-D05 | Romanian | 5 | text "a 5-a" |
      | DO-DM6-ROMANIAN-DAYS-D06 | Romanian | 6 | text "a 6-a" |
      | DO-DM6-ROMANIAN-DAYS-D07 | Romanian | 7 | text "a 7-a" |
      | DO-DM6-ROMANIAN-DAYS-D08 | Romanian | 8 | text "a 8-a" |
      | DO-DM6-ROMANIAN-DAYS-D09 | Romanian | 9 | text "a 9-a" |
      | DO-DM6-ROMANIAN-DAYS-D10 | Romanian | 10 | text "a 10-a" |
      | DO-DM6-ROMANIAN-DAYS-D11 | Romanian | 11 | text "a 11-a" |
      | DO-DM6-ROMANIAN-DAYS-D12 | Romanian | 12 | text "a 12-a" |
      | DO-DM6-ROMANIAN-DAYS-D13 | Romanian | 13 | text "a 13-a" |
      | DO-DM6-ROMANIAN-DAYS-D14 | Romanian | 14 | text "a 14-a" |
      | DO-DM6-ROMANIAN-DAYS-D15 | Romanian | 15 | text "a 15-a" |
      | DO-DM6-ROMANIAN-DAYS-D16 | Romanian | 16 | text "a 16-a" |
      | DO-DM6-ROMANIAN-DAYS-D17 | Romanian | 17 | text "a 17-a" |
      | DO-DM6-ROMANIAN-DAYS-D18 | Romanian | 18 | text "a 18-a" |
      | DO-DM6-ROMANIAN-DAYS-D19 | Romanian | 19 | text "a 19-a" |
      | DO-DM6-ROMANIAN-DAYS-D20 | Romanian | 20 | text "a 20-a" |
      | DO-DM6-ROMANIAN-DAYS-D21 | Romanian | 21 | text "a 21-a" |
      | DO-DM6-ROMANIAN-DAYS-D22 | Romanian | 22 | text "a 22-a" |
      | DO-DM6-ROMANIAN-DAYS-D23 | Romanian | 23 | text "a 23-a" |
      | DO-DM6-ROMANIAN-DAYS-D24 | Romanian | 24 | text "a 24-a" |
      | DO-DM6-ROMANIAN-DAYS-D25 | Romanian | 25 | text "a 25-a" |
      | DO-DM6-ROMANIAN-DAYS-D26 | Romanian | 26 | text "a 26-a" |
      | DO-DM6-ROMANIAN-DAYS-D27 | Romanian | 27 | text "a 27-a" |
      | DO-DM6-ROMANIAN-DAYS-D28 | Romanian | 28 | text "a 28-a" |
      | DO-DM6-ROMANIAN-DAYS-D29 | Romanian | 29 | text "a 29-a" |
      | DO-DM6-ROMANIAN-DAYS-D30 | Romanian | 30 | text "a 30-a" |
      | DO-DM6-ROMANIAN-DAYS-D31 | Romanian | 31 | text "a 31-a" |
      | DO-DM6-RUSSIAN-DAYS-D01 | Russian | 1 | text "1" |
      | DO-DM6-RUSSIAN-DAYS-D02 | Russian | 2 | text "2" |
      | DO-DM6-RUSSIAN-DAYS-D03 | Russian | 3 | text "3" |
      | DO-DM6-RUSSIAN-DAYS-D04 | Russian | 4 | text "4" |
      | DO-DM6-RUSSIAN-DAYS-D05 | Russian | 5 | text "5" |
      | DO-DM6-RUSSIAN-DAYS-D06 | Russian | 6 | text "6" |
      | DO-DM6-RUSSIAN-DAYS-D07 | Russian | 7 | text "7" |
      | DO-DM6-RUSSIAN-DAYS-D08 | Russian | 8 | text "8" |
      | DO-DM6-RUSSIAN-DAYS-D09 | Russian | 9 | text "9" |
      | DO-DM6-RUSSIAN-DAYS-D10 | Russian | 10 | text "10" |
      | DO-DM6-RUSSIAN-DAYS-D11 | Russian | 11 | text "11" |
      | DO-DM6-RUSSIAN-DAYS-D12 | Russian | 12 | text "12" |
      | DO-DM6-RUSSIAN-DAYS-D13 | Russian | 13 | text "13" |
      | DO-DM6-RUSSIAN-DAYS-D14 | Russian | 14 | text "14" |
      | DO-DM6-RUSSIAN-DAYS-D15 | Russian | 15 | text "15" |
      | DO-DM6-RUSSIAN-DAYS-D16 | Russian | 16 | text "16" |
      | DO-DM6-RUSSIAN-DAYS-D17 | Russian | 17 | text "17" |
      | DO-DM6-RUSSIAN-DAYS-D18 | Russian | 18 | text "18" |
      | DO-DM6-RUSSIAN-DAYS-D19 | Russian | 19 | text "19" |
      | DO-DM6-RUSSIAN-DAYS-D20 | Russian | 20 | text "20" |
      | DO-DM6-RUSSIAN-DAYS-D21 | Russian | 21 | text "21" |
      | DO-DM6-RUSSIAN-DAYS-D22 | Russian | 22 | text "22" |
      | DO-DM6-RUSSIAN-DAYS-D23 | Russian | 23 | text "23" |
      | DO-DM6-RUSSIAN-DAYS-D24 | Russian | 24 | text "24" |
      | DO-DM6-RUSSIAN-DAYS-D25 | Russian | 25 | text "25" |
      | DO-DM6-RUSSIAN-DAYS-D26 | Russian | 26 | text "26" |
      | DO-DM6-RUSSIAN-DAYS-D27 | Russian | 27 | text "27" |
      | DO-DM6-RUSSIAN-DAYS-D28 | Russian | 28 | text "28" |
      | DO-DM6-RUSSIAN-DAYS-D29 | Russian | 29 | text "29" |
      | DO-DM6-RUSSIAN-DAYS-D30 | Russian | 30 | text "30" |
      | DO-DM6-RUSSIAN-DAYS-D31 | Russian | 31 | text "31" |
      | DO-DM6-SPANISH-DAYS-D01 | Spanish | 1 | text "1o" |
      | DO-DM6-SPANISH-DAYS-D02 | Spanish | 2 | text "2o" |
      | DO-DM6-SPANISH-DAYS-D03 | Spanish | 3 | text "3o" |
      | DO-DM6-SPANISH-DAYS-D04 | Spanish | 4 | text "4o" |
      | DO-DM6-SPANISH-DAYS-D05 | Spanish | 5 | text "5o" |
      | DO-DM6-SPANISH-DAYS-D06 | Spanish | 6 | text "6o" |
      | DO-DM6-SPANISH-DAYS-D07 | Spanish | 7 | text "7o" |
      | DO-DM6-SPANISH-DAYS-D08 | Spanish | 8 | text "8o" |
      | DO-DM6-SPANISH-DAYS-D09 | Spanish | 9 | text "9o" |
      | DO-DM6-SPANISH-DAYS-D10 | Spanish | 10 | text "10o" |
      | DO-DM6-SPANISH-DAYS-D11 | Spanish | 11 | text "11o" |
      | DO-DM6-SPANISH-DAYS-D12 | Spanish | 12 | text "12o" |
      | DO-DM6-SPANISH-DAYS-D13 | Spanish | 13 | text "13o" |
      | DO-DM6-SPANISH-DAYS-D14 | Spanish | 14 | text "14o" |
      | DO-DM6-SPANISH-DAYS-D15 | Spanish | 15 | text "15o" |
      | DO-DM6-SPANISH-DAYS-D16 | Spanish | 16 | text "16o" |
      | DO-DM6-SPANISH-DAYS-D17 | Spanish | 17 | text "17o" |
      | DO-DM6-SPANISH-DAYS-D18 | Spanish | 18 | text "18o" |
      | DO-DM6-SPANISH-DAYS-D19 | Spanish | 19 | text "19o" |
      | DO-DM6-SPANISH-DAYS-D20 | Spanish | 20 | text "20o" |
      | DO-DM6-SPANISH-DAYS-D21 | Spanish | 21 | text "21o" |
      | DO-DM6-SPANISH-DAYS-D22 | Spanish | 22 | text "22o" |
      | DO-DM6-SPANISH-DAYS-D23 | Spanish | 23 | text "23o" |
      | DO-DM6-SPANISH-DAYS-D24 | Spanish | 24 | text "24o" |
      | DO-DM6-SPANISH-DAYS-D25 | Spanish | 25 | text "25o" |
      | DO-DM6-SPANISH-DAYS-D26 | Spanish | 26 | text "26o" |
      | DO-DM6-SPANISH-DAYS-D27 | Spanish | 27 | text "27o" |
      | DO-DM6-SPANISH-DAYS-D28 | Spanish | 28 | text "28o" |
      | DO-DM6-SPANISH-DAYS-D29 | Spanish | 29 | text "29o" |
      | DO-DM6-SPANISH-DAYS-D30 | Spanish | 30 | text "30o" |
      | DO-DM6-SPANISH-DAYS-D31 | Spanish | 31 | text "31o" |
      | DO-DM6-SWEDISH-DAYS-D01 | Swedish | 1 | text "1:a" |
      | DO-DM6-SWEDISH-DAYS-D02 | Swedish | 2 | text "2:a" |
      | DO-DM6-SWEDISH-DAYS-D03 | Swedish | 3 | text "3:e" |
      | DO-DM6-SWEDISH-DAYS-D04 | Swedish | 4 | text "4:e" |
      | DO-DM6-SWEDISH-DAYS-D05 | Swedish | 5 | text "5:e" |
      | DO-DM6-SWEDISH-DAYS-D06 | Swedish | 6 | text "6:e" |
      | DO-DM6-SWEDISH-DAYS-D07 | Swedish | 7 | text "7:e" |
      | DO-DM6-SWEDISH-DAYS-D08 | Swedish | 8 | text "8:e" |
      | DO-DM6-SWEDISH-DAYS-D09 | Swedish | 9 | text "9:e" |
      | DO-DM6-SWEDISH-DAYS-D10 | Swedish | 10 | text "10:e" |
      | DO-DM6-SWEDISH-DAYS-D11 | Swedish | 11 | text "11:e" |
      | DO-DM6-SWEDISH-DAYS-D12 | Swedish | 12 | text "12:e" |
      | DO-DM6-SWEDISH-DAYS-D13 | Swedish | 13 | text "13:e" |
      | DO-DM6-SWEDISH-DAYS-D14 | Swedish | 14 | text "14:e" |
      | DO-DM6-SWEDISH-DAYS-D15 | Swedish | 15 | text "15:e" |
      | DO-DM6-SWEDISH-DAYS-D16 | Swedish | 16 | text "16:e" |
      | DO-DM6-SWEDISH-DAYS-D17 | Swedish | 17 | text "17:e" |
      | DO-DM6-SWEDISH-DAYS-D18 | Swedish | 18 | text "18:e" |
      | DO-DM6-SWEDISH-DAYS-D19 | Swedish | 19 | text "19:e" |
      | DO-DM6-SWEDISH-DAYS-D20 | Swedish | 20 | text "20:e" |
      | DO-DM6-SWEDISH-DAYS-D21 | Swedish | 21 | text "21:a" |
      | DO-DM6-SWEDISH-DAYS-D22 | Swedish | 22 | text "22:a" |
      | DO-DM6-SWEDISH-DAYS-D23 | Swedish | 23 | text "23:e" |
      | DO-DM6-SWEDISH-DAYS-D24 | Swedish | 24 | text "24:e" |
      | DO-DM6-SWEDISH-DAYS-D25 | Swedish | 25 | text "25:e" |
      | DO-DM6-SWEDISH-DAYS-D26 | Swedish | 26 | text "26:e" |
      | DO-DM6-SWEDISH-DAYS-D27 | Swedish | 27 | text "27:e" |
      | DO-DM6-SWEDISH-DAYS-D28 | Swedish | 28 | text "28:e" |
      | DO-DM6-SWEDISH-DAYS-D29 | Swedish | 29 | text "29:e" |
      | DO-DM6-SWEDISH-DAYS-D30 | Swedish | 30 | text "30:e" |
      | DO-DM6-SWEDISH-DAYS-D31 | Swedish | 31 | text "31:a" |
      | DO-DM6-TURKISH-DAYS-D01 | Turkish | 1 | text "bir" |
      | DO-DM6-TURKISH-DAYS-D02 | Turkish | 2 | text "iki" |
      | DO-DM6-TURKISH-DAYS-D03 | Turkish | 3 | text "üç" |
      | DO-DM6-TURKISH-DAYS-D04 | Turkish | 4 | text "dört" |
      | DO-DM6-TURKISH-DAYS-D05 | Turkish | 5 | text "beş" |
      | DO-DM6-TURKISH-DAYS-D06 | Turkish | 6 | text "altı" |
      | DO-DM6-TURKISH-DAYS-D07 | Turkish | 7 | text "yedi" |
      | DO-DM6-TURKISH-DAYS-D08 | Turkish | 8 | text "sekiz" |
      | DO-DM6-TURKISH-DAYS-D09 | Turkish | 9 | text "dokuz" |
      | DO-DM6-TURKISH-DAYS-D10 | Turkish | 10 | text "on" |
      | DO-DM6-TURKISH-DAYS-D11 | Turkish | 11 | text "on bir" |
      | DO-DM6-TURKISH-DAYS-D12 | Turkish | 12 | text "on iki" |
      | DO-DM6-TURKISH-DAYS-D13 | Turkish | 13 | text "on üç" |
      | DO-DM6-TURKISH-DAYS-D14 | Turkish | 14 | text "on dört" |
      | DO-DM6-TURKISH-DAYS-D15 | Turkish | 15 | text "on beş" |
      | DO-DM6-TURKISH-DAYS-D16 | Turkish | 16 | text "on altı" |
      | DO-DM6-TURKISH-DAYS-D17 | Turkish | 17 | text "on yedi" |
      | DO-DM6-TURKISH-DAYS-D18 | Turkish | 18 | text "on sekiz" |
      | DO-DM6-TURKISH-DAYS-D19 | Turkish | 19 | text "on dokuz" |
      | DO-DM6-TURKISH-DAYS-D20 | Turkish | 20 | text "yirmi" |
      | DO-DM6-TURKISH-DAYS-D21 | Turkish | 21 | text "yirmi bir" |
      | DO-DM6-TURKISH-DAYS-D22 | Turkish | 22 | text "yirmi iki" |
      | DO-DM6-TURKISH-DAYS-D23 | Turkish | 23 | text "yirmi üç" |
      | DO-DM6-TURKISH-DAYS-D24 | Turkish | 24 | text "yirmi dört" |
      | DO-DM6-TURKISH-DAYS-D25 | Turkish | 25 | text "yirmi beş" |
      | DO-DM6-TURKISH-DAYS-D26 | Turkish | 26 | text "yirmi altı" |
      | DO-DM6-TURKISH-DAYS-D27 | Turkish | 27 | text "yirmi yedi" |
      | DO-DM6-TURKISH-DAYS-D28 | Turkish | 28 | text "yirmi sekiz" |
      | DO-DM6-TURKISH-DAYS-D29 | Turkish | 29 | text "yirmi dokuz" |
      | DO-DM6-TURKISH-DAYS-D30 | Turkish | 30 | text "otuz" |
      | DO-DM6-TURKISH-DAYS-D31 | Turkish | 31 | text "otuz bir" |
