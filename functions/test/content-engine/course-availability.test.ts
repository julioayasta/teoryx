import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('course record alone is not enough for availability', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'missing-offering',
    courseId: 'course-record-only',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'course_not_available');
});

test('enabled offering without CourseMap is unavailable', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-course-map',
    courseId: 'grade-4-ela',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'course_plan_not_found');
});

test('enabled offering without UnitPlans is unavailable', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-units',
    courseId: 'grade-5-math',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'unit_plans_not_found');
});

test('enabled offering without LessonSpecifications is unavailable', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-lessons',
    courseId: 'grade-5-ela',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'lesson_specification_not_found');
});

test('available course returns LessonSpecification read models only', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    language: 'en',
  }, callers.student);

  assert.equal(response.status, 'ready');
  const lessons = response.lessons as Array<Record<string, unknown>>;
  assert.ok(lessons.length >= 1);
  assert.equal('lessonSpecificationId' in lessons[0], true);
  assert.equal('lessonBlueprintIds' in lessons[0], false);
  assert.equal('standardIds' in lessons[0], false);
});
