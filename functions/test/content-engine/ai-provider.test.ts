import assert from 'node:assert/strict';
import test from 'node:test';

import { AIExecutionService } from '../../src/content-engine/ai/ai-execution-service.js';
import { ModelRoutingPolicy } from '../../src/content-engine/ai/model-routing-policy.js';
import { PromptResolver } from '../../src/content-engine/ai/prompt-resolver.js';
import { SafeFakeAIProvider } from '../../src/content-engine/ai/safe-fake-ai-provider.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';

function createService() {
  const context = createFirestoreTestContext();
  const provider = new SafeFakeAIProvider();
  const service = new AIExecutionService(
    context.repo,
    new PromptResolver(context.repo),
    new ModelRoutingPolicy(),
    new Map([[provider.providerName, provider]]),
  );

  return { context, provider, service };
}

test('SafeFakeAIProvider returns deterministic output', async () => {
  const provider = new SafeFakeAIProvider();
  const request = {
    schoolId: 'school-demo',
    taskType: 'lesson_content_generation',
    variables: { title: 'Fractions' },
    prompt: 'Generate {{title}}',
    promptTemplateVersionId: 'prompt-template-lesson-content-v1',
  };

  const first = await provider.generate(request);
  const second = await provider.generate(request);

  assert.equal(first.content, second.content);
  assert.equal(first.estimatedCostUsd, 0);
  assert.ok(first.content.includes('SAFE_FAKE_OUTPUT:lesson_content_generation'));
});

test('PromptResolver selects the expected active prompt template version', async () => {
  const { context } = createService();
  await context.repo.savePromptTemplateVersion({
    id: 'prompt-template-lesson-content-v2',
    templateId: 'prompt-template-lesson-content',
    version: '2.0.0',
    taskType: 'lesson_content_generation',
    status: 'active',
    promptText: 'Use official sources for {{input}}.',
    outputSchemaId: 'schema-lesson-content-v2',
    createdAt: '2026-06-21T00:00:00.000Z',
  });
  const resolver = new PromptResolver(context.repo);

  const result = await resolver.resolve(
    { taskType: 'lesson_content_generation' },
    { title: 'Fractions' },
  );

  assert.equal(result.template.id, 'prompt-template-lesson-content-v2');
  assert.equal(result.renderedPrompt.includes('Fractions'), true);
});

test('AIExecutionService persists prompt execution and cost records', async () => {
  const { context, service } = createService();

  const result = await service.execute({
    schoolId: 'school-demo',
    requestId: 'request-ai-success',
    taskType: 'lesson_content_generation',
    source: 'student_app',
    intent: 'fill_missing',
    variables: { title: 'Fractions' },
    timeoutMs: 1000,
    retry: { attempt: 1, maxRetries: 2 },
  });

  const promptExecutions = await context.repo.listPromptExecutionRecords();
  const costRecords = await context.repo.listCostTrackingRecords();

  assert.equal(result.promptExecutionRecord.status, 'succeeded');
  assert.ok(result.response?.content);
  assert.equal(promptExecutions.length, 1);
  assert.equal(costRecords.length, 1);
  assert.equal(promptExecutions[0].promptTemplateVersionId, 'prompt-template-lesson_content_generation-v1');
  assert.equal(promptExecutions[0].provider, 'safe_fake');
  assert.equal(promptExecutions[0].inputHash.length, 64);
  assert.equal(promptExecutions[0].outputHash?.length, 64);
  assert.equal(costRecords[0].promptExecutionRecordId, promptExecutions[0].id);
  assert.equal(costRecords[0].estimatedCostUsd, 0);
});

test('failed provider response records safe error details and cost record', async () => {
  const { context, service } = createService();

  const result = await service.execute({
    schoolId: 'school-demo',
    requestId: 'request-ai-failure',
    taskType: 'lesson_content_generation',
    source: 'school_admin_portal',
    intent: 'regenerate',
    variables: { failProvider: true },
    timeoutMs: 500,
    retry: { attempt: 2, maxRetries: 3 },
  });

  const promptExecutions = await context.repo.listPromptExecutionRecords();
  const costRecords = await context.repo.listCostTrackingRecords();

  assert.equal(result.response, undefined);
  assert.equal(result.promptExecutionRecord.status, 'failed');
  assert.equal(result.promptExecutionRecord.error?.code, 'safe_fake_failure');
  assert.equal(result.promptExecutionRecord.error?.message, 'Safe fake provider failure requested.');
  assert.equal(result.promptExecutionRecord.error?.retryable, false);
  assert.equal(promptExecutions.length, 1);
  assert.equal(costRecords.length, 1);
  assert.equal(costRecords[0].estimatedInputTokens, 0);
  assert.equal(costRecords[0].estimatedOutputTokens, 0);
});
