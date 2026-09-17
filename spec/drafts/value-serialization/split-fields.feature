@portable @value-serialization
Feature: Split serialized values into ordered fields
  Concrete inputs and literal results define the value.split-fields operation.
  An absent value is distinct from empty text and from an exception.

  Background:
    Given the value serialization profile uses English and ASCII text
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US, its default Printable mode is 0, and Monday starts the week
    And business days are Monday through Friday from "09:00" through "17:00"
    And date fields are ordered year, month, day, hour, minute, second
    And hms, offset and time fields are ordered hour, minute, second
    And delta and business fields are ordered year, month, week, day, hour, minute, second

  Scenario Outline: Split serialized values into ordered fields
    When I split the <kind> value <input> with <options and configuration>
    Then the value.split-fields result is <literal result>

    Examples:
      | case | kind | input | options and configuration | literal result |
      | VS-DATE-SPLIT-COLON | date | text "2040022916:05:09" | no options | ordered fields [2040,2,29,16,5,9] |
      | VS-DATE-SPLIT-COMPACT | date | text "20400229160509" | no options | ordered fields [2040,2,29,16,5,9] |
      | VS-DATE-SPLIT-PRINTABLE | date | text "2040-02-29-16:05:09" | no options | ordered fields [2040,2,29,16,5,9] |
      | VS-DATE-SPLIT-BAD-SEPARATOR | date | text "2040/02/29 16:05:09" | no options | an absent value |
      | VS-DATE-SPLIT-TRAILING | date | text "2040022916:05:09Z" | no options | an absent value |
      | VS-DATE-SPLIT-EMPTY | date | text "" | no options | an absent value |
      | VS-HMS-SPLIT-HOUR | hms | text "7" | no options | ordered fields [7,0,0] |
      | VS-HMS-SPLIT-COMPACT4 | hms | text "0715" | no options | ordered fields [7,15,0] |
      | VS-HMS-SPLIT-COMPACT6 | hms | text "071509" | no options | ordered fields [7,15,9] |
      | VS-HMS-SPLIT-COLON2 | hms | text "7:15" | no options | ordered fields [7,15,0] |
      | VS-HMS-SPLIT-ENDPOINT | hms | text "24:00:00" | no options | ordered fields [24,0,0] |
      | VS-HMS-SPLIT-PAST-END | hms | text "24:00:01" | no options | an absent value |
      | VS-HMS-SPLIT-MINUTE60 | hms | text "12:60:00" | no options | an absent value |
      | VS-HMS-SPLIT-NONNUMERIC | hms | text "noon" | no options | an absent value |
      | VS-OFFSET-SPLIT-UNSIGNED | offset | text "5:30" | no options | ordered fields [5,30,0] |
      | VS-OFFSET-SPLIT-COMPACT | offset | text "-053045" | no options | ordered fields [-5,-30,-45] |
      | VS-OFFSET-SPLIT-POS-END | offset | text "+23:59:59" | no options | ordered fields [23,59,59] |
      | VS-OFFSET-SPLIT-NEG-END | offset | text "-23:59:59" | no options | ordered fields [-23,-59,-59] |
      | VS-OFFSET-SPLIT-OUT-OF-RANGE | offset | text "+24:00:00" | no options | an absent value |
      | VS-OFFSET-SPLIT-BAD-MINUTE | offset | text "+05:60" | no options | an absent value |
      | VS-TIME-SPLIT-ZERO | time | text "0:0:0" | no options | ordered fields [0,0,0] |
      | VS-TIME-SPLIT-ORDINARY | time | text "1:02:03" | no options | ordered fields [1,2,3] |
      | VS-TIME-SPLIT-NEGATIVE | time | text "-1:-02:-03" | no options | ordered fields [-1,-2,-3] |
      | VS-TIME-SPLIT-MIXED-SIGN | time | text "-1:30:00" | no options | ordered fields [-1,-30,0] |
      | VS-TIME-SPLIT-OVERFLOW | time | text "1:120:90" | no options | ordered fields [3,1,30] |
      | VS-TIME-SPLIT-OVERFLOW-NONORM | time | text "1:120:90" | options {"nonorm":1} | ordered fields [1,120,90] |
      | VS-TIME-SPLIT-NONNUMERIC | time | text "1:x:3" | no options | an absent value |
      | VS-DELTA-SPLIT-ZERO | delta | text "0:0:0:0:0:0:0" | no options | ordered fields [0,0,0,0,0,0,0] |
      | VS-DELTA-SPLIT-FULL | delta | text "1:2:3:4:5:6:7" | no options | ordered fields [1,2,3,4,5,6,7] |
      | VS-DELTA-SPLIT-SHORT | delta | text "4:5:6:7" | no options | ordered fields [0,0,0,4,5,6,7] |
      | VS-DELTA-SPLIT-NEGATIVE | delta | text "0:0:0:-1:-2:-3:-4" | no options | ordered fields [0,0,0,-1,-2,-3,-4] |
      | VS-DELTA-SPLIT-OVERFLOW | delta | text "0:0:0:0:1:120:90" | no options | ordered fields [0,0,0,0,3,1,30] |
      | VS-DELTA-SPLIT-OVERFLOW-NONORM | delta | text "0:0:0:0:1:120:90" | options {"nonorm":1} | ordered fields [0,0,0,0,1,120,90] |
      | VS-DELTA-SPLIT-ESTIMATED | delta | text "0:1:0:0:0:0:0" | options {"type":"estimated"} | ordered fields [0,1,0,0,0,0,0] |
      | VS-DELTA-SPLIT-NONNUMERIC | delta | text "0:0:0:0:x:0:0" | no options | an absent value |
      | VS-DELTA-SPLIT-TOO-MANY | delta | text "1:2:3:4:5:6:7:8" | no options | an absent value |
