import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('validator', ROOT / 'scripts/validate_plugins.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class ValidationTests(unittest.TestCase):
    def test_current_tree(self):
        self.assertEqual(validator.validate(), [])

    def test_yaml_duplicate_or_missing_body(self):
        for text in ('name: x', '---\nname: x\n---', '---\nname: x\nname: y\n---\nbody'):
            with self.subTest(text=text), self.assertRaises(ValueError):
                validator.frontmatter(text)

    def test_regression_examples(self):
        for command in ('ksm profile init --token bad', 'ksm interpolate --in-file a --out-file b',
                        'keeper --batch-mode api-server', 'pam rotation create --record uid',
                        'tmux capture-pane -p', 'source rendered.env', 'echo "$API_KEY"'):
            with self.subTest(command=command):
                self.assertTrue(validator.unsafe_examples(f'```bash\n{command}\n```\n'))
        self.assertEqual(validator.unsafe_examples("```bash\nAPI_KEY='keeper://<UID>/field/password' ksm exec -- ./app\n```\n"), [])

    def test_packaging_failures(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'kit'
            shutil.copytree(ROOT, root, ignore=shutil.ignore_patterns('.git', 'node_modules', 'dist', '__pycache__', '.venv'))
            safety = root / 'plugins/keeper-mcp/skills/keeper-mcp/references/safety.md'
            safety.write_text('stale safety')
            skill = root / 'plugins/keeper-mcp/skills/keeper-mcp/SKILL.md'
            skill.write_text(skill.read_text() + '\n[missing](references/not-found.md)\n')
            errors = validator.validate(root)
            self.assertTrue(any('out of sync' in error for error in errors))
            self.assertTrue(any('Broken relative link' in error for error in errors))


if __name__ == '__main__':
    unittest.main()
