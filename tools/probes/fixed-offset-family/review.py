#!/usr/bin/env python3
"""Validate durable fixed-offset evidence and optionally its external corpus."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/fixed-offset-family"


def load(path: Path):
    return json.loads(path.read_text())


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_digest(directory: Path) -> str:
    value = hashlib.sha256()
    for path in sorted(item for item in directory.rglob("*") if item.is_file()):
        relative = path.relative_to(directory).as_posix().encode()
        value.update(len(relative).to_bytes(8, "big"))
        value.update(relative)
        content = path.read_bytes()
        value.update(len(content).to_bytes(8, "big"))
        value.update(content)
    return value.hexdigest()


def main() -> None:
    result = load(FAMILY / "fixed-offset-result.json")
    selected_path = FAMILY / "selected-observations.json"
    selected = load(selected_path)
    mapping = load(FAMILY / "feature-map.json")
    feature = (ROOT / mapping["feature"]).read_text()
    binding = load(FAMILY / "bindings.json")

    assert result["external_artifact_hashes"]["selected-observations.json"] == digest(selected_path)
    assert len(selected["observations"]) == len(mapping["examples"]) == 7
    assert "Date/Manip/Offset/" not in selected_path.read_text()
    assert binding["observers"][2]["pattern"] == "%Y-%m-%d %H:%M:%S %z %Z"
    feature_rows = {}
    for line in feature.splitlines():
        if line.strip().startswith("| FO-SUPPORTED-"):
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            feature_rows[cells[0]] = cells[1:]
    assert len(feature_rows) == 6
    by_id = {row["example_id"]: row for row in selected["observations"]}
    assert set(by_id) == {row["example_id"] for row in mapping["examples"]}
    for item in mapping["examples"]:
        row = by_id[item["example_id"]]
        assert item["example_id"] in feature
        assert row["input_text"].endswith(item["input_offset"])
        assert item["input_offset"] in feature
        public = row["public_result"]
        if item["outcome"] == "success":
            assert public["value_observers_called"] is True
            assert public["parsed_scalar"] == "2040022912:34:56"
            assert feature_rows[item["example_id"]] == [item["input_offset"], public["gmt_scalar"], public["formatted"]]
            assert public["error_after_parse"] == public["error_after_reads"] == ""
        else:
            assert public == {
                "error_after_parse": "[parse] Unable to determine timezone",
                "value_observers_called": False,
            }
            assert "no date value is read after the failed request" in feature

    for name, expected in result["installed_source_sha256"].items():
        if name == "Devel/Cover.pm":
            path = ROOT / "local/devel-cover-1.52/lib/perl5" / result["runtime"]["perl_archname"] / name
        else:
            path = ROOT / "local/date-manip-7.00/lib/perl5" / name
        assert digest(path) == expected, name
    for name, expected in result["probe_sha256"].items():
        assert digest(ROOT / "tools/probes/fixed-offset-family" / name) == expected, name

    if len(sys.argv) == 2:
        external = Path(sys.argv[1]).resolve()
        for name, expected in result["external_artifact_hashes"].items():
            actual = tree_digest(external / "cover_db") if name == "cover_db_tree" else digest(external / name)
            assert actual == expected, name
        summary = load(external / "summary.json")
        assert summary["entry_count"] == summary["target_offset_module_rows"] == 408
        assert summary["successful_parse_count"] == 40
        assert summary["rejected_parse_count"] == 368
        assert summary["target_offset_statement_coverage"] == {
            "covered": 3672, "total": 3672,
            "per_module_covered": 9, "per_module_total": 9,
        }
    elif len(sys.argv) != 1:
        raise SystemExit(f"usage: {sys.argv[0]} [EXTERNAL_RUN_DIRECTORY]")

    print("7 durable feature observations verified; fixed-offset provenance hashes match")


if __name__ == "__main__":
    main()
