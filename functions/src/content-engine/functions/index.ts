import type { CallableName, CallableRequest, CallableResponse, CallerContext, ContentEngineStore } from '../contracts.js';
import { handleApproveArtifactForPublication } from './review.js';
import { handleGetContentGenerationStatus, handleGetCoursePlanStatus } from './status-functions.js';
import { handleGetLessonSpecificationsForCourse, handlePublishCourseOffering, handleRequestCoursePlanGeneration } from './course-functions.js';
import { handlePublishValidatedArtifact, handleRequestArtifactRegeneration, handleRequestLessonContent, handleRequestSchoolLessonGeneration } from './generation-functions.js';

export type ContentEngineHandler = (request: CallableRequest, caller: CallerContext) => Promise<CallableResponse>;

export function createContentEngineHandlers(store: ContentEngineStore): Record<CallableName, ContentEngineHandler> {
  return {
    requestCoursePlanGeneration: (request, caller) => handleRequestCoursePlanGeneration(store, request, caller),
    getCoursePlanStatus: (request, caller) => handleGetCoursePlanStatus(store, request, caller),
    publishCourseOffering: (request, caller) => handlePublishCourseOffering(store, request, caller),
    getLessonSpecificationsForCourse: (request, caller) => handleGetLessonSpecificationsForCourse(store, request, caller),
    requestLessonContent: (request, caller) => handleRequestLessonContent(store, request, caller),
    getContentGenerationStatus: (request, caller) => handleGetContentGenerationStatus(store, request, caller),
    requestSchoolLessonGeneration: (request, caller) => handleRequestSchoolLessonGeneration(store, request, caller),
    requestArtifactRegeneration: (request, caller) => handleRequestArtifactRegeneration(store, request, caller),
    approveArtifactForPublication: (request, caller) => handleApproveArtifactForPublication(store, request, caller),
    publishValidatedArtifact: (request, caller) => handlePublishValidatedArtifact(store, request, caller),
    importCurriculumSource: async () => ({
      status: 'failed',
      errorCode: 'repository_runtime_required',
      message: 'Curriculum import is available through the repository-backed runtime.',
    }),
    requestPedagogicalAnalysis: async () => ({
      status: 'failed',
      errorCode: 'repository_runtime_required',
      message: 'Pedagogical analysis is available through the repository-backed runtime.',
    }),
    getPedagogicalAnalysisStatus: async () => ({
      status: 'failed',
      errorCode: 'repository_runtime_required',
      message: 'Pedagogical analysis status is available through the repository-backed runtime.',
    }),
  };
}
