import { MemoryDocumentStore } from '../../src/content-engine/firestore/document-store.js';
import { FirestoreContentEngineRepository } from '../../src/content-engine/repositories/firestore-content-engine-repository.js';
import type { ContentEngineRepository } from '../../src/content-engine/repositories/content-engine-repository.js';
import { seedRepository } from '../fixtures/repository-seed-data.js';

export interface FirestoreTestContext {
  repo: ContentEngineRepository;
  store: MemoryDocumentStore;
  seed(): Promise<void>;
}

export function createFirestoreTestContext(): FirestoreTestContext {
  const store = new MemoryDocumentStore();
  const repo = new FirestoreContentEngineRepository(store);
  return {
    repo,
    store,
    seed: async () => {
      await store.clear();
      await seedRepository(repo);
    },
  };
}
