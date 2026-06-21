import type {
  ContentGenerationJob,
  CourseMap,
  CurriculumStandard,
  LessonSpecification,
  PedagogicalAnalysis,
  UnitPlan,
} from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';

export interface AnalysisBackedCoursePlanInput {
  requestId: string;
  schoolId: string;
  courseId: string;
  curriculumSourceId: string;
  curriculumVersionId: string;
  language: string;
  gradeLevelId: string;
  subjectId: string;
  standards: CurriculumStandard[];
  analyses: PedagogicalAnalysis[];
}

export interface AnalysisBackedCoursePlanOutput {
  courseMap: CourseMap;
  unitPlans: UnitPlan[];
  lessonSpecifications: LessonSpecification[];
  job: ContentGenerationJob;
}

export class AnalysisBackedCoursePlanError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'AnalysisBackedCoursePlanError';
  }
}

export async function runAnalysisBackedCoursePlanWorker(
  repo: ContentEngineRepository,
  input: AnalysisBackedCoursePlanInput,
): Promise<AnalysisBackedCoursePlanOutput> {
  const orderedStandards = [...input.standards].sort((a, b) => a.code.localeCompare(b.code));
  const analysesByStandardId = new Map(input.analyses.map((analysis) => [analysis.standardId, analysis]));
  const missingAnalysis = orderedStandards.find((standard) => !analysesByStandardId.has(standard.id));
  if (missingAnalysis) {
    throw new AnalysisBackedCoursePlanError(
      `PedagogicalAnalysis is missing for standard ${missingAnalysis.id}.`,
      'pedagogical_analysis_missing',
    );
  }

  const courseMap = buildCourseMap(input);
  const existingMap = await repo.getCourseMap(courseMap.id);
  if (!existingMap) await repo.saveCourseMap(courseMap);

  const existingUnits = await repo.listUnitPlans({
    schoolId: input.schoolId,
    courseId: input.courseId,
    courseMapId: courseMap.id,
  });
  const unitPlans = buildUnitPlans(input, courseMap.id);
  for (const unitPlan of unitPlans) {
    if (!existingUnits.some((existing) => existing.id === unitPlan.id)) {
      await repo.saveUnitPlan(unitPlan);
    }
  }

  const existingSpecs = await repo.listLessonSpecifications({
    schoolId: input.schoolId,
    courseId: input.courseId,
    courseMapId: courseMap.id,
    language: input.language,
  });
  const lessonSpecifications = orderedStandards.map((standard, index) => {
    const analysis = analysesByStandardId.get(standard.id);
    if (!analysis) {
      throw new AnalysisBackedCoursePlanError(
        `PedagogicalAnalysis is missing for standard ${standard.id}.`,
        'pedagogical_analysis_missing',
      );
    }

    return buildLessonSpecification(input, courseMap.id, unitPlans, orderedStandards, standard, analysis, index);
  });

  for (const lesson of lessonSpecifications) {
    if (!existingSpecs.some((existing) => existing.id === lesson.id)) {
      await repo.saveLessonSpecification(lesson);
    }
  }

  const job = await saveCompletedJob(repo, input, courseMap.id, unitPlans.length, lessonSpecifications.length);
  return { courseMap, unitPlans, lessonSpecifications, job };
}

function buildCourseMap(input: AnalysisBackedCoursePlanInput): CourseMap {
  return {
    id: `course-map-${input.schoolId}-${input.courseId}-${input.curriculumVersionId}-${input.language}`,
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

function buildUnitPlans(input: AnalysisBackedCoursePlanInput, courseMapId: string): UnitPlan[] {
  return [1, 2].map((order) => ({
    id: `unit-${input.courseId}-${input.curriculumVersionId}-${order}`,
    schoolId: input.schoolId,
    courseMapId,
    courseId: input.courseId,
    order,
    status: 'active',
  }));
}

function buildLessonSpecification(
  input: AnalysisBackedCoursePlanInput,
  courseMapId: string,
  unitPlans: UnitPlan[],
  orderedStandards: CurriculumStandard[],
  standard: CurriculumStandard,
  analysis: PedagogicalAnalysis,
  index: number,
): LessonSpecification {
  const order = index + 1;
  const padded = String(order).padStart(3, '0');
  const id = `lesson-spec-${input.courseId}-${input.curriculumVersionId}-${normalizeIdSegment(standard.code)}`;
  const previousStandard = orderedStandards[index - 1];
  const previousId = previousStandard
    ? `lesson-spec-${input.courseId}-${input.curriculumVersionId}-${normalizeIdSegment(previousStandard.code)}`
    : null;
  const splitPoint = Math.ceil(orderedStandards.length / 2);
  const unit = order <= splitPoint ? unitPlans[0] : unitPlans[1];

  return {
    id,
    lessonId: `lesson-${input.courseId}-${input.curriculumVersionId}-${padded}`,
    schoolId: input.schoolId,
    courseMapId,
    courseId: input.courseId,
    unitId: unit.id,
    title: standard.title,
    order,
    estimatedDuration: '20m',
    difficultyLevel: order === 1 ? 'introductory' : 'core',
    language: input.language,
    generationStatus: 'not_generated',
    publishedContentId: null,
    status: 'active',
    standardIds: [standard.id],
    pedagogicalAnalysisIds: [analysis.pedagogicalAnalysisId],
    learningObjectiveIds: [`objective-${standard.id}`],
    masteryDefinitionIds: [`mastery-${standard.id}`],
    assessmentBlueprintIds: [`assessment-blueprint-${standard.id}`],
    lessonBlueprintIds: [`lesson-blueprint-${standard.id}`],
    targetSkills: analysis.targetSkills,
    vocabularyTargets: analysis.vocabularyTerms,
    misconceptionTargets: analysis.misconceptions,
    prerequisiteLessonIds: previousId ? [previousId] : [],
  };
}

async function saveCompletedJob(
  repo: ContentEngineRepository,
  input: AnalysisBackedCoursePlanInput,
  courseMapId: string,
  unitPlanCount: number,
  lessonSpecificationCount: number,
): Promise<ContentGenerationJob> {
  const now = new Date().toISOString();
  const job: ContentGenerationJob = {
    id: `job-course-plan-${input.schoolId}-${input.courseId}-${input.curriculumVersionId}-${input.language}`,
    requestId: input.requestId,
    schoolId: input.schoolId,
    jobType: 'course_plan_generation',
    stage: 'analysis_backed_course_plan_generation',
    status: 'completed',
    attempt: 1,
    maxAttempts: 1,
    payload: {
      courseId: input.courseId,
      curriculumSourceId: input.curriculumSourceId,
      curriculumVersionId: input.curriculumVersionId,
      language: input.language,
      courseMapId,
      unitPlanCount,
      lessonSpecificationCount,
    },
    createdAt: now,
    updatedAt: now,
    completedAt: now,
  };
  await repo.saveContentGenerationJob(job);
  return job;
}

function normalizeIdSegment(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}
