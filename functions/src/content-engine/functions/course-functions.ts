import type { CallableRequest, CallerContext, ContentEngineStore } from '../contracts.js';
import { writeAuditProvenance } from '../audit.js';
import { isLessonSpecificationValid, resolveCourseAvailability } from '../course-availability.js';
import { createPendingRequest } from '../fake-workers.js';
import { assertAllowed, failure, requiredString } from './common.js';

export async function handleRequestCoursePlanGeneration(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestCoursePlanGeneration', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const language = requiredString(request, 'language');
    const curriculumVersionId = requiredString(request, 'curriculumVersionId');
    const idempotencyKey = `school:${schoolId}:course-plan:${courseId}:${curriculumVersionId}:${language}`;
    const generationRequest = createPendingRequest(store, caller, {
      schoolId,
      courseId,
      idempotencyKey,
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent: 'create_new',
      publicationMode: 'require_review',
    });
    return { status: 'pending', requestId: generationRequest.id, courseMapId: null, message: 'Course plan generation has started.' };
  } catch (error) {
    return failure(error);
  }
}

export async function handlePublishCourseOffering(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('publishCourseOffering', caller, schoolId);
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const offering = store.courseOfferings.get(courseOfferingId);
    if (!offering || offering.schoolId !== schoolId) return { status: 'failed', errorCode: 'course_not_available', message: 'Course offering was not found.' };
    const availability = resolveCourseAvailability(store, {
      schoolId,
      courseId: offering.courseId,
      courseOfferingId,
      language: offering.language,
    });
    if (!availability.available) return { status: 'failed', errorCode: availability.reason, message: 'Course is not ready for students.' };
    writeAuditProvenance(store, caller, {
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

export async function handleGetLessonSpecificationsForCourse(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getLessonSpecificationsForCourse', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const language = requiredString(request, 'language');
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const availability = resolveCourseAvailability(store, { schoolId, courseId, courseOfferingId, language });
    if (!availability.available) return { status: 'failed', errorCode: availability.reason, message: 'Course is not available.' };

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
