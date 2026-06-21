import assert from 'node:assert/strict';
import test from 'node:test';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';

const generatedCourseRequest = {
  schoolId: 'school-demo',
  courseId: 'grade-4-math-generated',
  curriculumVersionId: 'ca-common-core-math-2025',
  gradeLevelId: 'grade-4',
  subjectId: 'math',
  language: 'en',
};

test('requestCoursePlanGeneration creates deterministic CourseMap UnitPlans and LessonSpecifications', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);
  const courseMapId = String(response.courseMapId);
  const courseMap = await context.repo.getCourseMap(courseMapId);
  const unitPlans = await context.repo.listUnitPlans({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-generated',
    courseMapId,
  });
  const lessons = await context.repo.listLessonSpecifications({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-generated',
    courseMapId,
    language: 'en',
  });
  const jobs = await context.repo.listContentGenerationJobs({ requestId: String(response.requestId) });

  assert.equal(response.status, 'ready');
  assert.equal(courseMap?.id, 'course-map-school-demo-grade-4-math-generated-en');
  assert.equal(unitPlans.length, 2);
  assert.equal(lessons.length, 5);
  assert.equal(jobs.length, 1);
  assert.equal(lessons[0].generationStatus, 'not_generated');
  assert.equal(lessons[0].publishedContentId, null);
  assert.ok((lessons[0].targetSkills ?? []).length >= 2);
  assert.ok((lessons[0].vocabularyTargets ?? []).length >= 2);
  assert.deepEqual(lessons[0].prerequisiteLessonIds, []);
  assert.deepEqual(lessons[1].prerequisiteLessonIds, ['lesson-spec-grade-4-math-generated-001']);
});

test('requestCoursePlanGeneration is idempotent and does not duplicate generated plan records', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const first = await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);
  const second = await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);
  const courseMapId = String(first.courseMapId);
  const unitPlans = await context.repo.listUnitPlans({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-generated',
    courseMapId,
  });
  const lessons = await context.repo.listLessonSpecifications({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-generated',
    courseMapId,
    language: 'en',
  });

  assert.equal(first.requestId, second.requestId);
  assert.equal(first.courseMapId, second.courseMapId);
  assert.equal(unitPlans.length, 2);
  assert.equal(lessons.length, 5);
});

test('publishCourseOffering fails before valid generated plan exists', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  await context.repo.saveCourseOffering({
    id: 'offering-empty-generated',
    schoolId: 'school-demo',
    courseId: 'grade-empty-generated',
    courseMapId: 'course-map-missing-generated',
    language: 'en',
    status: 'draft',
    enabledForStudents: false,
  });
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.publishCourseOffering({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-empty-generated',
  }, repoCallers.publisher);
  const offering = await context.repo.getCourseOffering('offering-empty-generated');

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'course_plan_not_found');
  assert.equal(offering?.enabledForStudents, false);
});

test('Student App cannot access generated specs until CourseOffering is enabled', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);
  const response = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'course_not_available');
});

test('publishCourseOffering succeeds after valid generated plan exists and exposes specs', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);
  const publishResponse = await handlers.publishCourseOffering({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
  }, repoCallers.publisher);
  const lessonResponse = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    language: 'en',
  }, repoCallers.student);
  const lessons = lessonResponse.lessons as Array<Record<string, unknown>>;

  assert.equal(publishResponse.status, 'published');
  assert.equal(lessonResponse.status, 'ready');
  assert.equal(lessons.length, 5);
  assert.equal(lessons[0].lessonSpecificationId, 'lesson-spec-grade-4-math-generated-001');
});

test('course plan generation writes audit provenance and version records', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.requestCoursePlanGeneration(generatedCourseRequest, repoCallers.planner);

  assert.ok((await context.repo.listAuditRecords()).length >= 2);
  assert.ok((await context.repo.listProvenanceRecords()).length >= 2);
});
