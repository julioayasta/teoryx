import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('invalid artifacts cannot be approved', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.approveArtifactForPublication({
    schoolId: 'school-demo',
    artifactType: 'presentation',
    artifactId: 'presentation-artifact-invalid',
    validationArtifactId: 'validation-artifact-invalid',
  }, callers.reviewer);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'validation_failed');
});

test('publishValidatedArtifact requires minimum publishable package', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.publishValidatedArtifact({
    schoolId: 'school-demo',
    presentationArtifactId: 'presentation-artifact-invalid',
    lessonSpecificationId: 'lesson-spec-missing',
  }, callers.publisher);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'minimum_publishable_package_missing');
});

test('publishValidatedArtifact maps PresentationArtifact into publishedLessonContent', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.publishValidatedArtifact({
    schoolId: 'school-demo',
    presentationArtifactId: 'presentation-artifact-valid',
    lessonSpecificationId: 'lesson-spec-missing',
  }, callers.publisher);

  assert.equal(response.status, 'published');
  assert.equal(store.publishedLessonContent.has(String(response.publishedContentId)), true);
  assert.equal(store.publicationRecords.length, 1);
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});
