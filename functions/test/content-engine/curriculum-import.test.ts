import assert from 'node:assert/strict';
import test from 'node:test';

import { standardId } from '../../src/content-engine/curriculum/curriculum-import-service.js';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';

test('SuperAdmin can import valid curriculum source payload', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  const source = await context.repo.getCurriculumSource('ca-common-core-math');
  const version = await context.repo.getCurriculumVersion({
    sourceId: 'ca-common-core-math',
    versionId: '2025',
  });
  const standards = await context.repo.listCurriculumStandards({
    curriculumSourceId: 'ca-common-core-math',
    curriculumVersionId: '2025',
  });
  const batch = await context.repo.getCurriculumImportBatch(String(response.batchId));

  assert.equal(response.status, 'completed');
  assert.equal(response.importedCount, 2);
  assert.equal(response.rejectedCount, 0);
  assert.equal(source?.name, 'California Common Core Mathematics');
  assert.equal(version?.checksum, response.checksum);
  assert.equal(standards.length, 2);
  assert.equal(batch?.checksum, response.checksum);
  assert.ok(batch?.checksum);
});

test('duplicate curriculum import is idempotent and does not duplicate standards', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const first = await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  const second = await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  const standards = await context.repo.listCurriculumStandards({
    curriculumSourceId: 'ca-common-core-math',
    curriculumVersionId: '2025',
  });
  const batches = await context.repo.listCurriculumImportBatches();

  assert.equal(first.batchId, second.batchId);
  assert.equal(standards.length, 2);
  assert.equal(batches.length, 1);
});

test('new curriculum version creates separate versioned standards', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  await handlers.importCurriculumSource({
    ...validPayload(),
    version: {
      id: '2026',
      sourceVersion: '2026',
      effectiveDate: '2026-01-01',
    },
  }, repoCallers.superAdmin);
  const oldStandards = await context.repo.listCurriculumStandards({
    curriculumVersionId: '2025',
  });
  const newStandards = await context.repo.listCurriculumStandards({
    curriculumVersionId: '2026',
  });

  assert.equal(oldStandards.length, 2);
  assert.equal(newStandards.length, 2);
  assert.notEqual(oldStandards[0].id, newStandards[0].id);
});

test('invalid curriculum schema fails safely', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.importCurriculumSource({
    source: { id: 'missing-fields' },
    version: { id: '2025' },
    standards: [],
  }, repoCallers.superAdmin);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'invalid_source');
});

test('invalid standards are rejected and counted without blocking valid standards', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);
  const payload = validPayload();

  const response = await handlers.importCurriculumSource({
    ...payload,
    standards: [
      ...payload.standards,
      {
        code: '',
        title: 'Incomplete',
        description: '',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
      },
    ],
  }, repoCallers.superAdmin);
  const standards = await context.repo.listCurriculumStandards({
    curriculumSourceId: 'ca-common-core-math',
    curriculumVersionId: '2025',
  });

  assert.equal(response.status, 'completed_with_rejections');
  assert.equal(response.importedCount, 2);
  assert.equal(response.rejectedCount, 1);
  assert.equal(standards.length, 2);
});

test('curriculum import writes audit and provenance records', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  const audit = await context.repo.listAuditRecords();
  const provenance = await context.repo.listProvenanceRecords();

  assert.ok(audit.some((record) => record.eventType === 'curriculum_imported'));
  assert.ok(provenance.some((record) => record.targetType === 'curriculumImportBatch'));
});

test('School Admin and Student App cannot import curriculum', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const plannerResponse = await handlers.importCurriculumSource(validPayload(), repoCallers.planner);
  const studentResponse = await handlers.importCurriculumSource(validPayload(), repoCallers.student);

  assert.equal(plannerResponse.status, 'failed');
  assert.equal(plannerResponse.errorCode, 'permission_denied');
  assert.equal(studentResponse.status, 'failed');
  assert.equal(studentResponse.errorCode, 'permission_denied');
});

test('standards can be queried by source version grade and subject', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  await handlers.importCurriculumSource(validPayload(), repoCallers.superAdmin);
  const standards = await context.repo.listCurriculumStandards({
    curriculumSourceId: 'ca-common-core-math',
    curriculumVersionId: '2025',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
  });
  const expectedId = standardId('ca-common-core-math', '2025', '4.NF.A.1');

  assert.equal(standards.length, 2);
  assert.equal(standards[0].id, expectedId);
});

function validPayload() {
  return {
    source: {
      id: 'ca-common-core-math',
      name: 'California Common Core Mathematics',
      jurisdiction: 'CA',
      framework: 'common_core',
      officialSourceUrl: 'https://www.cde.ca.gov/be/st/ss/',
    },
    version: {
      id: '2025',
      sourceVersion: '2025',
      effectiveDate: '2025-01-01',
    },
    standards: [
      {
        code: '4.NF.A.1',
        title: 'Explain why a fraction a/b is equivalent to a fraction n x a/n x b.',
        description: 'Explain equivalent fractions using visual fraction models.',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
      },
      {
        code: '4.NF.A.2',
        title: 'Compare two fractions with different numerators and denominators.',
        description: 'Compare fractions by creating common denominators or using benchmarks.',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
      },
    ],
  };
}
