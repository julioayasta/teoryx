import assert from 'node:assert/strict';
import test from 'node:test';

import type { AIProvider, AIRequest, AIResponse } from '../../src/content-engine/ai/types.js';
import { standardId } from '../../src/content-engine/curriculum/curriculum-import-service.js';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';

class MockAIProvider implements AIProvider {
  readonly providerName = 'openai';
  readonly model = 'mock-openai-json-v1';

  constructor(private readonly content: string) {}

  async generate(_request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse> {
    return {
      content: this.content,
      estimatedInputTokens: 100,
      estimatedOutputTokens: 120,
      estimatedCostUsd: 0.01,
    };
  }
}

class CapturingAIProvider implements AIProvider {
  readonly providerName = 'openai';
  readonly model = 'capturing-openai-json-v1';
  requests: Array<AIRequest & { prompt: string; promptTemplateVersionId: string }> = [];

  async generate(request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse> {
    this.requests.push(request);
    return {
      content: JSON.stringify(validLessonJson()),
      estimatedInputTokens: 100,
      estimatedOutputTokens: 120,
      estimatedCostUsd: 0.01,
    };
  }
}

test('real provider is not used by default and fake lesson generation remains available', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await requestMissingLesson(handlers);

  assert.equal(response.status, 'ready');
  assert.ok(response.publishedContentId);
  assert.equal((await context.repo.listPromptExecutionRecords()).length, 0);
  assert.equal((await context.repo.listCostTrackingRecords()).length, 0);
});

test('missing OpenAI API key does not crash and falls back to fake generation', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    env: {
      CONTENT_ENGINE_ENABLE_REAL_AI: 'true',
      CONTENT_ENGINE_AI_PROVIDER: 'openai',
    },
  });

  const response = await requestMissingLesson(handlers);

  assert.equal(response.status, 'ready');
  assert.ok(response.publishedContentId);
  assert.equal((await context.repo.listPromptExecutionRecords()).length, 0);
});

test('invalid AI JSON does not publish and records prompt and cost execution', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider('not-json'),
  });
  await seedRealBackedLesson(context.repo);

  const response = await requestRealBackedLesson(handlers);
  const validation = await context.repo.getValidationArtifact('validation-artifact-lesson-spec-real-backed');
  const lesson = await context.repo.getLessonSpecification('lesson-spec-real-backed');

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'invalid_json');
  assert.equal(validation?.validationStatus, 'invalid');
  assert.equal(lesson?.publishedContentId, null);
  assert.equal((await context.repo.listPublishedLessonContent()).length, 0);
  assert.equal((await context.repo.listPromptExecutionRecords()).length, 1);
  assert.equal((await context.repo.listCostTrackingRecords()).length, 1);
});

test('unsupported AI step type does not publish', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify({
      ...validLessonJson(),
      steps: [
        {
          id: 'step-1',
          lessonId: 'lesson-missing',
          order: 1,
          type: 'video',
          title: 'Unsupported',
          body: 'This should not publish.',
        },
      ],
    })),
  });
  await seedRealBackedLesson(context.repo);

  const response = await requestRealBackedLesson(handlers);
  const lesson = await context.repo.getLessonSpecification('lesson-spec-real-backed');

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'unsupported_step_type');
  assert.equal(lesson?.publishedContentId, null);
  assert.equal((await context.repo.listPublishedLessonContent()).length, 0);
});

test('valid mocked AI JSON publishes through artifacts and publishedLessonContent', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify(validLessonJson())),
  });
  await seedRealBackedLesson(context.repo);

  const response = await requestRealBackedLesson(handlers);
  const published = await context.repo.getPublishedLessonContent(String(response.publishedContentId));
  const lessonArtifact = await context.repo.getLessonArtifact('lesson-artifact-lesson-spec-real-backed');
  const presentationArtifact = await context.repo.getPresentationArtifact('presentation-artifact-lesson-spec-real-backed');
  const validationArtifact = await context.repo.getValidationArtifact('validation-artifact-lesson-spec-real-backed');
  const promptExecutions = await context.repo.listPromptExecutionRecords();
  const costRecords = await context.repo.listCostTrackingRecords();
  const provenance = await context.repo.listProvenanceRecords();

  assert.equal(response.status, 'ready');
  assert.equal(published?.status, 'published');
  assert.equal(published?.title, 'AI Fractions Lesson');
  assert.equal(published?.steps?.[1].type, 'imagePlaceholder');
  assert.equal(lessonArtifact?.status, 'published');
  assert.equal(presentationArtifact?.status, 'published');
  assert.equal(validationArtifact?.validationStatus, 'valid');
  assert.equal(promptExecutions.length, 1);
  assert.equal(costRecords.length, 1);
  assert.equal(promptExecutions[0].provider, 'openai');
  assert.equal(costRecords[0].estimatedCostUsd, 0.01);
  assert.ok(provenance.some((record) => record.targetType === 'promptExecutionRecord'));
});

