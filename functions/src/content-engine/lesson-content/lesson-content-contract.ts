import type { PublishedLessonStep } from '../contracts.js';

export interface LessonContentContract {
  title: string;
  bigIdea: string;
  essentialQuestion: string;
  learningObjective: string;
  lessonContent: string;
  guidedPractice: string;
  independentPractice: string;
  summary: string;
  steps: PublishedLessonStep[];
}

const supportedStepTypes = new Set<PublishedLessonStep['type']>([
  'story',
  'imagePlaceholder',
  'explanation',
  'question',
  'practice',
  'summary',
]);

export function parseLessonContentContract(content: string): LessonContentContract {
  let parsed: unknown;
  try {
    parsed = JSON.parse(content);
  } catch {
    throw new LessonContentContractError('AI lesson output was not valid JSON.', 'invalid_json');
  }

  return validateLessonContentContract(parsed);
}

export function validateLessonContentContract(value: unknown): LessonContentContract {
  if (!isRecord(value)) {
    throw new LessonContentContractError('AI lesson output must be a JSON object.', 'invalid_contract');
  }

  const contract: LessonContentContract = {
    title: requiredString(value, 'title'),
    bigIdea: requiredString(value, 'bigIdea'),
    essentialQuestion: requiredString(value, 'essentialQuestion'),
    learningObjective: requiredString(value, 'learningObjective'),
    lessonContent: requiredString(value, 'lessonContent'),
    guidedPractice: requiredString(value, 'guidedPractice'),
    independentPractice: requiredString(value, 'independentPractice'),
    summary: requiredString(value, 'summary'),
    steps: validateSteps(value.steps),
  };

  return contract;
}

export class LessonContentContractError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'LessonContentContractError';
  }
}

function validateSteps(value: unknown): PublishedLessonStep[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new LessonContentContractError('AI lesson output must include at least one step.', 'invalid_steps');
  }

  return value.map((step, index) => {
    if (!isRecord(step)) {
      throw new LessonContentContractError('AI lesson step must be an object.', 'invalid_step');
    }

    const type = requiredString(step, 'type');
    if (!supportedStepTypes.has(type as PublishedLessonStep['type'])) {
      throw new LessonContentContractError(`Unsupported lesson step type: ${type}`, 'unsupported_step_type');
    }

    return {
      id: stringOrDefault(step.id, `ai-step-${index + 1}`),
      lessonId: stringOrDefault(step.lessonId, 'ai-generated-lesson'),
      order: numberOrDefault(step.order, index + 1),
      type: type as PublishedLessonStep['type'],
      title: requiredString(step, 'title'),
      body: requiredString(step, 'body'),
      prompt: optionalString(step.prompt),
      expectedAnswer: optionalString(step.expectedAnswer),
      imageDescription: optionalString(step.imageDescription),
    };
  });
}

function requiredString(record: Record<string, unknown>, key: string): string {
  const value = record[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new LessonContentContractError(`AI lesson output is missing ${key}.`, 'missing_required_field');
  }

  return value;
}

function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

function stringOrDefault(value: unknown, fallback: string): string {
  return typeof value === 'string' && value.length > 0 ? value : fallback;
}

function numberOrDefault(value: unknown, fallback: number): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}
