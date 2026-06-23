import assert from 'node:assert/strict';
import test from 'node:test';

import { SafeFakeAIProvider } from '../../src/content-engine/ai/safe-fake-ai-provider.js';
import type { CallableResponse, CallerContext } from '../../src/content-engine/contracts.js';
import { MemoryDocumentStore } from '../../src/content-engine/firestore/document-store.js';
import { FirestoreContentEngineRepository } from '../../src/content-engine/repositories/firestore-content-engine-repository.js';
import { createFirestoreBackedContentEngineHandlers } from '../../src/content-engine/repository-runtime.js';
import {
  flutterRealAIE2ELessons,
  flutterRealAIE2ESeed,
  lessonSpecificationIdForSeedLesson,
  seedFlutterRealAIE2EData,
} from '../../src/content-engine/seed/seed-flutter-real-ai-e2e.js';

test('Flutter real AI E2E seed creates five visible missing-content lesson specifications', async () => {
  const store = new MemoryDocumentStore();
  const repo = new FirestoreContentEngineRepository(store);
  await seedFlutterRealAIE2EData(store, repo);

  const caller: CallerContext = {
    userId: 'emulator-student-001',
    role: 'student',
    schoolId: flutterRealAIE2ESeed.schoolId,
  };
  const handlers = createFirestoreBackedContentEngineHandlers(repo, {
    env: {},
    aiProvider: new SafeFakeAIProvider(),
  });

  const listing = await handlers.getLessonSpecificationsForCourse({
    schoolId: flutterRealAIE2ESeed.schoolId,
    courseOfferingId: flutterRealAIE2ESeed.courseOfferingId,
    courseId: flutterRealAIE2ESeed.courseId,
    language: flutterRealAIE2ESeed.language,
  }, caller) as CallableResponse & {
    lessons?: Array<{
      lessonSpecificationId: string;
      generationStatus: string;
      publishedContentId: string | null;
    }>;
  };

  assert.equal(listing.status, 'ready');
  assert.equal(listing.lessons?.length, 5);
  assert.deepEqual(
    listing.lessons?.map((lesson) => lesson.lessonSpecificationId),
    flutterRealAIE2ELessons.map(lessonSpecificationIdForSeedLesson),
  );
  assert.equal(
    listing.lessons?.every((lesson) =>
      lesson.generationStatus === 'not_generated' &&
      lesson.publishedContentId === null
    ),
    true,
  );

  for (const lesson of flutterRealAIE2ELessons) {
    const lessonSpecification = await repo.getLessonSpecification(lessonSpecificationIdForSeedLesson(lesson));
    assert.ok(lessonSpecification);
    assert.equal(lessonSpecification.standardIds.length, 1);
    assert.equal(lessonSpecification.pedagogicalAnalysisIds.length, 1);
    assert.ok(await repo.getCurriculumStandard(lessonSpecification.standardIds[0]));
    assert.ok(await repo.getPedagogicalAnalysis(lessonSpecification.pedagogicalAnalysisIds[0]));
  }

  const firstLessonSpecificationId = lessonSpecificationIdForSeedLesson(flutterRealAIE2ELessons[0]);
  const generation = await handlers.requestLessonContent({
    schoolId: flutterRealAIE2ESeed.schoolId,
    courseOfferingId: flutterRealAIE2ESeed.courseOfferingId,
    courseId: flutterRealAIE2ESeed.courseId,
    lessonSpecificationId: firstLessonSpecificationId,
    language: flutterRealAIE2ESeed.language,
  }, caller);

  assert.equal(generation.status, 'ready');
  assert.equal(typeof generation.publishedContentId, 'string');

  const updated = await repo.getLessonSpecification(firstLessonSpecificationId);
  assert.equal(updated?.generationStatus, 'published');
  assert.equal(updated?.publishedContentId, generation.publishedContentId);
  assert.ok(await repo.getPublishedLessonContent(String(generation.publishedContentId)));
});