test('AI lesson generation request includes CurriculumStandard and PedagogicalAnalysis context', async () => {
  const context = createFirestoreTestContext();
  const capture = new CapturingAIProvider();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: capture,
  });
  await seedRealBackedLesson(context.repo);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-real-backed',
    courseId: 'grade-4-math-real',
    lessonSpecificationId: 'lesson-spec-real-backed',
    language: 'en',
  }, repoCallers.student);
  const variables = capture.requests[0].variables as Record<string, unknown>;
  const standards = variables.standards as Array<Record<string, unknown>>;
  const analyses = variables.pedagogicalAnalyses as Array<Record<string, unknown>>;
  const targets = variables.generationTargets as Record<string, unknown>;

  assert.equal(response.status, 'ready');
  assert.equal(standards[0].code, '4.NF.A.1');
  assert.equal(standards[0].description, 'Explain equivalent fractions using visual fraction models.');
  assert.equal(analyses[0].pedagogicalAnalysisId, 'analysis-real-backed');
  assert.deepEqual(targets.targetSkills, ['explain equivalent fractions']);
  assert.deepEqual(targets.vocabularyTargets, ['equivalent fractions']);
  assert.deepEqual(targets.misconceptionTargets, ['Students may compare only numerators.']);
});

test('publishedLessonContent preserves real standard metadata', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify(validLessonJson())),
  });
  await seedRealBackedLesson(context.repo);

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-real-backed',
    courseId: 'grade-4-math-real',
    lessonSpecificationId: 'lesson-spec-real-backed',
    language: 'en',
  }, repoCallers.student);
  const published = await context.repo.getPublishedLessonContent(String(response.publishedContentId));

  assert.equal(published?.standardId, standardId('ca-common-core-math', '2025', '4.NF.A.1'));
  assert.equal(published?.standardCode, '4.NF.A.1');
  assert.equal(published?.curriculumId, 'ca-common-core-math');
  assert.equal(published?.gradeLevelId, 'grade-4');
  assert.equal(published?.subjectId, 'math');
});

test('missing referenced CurriculumStandard fails safely', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify(validLessonJson())),
  });
  await seedRealBackedLesson(context.repo, { includeStandard: false });

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-real-backed',
    courseId: 'grade-4-math-real',
    lessonSpecificationId: 'lesson-spec-real-backed',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'curriculum_standard_missing');
});

test('missing referenced PedagogicalAnalysis fails safely', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify(validLessonJson())),
  });
  await seedRealBackedLesson(context.repo, { includeAnalysis: false });

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-real-backed',
    courseId: 'grade-4-math-real',
    lessonSpecificationId: 'lesson-spec-real-backed',
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'pedagogical_analysis_missing');
});

type HandlerMap = ReturnType<typeof createFirestoreBackedContentEngineHandlers>;

async function requestMissingLesson(handlers: HandlerMap) {
  return handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-available',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    language: 'en',
  }, repoCallers.student);
}

async function requestRealBackedLesson(handlers: HandlerMap) {
  return handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-real-backed',
    courseId: 'grade-4-math-real',
    lessonSpecificationId: 'lesson-spec-real-backed',
    language: 'en',
  }, repoCallers.student);
}

function validLessonJson() {
  return {
    title: 'AI Fractions Lesson',
    bigIdea: 'Fractions describe equal parts of a whole.',
    essentialQuestion: 'How can fractions help us describe equal parts?',
    learningObjective: 'I can explain a fraction as equal parts of a whole.',
    lessonContent: 'A fraction names part of a whole when the parts are equal.',
    guidedPractice: 'Look at a shape split into equal parts and name the shaded part.',
    independentPractice: 'Draw a whole split into four equal parts and shade one part.',
    summary: 'Fractions help us describe equal parts clearly.',
    steps: [
      {
        id: 'ai-step-1',
        lessonId: 'lesson-missing',
        order: 1,
        type: 'story',
        title: 'A Shared Snack',
        body: 'Four friends share one snack equally.',
      },
      {
        id: 'ai-step-2',
        lessonId: 'lesson-missing',
        order: 2,
        type: 'imagePlaceholder',
        title: 'Equal Parts',
        body: 'Picture one rectangle split into four equal parts.',
        imageDescription: 'A rectangle divided into four equal parts.',
      },
      {
        id: 'ai-step-3',
        lessonId: 'lesson-missing',
        order: 3,
        type: 'explanation',
        title: 'What The Fraction Means',
        body: 'The bottom number tells how many equal parts make the whole.',
      },
      {
        id: 'ai-step-4',
        lessonId: 'lesson-missing',
        order: 4,
        type: 'question',
        title: 'Check',
        body: 'Name one part out of four equal parts.',
        prompt: 'What fraction names one out of four equal parts?',
        expectedAnswer: 'One fourth.',
      },
      {
        id: 'ai-step-5',
        lessonId: 'lesson-missing',
        order: 5,
        type: 'practice',
        title: 'Try It',
        body: 'Draw four equal parts and shade one.',
      },
      {
        id: 'ai-step-6',
        lessonId: 'lesson-missing',
        order: 6,
        type: 'summary',
        title: 'Wrap Up',
        body: 'A fraction names equal parts of a whole.',
      },
    ],
  };
}

