import importlib.util
import io
import contextlib
import json
from pathlib import Path
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('upstream', ROOT / 'scripts/check_upstream.py')
upstream = importlib.util.module_from_spec(spec)
spec.loader.exec_module(upstream)


class UpstreamTests(unittest.TestCase):
    def test_normalization(self):
        self.assertEqual(upstream.normalize('https://docs.keeper.io/example.md#section'), '/example')
        self.assertEqual(upstream.normalize('https://docs.keeper.io/example/'), '/example')

    def test_network_failure_is_reported_without_writes(self):
        with patch.object(upstream, 'get', side_effect=RuntimeError('synthetic-network-error')):
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                self.assertEqual(upstream.main(), 1)
            self.assertIn('index unavailable', stderr.getvalue())
            self.assertNotIn('synthetic-network-error', stderr.getvalue())

    def test_package_drift_is_review_only(self):
        def fake_get(url):
            if url.endswith('llms.txt'):
                return ''
            return json.dumps({'info': {'version': '99.0.0'}})
        stdout = io.StringIO()
        with patch.object(upstream, 'get', side_effect=fake_get), contextlib.redirect_stdout(stdout):
            self.assertEqual(upstream.main(), 1)
        self.assertIn('upstream latest 99.0.0', stdout.getvalue())
        self.assertIn('no files', stdout.getvalue())


if __name__ == '__main__':
    unittest.main()
