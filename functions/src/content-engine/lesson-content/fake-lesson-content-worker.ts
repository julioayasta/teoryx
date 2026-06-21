import type {
  ContentGenerationJob,
  LessonArtifact,
  LessonSpecification,
  PresentationArtifact,
  PublishedLessonContent,
  PublishedLessonStep,
  ValidationArtifact,
} from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';

export interface LessonContentInput {
  requestId: string;
  schoolId: string;
  courseId: string;
  language: string;
  lesson: LessonSpecification;
}

export interface LessonContentOutput {
  job: ContentGenerationJob;
  lessonArtifact: LessonArtifact;
  presentationArtifact: PresentationArtifact;
  validationArtifact: ValidationArtifact;
  publishedContent: PublishedLessonContent;
}

export async function runFakeLessonContentWorker(repo: ContentEngineRepository, input: LessonContentInput): Promise<LessonContentOutput> {
  const existingPublished = input.lesson.publishedContentId
    ? await repo.getPublishedLessonContent(input.lesson.publishedContentId)
    : undefined;
  if (existingPublished?.status === 'published') {
    const existingLessonArtifact = await repo.findLessonArtifactBySpecification({
      schoolId: input.schoolId,
      lessonSpecificationId: input.lesson.id,
    });
    const existingPresentationArtifact = await repo.findPresentationArtifactBySpecification({
      schoolId: input.schoolId,
      lessonSpecificationId: input.lesson.id,
    });
    const validationArtifact = existingPresentationArtifact?.validationArtifactId
      ? await repo.getValidationArtifact(existingPresentationArtifact.validationArtifactId)
      : undefined;
    return {
      job: await saveCompletedJob(repo, input, existingPublished.id),
      lessonArtifact: existingLessonArtifact ?? buildLessonArtifact(input),
      presentationArtifact: existingPresentationArtifact ?? buildPresentationArtifact(input, buildSteps(input.lesson), existingPublished.id),
      validationArtifact: validationArtifact ?? buildValidationArtifact(input, buildLessonArtifact(input).id, buildPresentationArtifact(input, buildSteps(input.lesson), existingPublished.id).id),
      publishedContent: existingPublished,
    };
  }

  const existingLessonArtifact = await repo.findLessonArtifactBySpecification({
    schoolId: input.schoolId,
    lessonSpecificationId: input.lesson.id,
  });
  const existingPresentationArtifact = await repo.findPresentationArtifactBySpecification({
    schoolId: input.schoolId,
    lessonSpecificationId: input.lesson.id,
  });

  if (existingPresentationArtifact?.publishedContentId) {
    const published = await repo.getPublishedLessonContent(existingPresentationArtifact.publishedContentId);
    if (published?.status === 'published') {
      await repo.updateLessonSpecification(input.lesson.id, {
        publishedContentId: published.id,
        generationStatus: 'published',
      });
      return {
        job: await saveCompletedJob(repo, input, published.id),
        lessonArtifact: existingLessonArtifact ?? buildLessonArtifact(input),
        presentationArtifact: existingPresentationArtifact,
        validationArtifact: existingPresentationArtifact.validationArtifactId
          ? (await repo.getValidationArtifact(existingPresentationArtifact.validationArtifactId)) ?? buildValidationArtifact(input, existingLessonArtifact?.id ?? buildLessonArtifact(input).id, existingPresentationArtifact.id)
          : buildValidationArtifact(input, existingLessonArtifact?.id ?? buildLessonArtifact(input).id, existingPresentationArtifact.id),
        publishedContent: published,
      };
    }
  }

  const lessonArtifact = existingLessonArtifact ?? buildLessonArtifact(input);
  await repo.saveLessonArtifact(lessonArtifact);

  const steps = buildSteps(input.lesson);
  const presentationArtifact = existingPresentationArtifact ?? buildPresentationArtifact(input, steps, publishedContentId(input.lesson.id));
  const validationArtifact = buildValidationArtifact(input, lessonArtifact.id, presentationArtifact.id);
  const publishedContent = buildPublishedContent(input, steps, presentationArtifact.publishedContentId ?? publishedContentId(input.lesson.id));

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

function buildLessonArtifact(input: LessonContentInput): LessonArtifact {
  return {
    id: `lesson-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    lessonSpecificationId: input.lesson.id,
    title: input.lesson.title,
    bigIdea: `Students connect ${input.lesson.title} to the selected standard.`,
    essentialQuestion: `How can we use ${input.lesson.title.toLowerCase()} to explain our thinking?`,
    learningObjective: `I can explain and practice ${input.lesson.title.toLowerCase()}.`,
    lessonContent: `This fake lesson introduces ${input.lesson.title} using a short guided explanation.`,
    guidedPractice: `Work through one example using ${input.lesson.title}.`,
    independentPractice: `Try a similar example and explain each step.`,
    summary: `Today you practiced ${input.lesson.title} and checked your understanding.`,
    status: 'generated',
  };
}

function buildPresentationArtifact(input: LessonContentInput, steps: PublishedLessonStep[], contentId: string): PresentationArtifact {
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

function buildValidationArtifact(input: LessonContentInput, lessonArtifactId: string, presentationArtifactId: string): ValidationArtifact {
  return {
    id: `validation-artifact-${input.lesson.id}`,
    schoolId: input.schoolId,
    validationStatus: 'valid',
    validatedArtifactIds: [lessonArtifactId, presentationArtifactId],
  };
}

function buildPublishedContent(input: LessonContentInput, steps: PublishedLessonStep[], contentId: string): PublishedLessonContent {
  const lessonArtifact = buildLessonArtifact(input);
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
    title: input.lesson.title,
    bigIdea: lessonArtifact.bigIdea,
    essentialQuestion: lessonArtifact.essentialQuestion,
    learningObjectiveId: input.lesson.learningObjectiveIds[0] ?? `objective-${input.lesson.id}`,
    learningObjective: lessonArtifact.learningObjective,
    lessonContent: lessonArtifact.lessonContent,
    guidedPractice: lessonArtifact.guidedPractice,
    independentPractice: lessonArtifact.independentPractice,
    summary: lessonArtifact.summary,
    steps,
    version: '1.0',
    createdAt: now,
    updatedAt: now,
  };
}

function buildSteps(lesson: LessonSpecification): PublishedLessonStep[] {
  return [
    {
      id: `${lesson.id}-step-1`,
      lessonId: lesson.lessonId,
      order: 1,
      type: 'story',
      title: 'A Quick Catch-Up',
      body: `Imagine you missed class when everyone learned ${lesson.title}. We will walk through it together.`,
    },
    {
      id: `${lesson.id}-step-2`,
      lessonId: lesson.lessonId,
      order: 2,
      type: 'imagePlaceholder',
      title: 'Picture The Idea',
      body: `Use this visual placeholder to think about ${lesson.title}.`,
      imageDescription: `A simple classroom diagram representing ${lesson.title}.`,
    },
    {
      id: `${lesson.id}-step-3`,
      lessonId: lesson.lessonId,
      order: 3,
      type: 'explanation',
      title: 'Teacher Explanation',
      body: `The key idea is to connect the standard to a clear example before practicing.`,
    },
    {
      id: `${lesson.id}-step-4`,
      lessonId: lesson.lessonId,
      order: 4,
      type: 'question',
      title: 'Check Your Thinking',
      body: `Pause and explain what ${lesson.title} means in your own words.`,
      prompt: `What is one important idea from ${lesson.title}?`,
      expectedAnswer: 'A clear explanation connected to the lesson idea.',
    },
    {
      id: `${lesson.id}-step-5`,
      lessonId: lesson.lessonId,
      order: 5,
      type: 'practice',
      title: 'Guided Practice',
      body: `Try one practice example using the same idea, then check your reasoning.`,
    },
    {
      id: `${lesson.id}-step-6`,
      lessonId: lesson.lessonId,
      order: 6,
      type: 'summary',
      title: 'Lesson Summary',
      body: `You practiced ${lesson.title}, explained your thinking, and prepared for the next lesson.`,
    },
  ];
}

async function saveCompletedJob(repo: ContentEngineRepository, input: LessonContentInput, publishedContentId: string): Promise<ContentGenerationJob> {
  const now = new Date().toISOString();
  const job: ContentGenerationJob = {
    id: `job-lesson-content-${input.lesson.id}`,
    requestId: input.requestId,
    schoolId: input.schoolId,
    jobType: 'lesson_content_generation',
    stage: 'fake_lesson_content_generation',
    status: 'completed',
    attempt: 1,
    maxAttempts: 1,
    payload: {
      courseId: input.courseId,
      lessonSpecificationId: input.lesson.id,
      publishedContentId,
    },
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  };
  await repo.saveContentGenerationJob(job);
  return job;
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
