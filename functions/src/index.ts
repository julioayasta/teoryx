import { onCall } from 'firebase-functions/v2/https';

import type { CallerContext, CallerRole } from './content-engine/contracts.js';
import { FirestoreAdminDocumentStore } from './content-engine/firestore/admin.js';
import { FirestoreContentEngineRepository } from './content-engine/repositories/firestore-content-engine-repository.js';
import { createFirestoreBackedContentEngineHandlers } from './content-engine/repository-runtime.js';

export { createContentEngineHandlers } from './content-engine/functions/index.js';
export { createFirestoreBackedContentEngineHandlers } from './content-engine/repository-runtime.js';
export type {
  CallableName,
  CallableRequest,
  CallableResponse,
  CallerContext,
} from './content-engine/contracts.js';

const repo = new FirestoreContentEngineRepository(new FirestoreAdminDocumentStore());
const handlers = createFirestoreBackedContentEngineHandlers(repo);

export const requestLessonContent = onCall(async (request) => {
  return handlers.requestLessonContent(request.data ?? {}, callerFromCallable(request));
});

export const getContentGenerationStatus = onCall(async (request) => {
  return handlers.getContentGenerationStatus(request.data ?? {}, callerFromCallable(request));
});

function callerFromCallable(request: { auth?: { uid: string; token: Record<string, unknown> } | null }): CallerContext {
  const role = isCallerRole(request.auth?.token.role)
    ? request.auth.token.role
    : process.env.FUNCTIONS_EMULATOR === 'true'
      ? 'student'
      : 'unauthorized';
  const schoolId = typeof request.auth?.token.schoolId === 'string'
    ? request.auth.token.schoolId
    : process.env.FUNCTIONS_EMULATOR === 'true'
      ? 'school-demo'
      : undefined;

  return {
    userId: request.auth?.uid ?? 'emulator-student-001',
    role,
    schoolId,
  };
}

function isCallerRole(value: unknown): value is CallerRole {
  return value === 'student' ||
    value === 'school_planner' ||
    value === 'school_reviewer' ||
    value === 'school_publisher' ||
    value === 'super_admin' ||
    value === 'system' ||
    value === 'unauthorized';
}
