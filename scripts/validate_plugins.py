"""Offline package, Markdown-link, safety, and version validation."""

import argparse
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

import yaml

ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r'\[[^\]\n]*\]\(([^\s)]+)(?:\s+"[^"]*")?\)')
FENCE = re.compile(r'^```([^\n]*)\n(.*?)^```\s*$', re.M | re.S)
NAME = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')


class UniqueLoader(yaml.SafeLoader):
    pass


def unique_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in result:
            raise ValueError(f'Duplicate YAML key: {key}')
        result[key] = loader.construct_object(value_node, deep=deep)
    return result


UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def frontmatter(text):
    parts = text.split('---', 2)
    if len(parts) != 3 or parts[0].strip():
        raise ValueError('Expected opening and closing YAML frontmatter')
    fields = yaml.load(parts[1], Loader=UniqueLoader)
    if not isinstance(fields, dict) or not parts[2].strip():
        raise ValueError('Expected frontmatter mapping and nonempty body')
    return fields


def unsafe_examples(text):
    """Fail known dangerous examples, not prose explaining what to avoid.

    This regression lint is not a complete secret scanner or agent evaluation.
    """
    errors = []
    for language, block in FENCE.findall(text):
        if not language.strip():
            errors.append('Code fence needs a language')
        for line in block.splitlines():
            command = line.strip()
            if command.startswith('#'):
                continue
            patterns = {
                'credential in command arguments': r'--(?:password|token)\b|--field\s+["\']?password=',
                'shell evaluation of secret output': r'\b(?:eval|source)\s|bash\s+-c\s+["\']echo\b',
                'captured secret or authenticated scrollback': r'tmux.*(?:capture-pane|send-keys)|\b(?:echo|printenv)\s+.*\$(?:\{|[A-Z_])',
                'disabled TLS verification': r'--skip-ssl-verify|verify_ssl_certs\s*=\s*False',
                'outdated KSM flags': r'ksm.*(?:--in-file|--out-file|--config-file|--profile\s|--type\s+(?:aws_sm|azure_kv|generic_http))',
                'unsupported Commander startup': r'keeper.*(?:\bapi-server\b|--commands-file)',
                'invented PAM rotation creation': r'pam\s+rotation\s+create\b',
            }
            for label, pattern in patterns.items():
                if re.search(pattern, command):
                    errors.append(label)
    return errors


