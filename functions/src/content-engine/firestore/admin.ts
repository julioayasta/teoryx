import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import type { DocumentRecord, DocumentStore } from './document-store.js';

export function getAdminFirestore(): Firestore {
  if (getApps().length === 0) {
    initializeApp({ projectId: process.env.GCLOUD_PROJECT ?? 'teoryx-demo' });
  }
  return getFirestore();
}

export class FirestoreAdminDocumentStore implements DocumentStore {
  constructor(private readonly db: Firestore = getAdminFirestore()) {}

  async get<T extends object>(collection: string, id: string): Promise<T | undefined> {
    const snapshot = await this.db.collection(collection).doc(id).get();
    return snapshot.exists ? ({ id: snapshot.id, ...snapshot.data() } as unknown as T) : undefined;
  }

  async set<T extends object>(collection: string, id: string, data: T): Promise<void> {
    await this.db.collection(collection).doc(id).set(data);
  }

  async update<T extends object>(collection: string, id: string, data: Partial<T>): Promise<void> {
    await this.db.collection(collection).doc(id).set(data, { merge: true });
  }

  async list<T extends object>(collection: string): Promise<Array<DocumentRecord<T>>> {
    const snapshot = await this.db.collection(collection).get();
    return snapshot.docs.map((doc) => ({ id: doc.id, data: { id: doc.id, ...doc.data() } as unknown as T }));
  }

  async clear(): Promise<void> {
    const names = [
      'contentGenerationRequests',
      'contentGenerationJobs',
      'courseOfferings',
      'courseMaps',
      'unitPlans',
      'lessonSpecifications',
      'lessonArtifacts',
      'presentationArtifacts',
      'validationArtifacts',
      'publishedLessonContent',
      'generationAuditEntries',
      'provenanceRecords',
      'versionHistories',
      'artifactPublicationRecords',
      'promptTemplateVersions',
      'promptExecutionRecords',
      'costTrackingRecords',
      'curriculumSources',
      'curriculumStandards',
      'curriculumImportBatches',
      'pedagogicalAnalyses',
      'schools/school-demo/courses',
      'schools/school-demo/students',
      'schools/school-demo/studentProgress',
    ];
    for (const name of names) {
      const snapshot = await this.db.collection(name).get();
      await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
    }
  }
}
