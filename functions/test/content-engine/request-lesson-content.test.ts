import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('requestLessonContent requires lessonSpecificationId as primary input', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonId: 'lesson-missing',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'missing_required_context');
});

test('requestLessonContent returns ready when published content exists', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-published',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'ready');
  assert.equal(response.publishedContentId, 'published-content-001');
});

test('requestLessonContent creates pending request and audit/provenance for missing content', async () => {
  const store = createSeededStore();
  store.generationRequests.clear();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'pending');
  assert.equal(store.generationRequests.size, 1);
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});

test('requestLessonContent reuses pending request by idempotency key', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const first = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, callers.student);
  const second = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, callers.student);

  assert.equal(first.status, 'pending');
  assert.equal(second.status, 'pending');
  assert.equal(first.requestId, second.requestId);
});

test('invalid lesson specification fails safely', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-invalid',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'invalid_lesson_specification');
});
