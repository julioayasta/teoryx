import assert from 'node:assert/strict';
import test from 'node:test';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';

test('Firestore repository returns available LessonSpecification read models', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'ready');
  const lessons = response.lessons as Array<Record<string, unknown>>;
  assert.ok(lessons.length >= 1);
  assert.equal('lessonSpecificationId' in lessons[0], true);
  assert.equal('lessonBlueprintIds' in lessons[0], false);
});

test('Firestore repository keeps unavailable course hidden when CourseMap is missing', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-course-map',
    courseId: 'grade-4-ela',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'course_plan_not_found');
});

test('Firestore repository keeps unavailable course hidden when UnitPlans are missing', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-units',
    courseId: 'grade-5-math',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'unit_plans_not_found');
});

test('Firestore repository keeps unavailable course hidden when LessonSpecifications are missing', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-no-lessons',
    courseId: 'grade-5-ela',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'lesson_specification_not_found');
});
