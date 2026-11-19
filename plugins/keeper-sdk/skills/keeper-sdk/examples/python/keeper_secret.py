"""Pass one KSM password to an application; never print credentials or bootstrap."""

from typing import Callable, Optional


class SecretAccessError(RuntimeError):
    """Safe public error; intentionally excludes SDK payloads and credentials."""


def read_password(
    config_path: str,
    record_uid: str,
    *,
    client_factory: Optional[Callable] = None,
) -> str:
    """Use an existing bound JSON config and an exact UID, not a title lookup.

    client_factory is a test seam. Production uses the actual KSM SDK adapter.
    Call this inside the intended application, not an agent's captured terminal.
    """
    if not config_path or not record_uid:
        raise SecretAccessError("A bound configuration and exact record UID are required")
    try:
        if client_factory is None:
            from keeper_secrets_manager_core import SecretsManager
            from keeper_secrets_manager_core.storage import FileKeyValueStorage

            client = SecretsManager(config=FileKeyValueStorage(config_path))
        else:
            client = client_factory(config_path)
        records = client.get_secrets([record_uid])
        if len(records) != 1 or records[0].uid != record_uid:
            raise SecretAccessError("Expected one exact accessible record")
        value = records[0].field("password", single=True)
        if not isinstance(value, str) or not value:
            raise SecretAccessError("Expected a nonempty password field")
        return value
    except Exception:
        # Do not expose SDK exception messages, full records, paths, or causes.
        raise SecretAccessError("Keeper secret access failed; review configuration and scope") from None
