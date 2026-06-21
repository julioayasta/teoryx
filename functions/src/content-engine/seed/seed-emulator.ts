import { FirestoreAdminDocumentStore } from '../firestore/admin.js';
import { FirestoreContentEngineRepository } from '../repositories/firestore-content-engine-repository.js';

async function main(): Promise<void> {
  const { seedRepository } = await import('../../../test/fixtures/repository-seed-data.js');
  const store = new FirestoreAdminDocumentStore();
  const repo = new FirestoreContentEngineRepository(store);
  await store.clear();
  await seedRepository(repo);
  console.log('Seeded Content Engine emulator data.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
