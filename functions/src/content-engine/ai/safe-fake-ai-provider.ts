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

    if (request.taskType === 'lesson_content_generation') {
      const lesson = lessonVariables(request.variables);
      const title = lesson.title;
      const content = JSON.stringify({
        title,
        bigIdea: `Students connect ${title} to the selected standard.`,
        essentialQuestion: `How can we use ${title.toLowerCase()} to explain our thinking?`,
        learningObjective: `I can explain and practice ${title.toLowerCase()}.`,
        lessonContent: `This safe fake lesson introduces ${title} using a short guided explanation.`,
        guidedPractice: `Work through one example using ${title}.`,
        independentPractice: 'Try a similar example and explain each step.',
        summary: `Today you practiced ${title} and checked your understanding.`,
        steps: [
          {
            id: `${lesson.lessonId}-story`,
            lessonId: lesson.lessonId,
            order: 1,
            type: 'story',
            title: 'A Quick Catch-Up',
            body: `Sofia is getting ready to learn ${title}.`,
          },
          {
            id: `${lesson.lessonId}-image`,
            lessonId: lesson.lessonId,
            order: 2,
            type: 'imagePlaceholder',
            title: 'Picture The Idea',
            body: `Imagine a clear visual model for ${title}.`,
          },
          {
            id: `${lesson.lessonId}-explanation`,
            lessonId: lesson.lessonId,
            order: 3,
            type: 'explanation',
            title: 'Teacher Explanation',
            body: `Use the model to explain ${title} one step at a time.`,
          },
          {
            id: `${lesson.lessonId}-question`,
            lessonId: lesson.lessonId,
            order: 4,
            type: 'question',
            title: 'Check Your Thinking',
            body: `What is one thing you notice about ${title}?`,
            prompt: `Explain ${title} in your own words.`,
          },
          {
            id: `${lesson.lessonId}-practice`,
            lessonId: lesson.lessonId,
            order: 5,
            type: 'practice',
            title: 'Guided Practice',
            body: `Try one example and explain how it shows ${title}.`,
          },
          {
            id: `${lesson.lessonId}-summary`,
            lessonId: lesson.lessonId,
            order: 6,
            type: 'summary',
            title: 'Lesson Summary',
            body: `You practiced ${title} and explained your reasoning.`,
          },
        ],
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

function lessonVariables(variables: Record<string, unknown>): { lessonId: string; title: string } {
  const lessonSpecification = variables.lessonSpecification;
  if (lessonSpecification && typeof lessonSpecification === 'object') {
    const values = lessonSpecification as Record<string, unknown>;
    return {
      lessonId: typeof values.lessonId === 'string' ? values.lessonId : 'lesson-safe-fake',
      title: typeof values.title === 'string' ? values.title : 'the lesson concept',
    };
  }

  return {
    lessonId: 'lesson-safe-fake',
    title: 'the lesson concept',
  };
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
