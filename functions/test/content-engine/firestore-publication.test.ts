import assert from 'node:assert/strict';
import test from 'node:test';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';

test('Firestore publication enforces minimum publishable package', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.publishValidatedArtifact({
    schoolId: 'school-demo',
    presentationArtifactId: 'presentation-artifact-invalid',
    lessonSpecificationId: 'lesson-spec-missing',
  }, repoCallers.publisher);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'minimum_publishable_package_missing');
});

test('Firestore publication writes publishedLessonContent and audit/provenance', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.publishValidatedArtifact({
    schoolId: 'school-demo',
    presentationArtifactId: 'presentation-artifact-valid',
    lessonSpecificationId: 'lesson-spec-missing',
  }, repoCallers.publisher);

  assert.equal(response.status, 'published');
  assert.equal((await context.repo.listPublishedLessonContent()).some((content) => content.id === response.publishedContentId), true);
  assert.equal((await context.repo.listPublicationRecords()).length, 1);
  assert.equal((await context.repo.listAuditRecords()).length, 1);
  assert.equal((await context.repo.listProvenanceRecords()).length, 1);
});

test('Firestore approval rejects invalid validation artifact', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.approveArtifactForPublication({
    schoolId: 'school-demo',
    artifactType: 'presentation',
    artifactId: 'presentation-artifact-invalid',
    validationArtifactId: 'validation-artifact-invalid',
  }, repoCallers.reviewer);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'validation_failed');
});
