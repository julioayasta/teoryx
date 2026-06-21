import type {
  AuditRecord,
  CallableName,
  CallableRequest,
  CallableResponse,
  CallerContext,
  ContentGenerationRequest,
  LessonSpecification,
  ProvenanceRecord,
  PublicationRecord,
  PublishedLessonContent,
  VersionHistoryRecord,
} from './contracts.js';
import { runFakeCoursePlanWorker } from './course-plan/fake-course-plan-worker.js';
import { runFakeLessonContentWorker } from './lesson-content/fake-lesson-content-worker.js';
import { canAccessSchool, canCall } from './permissions.js';
import { statusResponseForCaller } from './status.js';
import type { ContentEngineRepository } from './repositories/content-engine-repository.js';

export type RepositoryHandler = (request: CallableRequest, caller: CallerContext) => Promise<CallableResponse>;

export function createFirestoreBackedContentEngineHandlers(repo: ContentEngineRepository): Record<CallableName, RepositoryHandler> {
  return {
    requestCoursePlanGeneration: (request, caller) => requestCoursePlanGeneration(repo, request, caller),
    getCoursePlanStatus: (request, caller) => getCoursePlanStatus(repo, request, caller),
    publishCourseOffering: (request, caller) => publishCourseOffering(repo, request, caller),
    getLessonSpecificationsForCourse: (request, caller) => getLessonSpecificationsForCourse(repo, request, caller),
    requestLessonContent: (request, caller) => requestLessonContent(repo, request, caller),
    getContentGenerationStatus: (request, caller) => getContentGenerationStatus(repo, request, caller),
    requestSchoolLessonGeneration: (request, caller) => requestSchoolLessonGeneration(repo, request, caller),
    requestArtifactRegeneration: (request, caller) => requestArtifactRegeneration(repo, request, caller),
    approveArtifactForPublication: (request, caller) => approveArtifactForPublication(repo, request, caller),
    publishValidatedArtifact: (request, caller) => publishValidatedArtifact(repo, request, caller),
  };
}

async function requestCoursePlanGeneration(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestCoursePlanGeneration', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const language = requiredString(request, 'language');
    const curriculumVersionId = requiredString(request, 'curriculumVersionId');
    const gradeLevelId = optionalString(request, 'gradeLevelId');
    const subjectId = optionalString(request, 'subjectId');
    const idempotencyKey = `school:${schoolId}:course-plan:${courseId}:${curriculumVersionId}:${language}`;
    const generationRequest = await createOrReusePendingRequest(repo, caller, {
      schoolId,
      courseId,
      idempotencyKey,
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent: 'create_new',
      publicationMode: 'require_review',
    });
    const output = await runFakeCoursePlanWorker(repo, {
      requestId: generationRequest.id,
      schoolId,
      courseId,
      curriculumVersionId,
      language,
      gradeLevelId,
      subjectId,
    });
    const existingOffering = await repo.findCourseOffering({ schoolId, courseId, language });
    await repo.saveCourseOffering({
      id: existingOffering?.id ?? `offering-${schoolId}-${courseId}-${language}`,
      schoolId,
      courseId,
      courseMapId: output.courseMap.id,
      language,
      status: existingOffering?.status === 'enabled' ? 'enabled' : 'draft',
      enabledForStudents: existingOffering?.enabledForStudents ?? false,
    });
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'course_plan_generated',
      targetType: 'courseMap',
      targetId: output.courseMap.id,
      sourceIds: [generationRequest.id, output.job.id, ...output.unitPlans.map((unit) => unit.id), ...output.lessonSpecifications.map((lesson) => lesson.id)],
      versionChangeType: 'generated',
    });
    return {
      status: 'ready',
      requestId: generationRequest.id,
      courseMapId: output.courseMap.id,
      unitPlanCount: output.unitPlans.length,
      lessonSpecificationCount: output.lessonSpecifications.length,
      message: 'Course plan generation completed with fake deterministic output.',
    };
  } catch (error) {
    return failure(error);
  }
}

