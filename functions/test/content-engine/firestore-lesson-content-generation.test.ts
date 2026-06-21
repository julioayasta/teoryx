import assert from 'node:assert/strict';
import test from 'node:test';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';

async function prepareGeneratedCourse() {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);
  await handlers.requestCoursePlanGeneration({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-generated',
    curriculumVersionId: 'ca-common-core-math-2025',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    language: 'en',
  }, repoCallers.planner);
  await handlers.publishCourseOffering({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
  }, repoCallers.publisher);
  return { context, handlers };
}

test('requestLessonContent generates artifacts and published lesson content', async () => {
  const { context, handlers } = await prepareGeneratedCourse();

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'lesson-spec-grade-4-math-generated-001',
    language: 'en',
  }, repoCallers.student);

  const publishedContentId = String(response.publishedContentId);
  const lessonArtifact = await context.repo.getLessonArtifact('lesson-artifact-lesson-spec-grade-4-math-generated-001');
  const presentationArtifact = await context.repo.getPresentationArtifact('presentation-artifact-lesson-spec-grade-4-math-generated-001');
  const validationArtifact = await context.repo.getValidationArtifact('validation-artifact-lesson-spec-grade-4-math-generated-001');
  const published = await context.repo.getPublishedLessonContent(publishedContentId);
  const lessonSpec = await context.repo.getLessonSpecification('lesson-spec-grade-4-math-generated-001');

  assert.equal(response.status, 'ready');
  assert.equal(lessonArtifact?.status, 'published');
  assert.equal(presentationArtifact?.status, 'published');
  assert.equal(validationArtifact?.validationStatus, 'valid');
  assert.equal(published?.status, 'published');
  assert.equal(lessonSpec?.publishedContentId, publishedContentId);
  assert.equal(lessonSpec?.generationStatus, 'published');
});

test('publishedLessonContent is compatible with current Flutter Firestore reader', async () => {
  const { context, handlers } = await prepareGeneratedCourse();

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'lesson-spec-grade-4-math-generated-001',
    language: 'en',
  }, repoCallers.student);
  const published = await context.repo.getPublishedLessonContent(String(response.publishedContentId));

  assert.equal(published?.publishedContentId, response.publishedContentId);
  assert.equal(published?.courseId, 'grade-4-math-generated');
  assert.equal(published?.schoolId, 'school-demo');
  assert.equal(published?.curriculumId, 'curriculum-grade-4-math-generated');
  assert.equal(published?.gradeLevelId, 'grade-4');
  assert.equal(published?.subjectId, 'math');
  assert.equal(published?.standardId, 'standard-grade-4-math-generated-001');
  assert.equal(published?.language, 'en');
  assert.ok(published?.bigIdea);
  assert.ok(published?.essentialQuestion);
  assert.ok(published?.learningObjective);
  assert.ok(published?.lessonContent);
  assert.ok(published?.guidedPractice);
  assert.ok(published?.independentPractice);
  assert.ok(published?.summary);
  assert.equal(published?.version, '1.0');
  assert.deepEqual(published?.steps?.map((step) => step.type), [
    'story',
    'imagePlaceholder',
    'explanation',
    'question',
    'practice',
    'summary',
  ]);
});

test('repeated requestLessonContent returns existing content without duplicate artifacts or publication records', async () => {
  const { context, handlers } = await prepareGeneratedCourse();
  const request = {
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'lesson-spec-grade-4-math-generated-001',
    language: 'en',
  };

  const first = await handlers.requestLessonContent(request, repoCallers.student);
  const publicationRecordsAfterFirst = await context.repo.listPublicationRecords();
  const second = await handlers.requestLessonContent(request, repoCallers.student);
  const publicationRecordsAfterSecond = await context.repo.listPublicationRecords();

  assert.equal(first.status, 'ready');
  assert.equal(second.status, 'ready');
  assert.equal(first.publishedContentId, second.publishedContentId);
  assert.equal(publicationRecordsAfterSecond.length, publicationRecordsAfterFirst.length);
});

test('Student App receives ready after fake lesson generation', async () => {
  const { handlers } = await prepareGeneratedCourse();

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'lesson-spec-grade-4-math-generated-002',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'ready');
  assert.ok(response.publishedContentId);
});

test('missing LessonSpecification fails safely', async () => {
  const { handlers } = await prepareGeneratedCourse();

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'missing-lesson-spec',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'lesson_specification_not_found');
});

test('lesson content generation writes audit provenance and publication records', async () => {
  const { context, handlers } = await prepareGeneratedCourse();
  const existingAuditCount = (await context.repo.listAuditRecords()).length;
  const existingProvenanceCount = (await context.repo.listProvenanceRecords()).length;
  const existingPublicationCount = (await context.repo.listPublicationRecords()).length;

  await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-generated-en',
    courseId: 'grade-4-math-generated',
    lessonSpecificationId: 'lesson-spec-grade-4-math-generated-003',
    language: 'en',
  }, repoCallers.student);

  assert.ok((await context.repo.listAuditRecords()).length > existingAuditCount);
  assert.ok((await context.repo.listProvenanceRecords()).length > existingProvenanceCount);
  assert.ok((await context.repo.listPublicationRecords()).length > existingPublicationCount);
});
