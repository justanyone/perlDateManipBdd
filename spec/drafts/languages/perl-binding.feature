@draft @languages @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve Perl legacy-language diagnostics and call carriers
  These scenarios retain Date::Manip::DM5 5.66 warning, exception, loading, and
  calling-context observations. They are not requirements for another language.

  Background:
    Given Perl loads the Date::Manip::DM5 5.66 compatibility backend from Date-Manip 7.00
    And the process clock is "2040-02-28 10:20:30 Etc/UTC"
    And Date_Init receives isolated configuration, non-US date order, internal output disabled, midnight omitted time, and erased holidays

  @LANG-BIND-SETUP-EXCEPTIONS @observed-compatibility @disputed
  Scenario: Perl preserves each native exception from failed legacy initialization
    When Date_Init receives each mapped language and IntCharSet value
    Then the call is interrupted before it returns a status
    And ParseDate and UnixDate are not called
    And the exact binding outcomes are:
      | binding case | source case | language | IntCharSet | exception prefix |
      | LANG-BIND-EXCEPTION-LEGACY-DEFAULT-catalan | LANG-DM5-LEGACY-DEFAULT-catalan | Catalan | 0 | Can't use an undefined value as an ARRAY reference |
      | LANG-BIND-EXCEPTION-LEGACY-INTERNATIONAL-catalan | LANG-DM5-LEGACY-INTERNATIONAL-catalan | Catalan | 1 | Can't use an undefined value as an ARRAY reference |
      | LANG-BIND-EXCEPTION-LEGACY-DEFAULT-finnish | LANG-DM5-LEGACY-DEFAULT-finnish | Finnish | 0 | ERROR: Unknown language in Date::Manip. |
      | LANG-BIND-EXCEPTION-LEGACY-INTERNATIONAL-finnish | LANG-DM5-LEGACY-INTERNATIONAL-finnish | Finnish | 1 | ERROR: Unknown language in Date::Manip. |
      | LANG-BIND-EXCEPTION-LEGACY-DEFAULT-norwegian | LANG-DM5-LEGACY-DEFAULT-norwegian | Norwegian | 0 | ERROR: Unknown language in Date::Manip. |
      | LANG-BIND-EXCEPTION-LEGACY-INTERNATIONAL-norwegian | LANG-DM5-LEGACY-INTERNATIONAL-norwegian | Norwegian | 1 | ERROR: Unknown language in Date::Manip. |

  @LANG-BIND-WARNING-CENSUS @observed-compatibility @disputed
  Scenario: Perl preserves the complete warning count and class census
    When each of the 32 mapped legacy source requests is executed in a fresh process
    Then every request emits the native deprecation warning
    And the exact additional warning outcomes are:
      | binding case | source case | warning count | warning class |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-danish | LANG-DM5-LEGACY-DEFAULT-danish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-danish | LANG-DM5-LEGACY-INTERNATIONAL-danish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-dutch | LANG-DM5-LEGACY-DEFAULT-dutch | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-dutch | LANG-DM5-LEGACY-INTERNATIONAL-dutch | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-english | LANG-DM5-LEGACY-DEFAULT-english | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-english | LANG-DM5-LEGACY-INTERNATIONAL-english | 4 | uninitialized month concatenation |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-french | LANG-DM5-LEGACY-DEFAULT-french | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-french | LANG-DM5-LEGACY-INTERNATIONAL-french | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-german | LANG-DM5-LEGACY-DEFAULT-german | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-german | LANG-DM5-LEGACY-INTERNATIONAL-german | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-italian | LANG-DM5-LEGACY-DEFAULT-italian | 36 | unescaped-left-brace regex warnings |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-italian | LANG-DM5-LEGACY-INTERNATIONAL-italian | 26 | unescaped-left-brace regex warnings |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-polish | LANG-DM5-LEGACY-DEFAULT-polish | 2 | uninitialized addition |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-polish | LANG-DM5-LEGACY-INTERNATIONAL-polish | 2 | uninitialized addition |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-portuguese | LANG-DM5-LEGACY-DEFAULT-portuguese | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-portuguese | LANG-DM5-LEGACY-INTERNATIONAL-portuguese | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-romanian | LANG-DM5-LEGACY-DEFAULT-romanian | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-romanian | LANG-DM5-LEGACY-INTERNATIONAL-romanian | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-russian | LANG-DM5-LEGACY-DEFAULT-russian | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-russian | LANG-DM5-LEGACY-INTERNATIONAL-russian | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-spanish | LANG-DM5-LEGACY-DEFAULT-spanish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-spanish | LANG-DM5-LEGACY-INTERNATIONAL-spanish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-swedish | LANG-DM5-LEGACY-DEFAULT-swedish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-swedish | LANG-DM5-LEGACY-INTERNATIONAL-swedish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-turkish | LANG-DM5-LEGACY-DEFAULT-turkish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-turkish | LANG-DM5-LEGACY-INTERNATIONAL-turkish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-catalan | LANG-DM5-LEGACY-DEFAULT-catalan | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-catalan | LANG-DM5-LEGACY-INTERNATIONAL-catalan | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-finnish | LANG-DM5-LEGACY-DEFAULT-finnish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-finnish | LANG-DM5-LEGACY-INTERNATIONAL-finnish | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-DEFAULT-norwegian | LANG-DM5-LEGACY-DEFAULT-norwegian | 1 | deprecation only |
      | LANG-BIND-WARNING-LEGACY-INTERNATIONAL-norwegian | LANG-DM5-LEGACY-INTERNATIONAL-norwegian | 1 | deprecation only |

  @LANG-BIND-CALL-SEQUENCE
  Scenario: Perl calls the legacy backend only after its native initializer succeeds
    When each source request loads Date::Manip::DM5 and calls Date_Init
    Then each of the 26 completed Date_Init calls returns native undefined status
    And the 26 initialized requests call UnixDate before any ParseDate request
    And the six special-input requests call ParseDate for that input before the three ordinary inputs
    And the 20 other initialized requests call ParseDate only for the three ordinary inputs
    And the six interrupted initializations call neither UnixDate nor ParseDate
