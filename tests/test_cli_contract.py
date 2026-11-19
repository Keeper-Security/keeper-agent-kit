"""Validate documented KSM syntax without invoking command callbacks/network."""

import inspect
from pathlib import Path
import shlex
import tempfile
import unittest

import click
from keeper_secrets_manager_cli.__main__ import cli
from keeper_secrets_manager_core import SecretsManager
from keeper_secrets_manager_core.dto.dtos import Record

ROOT = Path(__file__).resolve().parents[1]


def parse_only(argv):
    """Parse the real Click tree; never invoke callbacks or bind a device."""
    command = cli
    parent = None
    while True:
        context = command.make_context(command.name, list(argv), parent=parent)
        if not isinstance(command, click.Group):
            return context.params
        next_args = list(context._protected_args) + list(context.args)
        if not next_args:
            return context.params
        command = command.get_command(context, next_args[0])
        if command is None:
            raise ValueError('Unknown subcommand')
        argv, parent = next_args[1:], context


class CliContractTests(unittest.TestCase):
    def test_packaged_ksm_commands_parse(self):
        import re
        checked = 0
        with tempfile.TemporaryDirectory() as directory:
            template = Path(directory) / 'config.tmpl'
            template.write_text('synthetic configuration, no secrets')
            for path in (ROOT / 'plugins').rglob('*.md'):
                if 'node_modules' in path.parts:
                    continue
                for block in re.findall(r'^```bash\n(.*?)^```', path.read_text(), re.M | re.S):
                    block = block.replace('\\\n', ' ')
                    for line in block.splitlines():
                        if line.lstrip().startswith('#') or not re.search(r'\bksm\s', line):
                            continue
                        argv = shlex.split(line.split('ksm ', 1)[1].rstrip(')'))
                        if argv[0] == 'interpolate':
                            argv[argv.index('config.tmpl')] = str(template)
                        with self.subTest(path=path, command=line):
                            parse_only(argv)
                        checked += 1
        self.assertGreater(checked, 10)

    def test_reject_old_flags(self):
        for args in (['profile', 'init', '--profile', 'dev'],
                     ['interpolate', '--in-file', 'a'],
                     ['sync', '--type', 'aws_sm'],
                     ['folder', 'get', '-u', 'uid']):
            with self.subTest(args=args), self.assertRaises((click.ClickException, ValueError)):
                parse_only(args)

    def test_python_example_sdk_contract(self):
        inspect.signature(SecretsManager.get_secrets).bind(object(), ['exact-test-uid'])
        inspect.signature(Record.field).bind(object(), 'password', single=True)


if __name__ == '__main__':
    unittest.main()
