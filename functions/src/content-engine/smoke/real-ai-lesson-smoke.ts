import type {
  CourseMap,
  CourseOffering,
  LessonSpecification,
  PromptTemplateVersion,
  PublishedLessonStep,
  UnitPlan,
} from '../contracts.js';
import { MemoryDocumentStore } from '../firestore/document-store.js';
import { FirestoreContentEngineRepository } from '../repositories/firestore-content-engine-repository.js';
import { createFirestoreBackedContentEngineHandlers } from '../repository-runtime.js';

const supportedStepTypes = new Set<PublishedLessonStep['type']>([
  'story',
  'imagePlaceholder',
  'explanation',
  'question',
  'practice',
  'summary',
]);

async function main(): Promise<void> {
  const envCheck = validateEnvironment(process.env);
  if (!envCheck.ok) {
    console.error(envCheck.message);
    process.exitCode = 1;
    return;
  }

  const store = new MemoryDocumentStore();
  const repo = new FirestoreContentEngineRepository(store);
  await seedSmokeData(repo);

  const handlers = createFirestoreBackedContentEngineHandlers(repo, {
    env: {
      CONTENT_ENGINE_ENABLE_REAL_AI: process.env.CONTENT_ENGINE_ENABLE_REAL_AI,
      CONTENT_ENGINE_AI_PROVIDER: process.env.CONTENT_ENGINE_AI_PROVIDER,
      OPENAI_API_KEY: process.env.OPENAI_API_KEY,
      CONTENT_ENGINE_OPENAI_MODEL: process.env.CONTENT_ENGINE_OPENAI_MODEL,
      CONTENT_ENGINE_OPENAI_ENDPOINT: process.env.CONTENT_ENGINE_OPENAI_ENDPOINT,
      CONTENT_ENGINE_AI_FALLBACK_TO_FAKE: process.env.CONTENT_ENGINE_AI_FALLBACK_TO_FAKE,
    },
  });

  const response = await handlers.requestLessonContent({
    schoolId: 'school-demo',
    courseOfferingId: 'offering-smoke-grade-4-math-en',
    courseId: 'grade-4-math-smoke',
    lessonSpecificationId: 'lesson-spec-smoke-001',
    language: 'en',
  }, {
    userId: 'smoke-student-001',
    role: 'student',
    schoolId: 'school-demo',
  });

  if (response.status !== 'ready' || typeof response.publishedContentId !== 'string') {
    throw new Error(`Smoke test failed: expected ready response, received ${JSON.stringify(response)}`);
  }

  const published = await repo.getPublishedLessonContent(response.publishedContentId);
  if (!published) {
    throw new Error(`Smoke test failed: publishedLessonContent not found for ${response.publishedContentId}`);
  }

  const steps = published.steps ?? [];
  if (steps.length === 0) {
    throw new Error('Smoke test failed: published lesson has no steps.');
  }

  const unsupported = steps.find((step) => !supportedStepTypes.has(step.type));
  if (unsupported) {
    throw new Error(`Smoke test failed: unsupported step type ${unsupported.type}`);
  }

  const promptExecutions = await repo.listPromptExecutionRecords();
  const costRecords = await repo.listCostTrackingRecords();
  if (promptExecutions.length === 0) {
    throw new Error('Smoke test failed: no PromptExecutionRecord was written.');
  }
  if (costRecords.length === 0) {
    throw new Error('Smoke test failed: no CostTrackingRecord was written.');
  }

  const latestPromptExecution = promptExecutions[promptExecutions.length - 1];
  const latestCost = costRecords[costRecords.length - 1];

  console.log('Real AI lesson smoke test passed.');
  console.log(`publishedContentId: ${published.id}`);
  console.log(`title: ${published.title}`);
  console.log(`steps: ${steps.length}`);
  console.log(`provider: ${latestPromptExecution.provider}`);
  console.log(`model: ${latestPromptExecution.model}`);
  console.log(`promptTemplateVersionId: ${latestPromptExecution.promptTemplateVersionId}`);
  console.log(`estimatedInputTokens: ${latestCost.estimatedInputTokens}`);
  console.log(`estimatedOutputTokens: ${latestCost.estimatedOutputTokens}`);
  console.log(`estimatedCostUsd: ${latestCost.estimatedCostUsd}`);
}