async function getCoursePlanStatus(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getCoursePlanStatus', caller, schoolId);
    const requestId = requiredString(request, 'requestId');
    const generationRequest = await repo.getGenerationRequest(requestId);
    if (!generationRequest || generationRequest.schoolId !== schoolId) {
      return { status: 'failed', errorCode: 'course_plan_not_found', message: 'Course plan request was not found.' };
    }
    return {
      status: generationRequest.schoolPortalVisibleStatus ?? generationRequest.status,
      requestId,
      courseMapId: null,
      message: 'Course plan status is available.',
    };
  } catch (error) {
    return failure(error);
  }
}

async function publishCourseOffering(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('publishCourseOffering', caller, schoolId);
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const offering = await repo.getCourseOffering(courseOfferingId);
    if (!offering || offering.schoolId !== schoolId) return failed('course_not_available', 'Course offering was not found.');
    const availability = await resolvePlanForPublication(repo, {
      schoolId,
      courseId: offering.courseId,
      courseMapId: offering.courseMapId,
      language: offering.language,
    });
    if (!availability.available) return failed(availability.reason ?? 'course_not_available', 'Course is not ready for students.');
    if (!offering.enabledForStudents || offering.status !== 'enabled') {
      await repo.saveCourseOffering({ ...offering, status: 'enabled', enabledForStudents: true });
    }
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'course_offering_published',
      targetType: 'courseOffering',
      targetId: courseOfferingId,
      sourceIds: [offering.courseMapId],
      versionChangeType: 'published',
    });
    return { status: 'published', courseOfferingId, enabledForStudents: true, message: 'Course is now available to students.' };
  } catch (error) {
    return failure(error);
  }
}

async function getLessonSpecificationsForCourse(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getLessonSpecificationsForCourse', caller, schoolId);
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const courseId = requiredString(request, 'courseId');
    const language = requiredString(request, 'language');
    const availability = await resolveAvailability(repo, { schoolId, courseId, courseOfferingId, language });
    if (!availability.available) return failed(availability.reason ?? 'course_not_available', 'Course is not available.');
    return {
      status: 'ready',
      courseId,
      courseOfferingId,
      lessons: availability.lessonSpecifications
        .filter(isLessonSpecificationValid)
        .map((lesson) => ({
          lessonSpecificationId: lesson.id,
          lessonId: lesson.lessonId,
          title: lesson.title,
          order: lesson.order,
          estimatedDuration: lesson.estimatedDuration,
          difficultyLevel: lesson.difficultyLevel,
          generationStatus: lesson.generationStatus,
          publishedContentId: lesson.publishedContentId,
        })),
    };
  } catch (error) {
    return failure(error);
  }
}

async function requestLessonContent(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestLessonContent', caller, schoolId);
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const courseId = requiredString(request, 'courseId');
    const language = requiredString(request, 'language');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');
    const availability = await resolveAvailability(repo, { schoolId, courseId, courseOfferingId, language });
    if (!availability.available) return failed(availability.reason ?? 'course_not_available', 'Course is not available.');
    const lesson = await repo.getLessonSpecification(lessonSpecificationId);
    if (!lesson || lesson.schoolId !== schoolId || lesson.courseId !== courseId || lesson.language !== language) {
      return failed('lesson_specification_not_found', 'Lesson specification was not found.');
    }
    if (!isLessonSpecificationValid(lesson)) return failed('invalid_lesson_specification', 'Lesson specification is not ready for generation.');
    if (lesson.publishedContentId) {
      const published = await repo.getPublishedLessonContent(lesson.publishedContentId);
      if (published?.status === 'published') {
        return { status: 'ready', requestId: null, publishedContentId: published.id, message: 'Lesson is ready.' };
      }
    }
    const idempotencyKey = optionalString(request, 'idempotencyKey') ?? `school:${schoolId}:lesson-content:${lessonSpecificationId}:${language}`;
    const generationRequest = await createOrReusePendingRequest(repo, caller, {
      schoolId,
      courseId,
      lessonSpecificationId,
      idempotencyKey,
      source: 'student_app',
      intent: 'fill_missing',
      publicationMode: 'auto_publish_after_validation',
    });
    const output = await runFakeLessonContentWorker(repo, {
      requestId: generationRequest.id,
      schoolId,
      courseId,
      language,
      lesson,
    });
    await repo.saveGenerationRequest({
      ...generationRequest,
      status: 'ready',
      studentVisibleStatus: 'ready',
      schoolPortalVisibleStatus: 'published',
      publishedContentId: output.publishedContent.id,
    });
    await repo.savePublicationRecord({
      id: `publication-${output.publishedContent.id}`,
      schoolId,
      presentationArtifactId: output.presentationArtifact.id,
      publishedContentId: output.publishedContent.id,
      status: 'published',
    });
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'lesson_content_published',
      targetType: 'publishedLessonContent',
      targetId: output.publishedContent.id,
      sourceIds: [generationRequest.id, output.job.id, output.lessonArtifact.id, output.presentationArtifact.id, output.validationArtifact.id, lesson.id],
      versionChangeType: 'published',
    });
    return {
      status: 'ready',
      requestId: generationRequest.id,
      publishedContentId: output.publishedContent.id,
      message: 'Lesson is ready.',
    };
  } catch (error) {
    return failure(error);
  }
}

