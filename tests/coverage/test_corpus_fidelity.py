"""Prevent coverage tooling from masking changed public behavior."""
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('corpus', ROOT / 'tools/coverage-corpus/collect.py')
corpus = importlib.util.module_from_spec(spec)
spec.loader.exec_module(corpus)


class FidelityTests(unittest.TestCase):
    def test_only_eval_attribution_of_known_warning_is_normalized(self):
        plain = corpus.DEPRECATION + ' at (eval 42) line 1.\n'
        covered = corpus.DEPRECATION + ' at (eval 71)[/tmp/probe.pl:108] line 1.\n'
        for field in ['warnings', 'load_warnings', 'configuration_warnings', 'setup_warnings']:
            self.assertEqual(corpus.normalize_deprecation_sites({field: [plain]}),
                             corpus.normalize_deprecation_sites({field: [covered]}))
            self.assertNotEqual(corpus.normalize_deprecation_sites({field: [plain]}),
                                corpus.normalize_deprecation_sites({field: [covered, covered]}))
            self.assertNotEqual(corpus.normalize_deprecation_sites({field: ['failure at (eval 1) line 1.\n']}),
                                corpus.normalize_deprecation_sites({field: ['failure at (eval 2) line 1.\n']}))
        for field in ['return', 'exception', 'stdout']:
            self.assertNotEqual(corpus.normalize_deprecation_sites({field: plain}),
                                corpus.normalize_deprecation_sites({field: covered}))

    def test_changed_warning_message_count_and_line_are_rejected(self):
        warning = corpus.DEPRECATION + ' at (eval 42) line 1.\n'
        base = corpus.normalize_deprecation_sites({'warnings': [warning]})
        for warnings in [[], [warning, warning], [warning.replace('7.00', '8.00')],
                         [warning.replace('line 1', 'line 2')]]:
            self.assertNotEqual(base, corpus.normalize_deprecation_sites({'warnings': warnings}))

    def test_other_diagnostics_and_results_remain_exact(self):
        self.assertNotEqual(corpus.normalize_deprecation_sites({'warnings': ['failure at (eval 1) line 1.\n']}),
                            corpus.normalize_deprecation_sites({'warnings': ['failure at (eval 2) line 1.\n']}))
        self.assertNotEqual(corpus.normalize_deprecation_sites({'warnings': [], 'return': None}),
                            corpus.normalize_deprecation_sites({'warnings': [], 'return': ''}))


if __name__ == '__main__':
    unittest.main()
