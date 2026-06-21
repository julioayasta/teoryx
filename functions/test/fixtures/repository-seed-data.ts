import type {
  CallerContext,
  ContentGenerationRequest,
  CourseMap,
  CourseOffering,
  LessonArtifact,
  LessonSpecification,
  PresentationArtifact,
  PublishedLessonContent,
  UnitPlan,
  ValidationArtifact,
} from '../../src/content-engine/contracts.js';
import type { ContentEngineRepository } from '../../src/content-engine/repositories/content-engine-repository.js';

export const repoCallers = {
  student: { userId: 'student-demo-001', role: 'student', schoolId: 'school-demo' },
  planner: { userId: 'school-planner-001', role: 'school_planner', schoolId: 'school-demo' },
  reviewer: { userId: 'school-reviewer-001', role: 'school_reviewer', schoolId: 'school-demo' },
  publisher: { userId: 'school-publisher-001', role: 'school_publisher', schoolId: 'school-demo' },
  superAdmin: { userId: 'super-admin-001', role: 'super_admin' },
  crossSchool: { userId: 'cross-school-user-001', role: 'student', schoolId: 'school-other' },
} satisfies Record<string, CallerContext>;

export async function seedRepository(repo: ContentEngineRepository): Promise<void> {
  await addOfferingSet(repo, {
    offeringId: 'offering-available',
    courseId: 'grade-4-math',
    courseMapId: 'course-map-grade-4-math',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: true,
    withLessonSpecs: true,
  });

  await addOfferingSet(repo, {
    offeringId: 'offering-no-course-map',
    courseId: 'grade-4-ela',
    courseMapId: 'course-map-missing',
    language: 'en',
    enabled: true,
    withCourseMap: false,
    withUnitPlans: false,
    withLessonSpecs: false,
  });

  await addOfferingSet(repo, {
    offeringId: 'offering-no-units',
    courseId: 'grade-5-math',
    courseMapId: 'course-map-grade-5-math',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: false,
    withLessonSpecs: false,
  });

  await addOfferingSet(repo, {
    offeringId: 'offering-no-lessons',
    courseId: 'grade-5-ela',
    courseMapId: 'course-map-grade-5-ela',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: true,
    withLessonSpecs: false,
  });

  const published: PublishedLessonContent = {
    id: 'published-content-001',
    schoolId: 'school-demo',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-published',
    language: 'en',
    status: 'published',
    title: 'Published Fractions Lesson',
  };
  await repo.savePublishedLessonContent(published);
  await repo.saveLessonSpecification({
    ...validLessonSpec('lesson-spec-published', 'lesson-published', 3),
    title: 'Published Fractions Lesson',
    generationStatus: 'published',
    publishedContentId: published.id,
  });
  await repo.saveLessonSpecification({
    ...validLessonSpec('lesson-spec-invalid', 'lesson-invalid', 4),
    assessmentBlueprintIds: [],
  });

  const pendingRequest: ContentGenerationRequest = {
    id: 'request-pending-001',
    schoolId: 'school-demo',
    courseId: 'grade-4-math',
    lessonSpecificationId: 'lesson-spec-missing',
    idempotencyKey: 'school:school-demo:lesson-content:lesson-spec-missing:en',
    source: 'student_app',
    intent: 'fill_missing',
    publicationMode: 'auto_publish_after_validation',
    status: 'generating_lesson_artifact',
    studentVisibleStatus: 'pending',
    schoolPortalVisibleStatus: 'generating',
    publishedContentId: null,
  };
  await repo.saveGenerationRequest(pendingRequest);

  await seedValidPackage(repo);
  await seedInvalidPackage(repo);
}

