import assert from 'node:assert/strict';
import test from 'node:test';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';

test('Firestore runtime requires lessonSpecificationId for requestLessonContent', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonId: 'lesson-missing',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'missing_required_context');
});

test('Firestore runtime returns published content before creating generation request', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const beforeCount = await context.repo.countGenerationRequests();
  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-published',
    language: 'en',
  }, repoCallers.student);
  const afterCount = await context.repo.countGenerationRequests();

  assert.equal(response.status, 'ready');
  assert.equal(response.publishedContentId, 'published-content-001');
  assert.equal(afterCount, beforeCount);
});

test('Firestore runtime persists generated request and audit/provenance records', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  await context.store.clear();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
    idempotencyKey: 'unique-firestore-request',
  }, repoCallers.student);

  assert.equal(response.status, 'ready');
  assert.ok((await context.repo.listAuditRecords()).length >= 2);
  assert.ok((await context.repo.listProvenanceRecords()).length >= 2);
});

test('Firestore runtime reuses generated content across separate handler instances', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlersA = createFirestoreBackedContentEngineHandlers(context.repo);
  const handlersB = createFirestoreBackedContentEngineHandlers(context.repo);

  const first = await handlersA.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, repoCallers.student);
  const second = await handlersB.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, repoCallers.student);

  assert.equal(first.status, 'ready');
  assert.equal(second.status, 'ready');
  assert.equal(first.publishedContentId, second.publishedContentId);
});

test('Firestore runtime filters Student App status to pending ready or failed', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.getContentGenerationStatus({
    schoolId: 'school-demo',
    requestId: 'request-pending-001',
  }, repoCallers.student);

  assert.equal(response.status, 'pending');
  assert.equal('stage' in response, false);
});