async function getContentGenerationStatus(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getContentGenerationStatus', caller, schoolId);
    const requestId = requiredString(request, 'requestId');
    const generationRequest = await repo.getGenerationRequest(requestId);
    if (!generationRequest || generationRequest.schoolId !== schoolId) {
      return failed('content_request_not_found', 'Content generation request was not found.');
    }
    return statusResponseForCaller(generationRequest, caller);
  } catch (error) {
    return failure(error);
  }
}

async function requestSchoolLessonGeneration(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestSchoolLessonGeneration', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');
    const intent = optionalString(request, 'intent') ?? 'create_new';
    const generationRequest = await createOrReusePendingRequest(repo, caller, {
      schoolId,
      courseId,
      lessonSpecificationId,
      idempotencyKey: optionalString(request, 'idempotencyKey') ?? `school:${schoolId}:school-lesson-generation:${lessonSpecificationId}:${intent}`,
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent,
      publicationMode: 'require_review',
    });
    return { status: 'pending', requestId: generationRequest.id, message: 'Lesson generation has started.' };
  } catch (error) {
    return failure(error);
  }
}

async function requestArtifactRegeneration(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestArtifactRegeneration', caller, schoolId);
    const artifactType = requiredString(request, 'artifactType');
    const artifactId = requiredString(request, 'artifactId');
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'artifact_regeneration_requested',
      targetType: artifactType,
      targetId: artifactId,
      sourceIds: [artifactId],
      versionChangeType: 'regenerated',
    });
    return { status: 'pending', regenerationRequestId: `regeneration-request-${Date.now()}`, message: 'Artifact regeneration has started.' };
  } catch (error) {
    return failure(error);
  }
}

async function approveArtifactForPublication(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('approveArtifactForPublication', caller, schoolId);
    const artifactType = requiredString(request, 'artifactType');
    const artifactId = requiredString(request, 'artifactId');
    const validationArtifactId = requiredString(request, 'validationArtifactId');
    const validation = await repo.getValidationArtifact(validationArtifactId);
    if (!validation || validation.schoolId !== schoolId || validation.validationStatus === 'invalid') {
      return failed('validation_failed', 'Invalid artifacts cannot be approved.');
    }
    const presentation = artifactType === 'presentation' ? await repo.getPresentationArtifact(artifactId) : undefined;
    if (presentation) await repo.savePresentationArtifact({ ...presentation, status: 'approved' });
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'artifact_approved',
      targetType: artifactType,
      targetId: artifactId,
      sourceIds: [validationArtifactId],
      versionChangeType: 'approved',
    });
    return { status: 'approved', artifactId, artifactVersion: '1.0', message: 'Artifact approved for publication.' };
  } catch (error) {
    return failure(error);
  }
}

