@draft @rendering @compatibility
Feature: Compare separately configured functional rendering profiles
  Each request starts in its stated fresh rendering profile. All profiles use
  English, Etc/UTC, reference clock 2040-02-28 10:20:30, month-first numeric
  dates, and midnight for omitted time. The source bindings are mapped separately.

  @RENDER-DM6-ZERO-PATTERNS @RENDER-DM6-ONE-PATTERN @RENDER-DM6-SCALAR-AND-LIST
  Scenario: The current functional profile has zero one and many requests
    Given the current functional rendering profile and date "2040-02-29 16:05:09"
    When I request zero patterns
    Then the text result is empty text and the ordered text result is an empty collection
    When I request one pattern "%Y"
    Then the text result is "2040" and the ordered text result is exactly one item "2040"
    When I request patterns "%Y", "%m", and "%d"
    Then the text result is "2040 02 29" and the ordered text result is "2040", "02", and "29"

  @RENDER-DM5-ZERO-PATTERNS @RENDER-DM5-ONE-PATTERN @RENDER-DM5-SCALAR-AND-LIST
  Scenario: The compatibility functional profile has zero one and many requests
    Given the compatibility rendering profile and date "02/29/2040 16:05:09"
    When I request zero patterns
    Then the text result is empty text and the ordered text result is an empty collection
    When I request one pattern "%Y"
    Then the text result is "2040" and the ordered text result is exactly one item "2040"
    When I request patterns "%Y", "%m", and "%d"
    Then the text result is "2040 02 29" and the ordered text result is "2040", "02", and "29"

  @RENDER-DM5-NATIVE-BASICS @RENDER-DM5-NATIVE-COMPOSITES @RENDER-DM5-NATIVE-LITERALS
  Scenario: The compatibility profile records complete native baseline groups
    Given the compatibility rendering profile and date "02/29/2040 16:05:09"
    When I request an ordered text result for these basic patterns:
      | %Y | %y | %m | %f | %b | %h | %B | %j | %d | %e | %v | %a | %A | %w | %E | %H | %k | %i | %I | %p | %M | %S | %Z | %z | %s | %o | %G | %W | %L | %U | %J |
    Then the ordered text result is:
      | 2040 | 40 | 02 | one leading ASCII space followed by 2 | Feb | Feb | February | 060 | 29 | 29 | one leading ASCII space followed by W | Wed | Wednesday | 3 | 29th | 16 | 16 | one leading ASCII space followed by 4 | 04 | PM | 05 | 09 | UTC | +0000 | 2214144309 | 2214144309 | 2040 | 09 | 2040 | 09 | 2040-W09-3 |
    When I request an ordered text result for these composite patterns:
      | %c | %C | %u | %g | %D | %x | %l | %r | %R | %T | %X | %V | %Q | %q | %P | %O | %F | %K |
    Then the ordered text result is:
      | Wed Feb 29 16:05:09 2040 | Wed Feb 29 16:05:09 +0000 2040 | Wed Feb 29 16:05:09 +0000 2040 | Wed, 29 Feb 2040 16:05:09 +0000 | 02/29/40 | 02/29/40 | Feb 29 16:05 | 04:05:09 PM | 16:05 | 16:05:09 | 16:05:09 | 0229160540 | 20400229 | 20400229160509 | 2040022916:05:09 | 2040-02-29T16:05:09 | Wednesday, February 29, 2040 | 2040-060 |
    When I request an ordered text result for patterns "%n", "%t", "%%", and "%+"
    Then the ordered text result is a line-feed character, a tab character, "%", and "+"

  @RENDER-DM5-UNSUPPORTED-N-EXTENDED
  Scenario: The compatibility profile keeps fallback text for unsupported forms
    Given the compatibility rendering profile and date "02/29/2040 16:05:09"
    When I request patterns "%N" and "%<A=1>"
    Then the ordered text result is "N" and "<A=1>"
