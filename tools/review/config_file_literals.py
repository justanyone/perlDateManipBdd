#!/usr/bin/env python3
"""Check config-file research against explicit split portable scenarios."""

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / "docs/research/config-files-family"
OBSERVATIONS = json.loads((FAMILY / "observations.json").read_text())
CASES = {
    row["case_id"]: row
    for row in json.loads((FAMILY / "cases.json").read_text())["cases"]
}
MAPPING = json.loads((FAMILY / "feature-map.json").read_text())
MAPPED = {row["case_id"]: row for row in MAPPING["cases"]}
OBSERVED = {row["case_id"]: row for row in OBSERVATIONS["observations"]}
CANONICAL = {
    row["id"]
    for row in json.loads(
        (ROOT / "docs/research/api/contract-map.json").read_text()
    )["operations"]
}

assert len(CASES) == len(OBSERVED) == len(MAPPED) == 36
for path, digest in OBSERVATIONS["sha256"].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path

feature_text = {
    path: (ROOT / path).read_text() for path in MAPPING["features"]
}
assert set(feature_text) == {
    "spec/drafts/config-files/loading.feature",
    "spec/drafts/config-files/functional-loading.feature",
}
listed_case_ids = [
    case_id
    for case_ids in MAPPING["features"].values()
    for case_id in case_ids
]
assert len(listed_case_ids) == len(set(listed_case_ids)) == 36
assert set(listed_case_ids) == set(CASES)

scenario_blocks = {}
scenario_titles = {}
for path, text in feature_text.items():
    assert "Scenario Outline:" not in text
    assert "Examples:" not in text
    assert "not requested" not in text and "not applicable" not in text
    assert not re.search(r"<[^>]+>", text)
    assert "/home/" not in text and "Obj.pm line" not in text
    expected_profile = "object" if path.endswith("/loading.feature") else "functional-current"
    assert text.count(f'Given the "{expected_profile}" public configuration profile') == 1
    starts = list(re.finditer(r"(?m)^  Scenario: (.+) \[(CF-[^]]+)\]$", text))
    assert len(starts) == 18, path
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        case_id = match.group(2)
        assert case_id not in scenario_blocks
        scenario_titles[case_id] = match.group(1)
        scenario_blocks[case_id] = (path, text[match.start():end])

assert set(scenario_blocks) == set(CASES)

for case_id, case in CASES.items():
    wrapper = OBSERVED[case_id]
    observed = wrapper["observation"]
    mapped = MAPPED[case_id]
    path, block = scenario_blocks[case_id]
    is_object = case["profile"] == "oo"

    assert case_id == wrapper["case_id"] == mapped["case_id"]
    assert wrapper["repeatable"] and wrapper["process_stderr"] == ""
    assert observed["request"] == case and observed["case_id"] == case_id
    assert observed["exception"] is None and observed["backend_version"] == "7.00"
    assert observed["later_warnings"] == [] and observed["call_stdout"] == ""
    assert mapped["operation_id"] == "config.apply-settings"
    assert set(mapped["contract_ids"]) <= CANONICAL
    assert mapped["profile"] == case["profile"]
    assert mapped["feature"] == path
    assert case_id in MAPPING["features"][path]
    assert mapped["scenario"] == scenario_titles[case_id]
    assert mapped["observation_case"] == case_id
    assert mapped["queries_date_order"] is is_object

    files = {
        name: json.loads(body)
        for name, body in re.findall(
            r'(?:Given|And) file "([^"]+)" contains.*?\n      """\n      (.*?)\n      """',
            block,
            re.S,
        )
    }
    settings = []
    for line in block.splitlines():
        if not line.strip().startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells[0] != "setting":
            settings.append([cells[0], "" if cells[1] == "[empty text]" else cells[1]])
    result = re.search(
        r'Then the parsed civil date-time is "([^"]+)"', block
    ).group(1)

    assert files == case["files"], case_id
    assert settings == case["settings"], case_id
    assert case["parse_text"] == "04/05/2040"
    assert result == mapped["result"], case_id
    assert observed["value"] == result.replace("-", "").replace(" ", ""), case_id
    assert bool(observed["configuration_exception"]) == bool(
        mapped["configuration_exception"]
    ), case_id
    assert len(observed["configuration_warnings"]) == int(
        bool(mapped["configuration_warning"])
    ), case_id
    if mapped["configuration_exception"]:
        assert "not an assignment" in observed["configuration_exception"]
        assert "configuration_return" not in observed
    else:
        assert observed["configuration_return"] == (None if is_object else "")
    warning_needles = {
        "missing configuration file": "file doesn't exist: missing.cnf",
        "unknown configuration variable": "invalid config variable: notasetting",
        "unknown configuration section": "unknown section created: fixturenotes",
    }
    if mapped["configuration_warning"]:
        assert warning_needles[mapped["configuration_warning"]] in observed[
            "configuration_warnings"
        ][0]

    query = re.search(r"date-order query returns JSON string (.+)$", block, re.M)
    if is_object:
        assert query is not None
        assert json.loads(query.group(1)) == observed["date_order"], case_id
        assert mapped["configuration_query_binding"] == "Date::Manip::Date::get_config"
        assert mapped["parse_binding"] == "Date::Manip::Date::parse"
        assert mapped["binding"] == "Date::Manip::Date::config"
        assert observed["setup_return"] is None and observed["setup_error"] == ""
        assert observed["error_after_configuration"] == ""
        assert observed["parse_status"] == 0
        assert observed["parse_error"] == observed["error_after_value"] == ""
    else:
        assert query is None and "date-order query" not in block
        assert mapped["configuration_query_binding"] is None
        assert mapped["parse_binding"] == "Date::Manip::DM6::ParseDate"
        assert mapped["binding"] == "Date::Manip::DM6::Date_Init"
        assert "date_order" not in observed
        assert observed["setup_return"] == ""

print(json.dumps({
    "file_configuration_requests_checked": 36,
    "object_cases_with_date_order_query": 18,
    "functional_cases_without_date_order_query": 18,
    "approved_specification_cases": 0,
}, indent=2))