def validate(root=ROOT):
    errors = []

    def fail(path, message):
        errors.append(f'{path.relative_to(root)}: {message}')

    def read_json(path):
        try:
            return json.loads(path.read_text())
        except (OSError, ValueError) as exc:
            fail(path, f'Invalid/missing JSON: {exc}')
            return {}

    version_path = root / 'version.txt'
    version = version_path.read_text().strip()
    if not re.fullmatch(r'\d+\.\d+\.\d+', version):
        fail(version_path, 'Expected semver')
    release = read_json(root / '.release-please-manifest.json')
    if release.get('.') != version:
        fail(root / '.release-please-manifest.json', 'Version differs from version.txt')
    release_config = read_json(root / 'release-please-config.json')
    extras = release_config.get('packages', {}).get('.', {}).get('extra-files', [])
    for host in ('.claude-plugin', '.cursor-plugin'):
        if not any(entry.get('path') == f'plugins/**/{host}/plugin.json' and entry.get('glob') for entry in extras):
            fail(root / 'release-please-config.json', f'Missing version glob for {host}')
    for path in list((root / '.github/workflows').glob('*.yml')) + [root / '.pre-commit-config.yaml', root / 'Taskfile.yaml']:
        try:
            data = yaml.load(path.read_text(), Loader=UniqueLoader)
            if not isinstance(data, dict):
                fail(path, 'Expected YAML mapping')
        except (ValueError, yaml.YAMLError) as exc:
            fail(path, f'Invalid YAML: {exc}')
    safety = (root / 'docs/safety.md').read_text()
    plugins = sorted(path for path in (root / 'plugins').iterdir() if path.is_dir())
    if not plugins:
        errors.append('No plugins found')
    plugin_names = {path.name for path in plugins}
    for plugin in plugins:
        manifests = []
        for host in ('.claude-plugin', '.cursor-plugin'):
            path = plugin / host / 'plugin.json'
            data = read_json(path)
            manifests.append(data)
            for field in ('name', 'description', 'version', 'author', 'license', 'keywords', 'repository'):
                if not data.get(field):
                    fail(path, f'Missing {field}')
            if data.get('name') != plugin.name or data.get('version') != version:
                fail(path, 'Name/version does not match directory/release')
            author = data.get('author', {})
            if not isinstance(author, dict) or not author.get('name') or not author.get('email'):
                fail(path, 'Author needs name and email')
            if not isinstance(data.get('keywords'), list):
                fail(path, 'Keywords must be an array')
            if data.get('logo') and not (plugin / data['logo']).is_file():
                fail(path, 'Logo is missing')
        if manifests[0].get('description') != manifests[1].get('description'):
            fail(plugin, 'Host descriptions differ')
        skills = list((plugin / 'skills').glob('*/SKILL.md'))
        if not skills:
            fail(plugin, 'No packaged skills')
        for skill in skills:
            text = skill.read_text()
            try:
                fields = frontmatter(text)
                name, description = fields.get('name'), fields.get('description')
                if not isinstance(name, str) or not NAME.fullmatch(name) or len(name) > 64 or name != skill.parent.name:
                    fail(skill, 'Invalid skill name/directory')
                if not isinstance(description, str) or not 1 <= len(description) <= 200:
                    fail(skill, 'Description must be 1–200 characters')
            except (ValueError, yaml.YAMLError) as exc:
                fail(skill, str(exc))
            if '[references/safety.md](references/safety.md)' not in text:
                fail(skill, 'Must load packaged safety guidance')
            copy = skill.parent / 'references/safety.md'
            if not copy.is_file() or copy.read_text() != safety:
                fail(skill, 'Packaged safety contract is missing or out of sync')

    for host in ('.claude-plugin', '.cursor-plugin'):
        path = root / host / 'marketplace.json'
        data = read_json(path)
        entries = data.get('plugins', [])
        if data.get('metadata', {}).get('version') != version:
            fail(path, 'Marketplace version differs from release')
        names = [entry.get('name') for entry in entries]
        if len(names) != len(set(names)) or set(names) != plugin_names:
            fail(path, 'Marketplace plugin set differs from packaged plugins')
        for entry in entries:
            if entry.get('source') != f"./plugins/{entry.get('name')}" or entry.get('version') != version:
                fail(path, 'Invalid plugin source/version')

    markdown = list((root / 'plugins').rglob('*.md')) + list((root / 'docs').rglob('*.md'))
    markdown += list((root / '.github').glob('*.md'))
    markdown += [root / name for name in ('README.md', 'CONTRIBUTING.md', 'TEST_PROMPTS.md', 'SECURITY.md', 'LICENSE.md')]
    markdown = [path for path in markdown if 'node_modules' not in path.parts and 'dist' not in path.parts]
    for path in markdown:
        if not path.is_file():
            fail(path, 'Required document missing')
            continue
        text = path.read_text()
        for issue in unsafe_examples(text):
            fail(path, issue)
        for target in LINK.findall(text):
            parsed = urlsplit(target.strip('<>'))
            if parsed.scheme or not parsed.path:
                continue
            resolved = (path.parent / unquote(parsed.path)).resolve()
            if not resolved.exists():
                fail(path, f'Broken relative link: {target}')
            if 'plugins' in path.relative_to(root).parts:
                skill_dirs = [parent for parent in path.parents if (parent / 'SKILL.md').is_file()]
                if skill_dirs and not resolved.is_relative_to(skill_dirs[0]):
                    fail(path, f'Link escapes independently installed skill: {target}')
    # Keep scheduled package comparisons tied to the actual tested dependencies.
    python_requirements = (root / 'requirements-dev.txt').read_text()
    ts_package = read_json(root / 'plugins/keeper-sdk/skills/keeper-sdk/examples/typescript/package.json')
    upstream_script = (root / 'scripts/check_upstream.py').read_text()
    for name in ('keeper-secrets-manager-cli', 'keeper-secrets-manager-core'):
        match = re.search(rf'^{name}==([^\s]+)$', python_requirements, re.M)
        if not match or f"'{match[1]}'" not in upstream_script:
            fail(root / 'scripts/check_upstream.py', f'Upstream baseline differs from {name} test pin')
    ts_version = ts_package.get('dependencies', {}).get('@keeper-security/secrets-manager-core')
    if not ts_version or f"'{ts_version}'" not in upstream_script:
        fail(root / 'scripts/check_upstream.py', 'Upstream baseline differs from TypeScript SDK pin')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT)
    args = parser.parse_args()
    errors = validate(args.root.resolve())
    if errors:
        print('\n'.join(f'ERROR: {error}' for error in errors), file=sys.stderr)
        return 1
    print('Plugin manifests, versions, packaged safety, links, and example lint passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
