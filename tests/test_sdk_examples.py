import contextlib
import importlib.util
import io
import traceback
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SAMPLE = ROOT / 'plugins/keeper-sdk/skills/keeper-sdk/examples/python/keeper_secret.py'
spec = importlib.util.spec_from_file_location('keeper_secret_example', SAMPLE)
sample = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sample)
CANARY = 'SYNTHETIC_SECRET_CANARY'


class Record:
    uid = 'exact-test-uid'

    def __init__(self, value=CANARY):
        self.value = value

    def field(self, name, single=False):
        assert (name, single) == ('password', True)
        return self.value


class Client:
    def __init__(self, records):
        self.records = records

    def get_secrets(self, uids):
        assert uids == ['exact-test-uid']
        return self.records


class SdkExampleTests(unittest.TestCase):
    def test_exact_filter_and_no_output(self):
        stdout, stderr = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            value = sample.read_password('synthetic-config', 'exact-test-uid', client_factory=lambda path: Client([Record()]))
        self.assertEqual(value, CANARY)
        self.assertEqual(stdout.getvalue(), '')
        self.assertEqual(stderr.getvalue(), '')

    def test_missing_ambiguous_wrong_or_empty(self):
        wrong = Record()
        wrong.uid = 'wrong'
        for records in ([], [Record(), Record()], [wrong], [Record(None)], [Record('')]):
            with self.subTest(records=records), self.assertRaises(sample.SecretAccessError):
                sample.read_password('config', 'exact-test-uid', client_factory=lambda path: Client(records))

    def test_sdk_failure_is_sanitized(self):
        def fail(path):
            raise RuntimeError(CANARY)
        with self.assertRaises(sample.SecretAccessError) as result:
            sample.read_password('config', 'exact-test-uid', client_factory=fail)
        self.assertNotIn(CANARY, str(result.exception))
        self.assertTrue(result.exception.__suppress_context__)
        self.assertNotIn(CANARY, ''.join(traceback.format_exception(result.exception)))

    def test_invalid_configuration(self):
        with self.assertRaises(sample.SecretAccessError):
            sample.read_password('', 'exact-test-uid')


if __name__ == '__main__':
    unittest.main()
