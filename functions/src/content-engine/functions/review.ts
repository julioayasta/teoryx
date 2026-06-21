import type { CallableRequest, CallerContext, ContentEngineStore } from '../contracts.js';
import { writeAuditProvenance } from '../audit.js';
import { assertAllowed, failure, requiredString } from './common.js';

export async function handleApproveArtifactForPublication(store: ContentEngineStore, request: CallableRequest, caller: CallerContext) {
  try {
    const schoolId = requiredString(request, 'schoolId');
    assertAllowed('approveArtifactForPublication', caller, schoolId);
    const artifactId = requiredString(request, 'artifactId');
    const artifactType = requiredString(request, 'artifactType');
    const validationArtifactId = requiredString(request, 'validationArtifactId');
    const validation = store.validationArtifacts.get(validationArtifactId);
    if (!validation || validation.schoolId !== schoolId || validation.validationStatus === 'invalid') {
      return { status: 'failed', errorCode: 'validation_failed', message: 'Invalid artifacts cannot be approved.' };
    }
    const presentation = artifactType === 'presentation' ? store.presentationArtifacts.get(artifactId) : undefined;
    if (presentation) presentation.status = 'approved';
    writeAuditProvenance(store, caller, {
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
