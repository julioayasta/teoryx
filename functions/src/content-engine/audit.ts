import type { CallerContext, ContentEngineStore } from './contracts.js';

interface AuditInput {
  schoolId: string;
  eventType: string;
  targetType: string;
  targetId: string;
  sourceIds?: string[];
  versionChangeType?: string;
}

export function writeAuditProvenance(
  store: ContentEngineStore,
  caller: CallerContext,
  input: AuditInput,
): void {
  const createdAt = new Date().toISOString();
  const suffix = `${input.targetType}-${input.targetId}-${store.auditRecords.length + 1}`;

  store.auditRecords.push({
    id: `audit-${suffix}`,
    schoolId: input.schoolId,
    eventType: input.eventType,
    actorUserId: caller.userId,
    targetType: input.targetType,
    targetId: input.targetId,
    createdAt,
  });

  store.provenanceRecords.push({
    id: `provenance-${suffix}`,
    schoolId: input.schoolId,
    targetType: input.targetType,
    targetId: input.targetId,
    sourceIds: input.sourceIds ?? [],
    createdAt,
  });

  store.versionHistoryRecords.push({
    id: `version-${suffix}`,
    schoolId: input.schoolId,
    entityType: input.targetType,
    entityId: input.targetId,
    changeType: input.versionChangeType ?? input.eventType,
    createdAt,
  });
}
