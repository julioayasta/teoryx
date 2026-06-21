import type { CallableName, CallableRequest, CallerContext } from '../contracts.js';
import { canAccessSchool, canCall } from '../permissions.js';

export function stringField(request: CallableRequest, key: string): string | undefined {
  const value = request[key];
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

export function requiredString(request: CallableRequest, key: string): string {
  const value = stringField(request, key);
  if (!value) throw new ContractError('missing_required_context', `${key} is required.`);
  return value;
}

export function assertAllowed(functionName: CallableName, caller: CallerContext, schoolId?: string): void {
  if (!canCall(functionName, caller)) {
    throw new ContractError('permission_denied', 'You do not have permission to perform this action.');
  }
  if (schoolId && !canAccessSchool(caller, schoolId)) {
    throw new ContractError('permission_denied', 'You do not have permission to access this school.');
  }
}

export class ContractError extends Error {
  constructor(public readonly errorCode: string, message: string) {
    super(message);
  }
}

export function failure(error: unknown) {
  if (error instanceof ContractError) {
    return { status: 'failed', errorCode: error.errorCode, message: error.message };
  }
  return { status: 'failed', errorCode: 'unknown_error', message: 'The request could not be completed.' };
}
