import json
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from hashlib import sha256
from pathlib import Path


SCRIPT = Path(__file__).parents[2] / "tools/automation/codex_quota_watchdog.py"
THREAD_ID = "thread-test"
GOAL_ID = "goal-test"
CWD = "/workspace/test"


def make_databases(home: Path, status="active", *, thread_id=THREAD_ID,
                   goal_id=GOAL_ID, cwd=CWD, archived=0):
    with sqlite3.connect(home / "goals_1.sqlite") as database:
        database.execute(
            "CREATE TABLE thread_goals (status TEXT, goal_id TEXT, thread_id TEXT)"
        )
        database.execute(
            "INSERT INTO thread_goals VALUES (?, ?, ?)", (status, goal_id, thread_id)
        )
    with sqlite3.connect(home / "state_5.sqlite") as database:
        database.execute("CREATE TABLE threads (id TEXT, cwd TEXT, archived INTEGER)")
        database.execute("INSERT INTO threads VALUES (?, ?, ?)", (thread_id, cwd, archived))


class CodexQuotaWatchdogTests(unittest.TestCase):
    def run_watchdog(self, home, *extra):
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--codex-home", str(home),
             "--thread-id", THREAD_ID, "--goal-id", GOAL_ID,
             "--expected-cwd", CWD, *extra],
            check=False, capture_output=True, text=True,
        )

    def assert_report(self, result, returncode, decision, reason, goal_status=None):
        self.assertEqual(result.returncode, returncode, result.stderr)
        expected = {"schema_version": 1, "decision": decision, "reason": reason}
        if goal_status is not None:
            expected["goal_status"] = goal_status
        self.assertEqual(json.loads(result.stdout), expected)

    def test_usage_limited_is_recovery_needed(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            make_databases(home, "usage_limited")
            self.assert_report(self.run_watchdog(home), 0, "recovery_needed", "usage_limited",
                               "usage_limited")

    def test_known_nonrecoverable_statuses_need_no_action(self):
        for status in ("active", "paused", "blocked", "budget_limited", "complete"):
            with self.subTest(status=status), tempfile.TemporaryDirectory() as directory:
                home = Path(directory)
                make_databases(home, status)
                self.assert_report(self.run_watchdog(home), 0, "no_action", status, status)

    def test_unknown_status_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            make_databases(home, "mystery")
            self.assert_report(self.run_watchdog(home), 2, "error", "unknown_goal_status", "mystery")

    def test_goal_and_thread_identity_mismatches_fail_closed(self):
        cases = (({"goal_id": "another-goal"}, "goal_identity_mismatch"),
                 ({"thread_id": "another-thread"}, "goal_identity_mismatch"),
                 ({"cwd": "/different"}, "thread_identity_mismatch"),
                 ({"archived": 1}, "thread_archived"))
        for values, reason in cases:
            with self.subTest(reason=reason, values=values), tempfile.TemporaryDirectory() as directory:
                home = Path(directory)
                make_databases(home, **values)
                self.assert_report(self.run_watchdog(home), 2, "error", reason)

    def test_missing_database_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assert_report(self.run_watchdog(Path(directory)), 2, "error", "database_unavailable")

    def test_unreadable_schema_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            sqlite3.connect(home / "goals_1.sqlite").close()
            sqlite3.connect(home / "state_5.sqlite").close()
            self.assert_report(self.run_watchdog(home), 2, "error", "database_unavailable")

    def test_read_only_databases_are_unchanged(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            make_databases(home)
            databases = (home / "goals_1.sqlite", home / "state_5.sqlite")
            before = [sha256(database.read_bytes()).digest() for database in databases]
            for database in databases:
                database.chmod(0o444)
            self.assert_report(self.run_watchdog(home), 0, "no_action", "active", "active")
            after = [sha256(database.read_bytes()).digest() for database in databases]
            self.assertEqual(after, before)

    def test_duplicate_goal_rows_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            make_databases(home)
            with sqlite3.connect(home / "goals_1.sqlite") as database:
                database.execute("INSERT INTO thread_goals VALUES (?, ?, ?)",
                                 ("active", GOAL_ID, THREAD_ID))
            self.assert_report(self.run_watchdog(home), 2, "error", "goal_identity_mismatch")

    def test_pause_file_prevents_database_access(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            pause_file = home / "pause"
            pause_file.touch()
            self.assert_report(self.run_watchdog(home, "--pause-file", str(pause_file)),
                               0, "no_action", "pause_file_present")

    def test_null_archived_flag_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            make_databases(home, archived=None)
            self.assert_report(self.run_watchdog(home), 2, "error", "thread_archived")


if __name__ == "__main__":
    unittest.main()