async function publishValidatedArtifact(repo: ContentEngineRepository, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('publishValidatedArtifact', caller, schoolId);
    const presentationArtifactId = requiredString(request, 'presentationArtifactId');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');
    const presentation = await repo.getPresentationArtifact(presentationArtifactId);
    const lesson = await repo.getLessonSpecification(lessonSpecificationId);
    if (!presentation || presentation.schoolId !== schoolId || presentation.lessonSpecificationId !== lessonSpecificationId) {
      return failed('publication_denied', 'Presentation artifact cannot be published.');
    }
    const validation = presentation.validationArtifactId ? await repo.getValidationArtifact(presentation.validationArtifactId) : undefined;
    const lessonArtifact = presentation.lessonArtifactId ? await repo.getLessonArtifact(presentation.lessonArtifactId) : undefined;
    if (!validation || validation.validationStatus === 'invalid' || !lessonArtifact) {
      return failed('minimum_publishable_package_missing', 'Minimum publishable package is missing.');
    }
    const publishedContentId = `published-content-${Date.now()}`;
    const published: PublishedLessonContent = {
      id: publishedContentId,
      schoolId,
      courseId: lesson?.courseId ?? 'unknown-course',
      lessonSpecificationId,
      language: lesson?.language ?? 'en',
      status: 'published',
      title: lesson?.title ?? 'Published Lesson',
    };
    await repo.savePublishedLessonContent(published);
    if (lesson) {
      await repo.updateLessonSpecification(lesson.id, {
        publishedContentId: published.id,
        generationStatus: 'published',
      });
    }
    const publicationRecord: PublicationRecord = {
      id: `publication-${Date.now()}`,
      schoolId,
      presentationArtifactId,
      publishedContentId,
      status: 'published',
    };
    await repo.savePublicationRecord(publicationRecord);
    await writeRepositoryAudit(repo, caller, {
      schoolId,
      eventType: 'artifact_published',
      targetType: 'publishedLessonContent',
      targetId: published.id,
      sourceIds: [presentationArtifactId, validation.id, lessonArtifact.id],
      versionChangeType: 'published',
    });
    return { status: 'published', publishedContentId: published.id, presentationArtifactId, message: 'Lesson content has been published.' };
  } catch (error) {
    return failure(error);
  }
}

interface Availability {
  available: boolean;
  reason?: string;
  lessonSpecifications: LessonSpecification[];
}

async function resolveAvailability(repo: ContentEngineRepository, input: { schoolId: string; courseId: string; courseOfferingId?: string; language: string }): Promise<Availability> {
  const offering = input.courseOfferingId
    ? await repo.getCourseOffering(input.courseOfferingId)
    : await repo.findCourseOffering(input);
  if (!offering) return unavailable('course_not_available');
  if (offering.schoolId !== input.schoolId || offering.courseId !== input.courseId || offering.language !== input.language) return unavailable('course_not_available');
  if (!offering.enabledForStudents || offering.status !== 'enabled') return unavailable('course_not_available');
  const courseMap = await repo.getCourseMap(offering.courseMapId);
  if (!courseMap || courseMap.schoolId !== input.schoolId || courseMap.courseId !== input.courseId) return unavailable('course_plan_not_found');
  if (courseMap.status !== 'active' && courseMap.status !== 'approved') return unavailable('course_plan_not_found');
  const unitPlans = (await repo.listUnitPlans({ schoolId: input.schoolId, courseId: input.courseId, courseMapId: courseMap.id }))
    .filter((unit) => unit.status === 'active' || unit.status === 'approved');
  if (unitPlans.length === 0) return unavailable('unit_plans_not_found');
  const lessons = (await repo.listLessonSpecifications({ schoolId: input.schoolId, courseId: input.courseId, courseMapId: courseMap.id, language: input.language }))
    .filter((lesson) => lesson.status === 'active' || lesson.status === 'approved');
  if (lessons.length === 0) return unavailable('lesson_specification_not_found');
  return { available: true, lessonSpecifications: lessons };
}

async function resolvePlanForPublication(repo: ContentEngineRepository, input: { schoolId: string; courseId: string; courseMapId: string; language: string }): Promise<Availability> {
  const courseMap = await repo.getCourseMap(input.courseMapId);
  if (!courseMap || courseMap.schoolId !== input.schoolId || courseMap.courseId !== input.courseId) return unavailable('course_plan_not_found');
  if (courseMap.status !== 'active' && courseMap.status !== 'approved') return unavailable('course_plan_not_found');
  const unitPlans = (await repo.listUnitPlans({ schoolId: input.schoolId, courseId: input.courseId, courseMapId: courseMap.id }))
    .filter((unit) => unit.status === 'active' || unit.status === 'approved');
  if (unitPlans.length === 0) return unavailable('unit_plans_not_found');
  const lessons = (await repo.listLessonSpecifications({ schoolId: input.schoolId, courseId: input.courseId, courseMapId: courseMap.id, language: input.language }))
    .filter((lesson) => lesson.status === 'active' || lesson.status === 'approved');
  if (lessons.length === 0) return unavailable('lesson_specification_not_found');
  return { available: true, lessonSpecifications: lessons };
}

