@draft @portable @date @replace-time
Feature: Replace a date value's clock fields
  Each request uses its stated replacement profile with English text, an
  Etc/UTC local zone, US numeric dates, and the fixed reference clock
  2040-02-28 10:20:30. Results are serialized date text; an empty result is
  distinct from a date text result.

  Scenario Outline: Replace time through documented request forms
    Given the <profile> replacement profile
    And date text "<date text>"
    When I replace its time with <time request>
    Then the date.replace-time result is <result>

    Examples:
      | case | profile | date text | time request | result |
      | RT-PORT-CURRENT-FIELDS-ORDINARY | current functional | 2040-02-29 16:05:09 | ordered fields [7, 8, 9] | text "2040022907:08:09" |
      | RT-PORT-CURRENT-TEXT-HOUR | current functional | 2040-02-29 16:05:09 | time text "05" | text "2040022905:00:00" |
      | RT-PORT-CURRENT-TEXT-MINUTE | current functional | 2040-02-29 16:05:09 | time text "05:06" | text "2040022905:06:00" |
      | RT-PORT-CURRENT-TEXT-SECOND | current functional | 2040-02-29 16:05:09 | time text "05:06:07" | text "2040022905:06:07" |
      | RT-PORT-CURRENT-FIELDS-LOWER | current functional | 2040-02-29 16:05:09 | ordered fields [0, 0, 0] | text "2040022900:00:00" |
      | RT-PORT-CURRENT-FIELDS-UPPER | current functional | 2040-02-29 16:05:09 | ordered fields [23, 59, 59] | text "2040022923:59:59" |
      | RT-PORT-CURRENT-FIELDS-BAD-MINUTE | current functional | 2040-02-29 16:05:09 | ordered fields [7, 60, 0] | empty text |
      | RT-PORT-CURRENT-FIELDS-NEGATIVE-HOUR | current functional | 2040-02-29 16:05:09 | ordered fields [-1, 0, 0] | empty text |
      | RT-PORT-CURRENT-BAD-DATE | current functional | not a calendar date | ordered fields [7, 8, 9] | empty text |
      | RT-PORT-LEGACY-FIELDS-ORDINARY | legacy compatibility | 2040-02-29 16:05:09 | ordered fields [7, 8, 9] | text "2040022907:08:09" |
      | RT-PORT-LEGACY-TEXT-HOUR | legacy compatibility | 2040-02-29 16:05:09 | time text "05" | text "2040022905:00:00" |
      | RT-PORT-LEGACY-TEXT-MINUTE | legacy compatibility | 2040-02-29 16:05:09 | time text "05:06" | text "2040022905:06:00" |
      | RT-PORT-LEGACY-TEXT-SECOND | legacy compatibility | 2040-02-29 16:05:09 | time text "05:06:07" | text "2040022905:06:07" |
      | RT-PORT-LEGACY-FIELDS-LOWER | legacy compatibility | 2040-02-29 16:05:09 | ordered fields [0, 0, 0] | text "2040022900:00:00" |
      | RT-PORT-LEGACY-FIELDS-UPPER | legacy compatibility | 2040-02-29 16:05:09 | ordered fields [23, 59, 59] | text "2040022923:59:59" |
      | RT-PORT-LEGACY-FIELDS-BAD-MINUTE | legacy compatibility | 2040-02-29 16:05:09 | ordered fields [7, 60, 0] | empty text |
      | RT-PORT-LEGACY-FIELDS-NEGATIVE-HOUR | legacy compatibility | 2040-02-29 16:05:09 | ordered fields [-1, 0, 0] | empty text |
      | RT-PORT-LEGACY-BAD-DATE | legacy compatibility | not a calendar date | ordered fields [7, 8, 9] | empty text |
