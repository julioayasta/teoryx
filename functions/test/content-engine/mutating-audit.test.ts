import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('requestSchoolLessonGeneration writes audit and provenance', async () => {
  const store = createSeededStore();
  store.generationRequests.clear();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestSchoolLessonGeneration({
    schoolId: 'school-demo',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    intent: 'create_new',
  }, callers.planner);

  assert.equal(response.status, 'pending');
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});

test('requestArtifactRegeneration writes audit and provenance', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestArtifactRegeneration({
    schoolId: 'school-demo',
    artifactType: 'lesson',
    artifactId: 'lesson-artifact-valid',
  }, callers.planner);

  assert.equal(response.status, 'pending');
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});

test('approveArtifactForPublication writes audit and provenance', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.approveArtifactForPublication({
    schoolId: 'school-demo',
    artifactType: 'presentation',
    artifactId: 'presentation-artifact-valid',
    validationArtifactId: 'validation-artifact-valid',
  }, callers.reviewer);

  assert.equal(response.status, 'approved');
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});
