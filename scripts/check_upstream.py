"""Read-only upstream drift report; never upgrades, writes issues, or publishes."""

from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import re
import ssl
import sys
from urllib.parse import urlsplit
from urllib.request import Request, urlopen

import certifi

ROOT = Path(__file__).resolve().parents[1]


def get(url):
    request = Request(url, headers={'User-Agent': 'keeper-agent-kit-upstream-check'})
    context = ssl.create_default_context()
    # Add public roots while preserving configured OS/enterprise trust roots.
    context.load_verify_locations(cafile=certifi.where())
    with urlopen(request, timeout=30, context=context) as response:
        return response.read().decode('utf-8')


def normalize(url):
    return urlsplit(url).path.removesuffix('.md').rstrip('/')


def main():
    problems = []
    try:
        index = get('https://docs.keeper.io/llms.txt')
    except Exception as exc:
        print(f'Documentation index unavailable: {type(exc).__name__}', file=sys.stderr)
        return 1
    known = {normalize(url) for url in re.findall(r'https://docs\.keeper\.io/[^\s)]+', index)}
    targets = set()
    for folder in ('plugins', 'docs'):
        for path in (ROOT / folder).rglob('*.md'):
            if 'node_modules' not in path.parts:
                targets.update(re.findall(r'https://docs\.keeper\.io/[^\s)>]+', path.read_text()))
    targets.update(re.findall(r'https://docs\.keeper\.io/[^\s)>]+', (ROOT / 'README.md').read_text()))
    for url in sorted(targets):
        if normalize(url) not in ('', '/llms.txt') and normalize(url) not in known:
            problems.append(f'Documentation path missing from current public index: {url}')

    packages = [
        ('KSM CLI', 'https://pypi.org/pypi/keeper-secrets-manager-cli/json', '1.5.0'),
        ('KSM Python', 'https://pypi.org/pypi/keeper-secrets-manager-core/json', '17.3.0'),
        ('KSM JavaScript', 'https://registry.npmjs.org/@keeper-security/secrets-manager-core/latest', '17.6.0'),
    ]

    def check_package(item):
        name, url, expected = item
        try:
            data = json.loads(get(url))
            latest = data.get('info', {}).get('version', data.get('version'))
            if latest != expected:
                return f'{name}: tested {expected}; upstream latest {latest}; review release notes and contracts'
        except Exception as exc:
            return f'{name}: registry check unavailable ({type(exc).__name__})'
        return None

    with ThreadPoolExecutor(max_workers=3) as pool:
        problems.extend(message for message in pool.map(check_package, packages) if message)
    print(f'Checked {len(targets)} documentation links and {len(packages)} packages')
    if problems:
        print('\n'.join(problems))
        print('Review only: no files, permissions, dependencies, or published content changed.')
        return 1
    print('No documentation-index or package-version drift found; deployment still needs verification.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
