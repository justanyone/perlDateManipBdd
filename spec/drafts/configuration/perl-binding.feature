@draft @reference-dm700 @configuration @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve native configuration binding diagnostics
  This exact warning is reference-binding evidence and is not a portable requirement.

  Scenario Outline: Preserve the native deprecated-setting warning
    Given native profile <native profile> and request <request>
    When the public configuration request is executed
    Then the exact native warning sequence is <native warnings>

    Examples:
      | binding case | native profile | request | native warnings |
      | CFG-DM6-JAN1WEEK1 | oo | {"settings":[["Jan1Week1","1"]],"read":["jan1week1"]} | ["WARNING: the jan1week1 Date::Manip config variable is deprecated\\n         and will be removed in version 7.00.  Please use\\n         the Week1ofYear config variable instead.\\n at /home/kevin/my_code/perlDateManipBdd/local/date-manip-7.00/lib/perl5/Date/Manip/Obj.pm line 286.\\n"] |
