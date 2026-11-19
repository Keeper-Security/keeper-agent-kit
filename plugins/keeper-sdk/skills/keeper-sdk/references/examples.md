# Packaged SDK Examples

Read [safety.md](safety.md). Samples return secrets to the consuming application,
not to stdout or an AI conversation. They require an already bound KSM **JSON**
config in a private location and one exact record UID. They do not create devices,
enable persistent login, or bind a one-time token automatically.

## Python

Install the supported core package in the application's virtual environment and
pin it in its dependency file. The repository's CI checks the sample against
`keeper-secrets-manager-core==17.3.0` without contacting Keeper.

```python
from keeper_secret import read_password

# Supply approved config path and record UID through application configuration.
password = read_password(config_path, record_uid)
# Pass directly to the intended client; do not print, log, or put it in argv.
```

The module is [../examples/python/keeper_secret.py](../examples/python/keeper_secret.py).
Its public failure messages intentionally omit SDK exception details, record data,
paths, and values. Add application-specific error handling without leaking these.

## TypeScript / Node

The packaged example pins npm `@keeper-security/secrets-manager-core` to 17.6.0.
Install with the example's lockfile and type-check before integration:

```bash
npm ci
npm run check
npm test
```

Run these in [../examples/typescript](../examples/typescript). `readPassword`
returns the selected string to the application, uses an exact UID filter, and
omits sensitive causes from public errors. Do not send its return value to logs.

## Testing boundaries

CI uses injected synthetic SDK adapters and secret canaries, checks missing fields,
identity mismatches, SDK failures, no token output, and no stdout/stderr leakage.
It type-checks the TypeScript adapter and checks the Python SDK signatures.
These tests do **not** prove live binding, backend authorization, database access,
or product integration behavior. Approved live tests use dedicated nonproduction
identities and must never print credentials.
