import { createHash } from 'node:crypto';

import type {
  CallerContext,
  CurriculumImportBatch,
  CurriculumSource,
  CurriculumStandard,
  CurriculumVersion,
} from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';
import {
  CurriculumImportSchemaError,
  validateCurriculumImportPayload,
  validateStandards,
  type CurriculumImportPayload,
} from './curriculum-import-schema.js';

export interface CurriculumImportResult {
  source: CurriculumSource;
  version: CurriculumVersion;
  batch: CurriculumImportBatch;
  standards: CurriculumStandard[];
}

export class CurriculumImportService {
  constructor(private readonly repo: ContentEngineRepository) {}

  async importPayload(payload: unknown, caller: CallerContext): Promise<CurriculumImportResult> {
    const parsed = validateCurriculumImportPayload(payload);
    const { validStandards, rejectedRecords } = validateStandards(parsed.standards);
    if (validStandards.length === 0) {
      throw new CurriculumImportSchemaError('Curriculum import contains no valid standards.', 'no_valid_standards');
    }

    const checksum = checksumFor(parsed);
    const now = new Date().toISOString();
    const source: CurriculumSource = {
      id: parsed.source.id,
      name: parsed.source.name,
      jurisdiction: parsed.source.jurisdiction,
      framework: parsed.source.framework,
      officialSourceUrl: parsed.source.officialSourceUrl,
      updatedAt: now,
    };
    const version: CurriculumVersion = {
      id: parsed.version.id,
      curriculumSourceId: source.id,
      sourceVersion: parsed.version.sourceVersion,
      effectiveDate: parsed.version.effectiveDate,
      retiredDate: parsed.version.retiredDate,
      importDate: now,
      checksum,
      officialSourceUrl: source.officialSourceUrl,
    };
    const standards = validStandards.map((standard) =>
      buildStandard(source.id, version.id, standard),
    );
    const batch: CurriculumImportBatch = {
      id: `curriculum-import-${source.id}-${version.id}-${checksum.slice(0, 12)}`,
      curriculumSourceId: source.id,
      curriculumVersionId: version.id,
      checksum,
      status: rejectedRecords.length > 0 ? 'completed_with_rejections' : 'completed',
      importedCount: standards.length,
      rejectedCount: rejectedRecords.length,
      rejectedRecords,
      createdAt: now,
    };

    await this.repo.saveCurriculumSource(source);
    await this.repo.saveCurriculumVersion(version);
    for (const standard of standards) {
      await this.repo.saveCurriculumStandard(standard);
    }
    await this.repo.saveCurriculumImportBatch(batch);
    await this.writeAuditProvenance(caller, batch, standards.map((standard) => standard.id));

    return { source, version, batch, standards };
  }

  private async writeAuditProvenance(
    caller: CallerContext,
    batch: CurriculumImportBatch,
    standardIds: string[],
  ): Promise<void> {
    const createdAt = new Date().toISOString();
    const suffix = `curriculumImportBatch-${batch.id}`;
    await this.repo.saveAudit({
      id: `audit-${suffix}`,
      schoolId: 'global',
      eventType: 'curriculum_imported',
      actorUserId: caller.userId,
      targetType: 'curriculumImportBatch',
      targetId: batch.id,
      createdAt,
    });
    await this.repo.saveProvenance({
      id: `provenance-${suffix}`,
      schoolId: 'global',
      targetType: 'curriculumImportBatch',
      targetId: batch.id,
      sourceIds: [batch.curriculumSourceId, batch.curriculumVersionId, ...standardIds],
      createdAt,
    });
    await this.repo.saveVersionHistory({
      id: `version-${suffix}`,
      schoolId: 'global',
      entityType: 'curriculumImportBatch',
      entityId: batch.id,
      changeType: 'imported',
      createdAt,
    });
  }
}

function buildStandard(
  sourceId: string,
  versionId: string,
  standard: CurriculumImportPayload['standards'][number],
): CurriculumStandard {
  const id = standardId(sourceId, versionId, standard.code);
  return {
    id,
    curriculumSourceId: sourceId,
    curriculumVersionId: versionId,
    code: standard.code,
    title: standard.title,
    description: standard.description,
    gradeLevelId: standard.gradeLevelId,
    subjectId: standard.subjectId,
    checksum: checksumFor(standard),
  };
}

export function standardId(sourceId: string, versionId: string, code: string): string {
  return `${sourceId}-${versionId}-${normalizeIdSegment(code)}`;
}

function normalizeIdSegment(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function checksumFor(value: unknown): string {
  return createHash('sha256').update(stableStringify(value)).digest('hex');
}

function stableStringify(value: unknown): string {
  return JSON.stringify(sortForStableStringify(value));
}

function sortForStableStringify(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortForStableStringify);
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortForStableStringify(nested)]),
    );
  }

  return value;
}
