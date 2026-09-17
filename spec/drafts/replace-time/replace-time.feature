@draft @date @replace-time @source-binding @reference-binding @excluded-from-portable-handoff
Feature: Replace the clock fields of a date value
  The replacement profile uses English and ASCII text, Etc/UTC, US numeric
  dates, and a fixed reference clock of 2040-02-28 10:20:30. Returned values
  are serialized date values. Defined empty text is distinct from no return
  because a native exception interrupted the call.

  Scenario Outline: Replace a time through every documented functional form
    Given the <profile> functional profile in a fresh process
    And date text "<date text>"
    When I replace its time with <time request>
    Then the date.replace-time scalar result is <scalar outcome>
    And the one-item list result is <list outcome>
    And the native diagnostic is <diagnostic>

    Examples:
      | case | profile | date text | time request | scalar outcome | list outcome | diagnostic |
      | RT-DM6-FIELDS-ORDINARY | current DM6 | 2040-02-29 16:05:09 | ordered fields [7, 8, 9] | text "2040022907:08:09" | one text "2040022907:08:09" | no call stdout; no process stderr; no warning |
      | RT-DM6-TEXT-HOUR | current DM6 | 2040-02-29 16:05:09 | time text "05" | text "2040022905:00:00" | one text "2040022905:00:00" | no call stdout; no process stderr; no warning |
      | RT-DM6-TEXT-MINUTE | current DM6 | 2040-02-29 16:05:09 | time text "05:06" | text "2040022905:06:00" | one text "2040022905:06:00" | no call stdout; no process stderr; no warning |
      | RT-DM6-TEXT-SECOND | current DM6 | 2040-02-29 16:05:09 | time text "05:06:07" | text "2040022905:06:07" | one text "2040022905:06:07" | no call stdout; no process stderr; no warning |
      | RT-DM6-FIELDS-LOWER | current DM6 | 2040-02-29 16:05:09 | ordered fields [0, 0, 0] | text "2040022900:00:00" | one text "2040022900:00:00" | no call stdout; no process stderr; no warning |
      | RT-DM6-FIELDS-UPPER | current DM6 | 2040-02-29 16:05:09 | ordered fields [23, 59, 59] | text "2040022923:59:59" | one text "2040022923:59:59" | no call stdout; no process stderr; no warning |
      | RT-DM6-FIELDS-BAD-MINUTE | current DM6 | 2040-02-29 16:05:09 | ordered fields [7, 60, 0] | defined empty text | one defined empty text | no call stdout; no process stderr; no warning |
      | RT-DM6-FIELDS-NEGATIVE-HOUR | current DM6 | 2040-02-29 16:05:09 | ordered fields [-1, 0, 0] | defined empty text | one defined empty text | no call stdout; no process stderr; no warning |
      | RT-DM6-BAD-DATE | current DM6 | not a calendar date | ordered fields [7, 8, 9] | defined empty text | one defined empty text | no call stdout; no process stderr; no warning |
      | RT-DM5-FIELDS-ORDINARY | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [7, 8, 9] | text "2040022907:08:09" | one text "2040022907:08:09" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-TEXT-HOUR | legacy DM5 | 2040-02-29 16:05:09 | time text "05" | text "2040022905:00:00" | one text "2040022905:00:00" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-TEXT-MINUTE | legacy DM5 | 2040-02-29 16:05:09 | time text "05:06" | text "2040022905:06:00" | one text "2040022905:06:00" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-TEXT-SECOND | legacy DM5 | 2040-02-29 16:05:09 | time text "05:06:07" | text "2040022905:06:07" | one text "2040022905:06:07" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-FIELDS-LOWER | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [0, 0, 0] | text "2040022900:00:00" | one text "2040022900:00:00" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-FIELDS-UPPER | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [23, 59, 59] | text "2040022923:59:59" | one text "2040022923:59:59" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-FIELDS-BAD-MINUTE | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [7, 60, 0] | defined empty text | one defined empty text | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-FIELDS-NEGATIVE-HOUR | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [-1, 0, 0] | defined empty text | one defined empty text | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM5-BAD-DATE | legacy DM5 | not a calendar date | ordered fields [7, 8, 9] | defined empty text | one defined empty text | no call stdout; no process stderr; one DM5 module-load deprecation warning |

  @observed-compatibility @reference-binding @excluded-from-portable-handoff
  Scenario Outline: Retain native compatibility carriers and diagnostics outside documented forms
    Given the <profile> functional profile in a fresh process
    And date text "<date text>"
    When I replace its time with <time request>
    Then the native scalar outcome is <scalar outcome>
    And the native list outcome is <list outcome>
    And the binding diagnostic is <diagnostic>

    Examples:
      | case | profile | date text | time request | scalar outcome | list outcome | diagnostic |
      | RT-DM6-FIELDS-24 | current DM6 | 2040-02-29 16:05:09 | ordered fields [24, 0, 0] | text "2040022924:00:00" | one text "2040022924:00:00" | no call stdout; no process stderr; no warning |
      | RT-DM5-FIELDS-24 | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [24, 0, 0] | defined empty text | one defined empty text | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM6-TEXT-MERIDIAN | current DM6 | 2040-02-29 16:05:09 | time text "1:30 PM" | no return; exception prefix "Can't use an undefined value as an ARRAY reference" | no returned items; same exception prefix | no call stdout; no process stderr; no warning |
      | RT-DM5-TEXT-MERIDIAN | legacy DM5 | 2040-02-29 16:05:09 | time text "1:30 PM" | defined empty text | one defined empty text | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM6-TEXT-EXTRA-FIELD | current DM6 | 2040-02-29 16:05:09 | time text "05:06:07:08" | no return; exception prefix "Can't use an undefined value as an ARRAY reference" | no returned items; same exception prefix | no call stdout; no process stderr; no warning |
      | RT-DM5-TEXT-EXTRA-FIELD | legacy DM5 | 2040-02-29 16:05:09 | time text "05:06:07:08" | text "2040022905:06:07" | one text "2040022905:06:07" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
      | RT-DM6-FIELDS-TWO | current DM6 | 2040-02-29 16:05:09 | ordered fields [7, 8] | text "2040022907:08:00" | one text "2040022907:08:00" | no call stdout; no process stderr; no warning |
      | RT-DM5-FIELDS-TWO | legacy DM5 | 2040-02-29 16:05:09 | ordered fields [7, 8] | text "2040022907:08:00" | one text "2040022907:08:00" | no call stdout; no process stderr; one DM5 module-load deprecation warning |
