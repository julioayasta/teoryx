import type {
  CallerContext,
  ContentEngineStore,
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
import { createEmptyStore } from '../../src/content-engine/store.js';

export const callers = {
  student: { userId: 'student-demo-001', role: 'student', schoolId: 'school-demo' },
  planner: { userId: 'school-planner-001', role: 'school_planner', schoolId: 'school-demo' },
  reviewer: { userId: 'school-reviewer-001', role: 'school_reviewer', schoolId: 'school-demo' },
  publisher: { userId: 'school-publisher-001', role: 'school_publisher', schoolId: 'school-demo' },
  superAdmin: { userId: 'super-admin-001', role: 'super_admin' },
  system: { userId: 'system-worker-001', role: 'system' },
  unauthorized: { userId: 'unauthorized-001', role: 'unauthorized', schoolId: 'school-demo' },
  crossSchool: { userId: 'cross-school-user-001', role: 'student', schoolId: 'school-other' },
} satisfies Record<string, CallerContext>;

export function createSeededStore(): ContentEngineStore {
  const store = createEmptyStore();

  addOfferingSet(store, {
    offeringId: 'offering-available',
    courseId: 'grade-4-math',
    courseMapId: 'course-map-grade-4-math',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: true,
    withLessonSpecs: true,
  });

  addOfferingSet(store, {
    offeringId: 'offering-no-course-map',
    courseId: 'grade-4-ela',
    courseMapId: 'course-map-missing',
    language: 'en',
    enabled: true,
    withCourseMap: false,
    withUnitPlans: false,
    withLessonSpecs: false,
  });

  addOfferingSet(store, {
    offeringId: 'offering-no-units',
    courseId: 'grade-5-math',
    courseMapId: 'course-map-grade-5-math',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: false,
    withLessonSpecs: false,
  });

  addOfferingSet(store, {
    offeringId: 'offering-no-lessons',
    courseId: 'grade-5-ela',
    courseMapId: 'course-map-grade-5-ela',
    language: 'en',
    enabled: true,
    withCourseMap: true,
    withUnitPlans: true,
    withLessonSpecs: false,
  });

  addOfferingSet(store, {
    offeringId: 'offering-disabled',
    courseId: 'grade-3-math',
    courseMapId: 'course-map-grade-3-math',
    language: 'en',
    enabled: false,
    withCourseMap: true,
    withUnitPlans: true,
    withLessonSpecs: true,
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
  store.publishedLessonContent.set(published.id, published);
  store.lessonSpecifications.set('lesson-spec-published', {
    ...validLessonSpec('lesson-spec-published', 'lesson-published', 3),
    title: 'Published Fractions Lesson',
    generationStatus: 'published',
    publishedContentId: published.id,
  });
  store.lessonSpecifications.set('lesson-spec-invalid', {
    ...validLessonSpec('lesson-spec-invalid', 'lesson-invalid', 4),
    assessmentBlueprintIds: [],
  });
  store.lessonSpecifications.set('lesson-spec-inactive', {
    ...validLessonSpec('lesson-spec-inactive', 'lesson-inactive', 5),
    status: 'archived',
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
  store.generationRequests.set(pendingRequest.id, pendingRequest);

  const readyForReviewRequest: ContentGenerationRequest = {
    ...pendingRequest,
    id: 'request-review-001',
    idempotencyKey: 'school:school-demo:school-lesson-generation:lesson-spec-missing:create_new',
    source: 'school_admin_portal',
    status: 'ready_for_review',
    studentVisibleStatus: 'pending',
    schoolPortalVisibleStatus: 'ready_for_review',
  };
  store.generationRequests.set(readyForReviewRequest.id, readyForReviewRequest);

  seedValidPackage(store);
  seedInvalidPackage(store);

  return store;
}

function addOfferingSet(
  store: ContentEngineStore,
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
): void {
  const offering: CourseOffering = {
    id: input.offeringId,
    schoolId: 'school-demo',
    courseId: input.courseId,
    courseMapId: input.courseMapId,
    language: input.language,
    status: input.enabled ? 'enabled' : 'disabled',
    enabledForStudents: input.enabled,
  };
  store.courseOfferings.set(offering.id, offering);

  if (input.withCourseMap) {
    const courseMap: CourseMap = {
      id: input.courseMapId,
      schoolId: 'school-demo',
      courseId: input.courseId,
      language: input.language,
      status: 'active',
    };
    store.courseMaps.set(courseMap.id, courseMap);
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
    store.unitPlans.set(unit.id, unit);
  }

  if (input.withLessonSpecs) {
    store.lessonSpecifications.set(`lesson-spec-${input.courseId}`, {
      ...validLessonSpec(`lesson-spec-${input.courseId}`, `lesson-${input.courseId}`, 1),
      courseId: input.courseId,
      courseMapId: input.courseMapId,
      unitId: `unit-${input.courseId}`,
      language: input.language,
    });
    if (input.courseId === 'grade-4-math') {
      store.lessonSpecifications.set('lesson-spec-missing', validLessonSpec('lesson-spec-missing', 'lesson-missing', 2));
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

function seedValidPackage(store: ContentEngineStore): void {
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
  store.lessonArtifacts.set(lessonArtifact.id, lessonArtifact);
  store.validationArtifacts.set(validationArtifact.id, validationArtifact);
  store.presentationArtifacts.set(presentationArtifact.id, presentationArtifact);
}

function seedInvalidPackage(store: ContentEngineStore): void {
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
  store.validationArtifacts.set(validationArtifact.id, validationArtifact);
  store.presentationArtifacts.set(presentationArtifact.id, presentationArtifact);
}
