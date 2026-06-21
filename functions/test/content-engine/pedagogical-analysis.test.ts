import assert from 'node:assert/strict';
import test from 'node:test';

import type { AIProvider, AIRequest, AIResponse } from '../../src/content-engine/ai/types.js';
import { analysisId } from '../../src/content-engine/pedagogy/pedagogical-analysis-service.js';
import { standardId } from '../../src/content-engine/curriculum/curriculum-import-service.js';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import { repoCallers } from '../fixtures/repository-seed-data.js';
import { createFirestoreTestContext } from '../helpers/firestore-test-context.js';

class MockAnalysisProvider implements AIProvider {
  readonly providerName = 'safe_fake';
  readonly model = 'mock-analysis-v1';

  constructor(private readonly content: string) {}

  async generate(_request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse> {
    return {
      content: this.content,
      estimatedInputTokens: 80,
      estimatedOutputTokens: 120,
      estimatedCostUsd: 0,
    };
  }
}

test('SuperAdmin can request pedagogical analysis', async () => {
  const { context, handlers, importedStandardId } = await setup();

  const response = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const analysis = await context.repo.getPedagogicalAnalysis(String(response.pedagogicalAnalysisId));

  assert.equal(response.status, 'ready');
  assert.equal(analysis?.standardId, importedStandardId);
  assert.equal(analysis?.status, 'ready');
});

test('Student App cannot request pedagogical analysis', async () => {
  const { handlers, importedStandardId } = await setup();

  const response = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.student);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'permission_denied');
});

test('request fails safely for missing standard', async () => {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);

  const response = await handlers.requestPedagogicalAnalysis({
    standardId: 'missing-standard',
    language: 'en',
  }, repoCallers.superAdmin);

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'standard_not_found');
});

test('valid request creates analysis tracing source version and standard', async () => {
  const { context, handlers, importedStandardId } = await setup();

  const response = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const analysis = await context.repo.getPedagogicalAnalysis(String(response.pedagogicalAnalysisId));

  assert.equal(analysis?.curriculumSourceId, 'ca-common-core-math');
  assert.equal(analysis?.curriculumVersionId, '2025');
  assert.equal(analysis?.standardCode, '4.NF.A.1');
  assert.equal(analysis?.gradeLevelId, 'grade-4');
  assert.equal(analysis?.subjectId, 'math');
  assert.ok((analysis?.prerequisites.length ?? 0) > 0);
  assert.ok((analysis?.targetSkills.length ?? 0) > 0);
  assert.ok((analysis?.vocabularyTerms.length ?? 0) > 0);
  assert.ok((analysis?.misconceptions.length ?? 0) > 0);
  assert.ok((analysis?.assessmentEvidence.length ?? 0) > 0);
  assert.equal(analysis?.validationStatus, 'valid');
});

test('repeated pedagogical analysis request is idempotent', async () => {
  const { context, handlers, importedStandardId } = await setup();

  const first = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const second = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const analyses = await context.repo.listPedagogicalAnalyses();

  assert.equal(first.pedagogicalAnalysisId, second.pedagogicalAnalysisId);
  assert.equal(analyses.length, 1);
});

test('analysis generation writes prompt cost audit provenance and version records', async () => {
  const { context, handlers, importedStandardId } = await setup();

  await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const prompts = await context.repo.listPromptExecutionRecords();
  const costs = await context.repo.listCostTrackingRecords();
  const audits = await context.repo.listAuditRecords();
  const provenance = await context.repo.listProvenanceRecords();

  assert.ok(prompts.some((record) => record.promptTemplateVersionId.includes('pedagogical_analysis_generation')));
  assert.ok(costs.length > 0);
  assert.ok(audits.some((record) => record.eventType === 'pedagogical_analysis_generated'));
  assert.ok(provenance.some((record) => record.targetType === 'pedagogicalAnalysis'));
});

test('invalid AI output fails safely and does not persist approved analysis', async () => {
  const { context, importedStandardId } = await setup();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo, {
    aiProvider: new MockAnalysisProvider('not-json'),
  });

  const response = await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'es',
  }, repoCallers.superAdmin);
  const analyses = await context.repo.listPedagogicalAnalyses();

  assert.equal(response.status, 'failed');
  assert.equal(response.errorCode, 'invalid_json');
  assert.equal(analyses.length, 0);
  assert.equal((await context.repo.listPromptExecutionRecords()).length, 1);
  assert.equal((await context.repo.listCostTrackingRecords()).length, 1);
});

test('getPedagogicalAnalysisStatus returns ready or failed safely', async () => {
  const { handlers, importedStandardId } = await setup();
  const generatedId = analysisId(importedStandardId, '2025', 'en');

  const missing = await handlers.getPedagogicalAnalysisStatus({
    pedagogicalAnalysisId: generatedId,
  }, repoCallers.superAdmin);
  await handlers.requestPedagogicalAnalysis({
    standardId: importedStandardId,
    language: 'en',
  }, repoCallers.superAdmin);
  const ready = await handlers.getPedagogicalAnalysisStatus({
    pedagogicalAnalysisId: generatedId,
  }, repoCallers.superAdmin);

  assert.equal(missing.status, 'failed');
  assert.equal(missing.errorCode, 'pedagogical_analysis_not_found');
  assert.equal(ready.status, 'ready');
  assert.equal(ready.validationStatus, 'valid');
});

async function setup() {
  const context = createFirestoreTestContext();
  const handlers = createFirestoreBackedContentEngineHandlers(context.repo);
  await handlers.importCurriculumSource(curriculumPayload(), repoCallers.superAdmin);
  return {
    context,
    handlers,
    importedStandardId: standardId('ca-common-core-math', '2025', '4.NF.A.1'),
  };
}

function curriculumPayload() {
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
    ],
  };
}