function validateEnvironment(env: NodeJS.ProcessEnv): { ok: true } | { ok: false; message: string } {
  if (env.CONTENT_ENGINE_ENABLE_REAL_AI !== 'true') {
    return {
      ok: false,
      message: 'Real AI smoke test skipped safely: CONTENT_ENGINE_ENABLE_REAL_AI must be true.',
    };
  }
  if (env.CONTENT_ENGINE_AI_PROVIDER !== 'openai') {
    return {
      ok: false,
      message: 'Real AI smoke test skipped safely: CONTENT_ENGINE_AI_PROVIDER must be openai.',
    };
  }
  if (!env.OPENAI_API_KEY) {
    return {
      ok: false,
      message: 'Real AI smoke test skipped safely: OPENAI_API_KEY is required and was not provided.',
    };
  }

  return { ok: true };
}

async function seedSmokeData(repo: FirestoreContentEngineRepository): Promise<void> {
  const courseOffering: CourseOffering = {
    id: 'offering-smoke-grade-4-math-en',
    schoolId: 'school-demo',
    courseId: 'grade-4-math-smoke',
    courseMapId: 'course-map-smoke-grade-4-math-en',
    language: 'en',
    status: 'enabled',
    enabledForStudents: true,
  };
  const courseMap: CourseMap = {
    id: courseOffering.courseMapId,
    schoolId: courseOffering.schoolId,
    courseId: courseOffering.courseId,
    language: courseOffering.language,
    curriculumVersionId: 'ca-common-core-math-smoke-v1',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    title: 'Smoke Test Grade 4 Math',
    status: 'active',
  };
  const unitPlan: UnitPlan = {
    id: 'unit-smoke-grade-4-math-001',
    schoolId: courseOffering.schoolId,
    courseMapId: courseMap.id,
    courseId: courseOffering.courseId,
    order: 1,
    status: 'active',
  };
  const lessonSpecification: LessonSpecification = {
    id: 'lesson-spec-smoke-001',
    lessonId: 'lesson-smoke-001',
    schoolId: courseOffering.schoolId,
    courseMapId: courseMap.id,
    courseId: courseOffering.courseId,
    unitId: unitPlan.id,
    title: 'Fractions as Equal Parts',
    order: 1,
    estimatedDuration: '20m',
    difficultyLevel: 'introductory',
    language: courseOffering.language,
    generationStatus: 'not_generated',
    publishedContentId: null,
    status: 'active',
    standardIds: ['ccss-math-4-nf-a-1'],
    pedagogicalAnalysisIds: ['analysis-smoke-001'],
    learningObjectiveIds: ['objective-smoke-001'],
    masteryDefinitionIds: ['mastery-smoke-001'],
    assessmentBlueprintIds: ['assessment-blueprint-smoke-001'],
    lessonBlueprintIds: ['lesson-blueprint-smoke-001'],
    targetSkills: ['explain fractions as equal parts', 'identify numerator and denominator'],
    vocabularyTargets: ['fraction', 'whole', 'equal parts', 'numerator', 'denominator'],
    prerequisiteLessonIds: [],
  };
  const promptTemplate: PromptTemplateVersion = {
    id: 'prompt-template-lesson_content_generation-smoke-v1',
    templateId: 'prompt-template-lesson_content_generation-smoke',
    version: '1.0.0',
    taskType: 'lesson_content_generation',
    status: 'active',
    outputSchemaId: 'lesson-content-contract-v1',
    createdAt: new Date().toISOString(),
    promptText: [
      'Generate one concise Grade 4 lesson as strict JSON only.',
      'The JSON object must include: title, bigIdea, essentialQuestion, learningObjective, lessonContent, guidedPractice, independentPractice, summary, steps.',
      'steps must be a non-empty array. Each step must include id, lessonId, order, type, title, body.',
      'Allowed step type values are exactly: story, imagePlaceholder, explanation, question, practice, summary.',
      'Use imagePlaceholder, not image_placeholder.',
      'Do not include markdown fences or commentary.',
      'Lesson specification input: {{input}}',
    ].join('\n'),
  };

  await repo.saveCourseOffering(courseOffering);
  await repo.saveCourseMap(courseMap);
  await repo.saveUnitPlan(unitPlan);
  await repo.saveLessonSpecification(lessonSpecification);
  await repo.savePromptTemplateVersion(promptTemplate);
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : 'Real AI lesson smoke test failed safely.');
  process.exitCode = 1;
});
