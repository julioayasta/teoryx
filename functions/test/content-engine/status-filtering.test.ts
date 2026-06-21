import assert from 'node:assert/strict';
import test from 'node:test';
import { createContentEngineHandlers } from '../../src/content-engine/functions/index.js';
import { callers, createSeededStore } from '../fixtures/seed-data.js';

test('Student App status response exposes only pending ready or failed', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getContentGenerationStatus({
    schoolId: 'school-demo',
    requestId: 'request-review-001',
  }, callers.student);

  assert.equal(response.status, 'pending');
  assert.equal('stage' in response, false);
});

test('School Portal status may expose review state and stage', async () => {
  const store = createSeededStore();
  const handlers = createContentEngineHandlers(store);

  const response = await handlers.getContentGenerationStatus({
    schoolId: 'school-demo',
    requestId: 'request-review-001',
  }, callers.planner);

  assert.equal(response.status, 'ready_for_review');
  assert.equal(response.stage, 'ready_for_review');
});
