import type {
  CallerContext,
  ContentEngineStore,
  ContentGenerationRequest,
  LessonArtifact,
  PresentationArtifact,
  ValidationArtifact,
} from './contracts.js';
import { writeAuditProvenance } from './audit.js';

export function createPendingRequest(
  store: ContentEngineStore,
  caller: CallerContext,
  input: {
    schoolId: string;
    courseId?: string;
    lessonSpecificationId?: string;
    idempotencyKey: string;
    source: ContentGenerationRequest['source'];
    intent: string;
    publicationMode?: ContentGenerationRequest['publicationMode'];
  },
): ContentGenerationRequest {
  const existing = [...store.generationRequests.values()].find((request) =>
    request.schoolId === input.schoolId &&
    request.idempotencyKey === input.idempotencyKey &&
    request.studentVisibleStatus === 'pending'
  );
  if (existing) return existing;

  const request: ContentGenerationRequest = {
    id: `request-${store.generationRequests.size + 1}`,
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

  store.generationRequests.set(request.id, request);
  writeAuditProvenance(store, caller, {
    schoolId: input.schoolId,
    eventType: 'request_created',
    targetType: 'contentGenerationRequest',
    targetId: request.id,
    sourceIds: input.lessonSpecificationId ? [input.lessonSpecificationId] : [],
    versionChangeType: 'created',
  });

  return request;
}

export function fakeGenerateMinimumPackage(
  store: ContentEngineStore,
  caller: CallerContext,
  input: { schoolId: string; lessonSpecificationId: string },
): { lessonArtifact: LessonArtifact; presentationArtifact: PresentationArtifact; validationArtifact: ValidationArtifact } {
  const lessonArtifact: LessonArtifact = {
    id: `lesson-artifact-${store.lessonArtifacts.size + 1}`,
    schoolId: input.schoolId,
    status: 'generated',
  };
  const validationArtifact: ValidationArtifact = {
    id: `validation-artifact-${store.validationArtifacts.size + 1}`,
    schoolId: input.schoolId,
    validationStatus: 'valid',
    validatedArtifactIds: [lessonArtifact.id],
  };
  const presentationArtifact: PresentationArtifact = {
    id: `presentation-artifact-${store.presentationArtifacts.size + 1}`,
    schoolId: input.schoolId,
    lessonSpecificationId: input.lessonSpecificationId,
    version: '1.0',
    status: 'approved',
    validationArtifactId: validationArtifact.id,
    lessonArtifactId: lessonArtifact.id,
  };

  validationArtifact.validatedArtifactIds.push(presentationArtifact.id);
  store.lessonArtifacts.set(lessonArtifact.id, lessonArtifact);
  store.validationArtifacts.set(validationArtifact.id, validationArtifact);
  store.presentationArtifacts.set(presentationArtifact.id, presentationArtifact);

  writeAuditProvenance(store, caller, {
    schoolId: input.schoolId,
    eventType: 'artifact_generated',
    targetType: 'presentationArtifact',
    targetId: presentationArtifact.id,
    sourceIds: [input.lessonSpecificationId, lessonArtifact.id, validationArtifact.id],
    versionChangeType: 'generated',
  });

  return { lessonArtifact, presentationArtifact, validationArtifact };
}
