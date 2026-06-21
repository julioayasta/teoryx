import assert from 'node:assert/strict';
import test from 'node:test';

import type { AIProvider, AIRequest, AIResponse } from '../../src/content-engine/ai/types.js';
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
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider('not-json'),
  });

  const response = await requestMissingLesson(handlers);
  const validation = await context.repo.getValidationArtifact('validation-artifact-lesson-spec-missing');
  const lesson = await context.repo.getLessonSpecification('lesson-spec-missing');

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'invalid_json');
  assert.equal(validation?.validationStatus, 'invalid');
  assert.equal(lesson?.publishedContentId, null);
  assert.equal((await context.repo.listPublishedLessonContent()).length, 1);
  assert.equal((await context.repo.listPromptExecutionRecords()).length, 1);
  assert.equal((await context.repo.listCostTrackingRecords()).length, 1);
});

test('unsupported AI step type does not publish', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
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

  const response = await requestMissingLesson(handlers);
  const lesson = await context.repo.getLessonSpecification('lesson-spec-missing');

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'unsupported_step_type');
  assert.equal(lesson?.publishedContentId, null);
  assert.equal((await context.repo.listPublishedLessonContent()).length, 1);
});

test('valid mocked AI JSON publishes through artifacts and publishedLessonContent', async () => {
  const context = createFirestoreTestContext();
  await context.seed();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAIProvider(JSON.stringify(validLessonJson())),
  });

  const response = await requestMissingLesson(handlers);
  const published = await context.repo.getPublishedLessonContent(String(response.publishedContentId));
  const lessonArtifact = await context.repo.getLessonArtifact('lesson-artifact-lesson-spec-missing');
  const presentationArtifact = await context.repo.getPresentationArtifact('presentation-artifact-lesson-spec-missing');
  const validationArtifact = await context.repo.getValidationArtifact('validation-artifact-lesson-spec-missing');
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
