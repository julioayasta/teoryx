import { createHash } from 'node:crypto';

import type { CostTrackingRecord, PromptExecutionRecord } from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';
import type { ModelRoutingPolicy } from './model-routing-policy.js';
import type { PromptResolver } from './prompt-resolver.js';
import type { AIProvider, AIRequest, AIResponse } from './types.js';
import { AIProviderError } from './types.js';

export interface AIExecutionResult {
  response?: AIResponse;
  promptExecutionRecord: PromptExecutionRecord;
  costTrackingRecord: CostTrackingRecord;
}

export class AIExecutionService {
  constructor(
    private readonly repo: ContentEngineRepository,
    private readonly promptResolver: PromptResolver,
    private readonly routingPolicy: ModelRoutingPolicy,
    private readonly providers: Map<string, AIProvider>,
  ) {}

  async execute(request: AIRequest): Promise<AIExecutionResult> {
    const startedAt = new Date().toISOString();
    const route = this.routingPolicy.select({
      taskType: request.taskType,
      source: request.source,
      intent: request.intent,
    });
    const provider = this.providers.get(route.provider);
    if (!provider) {
      throw new AIProviderError(`AI provider is not registered: ${route.provider}`, 'provider_not_registered', false);
    }

    const promptResolution = await this.promptResolver.resolve(
      {
        taskType: request.taskType,
        promptTemplateVersionId: request.promptTemplateVersionId,
      },
      {
        ...request.variables,
        taskType: request.taskType,
      },
    );
    const promptRequest = {
      ...request,
      prompt: promptResolution.renderedPrompt,
      promptTemplateVersionId: promptResolution.template.id,
    };
    const inputHash = hashStableJson({
      prompt: promptRequest.prompt,
      promptTemplateVersionId: promptRequest.promptTemplateVersionId,
      variables: request.variables,
    });

    try {
      const response = await provider.generate(promptRequest);
      const completedAt = new Date().toISOString();
      const promptExecutionRecord: PromptExecutionRecord = {
        id: recordId('prompt-execution', request, inputHash),
        schoolId: request.schoolId,
        requestId: request.requestId,
        artifactId: request.artifactId,
        provider: provider.providerName,
        model: route.model,
        promptTemplateVersionId: promptResolution.template.id,
        inputHash,
        outputHash: hashStableJson(response.content),
        estimatedInputTokens: response.estimatedInputTokens,
        estimatedOutputTokens: response.estimatedOutputTokens,
        estimatedCostUsd: response.estimatedCostUsd,
        status: 'succeeded',
        timeoutMs: request.timeoutMs,
        retryAttempt: request.retry?.attempt ?? 1,
        maxRetries: request.retry?.maxRetries ?? 0,
        createdAt: startedAt,
        completedAt,
      };
      const costTrackingRecord = buildCostRecord(request, promptExecutionRecord, response, completedAt);

      await this.repo.savePromptExecutionRecord(promptExecutionRecord);
      await this.repo.saveCostTrackingRecord(costTrackingRecord);

      return { response, promptExecutionRecord, costTrackingRecord };
    } catch (error) {
      const safeError = toSafeProviderError(error);
      const completedAt = new Date().toISOString();
      const promptExecutionRecord: PromptExecutionRecord = {
        id: recordId('prompt-execution', request, inputHash),
        schoolId: request.schoolId,
        requestId: request.requestId,
        artifactId: request.artifactId,
        provider: provider.providerName,
        model: route.model,
        promptTemplateVersionId: promptResolution.template.id,
        inputHash,
        status: 'failed',
        error: safeError,
        timeoutMs: request.timeoutMs,
        retryAttempt: request.retry?.attempt ?? 1,
        maxRetries: request.retry?.maxRetries ?? 0,
        createdAt: startedAt,
        completedAt,
      };
      const costTrackingRecord = buildCostRecord(request, promptExecutionRecord, undefined, completedAt);

      await this.repo.savePromptExecutionRecord(promptExecutionRecord);
      await this.repo.saveCostTrackingRecord(costTrackingRecord);

      return { promptExecutionRecord, costTrackingRecord };
    }
  }
}

function buildCostRecord(
  request: AIRequest,
  promptExecutionRecord: PromptExecutionRecord,
  response: AIResponse | undefined,
  createdAt: string,
): CostTrackingRecord {
  return {
    id: `cost-${promptExecutionRecord.id}`,
    schoolId: request.schoolId,
    requestId: request.requestId,
    promptExecutionRecordId: promptExecutionRecord.id,
    provider: promptExecutionRecord.provider,
    model: promptExecutionRecord.model,
    estimatedInputTokens: response?.estimatedInputTokens ?? 0,
    estimatedOutputTokens: response?.estimatedOutputTokens ?? 0,
    estimatedCostUsd: response?.estimatedCostUsd ?? 0,
    createdAt,
  };
}

function toSafeProviderError(error: unknown): PromptExecutionRecord['error'] {
  if (error instanceof AIProviderError) {
    return {
      code: error.code,
      message: error.message,
      retryable: error.retryable,
    };
  }

  return {
    code: 'provider_error',
    message: 'AI provider execution failed.',
    retryable: false,
  };
}

function recordId(prefix: string, request: AIRequest, inputHash: string): string {
  const requestPart = request.requestId ?? request.artifactId ?? request.taskType;
  return `${prefix}-${request.schoolId}-${requestPart}-${inputHash.slice(0, 12)}`;
}

function hashStableJson(value: unknown): string {
  return createHash('sha256').update(stableStringify(value)).digest('hex');
}

function stableStringify(value: unknown): string {
  return JSON.stringify(sortForStableStringify(value));
}

function sortForStableStringify(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortForStableStringify);
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortForStableStringify(nested)]),
    );
  }

  return value;
}
