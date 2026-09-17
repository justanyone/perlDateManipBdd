#!/usr/bin/env python3
"""Read-only detection for a Codex goal paused by a usage limit.

This program deliberately has no resume, launch, or database-update capability.
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 1
RECOVERABLE_STATUS = "usage_limited"
NO_ACTION_STATUSES = {"active", "paused", "blocked", "budget_limited", "complete"}


def read_rows(database: Path, query: str, parameters: tuple[str, ...]) -> list[sqlite3.Row]:
    """Run one query against an existing SQLite database without write access."""
    if not database.is_file():
        raise RuntimeError("required database is missing")
    uri = f"{database.resolve().as_uri()}?mode=ro"
    try:
        connection = sqlite3.connect(uri, uri=True)
        connection.row_factory = sqlite3.Row
        try:
            connection.execute("PRAGMA query_only = ON")
            return connection.execute(query, parameters).fetchall()
        finally:
            connection.close()
    except sqlite3.Error as error:
        raise RuntimeError("database cannot be read") from error


def report(decision: str, reason: str, goal_status: str | None = None) -> dict[str, Any]:
    result: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "decision": decision,
        "reason": reason,
    }
    if goal_status is not None:
        result["goal_status"] = goal_status
    return result


def inspect(args: argparse.Namespace) -> tuple[dict[str, Any], int]:
    if args.pause_file is not None and args.pause_file.exists():
        return report("no_action", "pause_file_present"), 0

    goals_db = args.codex_home / "goals_1.sqlite"
    state_db = args.codex_home / "state_5.sqlite"
    try:
        goal_rows = read_rows(
            goals_db,
            "SELECT status, goal_id, thread_id FROM thread_goals "
            "WHERE goal_id = ? AND thread_id = ?",
            (args.goal_id, args.thread_id),
        )
        thread_rows = read_rows(
            state_db,
            "SELECT id, cwd, archived FROM threads WHERE id = ?",
            (args.thread_id,),
        )
    except RuntimeError:
        return report("error", "database_unavailable"), 2

    if len(goal_rows) != 1:
        return report("error", "goal_identity_mismatch"), 2
    if len(thread_rows) != 1:
        return report("error", "thread_identity_mismatch"), 2

    goal = goal_rows[0]
    thread = thread_rows[0]
    if goal["goal_id"] != args.goal_id or goal["thread_id"] != args.thread_id:
        return report("error", "goal_identity_mismatch"), 2
    if thread["id"] != args.thread_id or thread["cwd"] != args.expected_cwd:
        return report("error", "thread_identity_mismatch"), 2
    if thread["archived"] != 0:
        return report("error", "thread_archived"), 2

    status = goal["status"]
    if status == RECOVERABLE_STATUS:
        return report("recovery_needed", RECOVERABLE_STATUS, status), 0
    if status in NO_ACTION_STATUSES:
        return report("no_action", status, status), 0
    return report("error", "unknown_goal_status", str(status)), 2


def write_report(result: dict[str, Any]) -> None:
    encoded = json.dumps(result, separators=(",", ":"), sort_keys=True)
    print(encoded)


def parse_arguments(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--codex-home", type=Path, required=True)
    parser.add_argument("--thread-id", required=True)
    parser.add_argument("--goal-id", required=True)
    parser.add_argument("--expected-cwd", required=True)
    parser.add_argument("--pause-file", type=Path)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_arguments(sys.argv[1:] if argv is None else argv)
    result, exit_code = inspect(args)
    write_report(result)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
