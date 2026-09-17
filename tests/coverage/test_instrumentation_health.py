"""Regression check for Devel::Cover logical-branch instrumentation."""
import json
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / "tools/coverage-healthcheck/run.py"


class CoverageInstrumentationHealthTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        process = subprocess.run(["python3", str(RUNNER)], cwd=ROOT,
                                 capture_output=True, text=True, timeout=60)
        try:
            cls.report = json.loads(process.stdout)
        except json.JSONDecodeError as error:
            raise AssertionError(f"health check did not emit JSON: {process.stdout!r}") from error
        if cls.report.get("status") == "skipped":
            raise unittest.SkipTest(cls.report["reason"])
        if process.returncode or process.stderr or cls.report.get("status") != "passed":
            raise AssertionError(
                f"coverage health check failed: rc={process.returncode}, "
                f"stderr={process.stderr!r}, report={cls.report!r}")

    def test_branch_only_mode_is_a_zero_hit_control(self):
        self.assertEqual(self.report["branch_only_zero_hit_control"],
                         {"simple": [0, 0], "chain": [0, 0]})

    def test_condition_enabled_mode_records_both_logical_branch_outcomes(self):
        counts = self.report["condition_enabled_branch_counts"]
        self.assertEqual(counts, {"simple": [1, 1], "chain": [2, 1]})
        self.assertTrue(all(hit > 0 for outcomes in counts.values() for hit in outcomes))

    def test_instrumentation_preserves_the_frozen_fixture_result(self):
        self.assertEqual(self.report["fixture_stdout"],
                         "rejected|accepted|rejected|accepted|accepted")
        self.assertEqual(self.report["runtime"]["devel_cover_version"], "1.52")
        self.assertEqual(self.report["environment"]["inherited_environment"], False)


if __name__ == "__main__":
    unittest.main()
