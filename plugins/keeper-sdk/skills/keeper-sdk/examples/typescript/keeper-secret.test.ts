import assert from 'node:assert/strict';
import test from 'node:test';
import { readPassword, SecretRecord } from './keeper-secret';

const canary = 'SYNTHETIC_SECRET_CANARY';
const record = (value: unknown = canary): SecretRecord => ({
  recordUid: 'exact-test-uid',
  data: { fields: [{ type: 'password', value: [value] }] },
});

test('exact UID filter, no stdout/stderr, and safe failures', async () => {
  const originalOut = process.stdout.write;
  const originalErr = process.stderr.write;
  const output: string[] = [];
  // Scoped interception: the test reporter uses these streams only after restoration.
  process.stdout.write = ((value: unknown) => { output.push(String(value)); return true; }) as typeof originalOut;
  process.stderr.write = ((value: unknown) => { output.push(String(value)); return true; }) as typeof originalErr;
  try {
    const value = await readPassword('/synthetic/config.json', 'exact-test-uid', async (path, uid) => {
      assert.equal(path, '/synthetic/config.json');
      assert.equal(uid, 'exact-test-uid');
      return [record()];
    });
    assert.equal(value, canary);
    for (const records of [[], [record(), record()], [{ ...record(), recordUid: 'wrong' }],
      [record(null)], [record('')], [{ ...record(), data: { fields: [] } }],
      [{ ...record(), data: { fields: [...record().data.fields, ...record().data.fields] } }]]) {
      await assert.rejects(readPassword('config', 'exact-test-uid', async () => records), /Keeper secret access failed/);
    }
    await assert.rejects(
      readPassword('config', 'exact-test-uid', async () => { throw new Error(canary); }),
      (error: unknown) => error instanceof Error && !String(error).includes(canary) && !error.stack?.includes(canary),
    );
    await assert.rejects(readPassword('', 'exact-test-uid'), /configuration/);
    assert.deepEqual(output, []);
  } finally {
    process.stdout.write = originalOut;
    process.stderr.write = originalErr;
  }
});
