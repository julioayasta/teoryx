import assert from 'node:assert/strict';
import test from 'node:test';

import { standardId } from '../../src/content-engine/curriculum/curriculum-import-service.js';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';

test('course plan can be generated from imported standards and pedagogical analyses', async () => {
  const { context, handlers } = await setupWithAnalyses();

  const response = await requestAnalysisBackedCoursePlan(handlers);
  const specs = await context.repo.listLessonSpecifications({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    courseMapId: String(response.courseMapId),
    language: 'en',
  });

  assert.equal(response.status, 'ready');
  assert.equal(response.unitPlanCount, 2);
  assert.equal(specs.length, 2);
  assert.deepEqual(specs.map((spec) => spec.standardIds), [
    [standardId('ca-common-core-math', '2025', '4.NF.A.1')],
    [standardId('ca-common-core-math', '2025', '4.NF.A.2')],
  ]);
  assert.ok(specs.every((spec) => spec.pedagogicalAnalysisIds.length === 1));
});

test('lesson specs copy target skills vocabulary and misconceptions from PedagogicalAnalysis', async () => {
  const { context, handlers } = await setupWithAnalyses();

  const response = await requestAnalysisBackedCoursePlan(handlers);
  const specs = await context.repo.listLessonSpecifications({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    courseMapId: String(response.courseMapId),
    language: 'en',
  });
  const firstAnalysis = await context.repo.getPedagogicalAnalysis(specs[0].pedagogicalAnalysisIds[0]);

  assert.deepEqual(specs[0].targetSkills, firstAnalysis?.targetSkills);
  assert.deepEqual(specs[0].vocabularyTargets, firstAnalysis?.vocabularyTerms);
  assert.deepEqual(specs[0].misconceptionTargets, firstAnalysis?.misconceptions);
  assert.equal(specs[0].generationStatus, 'not_generated');
  assert.equal(specs[0].publishedContentId, null);
});

test('missing PedagogicalAnalysis fails safely when standards exist', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);
  await handlers.importCurriculumSource(curriculumPayload(), repoCallers.superAdmin);

  const response = await requestAnalysisBackedCoursePlan(handlers);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'pedagogical_analysis_missing');
  assert.equal((await context.repo.listPedagogicalAnalyses()).length, 0);
});

test('repeated analysis-backed course planning does not duplicate plans or specs', async () => {
  const { context, handlers } = await setupWithAnalyses();

  const first = await requestAnalysisBackedCoursePlan(handlers);
  const second = await requestAnalysisBackedCoursePlan(handlers);
  const units = await context.repo.listUnitPlans({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    courseMapId: String(first.courseMapId),
  });
  const specs = await context.repo.listLessonSpecifications({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    courseMapId: String(first.courseMapId),
    language: 'en',
  });

  assert.equal(first.courseMapId, second.courseMapId);
  assert.equal(units.length, 2);
  assert.equal(specs.length, 2);
});

test('publishCourseOffering succeeds after analysis-backed course plan generation', async () => {
  const { handlers } = await setupWithAnalyses();
  await requestAnalysisBackedCoursePlan(handlers);

  const publish = await handlers.publishCourseOffering({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-real-en',
  }, repoCallers.publisher);
  const specs = await handlers.getLessonSpecificationsForCourse({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-school-demo-grade-4-math-real-en',
    courseId: 'grade-4-math-real',
    language: 'en',
  }, repoCallers.student);

  assert.equal(publish.status, 'published');
  assert.equal(specs.status, 'ready');
  assert.equal((specs.lessons as unknown[]).length, 2);
});

async function setupWithAnalyses() {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);
  await handlers.importCurriculumSource(curriculumPayload(), repoCallers.superAdmin);
  await handlers.requestPedagogicalAnalysis({
    standardId: standardId('ca-common-core-math', '2025', '4.NF.A.1'),
    language: 'en',
  }, repoCallers.superAdmin);
  await handlers.requestPedagogicalAnalysis({
    standardId: standardId('ca-common-core-math', '2025', '4.NF.A.2'),
    language: 'en',
  }, repoCallers.superAdmin);

  return { context, handlers };
}

async function requestAnalysisBackedCoursePlan(
  handlers: ReturnType<typeof createFirestoreBackedContentEngineHandlers>,
) {
  return handlers.requestCoursePlanGeneration({
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    curriculumSourceId: 'ca-common-core-math',
    curriculumVersionId: '2025',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    language: 'en',
  }, repoCallers.planner);
}

function curriculumPayload() {
  return {
    source: {
      id: 'ca-common-core-math',
      name: 'California Common Core Mathematics',
      jurisdiction: 'CA',
      framework: 'common_core',
      officialSourceUrl: 'https://www.cde.ca.gov/be/st/ss/',
    },
    version: {
      id: '2025',
      sourceVersion: '2025',
      effectiveDate: '2025-01-01',
    },
    standards: [
      {
        code: '4.NF.A.1',
        title: 'Explain equivalent fractions.',
        description: 'Explain equivalent fractions using visual fraction models.',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
      },
      {
        code: '4.NF.A.2',
        title: 'Compare fractions.',
        description: 'Compare fractions with different numerators and denominators.',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
      },
    ],
  };
}
