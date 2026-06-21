import { createHash } from 'node:crypto';

import type { AIProvider, AIRequest, AIResponse } from './types.js';
import { AIProviderError } from './types.js';

export class SafeFakeAIProvider implements AIProvider {
  readonly providerName = 'safe_fake';
  readonly model = 'safe-fake-deterministic-v1';

  async generate(request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse> {
    if (request.variables.failProvider === true) {
      throw new AIProviderError('Safe fake provider failure requested.', 'safe_fake_failure', false);
    }

    if (request.taskType === 'pedagogical_analysis_generation') {
      const content = JSON.stringify({
        prerequisites: ['Understand grade-level vocabulary', 'Recall prior related concepts'],
        targetSkills: ['Explain the standard in student-friendly language', 'Apply the standard to a concrete example'],
        vocabularyTerms: ['standard', 'evidence', 'strategy'],
        misconceptions: ['Students may confuse the procedure with the concept'],
        assessmentEvidence: ['Student explains the concept accurately', 'Student applies the skill in a new example'],
        languageProfile: {
          band: String(request.variables.gradeLevelId ?? 'grade-4'),
          sentenceComplexity: 'short compound sentences',
          vocabularySupport: 'define academic terms before use',
          scaffolding: 'use concrete examples before abstraction',
        },
      });

      return {
        content,
        rawOutput: { deterministic: true },
        estimatedInputTokens: estimateTokens(request.prompt),
        estimatedOutputTokens: estimateTokens(content),
        estimatedCostUsd: 0,
      };
    }

    const input = stableStringify({
      taskType: request.taskType,
      promptTemplateVersionId: request.promptTemplateVersionId,
      prompt: request.prompt,
      variables: request.variables,
    });
    const digest = createHash('sha256').update(input).digest('hex').slice(0, 16);
    const content = `SAFE_FAKE_OUTPUT:${request.taskType}:${request.promptTemplateVersionId}:${digest}`;

    return {
      content,
      rawOutput: { digest },
      estimatedInputTokens: estimateTokens(request.prompt),
      estimatedOutputTokens: estimateTokens(content),
      estimatedCostUsd: 0,
    };
  }
}

function estimateTokens(text: string): number {
  return Math.max(1, Math.ceil(text.length / 4));
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
