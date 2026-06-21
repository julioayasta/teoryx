import type { ContentGenerationJob, CourseMap, LessonSpecification, UnitPlan } from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';

export interface CoursePlanInput {
  requestId: string;
  schoolId: string;
  courseId: string;
  curriculumVersionId: string;
  language: string;
  gradeLevelId?: string;
  subjectId?: string;
}

export interface CoursePlanOutput {
  courseMap: CourseMap;
  unitPlans: UnitPlan[];
  lessonSpecifications: LessonSpecification[];
  job: ContentGenerationJob;
}

export async function runFakeCoursePlanWorker(repo: ContentEngineRepository, input: CoursePlanInput): Promise<CoursePlanOutput> {
  const courseMap = buildCourseMap(input);
  const existingMap = await repo.getCourseMap(courseMap.id);
  const existingUnits = await repo.listUnitPlans({
    schoolId: input.schoolId,
    courseId: input.courseId,
    courseMapId: courseMap.id,
  });
  const existingSpecs = await repo.listLessonSpecifications({
    schoolId: input.schoolId,
    courseId: input.courseId,
    courseMapId: courseMap.id,
    language: input.language,
  });

  if (!existingMap) await repo.saveCourseMap(courseMap);

  const unitPlans = buildUnitPlans(input, courseMap.id);
  for (const unitPlan of unitPlans) {
    if (!existingUnits.some((existing) => existing.id === unitPlan.id)) {
      await repo.saveUnitPlan(unitPlan);
    }
  }

  const lessonSpecifications = buildLessonSpecifications(input, courseMap.id);
  for (const lesson of lessonSpecifications) {
    if (!existingSpecs.some((existing) => existing.id === lesson.id)) {
      await repo.saveLessonSpecification(lesson);
    }
  }

  const now = new Date().toISOString();
  const job: ContentGenerationJob = {
    id: `job-course-plan-${input.schoolId}-${input.courseId}-${input.language}`,
    requestId: input.requestId,
    schoolId: input.schoolId,
    jobType: 'course_plan_generation',
    stage: 'fake_course_plan_generation',
    status: 'completed',
    attempt: 1,
    maxAttempts: 1,
    payload: {
      courseId: input.courseId,
      curriculumVersionId: input.curriculumVersionId,
      language: input.language,
      courseMapId: courseMap.id,
      unitPlanCount: unitPlans.length,
      lessonSpecificationCount: lessonSpecifications.length,
    },
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  };
  await repo.saveContentGenerationJob(job);

  return { courseMap, unitPlans, lessonSpecifications, job };
}

export function buildCourseMap(input: CoursePlanInput): CourseMap {
  return {
    id: `course-map-${input.schoolId}-${input.courseId}-${input.language}`,
    schoolId: input.schoolId,
    courseId: input.courseId,
    language: input.language,
    curriculumVersionId: input.curriculumVersionId,
    gradeLevelId: input.gradeLevelId,
    subjectId: input.subjectId,
    title: `Generated plan for ${input.courseId}`,
    status: 'active',
  };
}

function buildUnitPlans(input: CoursePlanInput, courseMapId: string): UnitPlan[] {
  return [1, 2].map((order) => ({
    id: `unit-${input.courseId}-${order}`,
    schoolId: input.schoolId,
    courseMapId,
    courseId: input.courseId,
    order,
    status: 'active',
  }));
}

function buildLessonSpecifications(input: CoursePlanInput, courseMapId: string): LessonSpecification[] {
  const unitOne = `unit-${input.courseId}-1`;
  const unitTwo = `unit-${input.courseId}-2`;
  return [1, 2, 3, 4, 5].map((order) => {
    const padded = String(order).padStart(3, '0');
    const id = `lesson-spec-${input.courseId}-${padded}`;
    const previousId = order > 1 ? `lesson-spec-${input.courseId}-${String(order - 1).padStart(3, '0')}` : null;
    return {
      id,
      lessonId: `lesson-${input.courseId}-${padded}`,
      schoolId: input.schoolId,
      courseMapId,
      courseId: input.courseId,
      unitId: order <= 3 ? unitOne : unitTwo,
      title: generatedTitle(order),
      order,
      estimatedDuration: order === 5 ? '30m' : '20m',
      difficultyLevel: order <= 2 ? 'introductory' : order === 5 ? 'challenging' : 'core',
      language: input.language,
      generationStatus: 'not_generated',
      publishedContentId: null,
      status: 'active',
      standardIds: [`standard-${input.courseId}-${padded}`],
      pedagogicalAnalysisIds: [`analysis-${input.courseId}-${padded}`],
      learningObjectiveIds: [`objective-${input.courseId}-${padded}`],
      masteryDefinitionIds: [`mastery-${input.courseId}-${padded}`],
      assessmentBlueprintIds: [`assessment-blueprint-${input.courseId}-${padded}`],
      lessonBlueprintIds: [`lesson-blueprint-${input.courseId}-${padded}`],
      targetSkills: [`skill-${order}-conceptual`, `skill-${order}-procedural`],
      vocabularyTargets: [`vocabulary-${order}-a`, `vocabulary-${order}-b`],
      prerequisiteLessonIds: previousId ? [previousId] : [],
    };
  });
}

function generatedTitle(order: number): string {
  const titles = [
    'Foundations and Key Ideas',
    'Guided Concept Practice',
    'Applying The Standard',
    'Checking For Understanding',
    'Review and Extension',
  ];
  return titles[order - 1] ?? `Generated Lesson ${order}`;
}