function isLessonSpecificationValid(lesson: LessonSpecification): boolean {
  return lesson.standardIds.length > 0 &&
    lesson.pedagogicalAnalysisIds.length > 0 &&
    lesson.learningObjectiveIds.length > 0 &&
    lesson.masteryDefinitionIds.length > 0 &&
    lesson.assessmentBlueprintIds.length > 0 &&
    lesson.lessonBlueprintIds.length > 0;
}

async function createOrReusePendingRequest(
  repo: ContentEngineRepository,
  caller: CallerContext,
  input: Pick<ContentGenerationRequest, 'schoolId' | 'courseId' | 'lessonSpecificationId' | 'idempotencyKey' | 'source' | 'intent' | 'publicationMode'>,
): Promise<ContentGenerationRequest> {
  const existing = await repo.findPendingRequestByIdempotency({
    schoolId: input.schoolId,
    idempotencyKey: input.idempotencyKey,
  });
  if (existing) return existing;
  const count = await repo.countGenerationRequests();
  const request: ContentGenerationRequest = {
    id: `request-${count + 1}`,
    schoolId: input.schoolId,
    courseId: input.courseId,
    lessonSpecificationId: input.lessonSpecificationId,
    idempotencyKey: input.idempotencyKey,
    source: input.source,
    intent: input.intent,
    publicationMode: input.publicationMode,
    status: 'created',
    studentVisibleStatus: 'pending',
    schoolPortalVisibleStatus: 'generating',
    publishedContentId: null,
  };
  await repo.saveGenerationRequest(request);
  await writeRepositoryAudit(repo, caller, {
    schoolId: input.schoolId,
    eventType: 'request_created',
    targetType: 'contentGenerationRequest',
    targetId: request.id,
    sourceIds: input.lessonSpecificationId ? [input.lessonSpecificationId] : [],
    versionChangeType: 'created',
  });
  return request;
}

async function writeRepositoryAudit(
  repo: ContentEngineRepository,
  caller: CallerContext,
  input: { schoolId: string; eventType: string; targetType: string; targetId: string; sourceIds?: string[]; versionChangeType?: string },
): Promise<void> {
  const createdAt = new Date().toISOString();
  const suffix = `${input.targetType}-${input.targetId}-${Date.now()}`;
  const audit: AuditRecord = {
    id: `audit-${suffix}`,
    schoolId: input.schoolId,
    eventType: input.eventType,
    actorUserId: caller.userId,
    targetType: input.targetType,
    targetId: input.targetId,
    createdAt,
  };
  const provenance: ProvenanceRecord = {
    id: `provenance-${suffix}`,
    schoolId: input.schoolId,
    targetType: input.targetType,
    targetId: input.targetId,
    sourceIds: input.sourceIds ?? [],
    createdAt,
  };
  const version: VersionHistoryRecord = {
    id: `version-${suffix}`,
    schoolId: input.schoolId,
    entityType: input.targetType,
    entityId: input.targetId,
    changeType: input.versionChangeType ?? input.eventType,
    createdAt,
  };
  await repo.saveAudit(audit);
  await repo.saveProvenance(provenance);
  await repo.saveVersionHistory(version);
}

function unavailable(reason: string): Availability {
  return { available: false, reason, lessonSpecifications: [] };
}

function failed(errorCode: string, message: string): CallableResponse {
  return { status: 'failed', errorCode, message };
}

function optionalString(request: CallableRequest, key: string): string | undefined {
  const value = request[key];
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

function requiredString(request: CallableRequest, key: string): string {
  const value = optionalString(request, key);
  if (!value) throw new ContractError('missing_required_context', `${key} is required.`);
  return value;
}

function assertAllowed(functionName: CallableName, caller: CallerContext, schoolId?: string): void {
  if (!canCall(functionName, caller)) throw new ContractError('permission_denied', 'You do not have permission to perform this action.');
  if (schoolId && !canAccessSchool(caller, schoolId)) throw new ContractError('permission_denied', 'You do not have permission to access this school.');
}

class ContractError extends Error {
  constructor(public readonly errorCode: string, message: string) {
    super(message);
  }
}

function failure(error: unknown): CallableResponse {
  if (error instanceof ContractError) return failed(error.errorCode, error.message);
  return failed('unknown_error', 'The request could not be completed.');
}
