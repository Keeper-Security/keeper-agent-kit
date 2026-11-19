import { getSecrets, localConfigStorage } from '@keeper-security/secrets-manager-core';

export interface SecretRecord {
  recordUid: string;
  data: { fields: Array<{ type: string; value: unknown[] }> };
}

export type LoadRecords = (configPath: string, recordUid: string) => Promise<SecretRecord[]>;

const loadFromKeeper: LoadRecords = async (configPath, recordUid) => {
  const { records } = await getSecrets(
    { storage: localConfigStorage(configPath) },
    [recordUid],
  );
  return records;
};

/** Use only inside the approved application with an already bound KSM JSON config. */
export async function readPassword(
  configPath: string,
  recordUid: string,
  loadRecords: LoadRecords = loadFromKeeper,
): Promise<string> {
  if (!configPath || !recordUid) {
    throw new Error('A bound configuration and exact record UID are required');
  }
  try {
    const records = await loadRecords(configPath, recordUid);
    if (records.length !== 1 || records[0].recordUid !== recordUid) {
      throw new Error('Expected one exact accessible record');
    }
    const fields = records[0].data.fields.filter((field) => field.type === 'password');
    const value = fields.length === 1 ? fields[0].value[0] : undefined;
    if (typeof value !== 'string' || value.length === 0) {
      throw new Error('Expected a nonempty password field');
    }
    return value;
  } catch {
    // No raw SDK cause, records, config paths, or credentials in public errors.
    throw new Error('Keeper secret access failed; review configuration and scope');
  }
}
