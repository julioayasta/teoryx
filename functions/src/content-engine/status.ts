import type { CallerContext, ContentGenerationRequest, VisibleStatus } from './contracts.js';

const studentStatusMap = new Map<string, VisibleStatus>([
  ['created', 'pending'],
  ['validating_request', 'pending'],
  ['resolving_curriculum', 'pending'],
  ['checking_existing_content', 'pending'],
  ['resolving_blueprints', 'pending'],
  ['generating_lesson_artifact', 'pending'],
  ['validating_artifacts', 'pending'],
  ['ready_for_review', 'pending'],
  ['approved', 'pending'],
  ['published', 'ready'],
  ['ready', 'ready'],
  ['failed', 'failed'],
  ['validation_failed', 'failed'],
]);

export function toStudentStatus(status: string): VisibleStatus {
  return studentStatusMap.get(status) ?? 'pending';
}

export function statusResponseForCaller(request: ContentGenerationRequest, caller: CallerContext) {
  if (caller.role === 'student') {
    return {
      status: request.studentVisibleStatus,
      requestId: request.id,
      publishedContentId: request.studentVisibleStatus === 'ready' ? request.publishedContentId ?? null : null,
      message: studentMessage(request.studentVisibleStatus),
    };
  }

  return {
    status: request.schoolPortalVisibleStatus ?? request.status,
    requestId: request.id,
    publishedContentId: request.publishedContentId ?? null,
    stage: request.status,
  };
}

function studentMessage(status: VisibleStatus): string {
  if (status === 'ready') return 'Lesson is ready.';
  if (status === 'failed') return 'We could not prepare this lesson yet.';
  return 'Getting your lesson ready.';
}
