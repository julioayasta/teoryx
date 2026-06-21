import type {
  ContentGenerationJob,
  LessonArtifact,
  LessonSpecification,
  PresentationArtifact,
  PublishedLessonContent,
  PublishedLessonStep,
  ValidationArtifact,
} from '../contracts.js';
import type { AIExecutionService } from '../ai/ai-execution-service.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';
import {
  LessonContentContractError,
  parseLessonContentContract,
  type LessonContentContract,
} from './lesson-content-contract.js';

export interface AILessonContentInput {
  requestId: string;
  schoolId: string;
  courseId: string;
  language: string;
  lesson: LessonSpecification;
}

export interface AILessonContentOutput {
  job: ContentGenerationJob;
  lessonArtifact: LessonArtifact;
  presentationArtifact: PresentationArtifact;
  validationArtifact: ValidationArtifact;
  publishedContent: PublishedLessonContent;
}

export class AILessonContentGenerationError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'AILessonContentGenerationError';
  }
}

export async function runAILessonContentWorker(
  repo: ContentEngineRepository,
  ai: AIExecutionService,
  input: AILessonContentInput,
): Promise<AILessonContentOutput> {
  const existingPublished = input.lesson.publishedContentId
    ? await repo.getPublishedLessonContent(input.lesson.publishedContentId)
    : undefined;
  if (existingPublished?.status === 'published') {
    throw new AILessonContentGenerationError('Published content already exists.', 'published_content_exists');
  }

  const execution = await ai.execute({
    schoolId: input.schoolId,
    requestId: input.requestId,
    artifactId: `lesson-artifact-${input.lesson.id}`,
    taskType: 'lesson_content_generation',
    source: 'student_app',
    intent: 'fill_missing',
    language: input.language,
    variables: {
      lessonSpecificationId: input.lesson.id,
      lessonId: input.lesson.lessonId,
      courseId: input.courseId,
      title: input.lesson.title,
      standardIds: input.lesson.standardIds,
      targetSkills: input.lesson.targetSkills ?? [],
      vocabularyTargets: input.lesson.vocabularyTargets ?? [],
      requiredStepTypes: [
        'story',
        'imagePlaceholder',
        'explanation',
        'question',
        'practice',
        'summary',
      ],
    },
    timeoutMs: 30000,
    retry: { attempt: 1, maxRetries: 0 },
  });

  if (!execution.response) {
    await saveFailedJob(repo, input, 'ai_provider_failed');
    throw new AILessonContentGenerationError('AI provider failed safely.', 'ai_provider_failed');
  }

  let contract: LessonContentContract;
  try {
    contract = parseLessonContentContract(execution.response.content);
  } catch (error) {
    const code = error instanceof LessonContentContractError ? error.code : 'invalid_ai_output';
    await saveInvalidValidation(repo, input, code);
    await saveFailedJob(repo, input, code);
    throw new AILessonContentGenerationError('AI lesson output failed validation.', code);
  }

  const lessonArtifact = buildLessonArtifact(input, contract);
  const steps = contract.steps.map((step) => ({
    ...step,
    lessonId: input.lesson.lessonId,
  }));
  const presentationArtifact = buildPresentationArtifact(input, steps, publishedContentId(input.lesson.id));
  const validationArtifact = buildValidationArtifact(input, lessonArtifact.id, presentationArtifact.id);
  const publishedContent = buildPublishedContent(input, contract, steps, presentationArtifact.publishedContentId ?? publishedContentId(input.lesson.id));

  await repo.saveLessonArtifact(lessonArtifact);
  await repo.saveValidationArtifact(validationArtifact);
  await repo.savePresentationArtifact({
    ...presentationArtifact,
    validationArtifactId: validationArtifact.id,
    lessonArtifactId: lessonArtifact.id,
    publishedContentId: publishedContent.id,
    status: 'published',
  });
  await repo.saveLessonArtifact({ ...lessonArtifact, status: 'published' });
  await repo.savePublishedLessonContent(publishedContent);
  await repo.updateLessonSpecification(input.lesson.id, {
    publishedContentId: publishedContent.id,
    generationStatus: 'published',
  });

  return {
    job: await saveCompletedJob(repo, input, publishedContent.id),
    lessonArtifact: { ...lessonArtifact, status: 'published' },
    presentationArtifact: {
      ...presentationArtifact,
      validationArtifactId: validationArtifact.id,
      lessonArtifactId: lessonArtifact.id,
      publishedContentId: publishedContent.id,
      status: 'published',
    },
    validationArtifact,
    publishedContent,
  };
}

