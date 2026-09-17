#!/usr/bin/env python3
"""Check the pinned Devel::Cover logical-branch collection mode."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
PERL = Path("/usr/bin/perl")
COVER_LIB = ROOT / "local/devel-cover-1.52/lib/perl5"
FIXTURE = HERE / "fixture.pl"
EXTRACTOR = HERE / "extract-branches.pl"
EXPECTED_STDOUT = b"rejected|accepted|rejected|accepted|accepted\n"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(command: list[str], *, cwd: Path, environment: dict[str, str]) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(command, cwd=cwd, env=environment, capture_output=True,
                          check=False, timeout=30)


def base_environment(perl5lib: str | None = None) -> dict[str, str]:
    environment = {
        "PATH": "/usr/bin:/bin",
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "TZ": "Etc/UTC",
    }
    if perl5lib is not None:
        environment["PERL5LIB"] = perl5lib
    return environment


def perl_value(option: str) -> str:
    result = execute([str(PERL), "-MConfig", "-e", f"print $Config::Config{{{option}}}"],
                     cwd=ROOT, environment=base_environment())
    if result.returncode or result.stderr:
        raise RuntimeError(f"cannot read Perl {option}: {result.stderr.decode(errors='replace')}")
    return result.stdout.decode("ascii")


def availability() -> tuple[dict[str, str] | None, str | None]:
    if not PERL.is_file():
        return None, f"pinned Perl executable is absent: {PERL}"
    archname = perl_value("archname")
    version = perl_value("version")
    if version != "5.40.1":
        raise RuntimeError(f"expected Perl 5.40.1, found {version}")
    cover_arch = COVER_LIB / archname
    cover_module = cover_arch / "Devel/Cover.pm"
    if not cover_module.is_file():
        return None, f"pinned Devel::Cover module is absent: {cover_module}"
    match = re.search(rb"\$VERSION\s*=\s*['\"]([^'\"]+)", cover_module.read_bytes())
    if not match or match.group(1) != b"1.52":
        found = match.group(1).decode(errors="replace") if match else "unreadable"
        raise RuntimeError(f"expected Devel::Cover 1.52, found {found}")
    perl5lib = f"{cover_arch}:{COVER_LIB}"
    return {"archname": archname, "perl_version": version,
            "devel_cover_version": "1.52", "perl5lib": perl5lib}, None


def marker_lines() -> dict[str, int]:
    markers: dict[str, int] = {}
    for number, line in enumerate(FIXTURE.read_text().splitlines(), 1):
        for name in ("simple", "chain"):
            if f"# healthcheck-{name}" in line:
                if name in markers:
                    raise RuntimeError(f"duplicate fixture branch marker: {name}")
                markers[name] = number
    if set(markers) != {"simple", "chain"}:
        raise RuntimeError("fixture branch markers are missing or duplicated")
    return markers


def normalized_command(criteria: list[str], database_name: str) -> list[str]:
    option = ",".join(["-MDevel::Cover=-db", f"<temporary>/{database_name}",
                       "-coverage", *criteria, "-silent", "1", "-select", str(FIXTURE)])
    return [str(PERL), option, str(FIXTURE)]


def collect(criteria: list[str], database: Path, runtime: dict[str, str], work: Path) -> dict:
    option = ",".join(["-MDevel::Cover=-db", str(database), "-coverage", *criteria,
                       "-silent", "1", "-select", str(FIXTURE)])
    command = [str(PERL), option, str(FIXTURE)]
    process = execute(command, cwd=work, environment=base_environment(runtime["perl5lib"]))
    if process.returncode:
        raise RuntimeError(f"instrumented fixture failed ({criteria}): "
                           f"{process.stderr.decode(errors='replace')}")
    if process.stderr:
        raise RuntimeError(f"instrumented fixture wrote stderr ({criteria}): "
                           f"{process.stderr.decode(errors='replace')}")
    extract = execute([str(PERL), str(EXTRACTOR), str(database), str(FIXTURE)],
                      cwd=work, environment=base_environment(runtime["perl5lib"]))
    if extract.returncode or extract.stderr:
        raise RuntimeError("branch extraction failed: " + extract.stderr.decode(errors="replace"))
    return {"stdout": process.stdout, "rows": json.loads(extract.stdout)["branches"]}


def main() -> int:
    try:
        runtime, reason = availability()
        if reason:
            print(json.dumps({"schema_version": 1, "status": "skipped", "reason": reason},
                             sort_keys=True))
            return 0
        assert runtime is not None
        markers = marker_lines()
        with tempfile.TemporaryDirectory(prefix="date-manip-cover-health-") as directory:
            temporary = Path(directory)
            plain_work = temporary / "plain-work"
            branch_work = temporary / "branch-work"
            condition_work = temporary / "condition-work"
            plain_work.mkdir()
            branch_work.mkdir()
            condition_work.mkdir()
            plain = execute([str(PERL), str(FIXTURE)], cwd=plain_work,
                            environment=base_environment())
            if plain.returncode or plain.stderr or plain.stdout != EXPECTED_STDOUT:
                raise RuntimeError("plain fixture output does not match its frozen expected value")
            branch_only = collect(["statement", "branch"], temporary / "branch-db",
                                  runtime, branch_work)
            corrected = collect(["statement", "branch", "condition"],
                                temporary / "condition-db", runtime, condition_work)

        def targets(rows: list[dict]) -> dict[str, list[int]]:
            by_line = {row["line"]: row["outcomes"] for row in rows}
            missing = [name for name, line in markers.items() if line not in by_line]
            if missing:
                raise RuntimeError("missing logical branch criteria: " + ", ".join(missing))
            return {name: by_line[line] for name, line in markers.items()}

        branch_targets = targets(branch_only["rows"])
        corrected_targets = targets(corrected["rows"])
        if branch_only["stdout"] != plain.stdout or corrected["stdout"] != plain.stdout:
            raise RuntimeError("coverage instrumentation changed fixture stdout")
        if branch_targets != {"simple": [0, 0], "chain": [0, 0]}:
            raise RuntimeError(f"branch-only zero-hit control changed: {branch_targets}")
        expected_corrected = {"simple": [1, 1], "chain": [2, 1]}
        if corrected_targets != expected_corrected:
            raise RuntimeError("condition-enabled logical branch counters are not trustworthy: "
                               f"expected {expected_corrected}, got {corrected_targets}")

        report = {
            "schema_version": 1,
            "status": "passed",
            "runtime": {key: value for key, value in runtime.items() if key != "perl5lib"},
            "environment": {**base_environment("<pinned Devel::Cover library paths>"),
                            "inherited_environment": False},
            "fixture_stdout": plain.stdout.decode("ascii").rstrip("\n"),
            "fixture_markers": markers,
            "branch_only_zero_hit_control": branch_targets,
            "condition_enabled_branch_counts": corrected_targets,
            "commands": {
                "branch_only": normalized_command(["statement", "branch"], "branch-db"),
                "condition_enabled": normalized_command(
                    ["statement", "branch", "condition"], "condition-db"),
            },
            "sha256": {str(path.relative_to(ROOT)): digest(path)
                       for path in (FIXTURE, EXTRACTOR, Path(__file__).resolve())},
        }
        print(json.dumps(report, indent=2, sort_keys=True))
        return 0
    except Exception as error:
        print(json.dumps({"schema_version": 1, "status": "failed", "error": str(error)},
                         sort_keys=True))
        return 1


if __name__ == "__main__":
    sys.exit(main())
