@draft @recurrence @source-binding @perl-binding @reference-observed @excluded-from-portable-handoff
Feature: Preserve the Perl diagnostic for an interrupted impossible recurrence lookup
  This binding-only scenario records the exact diagnostic from the public Perl
  call. The portable disputed scenario records only that the call does not
  complete and returns neither public result value.

  Background:
    Given the named recurrence fixture "utc-working-week-2040" has:
      | setting                 | value                       |
      | input language          | English                     |
      | time zone               | Etc/UTC                     |
      | reference clock         | 2040-02-28 10:20:30         |
      | numeric date ordering   | month then day              |
      | omitted time            | midnight                    |
      | first day of week       | Monday                      |
      | first week rule         | week containing January 4   |
      | working days            | Monday through Friday       |
      | working hours           | 09:00 through 17:00         |
      | holidays and events     | none                        |

  @RECUR-BIND-MAX-ATTEMPTS-DIAGNOSTIC @compatibility @disputed
  Scenario: The Perl binding reports its exact diagnostic for the impossible February lookup
    Given public operation "recur.next-occurrence" with maximum recurrence attempts setting 1
    And a recurrence with frequency text "1*2:0:30:0:0:0" is anchored at "2040-02-01 00:00:00" in "Etc/UTC"
    When I request the next event through the Perl binding
    Then the call raises a diagnostic containing "Can't use an undefined value as an ARRAY reference"
    And neither an event return nor a lookup-error return exists
