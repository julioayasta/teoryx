import type { ContentEngineStore, CourseOffering, LessonSpecification } from './contracts.js';

export interface CourseAvailabilityResult {
  available: boolean;
  reason?: string;
  offering?: CourseOffering;
  lessonSpecifications: LessonSpecification[];
}

export function resolveCourseAvailability(
  store: ContentEngineStore,
  input: { schoolId: string; courseId: string; courseOfferingId?: string; language: string },
): CourseAvailabilityResult {
  const offering = input.courseOfferingId
    ? store.courseOfferings.get(input.courseOfferingId)
    : [...store.courseOfferings.values()].find((candidate) =>
        candidate.schoolId === input.schoolId &&
        candidate.courseId === input.courseId &&
        candidate.language === input.language
      );

  if (!offering) return unavailable('course_not_available');
  if (offering.schoolId !== input.schoolId) return unavailable('course_not_available');
  if (offering.courseId !== input.courseId) return unavailable('course_not_available');
  if (offering.language !== input.language) return unavailable('course_not_available');
  if (!offering.enabledForStudents || offering.status !== 'enabled') return unavailable('course_not_available');

  const courseMap = store.courseMaps.get(offering.courseMapId);
  if (!courseMap || courseMap.schoolId !== input.schoolId || courseMap.courseId !== input.courseId) {
    return unavailable('course_plan_not_found');
  }
  if (courseMap.status !== 'active' && courseMap.status !== 'approved') return unavailable('course_plan_not_found');

  const unitPlans = [...store.unitPlans.values()].filter((unit) =>
    unit.schoolId === input.schoolId &&
    unit.courseId === input.courseId &&
    unit.courseMapId === courseMap.id &&
    (unit.status === 'active' || unit.status === 'approved')
  );
  if (unitPlans.length === 0) return unavailable('unit_plans_not_found');

  const lessonSpecifications = [...store.lessonSpecifications.values()]
    .filter((lesson) =>
      lesson.schoolId === input.schoolId &&
      lesson.courseId === input.courseId &&
      lesson.courseMapId === courseMap.id &&
      lesson.language === input.language &&
      (lesson.status === 'active' || lesson.status === 'approved')
    )
    .sort((a, b) => a.order - b.order);

  if (lessonSpecifications.length === 0) return unavailable('lesson_specification_not_found');

  return { available: true, offering, lessonSpecifications };
}

export function isLessonSpecificationValid(lesson: LessonSpecification): boolean {
  return lesson.standardIds.length > 0 &&
    lesson.pedagogicalAnalysisIds.length > 0 &&
    lesson.learningObjectiveIds.length > 0 &&
    lesson.masteryDefinitionIds.length > 0 &&
    lesson.assessmentBlueprintIds.length > 0 &&
    lesson.lessonBlueprintIds.length > 0;
}

function unavailable(reason: string): CourseAvailabilityResult {
  return { available: false, reason, lessonSpecifications: [] };
}