async function seedRealBackedLesson(
  repo: ReturnType<typeof createFirestoreTestContext>['repo'],
  options: { includeStandard?: boolean; includeAnalysis?: boolean } = {},
) {
  const includeStandard = options.includeStandard ?? true;
  const includeAnalysis = options.includeAnalysis ?? true;
  const realStandardId = standardId('ca-common-core-math', '2025', '4.NF.A.1');

  await repo.saveCourseOffering({
    id: 'offering-real-backed',
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    courseMapId: 'course-map-real-backed',
    language: 'en',
    status: 'enabled',
    enabledForStudents: true,
  });
  await repo.saveCourseMap({
    id: 'course-map-real-backed',
    schoolId: 'school-demo',
    courseId: 'grade-4-math-real',
    language: 'en',
    curriculumVersionId: '2025',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    status: 'active',
  });
  await repo.saveUnitPlan({
    id: 'unit-real-backed',
    schoolId: 'school-demo',
    courseMapId: 'course-map-real-backed',
    courseId: 'grade-4-math-real',
    order: 1,
    status: 'active',
  });
  if (includeStandard) {
    await repo.saveCurriculumStandard({
      id: realStandardId,
      curriculumSourceId: 'ca-common-core-math',
      curriculumVersionId: '2025',
      code: '4.NF.A.1',
      title: 'Explain equivalent fractions.',
      description: 'Explain equivalent fractions using visual fraction models.',
      gradeLevelId: 'grade-4',
      subjectId: 'math',
      checksum: 'checksum-standard',
    });
  }
  if (includeAnalysis) {
    await repo.savePedagogicalAnalysis({
      pedagogicalAnalysisId: 'analysis-real-backed',
      standardId: realStandardId,
      curriculumSourceId: 'ca-common-core-math',
      curriculumVersionId: '2025',
      standardCode: '4.NF.A.1',
      language: 'en',
      gradeLevelId: 'grade-4',
      subjectId: 'math',
      prerequisites: ['understand fractions as parts of a whole'],
      targetSkills: ['explain equivalent fractions'],
      vocabularyTerms: ['equivalent fractions'],
      misconceptions: ['Students may compare only numerators.'],
      assessmentEvidence: ['student explains equivalence with a model'],
      languageProfile: {
        band: 'grade-4',
        sentenceComplexity: 'short compound sentences',
        vocabularySupport: 'define equivalent',
        scaffolding: 'use visual models',
      },
      validationStatus: 'valid',
      promptTemplateVersionIds: ['prompt-analysis-v1'],
      sourceGenerationRequestId: 'request-analysis-1',
      status: 'ready',
      createdAt: '2026-06-21T00:00:00.000Z',
      updatedAt: '2026-06-21T00:00:00.000Z',
    });
  }
  await repo.saveLessonSpecification({
    id: 'lesson-spec-real-backed',
    lessonId: 'lesson-real-backed',
    schoolId: 'school-demo',
    courseMapId: 'course-map-real-backed',
    courseId: 'grade-4-math-real',
    unitId: 'unit-real-backed',
    title: 'Explain equivalent fractions.',
    order: 1,
    estimatedDuration: '20m',
    difficultyLevel: 'introductory',
    language: 'en',
    generationStatus: 'not_generated',
    publishedContentId: null,
    status: 'active',
    standardIds: [realStandardId],
    pedagogicalAnalysisIds: ['analysis-real-backed'],
    learningObjectiveIds: ['objective-real-backed'],
    masteryDefinitionIds: ['mastery-real-backed'],
    assessmentBlueprintIds: ['assessment-real-backed'],
    lessonBlueprintIds: ['lesson-blueprint-real-backed'],
    targetSkills: ['explain equivalent fractions'],
    vocabularyTargets: ['equivalent fractions'],
    misconceptionTargets: ['Students may compare only numerators.'],
    prerequisiteLessonIds: [],
  });
}
