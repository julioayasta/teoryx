import type { CallableRequest, CallerContext, ContentEngineStore } from '../contracts.js';
import { statusResponseForCaller } from '../status.js';
import { assertAllowed, failure, requiredString } from './common.js';

export async function handleGetCoursePlanStatus(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getCoursePlanStatus', caller, schoolId);
    const requestId = requiredString(request, 'requestId');
    const generationRequest = store.generationRequests.get(requestId);
    if (!generationRequest || generationRequest.schoolId !== schoolId) {
      return { status: 'failed', errorCode: 'course_plan_not_found', message: 'Course plan request was not found.' };
    }
    return {
      status: generationRequest.schoolPortalVisibleStatus ?? generationRequest.status,
      requestId,
      courseMapId: null,
      unitPlanCount: [...store.unitPlans.values()].filter((unit) => unit.schoolId === schoolId).length,
      lessonSpecificationCount: [...store.lessonSpecifications.values()].filter((lesson) => lesson.schoolId === schoolId).length,
      message: 'Course plan status is available.',
    };
  } catch (error) {
    return failure(error);
  }
}

export async function handleGetContentGenerationStatus(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('getContentGenerationStatus', caller, schoolId);
    const requestId = requiredString(request, 'requestId');
    const generationRequest = store.generationRequests.get(requestId);
    if (!generationRequest || generationRequest.schoolId !== schoolId) {
      return { status: 'failed', errorCode: 'content_request_not_found', message: 'Content generation request was not found.' };
    }
    return statusResponseForCaller(generationRequest, caller);
  } catch (error) {
    return failure(error);
  }
}