async function addOfferingSet(
  repo: ContentEngineRepository,
  input: {
    offeringId: string;
    courseId: string;
    courseMapId: string;
    language: string;
    enabled: boolean;
    withCourseMap: boolean;
    withUnitPlans: boolean;
    withLessonSpecs: boolean;
  },
): Promise<void> {
  const offering: CourseOffering = {
    id: input.offeringId,
    schoolId: 'school-demo',
    courseId: input.courseId,
    courseMapId: input.courseMapId,
    language: input.language,
    status: input.enabled ? 'enabled' : 'disabled',
    enabledForStudents: input.enabled,
  };
  await repo.saveCourseOffering(offering);

  if (input.withCourseMap) {
    const courseMap: CourseMap = {
      id: input.courseMapId,
      schoolId: 'school-demo',
      courseId: input.courseId,
      language: input.language,
      status: 'active',
    };
    await repo.saveCourseMap(courseMap);
  }
  if (input.withUnitPlans) {
    const unit: UnitPlan = {
      id: `unit-${input.courseId}`,
      schoolId: 'school-demo',
      courseMapId: input.courseMapId,
      courseId: input.courseId,
      order: 1,
      status: 'active',
    };
    await repo.saveUnitPlan(unit);
  }
  if (input.withLessonSpecs) {
    await repo.saveLessonSpecification({
      ...validLessonSpec(`lesson-spec-${input.courseId}`, `lesson-${input.courseId}`, 1),
      courseId: input.courseId,
      courseMapId: input.courseMapId,
      unitId: `unit-${input.courseId}`,
      language: input.language,
    });
    if (input.courseId === 'grade-4-math') {
      await repo.saveLessonSpecification(validLessonSpec('lesson-spec-missing', 'lesson-missing', 2));
    }
  }
}

function validLessonSpec(id: string, lessonId: string, order: number): LessonSpecification {
  return {
    id,
    lessonId,
    schoolId: 'school-demo',
    courseMapId: 'course-map-grade-4-math',
    courseId: 'grade-4-math',
    unitId: 'unit-grade-4-math',
    title: `Lesson ${order}`,
    order,
    estimatedDuration: '20m',
    difficultyLevel: 'core',
    language: 'en',
    generationStatus: 'not_generated',
    publishedContentId: null,
    status: 'active',
    standardIds: ['standard-001'],
    pedagogicalAnalysisIds: ['analysis-001'],
    learningObjectiveIds: ['objective-001'],
    masteryDefinitionIds: ['mastery-001'],
    assessmentBlueprintIds: ['assessment-blueprint-001'],
    lessonBlueprintIds: ['lesson-blueprint-001'],
  };
}

async function seedValidPackage(repo: ContentEngineRepository): Promise<void> {
  const lessonArtifact: LessonArtifact = {
    id: 'lesson-artifact-valid',
    schoolId: 'school-demo',
    status: 'approved',
  };
  const validationArtifact: ValidationArtifact = {
    id: 'validation-artifact-valid',
    schoolId: 'school-demo',
    validationStatus: 'valid',
    validatedArtifactIds: ['lesson-artifact-valid', 'presentation-artifact-valid'],
  };
  const presentationArtifact: PresentationArtifact = {
    id: 'presentation-artifact-valid',
    schoolId: 'school-demo',
    lessonSpecificationId: 'lesson-spec-missing',
    version: '1.0',
    status: 'approved',
    validationArtifactId: validationArtifact.id,
    lessonArtifactId: lessonArtifact.id,
  };
  await repo.saveLessonArtifact(lessonArtifact);
  await repo.saveValidationArtifact(validationArtifact);
  await repo.savePresentationArtifact(presentationArtifact);
}

async function seedInvalidPackage(repo: ContentEngineRepository): Promise<void> {
  const validationArtifact: ValidationArtifact = {
    id: 'validation-artifact-invalid',
    schoolId: 'school-demo',
    validationStatus: 'invalid',
    validatedArtifactIds: ['presentation-artifact-invalid'],
  };
  const presentationArtifact: PresentationArtifact = {
    id: 'presentation-artifact-invalid',
    schoolId: 'school-demo',
    lessonSpecificationId: 'lesson-spec-missing',
    version: '1.0',
    status: 'validation_failed',
    validationArtifactId: validationArtifact.id,
  };
  await repo.saveValidationArtifact(validationArtifact);
  await repo.savePresentationArtifact(presentationArtifact);
}