function buildLessonArtifact(input: AILessonContentInput, contract: LessonContentContract): LessonArtifact {
  return {
    id: `lesson-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    lessonSpecificationId: input.lesson.id,
    title: contract.title,
    bigIdea: contract.bigIdea,
    essentialQuestion: contract.essentialQuestion,
    learningObjective: contract.learningObjective,
    lessonContent: contract.lessonContent,
    guidedPractice: contract.guidedPractice,
    independentPractice: contract.independentPractice,
    summary: contract.summary,
    status: 'generated',
  };
}

function buildPresentationArtifact(input: AILessonContentInput, steps: PublishedLessonStep[], contentId: string): PresentationArtifact {
  return {
    id: `presentation-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    lessonSpecificationId: input.lesson.id,
    version: '1.0',
    status: 'generated',
    publishedContentId: contentId,
    blocks: steps,
  };
}

function buildValidationArtifact(input: AILessonContentInput, lessonArtifactId: string, presentationArtifactId: string): ValidationArtifact {
  return {
    id: `validation-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    validationStatus: 'valid',
    validatedArtifactIds: [lessonArtifactId, presentationArtifactId],
  };
}

function buildPublishedContent(
  input: AILessonContentInput,
  contract: LessonContentContract,
  steps: PublishedLessonStep[],
  contentId: string,
): PublishedLessonContent {
  const standardId = input.lesson.standardIds[0] ?? `standard-${input.lesson.id}`;
  const now = new Date().toISOString();
  return {
    id: contentId,
    publishedContentId: contentId,
    schoolId: input.schoolId,
    courseId: input.courseId,
    lessonSpecificationId: input.lesson.id,
    curriculumId: `curriculum-${input.courseId}`,
    gradeLevelId: gradeLevelFromCourse(input.courseId),
    subjectId: subjectFromCourse(input.courseId),
    standardId,
    standardCode: standardId.toUpperCase(),
    language: input.language,
    status: 'published',
    title: contract.title,
    bigIdea: contract.bigIdea,
    essentialQuestion: contract.essentialQuestion,
    learningObjectiveId: input.lesson.learningObjectiveIds[0] ?? `objective-${input.lesson.id}`,
    learningObjective: contract.learningObjective,
    lessonContent: contract.lessonContent,
    guidedPractice: contract.guidedPractice,
    independentPractice: contract.independentPractice,
    summary: contract.summary,
    steps,
    version: '1.0',
    createdAt: now,
    updatedAt: now,
  };
}

async function saveCompletedJob(repo: ContentEngineRepository, input: AILessonContentInput, contentId: string): Promise<ContentGenerationJob> {
  const now = new Date().toISOString();
  const job: ContentGenerationJob = {
    id: `job-lesson-content-${input.lesson.id}`,
    requestId: input.requestId,
    schoolId: input.schoolId,
    jobType: 'lesson_content_generation',
    stage: 'ai_lesson_content_generation',
    status: 'completed',
    attempt: 1,
    maxAttempts: 1,
    payload: {
      courseId: input.courseId,
      lessonSpecificationId: input.lesson.id,
      publishedContentId: contentId,
    },
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  };
  await repo.saveContentGenerationJob(job);
  return job;
}

async function saveFailedJob(repo: ContentEngineRepository, input: AILessonContentInput, errorCode: string): Promise<void> {
  const now = new Date().toISOString();
  await repo.saveContentGenerationJob({
    id: `job-lesson-content-${input.lesson.id}`,
    requestId: input.requestId,
    schoolId: input.schoolId,
    jobType: 'lesson_content_generation',
    stage: 'ai_lesson_content_generation',
    status: 'failed',
    attempt: 1,
    maxAttempts: 1,
    payload: {
      courseId: input.courseId,
      lessonSpecificationId: input.lesson.id,
      errorCode,
    },
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  });
}

async function saveInvalidValidation(repo: ContentEngineRepository, input: AILessonContentInput, errorCode: string): Promise<void> {
  await repo.saveValidationArtifact({
    id: `validation-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    validationStatus: 'invalid',
    validatedArtifactIds: [`ai-output-${input.lesson.id}`, errorCode],
  });
}

function publishedContentId(lessonSpecificationId: string): string {
  return `published-content-${lessonSpecificationId}`;
}

function gradeLevelFromCourse(courseId: string): string {
  const match = courseId.match(/grade-\d+/);
  return match?.[0] ?? 'grade-4';
}

function subjectFromCourse(courseId: string): string {
  if (courseId.includes('ela')) return 'ela';
  if (courseId.includes('science')) return 'science';
  return 'math';
}
