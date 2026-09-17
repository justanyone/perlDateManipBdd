@draft @rendering
Feature: Render native date presentation forms
  All requests use the portable "utc-english-2040" profile: English, UTC,
  US numeric order, Monday-first Jan-4 weeks, and reference clock 2040-02-28
  10:20:30. Working days are Monday through Friday, 09:00 through 17:00;
  holidays and events are empty. Omitted date times default to midnight.

  @RENDER-NATIVE-BASICS
  Scenario: Render the ordered native basic-field request
    Given a complete UTC date-time "2040-02-29 16:05:09"
    When I request an ordered text result for the ordered patterns in row order:
      | %Y | %y | %m | %f | %b | %h | %B | %j | %d | %e | %v | %a | %A | %w | %E | %H | %k | %i | %I | %p | %M | %S | %Z | %z | %N | %s | %o | %G | %W | %L | %U | %J |
    Then the ordered text result is:
      | 2040 | 40 | 02 | one leading ASCII space followed by 2 | Feb | Feb | February | 060 | 29 | 29 | W | Wed | Wednesday | 3 | 29th | 16 | 16 | one leading ASCII space followed by 4 | 04 | PM | 05 | 09 | UTC | +0000 | +00:00:00 | 2214144309 | 2214144309 | 2040 | 09 | 2040 | 09 | 2040-W09-3 |

  @RENDER-NATIVE-COMPOSITES
  Scenario: Render the ordered native composite request
    Given a complete UTC date-time "2040-02-29 16:05:09"
    When I request an ordered text result for the ordered patterns in row order:
      | %c | %C | %u | %g | %D | %x | %l | %r | %R | %T | %X | %V | %Q | %q | %P | %O | %F | %K |
    Then the ordered text result is:
      | Wed Feb 29 16:05:09 2040 | Wed Feb 29 16:05:09 UTC 2040 | Wed Feb 29 16:05:09 UTC 2040 | Wed, 29 Feb 2040 16:05:09 UTC | 02/29/40 | 02/29/40 | Feb 29 16:05 | 04:05:09 PM | 16:05 | 16:05:09 | 16:05:09 | 0229160540 | 20400229 | 20400229160509 | 2040022916:05:09 | 2040-02-29T16:05:09 | Wednesday, February 29, 2040 | 2040-060 |

  @RENDER-NATIVE-LITERALS
  Scenario: Render the ordered literal-pattern request
    Given a complete UTC date-time "2040-02-29 16:05:09"
    When I request an ordered text result for the ordered patterns "%n", "%t", "%%", and "%+"
    Then the ordered text result is a line-feed character, a tab character, "%", and "+"

  @RENDER-UNKNOWN-AND-TRAILING-PERCENT
  Scenario: Keep unknown and unfinished directive text observable
    Given a complete UTC date-time "2040-02-29 16:05:09"
    When I request an ordered text result for patterns "before%?after", "end%", and "%<nope>"
    Then the ordered text result is "before?after", "end", and "%<nope>"

  @RENDER-OO-ZERO-PATTERNS @RENDER-OO-ONE-PATTERN @RENDER-OO-SCALAR-AND-LIST
  Scenario: Object rendering has zero one and many pattern requests
    Given a complete UTC date-time "2040-02-29 16:05:09"
    When I request zero patterns
    Then the text result is empty text and the ordered text result is an empty collection
    When I request one pattern "%Y"
    Then the text result is "2040" and the ordered text result is exactly one item "2040"
    When I request the ordered patterns "%Y", "%m", and "%d"
    Then the text result is empty text and the ordered text result is "2040", "02", and "29"
