import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('student cannot call School Portal planning function', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.requestCoursePlanGeneration({
    schoolId: 'school-demo',
    courseId: 'grade-4-math',
    curriculumVersionId: 'ca-common-core-math-2025',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'permission_denied');
});

test('cross-school student cannot read another school course', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    language: 'en',
  }, callers.crossSchool);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'permission_denied');
});

test('school publisher can publish course offering when planning records are valid', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.publishCourseOffering({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
  }, callers.publisher);

  assert.equal(response.status, 'published');
  assert.equal(store.auditRecords.length, 1);
  assert.equal(store.provenanceRecords.length, 1);
});
