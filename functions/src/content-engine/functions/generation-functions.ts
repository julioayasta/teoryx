import type { CallableRequest, CallerContext, ContentEngineStore, PublishedLessonContent } from '../contracts.js';
import { writeAuditProvenance } from '../audit.js';
import { isLessonSpecificationValid, resolveCourseAvailability } from '../course-availability.js';
import { createPendingRequest } from '../fake-workers.js';
import { assertAllowed, failure, requiredString, stringField } from './common.js';

export async function handleRequestLessonContent(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestLessonContent', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const courseOfferingId = requiredString(request, 'courseOfferingId');
    const language = requiredString(request, 'language');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');

    const availability = resolveCourseAvailability(store, { schoolId, courseId, courseOfferingId, language });
    if (!availability.available) return { status: 'failed', errorCode: availability.reason, message: 'Course is not available.' };

    const lesson = store.lessonSpecifications.get(lessonSpecificationId);
    if (!lesson || lesson.schoolId !== schoolId || lesson.courseId !== courseId || lesson.language !== language) {
      return { status: 'failed', errorCode: 'lesson_specification_not_found', message: 'Lesson specification was not found.' };
    }
    if (!isLessonSpecificationValid(lesson)) {
      return { status: 'failed', errorCode: 'invalid_lesson_specification', message: 'Lesson specification is not ready for generation.' };
    }
    if (lesson.publishedContentId) {
      const published = store.publishedLessonContent.get(lesson.publishedContentId);
      if (published?.status === 'published') {
        return { status: 'ready', requestId: null, publishedContentId: published.id, message: 'Lesson is ready.' };
      }
    }

    const idempotencyKey = stringField(request, 'idempotencyKey') ?? `school:${schoolId}:lesson-content:${lessonSpecificationId}:${language}`;
    const generationRequest = createPendingRequest(store, caller, {
      schoolId,
      courseId,
      lessonSpecificationId,
      idempotencyKey,
      source: 'student_app',
      intent: 'fill_missing',
      publicationMode: 'auto_publish_after_validation',
    });
    return { status: 'pending', requestId: generationRequest.id, publishedContentId: null, message: 'Getting your lesson ready.' };
  } catch (error) {
    return failure(error);
  }
}

export async function handleRequestSchoolLessonGeneration(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestSchoolLessonGeneration', caller, schoolId);
    const courseId = requiredString(request, 'courseId');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');
    const intent = stringField(request, 'intent') ?? 'create_new';
    const idempotencyKey = stringField(request, 'idempotencyKey') ?? `school:${schoolId}:school-lesson-generation:${lessonSpecificationId}:${intent}`;
    const generationRequest = createPendingRequest(store, caller, {
      schoolId,
      courseId,
      lessonSpecificationId,
      idempotencyKey,
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent,
      publicationMode: 'require_review',
    });
    return { status: 'pending', requestId: generationRequest.id, message: 'Lesson generation has started.' };
  } catch (error) {
    return failure(error);
  }
}

export async function handleRequestArtifactRegeneration(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('requestArtifactRegeneration', caller, schoolId);
    const artifactId = requiredString(request, 'artifactId');
    const artifactType = requiredString(request, 'artifactType');
    const regenerationRequestId = `regeneration-request-${store.generationRequests.size + 1}`;
    writeAuditProvenance(store, caller, {
      schoolId,
      eventType: 'artifact_regeneration_requested',
      targetType: artifactType,
      targetId: artifactId,
      sourceIds: [artifactId],
      versionChangeType: 'regenerated',
    });
    return { status: 'pending', regenerationRequestId, message: 'Artifact regeneration has started.' };
  } catch (error) {
    return failure(error);
  }
}

export async function handlePublishValidatedArtifact(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('publishValidatedArtifact', caller, schoolId);
    const presentationArtifactId = requiredString(request, 'presentationArtifactId');
    const lessonSpecificationId = requiredString(request, 'lessonSpecificationId');
    const presentation = store.presentationArtifacts.get(presentationArtifactId);
    const lesson = store.lessonSpecifications.get(lessonSpecificationId);
    if (!presentation || presentation.schoolId !== schoolId || presentation.lessonSpecificationId !== lessonSpecificationId) {
      return { status: 'failed', errorCode: 'publication_denied', message: 'Presentation artifact cannot be published.' };
    }
    const validation = presentation.validationArtifactId ? store.validationArtifacts.get(presentation.validationArtifactId) : undefined;
    const lessonArtifact = presentation.lessonArtifactId ? store.lessonArtifacts.get(presentation.lessonArtifactId) : undefined;
    if (!validation || validation.validationStatus === 'invalid' || !lessonArtifact) {
      return { status: 'failed', errorCode: 'minimum_publishable_package_missing', message: 'Minimum publishable package is missing.' };
    }
    const publishedContentId = `published-content-${store.publishedLessonContent.size + 1}`;
    const published: PublishedLessonContent = {
      id: publishedContentId,
      schoolId,
      courseId: lesson?.courseId ?? 'unknown-course',
      lessonSpecificationId,
      language: lesson?.language ?? 'en',
      status: 'published',
      title: lesson?.title ?? 'Published Lesson',
    };
    store.publishedLessonContent.set(published.id, published);
    if (lesson) {
      lesson.publishedContentId = published.id;
      lesson.generationStatus = 'published';
    }
    store.publicationRecords.push({
      id: `publication-${store.publicationRecords.length + 1}`,
      schoolId,
      presentationArtifactId,
      publishedContentId,
      status: 'published',
    });
    writeAuditProvenance(store, caller, {
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
