# Codex quota watchdog

`tools/automation/codex_quota_watchdog.py` is a read-only detector for one exact
Codex goal and thread. It has no resume, launch, database-update, or network
capability. In the current VS Code stdio topology, there is no managed control
socket through which a timer could safely resume a session. The watchdog therefore
reports detection only; `recovery_needed` is a signal for an operator or a future
supported controller, not an instruction the script can act on.

The script opens only these databases below `--codex-home`, using SQLite read-only
mode and `PRAGMA query_only`:

- `goals_1.sqlite`: `thread_goals(status, goal_id, thread_id)`
- `state_5.sqlite`: `threads(id, cwd, archived)`

It requires exactly one row matching both supplied goal and thread IDs, exactly one
matching thread row, an exact `cwd` match, and an unarchived thread. `usage_limited`
emits `{"decision":"recovery_needed",...}`. `active`, `paused`, `blocked`,
`budget_limited`, and `complete` emit `no_action`. Missing rows, identity conflicts,
archived threads, unreadable databases, and unknown states emit `error` with exit
status 2. This fails closed and never infers whether quota has become available.

For example:

```sh
python3 tools/automation/codex_quota_watchdog.py \
  --codex-home /path/to/codex-home \
  --thread-id YOUR_THREAD_ID \
  --goal-id YOUR_GOAL_ID \
  --expected-cwd "$(pwd)"
```

Each invocation writes one compact JSON object to standard output. A systemd unit
records that output in the user journal. `--pause-file PATH` makes the detector
return `no_action` before accessing the databases whenever that file exists. The
example uses `/path/to/perlDateManipBdd/.automation/watchdog.pause`, a persistent
repository-local marker that must be ignored by Git.

The example user-unit files in [systemd](systemd) schedule the detector every ten
minutes. They deliberately contain placeholders, no local IDs, and no `ExecStartPost`
or other resume command. Copy them into a user systemd configuration only after
replacing every `/path/to/...` and `REPLACE_...` value for the intended session.

Run its isolated tests with:

```sh
python3 -m unittest tests/automation/test_codex_quota_watchdog.py
```

## Installed monitor

On 2026-09-17 the coordinator installed and enabled the user timer
`perldatemanipbdd-quota-watchdog.timer` for this repository's current goal.
The configured service and timer are in the local user's systemd configuration;
their session identifiers are not part of the portable specification. Ten isolated
tests passed and a live service invocation reported `no_action` / `active`.

Inspect scheduling and reports:

```sh
systemctl --user list-timers perldatemanipbdd-quota-watchdog.timer
journalctl --user -u perldatemanipbdd-quota-watchdog.service -n 20
```

Stop the monitor:

```sh
systemctl --user disable --now perldatemanipbdd-quota-watchdog.timer
```

The timer runs while the machine and user service manager are running. It starts
shortly after activation, then every ten minutes. It does not wake a suspended or
powered-off computer. No model calls or paid credits are used. SQLite filenames
and status spellings are specific to the inspected Codex installation; an
incompatible upgrade produces an error rather than an attempted restart.

Goal mode drives the work while available. If usage limits stop it, this monitor
only records that condition. Continue the goal through the existing Codex session
after quota becomes available; use [the checkpoint](checkpoint.md) to resume the
next unfinished batch. Do not launch a competing writer or edit Codex's databases.
