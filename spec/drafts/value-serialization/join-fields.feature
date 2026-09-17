@portable @value-serialization
Feature: Join ordered fields into serialized values
  Concrete inputs and literal results define the value.join-fields operation.
  An absent value is distinct from empty text and from an exception.

  Background:
    Given the value serialization profile uses English and ASCII text
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US, its default Printable mode is 0, and Monday starts the week
    And business days are Monday through Friday from "09:00" through "17:00"
    And date fields are ordered year, month, day, hour, minute, second
    And hms, offset and time fields are ordered hour, minute, second
    And delta and business fields are ordered year, month, week, day, hour, minute, second

  Scenario Outline: Join ordered fields into serialized values
    When I join the <kind> value <input> with <options and configuration>
    Then the value.join-fields result is <literal result>

    Examples:
      | case | kind | input | options and configuration | literal result |
      | VS-DATE-JOIN-PRINTABLE0 | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=0 | text "2040022916:05:09" |
      | VS-DATE-JOIN-PRINTABLE1 | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=1 | text "20400229160509" |
      | VS-DATE-JOIN-PRINTABLE2 | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=2 | text "2040-02-29-16:05:09" |
      | VS-DATE-JOIN-WRONG-ARITY | date | ordered fields [2040,2,29,16,5] | no options | an absent value |
      | VS-HMS-JOIN-ZERO | hms | ordered fields [0,0,0] | no options | text "00:00:00" |
      | VS-HMS-JOIN-ENDPOINT | hms | ordered fields [24,0,0] | no options | text "24:00:00" |
      | VS-HMS-JOIN-INVALID | hms | ordered fields [-1,0,0] | no options | an absent value |
      | VS-OFFSET-JOIN-ZERO | offset | ordered fields [0,0,0] | no options | text "+00:00:00" |
      | VS-OFFSET-JOIN-POSITIVE | offset | ordered fields [5,30,45] | no options | text "+05:30:45" |
      | VS-OFFSET-JOIN-NEGATIVE | offset | ordered fields [-5,-30,-45] | no options | text "-05:30:45" |
      | VS-OFFSET-JOIN-MIXED-SIGN | offset | ordered fields [-5,30,0] | no options | an absent value |
      | VS-OFFSET-JOIN-OUT-OF-RANGE | offset | ordered fields [24,0,0] | no options | an absent value |
      | VS-TIME-JOIN-ORDINARY | time | ordered fields [1,2,3] | no options | text "1:2:3" |
      | VS-TIME-JOIN-MIXED-SIGN | time | ordered fields [-1,30,0] | no options | text "0:-30:0" |
      | VS-TIME-JOIN-OVERFLOW | time | ordered fields [1,120,90] | no options | text "3:1:30" |
      | VS-TIME-JOIN-OVERFLOW-NONORM | time | ordered fields [1,120,90] | options {"nonorm":1} | text "1:120:90" |
      | VS-TIME-JOIN-TOO-MANY | time | ordered fields [1,2,3,4] | no options | an absent value |
      | VS-DELTA-JOIN-FULL | delta | ordered fields [1,2,3,4,5,6,7] | no options | text "1:2:3:4:5:6:7" |
      | VS-DELTA-JOIN-OVERFLOW | delta | ordered fields [0,0,0,0,1,120,90] | no options | text "0:0:0:0:3:1:30" |
      | VS-DELTA-JOIN-OVERFLOW-NONORM | delta | ordered fields [0,0,0,0,1,120,90] | options {"nonorm":1} | text "0:0:0:0:1:120:90" |
      | VS-DELTA-JOIN-FRACTION | delta | ordered fields [0,0,0,0,0,0,1.5] | no options | text "0:0:0:0:0:0:1" |
      | VS-DELTA-JOIN-NONNUMERIC | delta | ordered fields [0,0,0,0,"x",0,0] | no options | an absent value |
