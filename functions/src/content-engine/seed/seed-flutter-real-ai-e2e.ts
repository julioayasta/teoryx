import { pathToFileURL } from 'node:url';

import { FirestoreAdminDocumentStore } from '../firestore/admin.js';
import type { DocumentStore } from '../firestore/document-store.js';
import { FirestoreContentEngineRepository } from '../repositories/firestore-content-engine-repository.js';

export const flutterRealAIE2ESeed = {
  schoolId: 'school-demo',
  courseId: 'grade-4-math-real',
  language: 'en',
  courseOfferingId: 'offering-school-demo-grade-4-math-real-en',
  courseMapId: 'course-map-school-demo-grade-4-math-real-2025-en',
  unitPlanId: 'unit-grade-4-math-real-2025-1',
  curriculumSourceId: 'ca-common-core-math',
  curriculumVersionId: '2025',
} as const;

interface SeedLesson {
  code: string;
  slug: string;
  title: string;
  description: string;
  targetSkill: string;
  vocabularyTerms: string[];
  misconception: string;
}

export const flutterRealAIE2ELessons: SeedLesson[] = [
  {
    code: '4.NF.A.1',
    slug: '4-nf-a-1',
    title: 'Explain Equivalent Fractions',
    description: 'Explain why a fraction a/b is equivalent to a fraction n x a/n x b by using visual fraction models.',
    targetSkill: 'Explain equivalent fractions with visual models.',
    vocabularyTerms: ['fraction', 'equivalent', 'numerator', 'denominator'],
    misconception: 'Students may compare only numerators or only denominators.',
  },
  {
    code: '4.NF.A.2',
    slug: '4-nf-a-2',
    title: 'Compare Fractions With Different Denominators',
    description: 'Compare two fractions with different numerators and different denominators using common denominators, common numerators, or benchmark fractions.',
    targetSkill: 'Compare fractions using common denominators and benchmark fractions.',
    vocabularyTerms: ['benchmark fraction', 'common denominator', 'compare'],
    misconception: 'Students may think a larger denominator always means a larger fraction.',
  },
  {
    code: '4.NF.B.3',
    slug: '4-nf-b-3',
    title: 'Add Fractions With Like Denominators',
    description: 'Understand a fraction a/b with a greater than 1 as a sum of fractions 1/b.',
    targetSkill: 'Decompose and add fractions with like denominators.',
    vocabularyTerms: ['decompose', 'unit fraction', 'sum'],
    misconception: 'Students may add denominators when adding fractions.',
  },
  {
    code: '4.NF.B.4',
    slug: '4-nf-b-4',
    title: 'Multiply Fractions By Whole Numbers',
    description: 'Apply and extend previous understandings of multiplication to multiply a fraction by a whole number.',
    targetSkill: 'Represent multiplying a fraction by a whole number with repeated addition and visual models.',
    vocabularyTerms: ['multiple', 'whole number', 'repeated addition'],
    misconception: 'Students may not connect multiplication to repeated groups of a fraction.',
  },
  {
    code: '4.NF.C.5',
    slug: '4-nf-c-5',
    title: 'Add Tenths And Hundredths',
    description: 'Express a fraction with denominator 10 as an equivalent fraction with denominator 100 and add fractions with denominators 10 and 100.',
    targetSkill: 'Convert tenths to hundredths and add related fractions.',
    vocabularyTerms: ['tenths', 'hundredths', 'equivalent fraction'],
    misconception: 'Students may treat tenths and hundredths as unrelated units.',
  },
];

export async function seedFlutterRealAIE2EData(
  store: DocumentStore,
  repo: FirestoreContentEngineRepository,
): Promise<void> {
  await seedFlutterFacingData(store);
  await seedContentEngineData(repo);
}

export function lessonSpecificationIdForSeedLesson(lesson: SeedLesson): string {
  return `lesson-spec-grade-4-math-real-${lesson.slug}`;
}

async function main(): Promise<void> {
  const store = new FirestoreAdminDocumentStore();
  const repo = new FirestoreContentEngineRepository(store);
  await store.clear();
  await seedFlutterRealAIE2EData(store, repo);

  console.log('Seeded Flutter real AI E2E emulator data.');
  console.log(`courseId: ${flutterRealAIE2ESeed.courseId}`);
  console.log(`courseOfferingId: ${flutterRealAIE2ESeed.courseOfferingId}`);
  console.log(`lessonSpecificationCount: ${flutterRealAIE2ELessons.length}`);
  for (const lesson of flutterRealAIE2ELessons) {
    console.log(`lessonSpecificationId: ${lessonSpecificationIdForSeedLesson(lesson)}`);
  }
  console.log('publishedContentId: null for all seeded lesson specifications');
}

async function seedFlutterFacingData(store: DocumentStore): Promise<void> {
  const { schoolId, courseId } = flutterRealAIE2ESeed;
  await store.set('schools', schoolId, {
    id: schoolId,
    name: 'K2S Demo',
    fullName: 'K2S Demo School',
    primaryColor: '#2F6FED',
    secondaryColor: '#14B8A6',
    fontFamily: 'Atkinson Hyperlegible',
    status: 'active',
  });
  await store.set(`schools/${schoolId}/courses`, courseId, {
    courseId,
    curriculumId: flutterRealAIE2ESeed.curriculumSourceId,
    gradeLevelId: 'grade-4',
    gradeLevelName: 'Grade 4',
    subjectId: 'math',
    subjectName: 'Math',
    title: 'Grade 4 Math Real AI E2E',
    status: 'published',
    order: 1,
  });
  await store.set(`schools/${schoolId}/students`, 'student-001', {
    studentId: 'student-001',
    firstName: 'Sofia',
    lastName: 'Rivera',
    gradeLevelId: 'grade-4',
    gradeLevelName: 'Grade 4',
    preferredLanguage: 'en',
    status: 'active',
  });
  await store.set('users', 'emulator-student-001', {
    userId: 'emulator-student-001',
    displayName: 'Sofia Rivera',
    email: 'student@example.com',
    schoolId,
    role: 'student',
    preferredLanguage: 'en',
  });
}

async function seedContentEngineData(repo: FirestoreContentEngineRepository): Promise<void> {
  const {
    schoolId,
    courseId,
    language,
    courseOfferingId,
    courseMapId,
    unitPlanId,
    curriculumSourceId,
    curriculumVersionId,
  } = flutterRealAIE2ESeed;

  await repo.saveCourseOffering({
    id: courseOfferingId,
    schoolId,
    courseId,
    courseMapId,
    language,
    status: 'enabled',
    enabledForStudents: true,
  });
  await repo.saveCourseMap({
    id: courseMapId,
    schoolId,
    courseId,
    language,
    curriculumVersionId,
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    title: 'Grade 4 Math Real AI E2E',
    status: 'active',
  });
  await repo.saveUnitPlan({
    id: unitPlanId,
    schoolId,
    courseMapId,
    courseId,
    order: 1,
    status: 'active',
  });
  await repo.saveCurriculumSource({
    id: curriculumSourceId,
    name: 'California Common Core Mathematics',
    jurisdiction: 'CA',
    framework: 'common_core',
    officialSourceUrl: 'https://www.cde.ca.gov/be/st/ss/',
    updatedAt: new Date().toISOString(),
  });
  await repo.saveCurriculumVersion({
    id: curriculumVersionId,
    curriculumSourceId,
    sourceVersion: curriculumVersionId,
    effectiveDate: '2025-01-01',
    importDate: new Date().toISOString(),
    checksum: 'dev-e2e-checksum',
    officialSourceUrl: 'https://www.cde.ca.gov/be/st/ss/',
  });

  for (const [index, lesson] of flutterRealAIE2ELessons.entries()) {
    await seedLesson(repo, lesson, index);
  }
}

async function seedLesson(
  repo: FirestoreContentEngineRepository,
  lesson: SeedLesson,
  index: number,
): Promise<void> {
  const {
    schoolId,
    courseId,
    language,
    courseMapId,
    unitPlanId,
    curriculumSourceId,
    curriculumVersionId,
  } = flutterRealAIE2ESeed;
  const standardId = `${curriculumSourceId}-${curriculumVersionId}-${lesson.slug}`;
  const analysisId = `pedagogical-analysis-${standardId}-${curriculumVersionId}-${language}`;
  const lessonSpecificationId = lessonSpecificationIdForSeedLesson(lesson);
  const previousLesson = flutterRealAIE2ELessons[index - 1];

  await repo.saveCurriculumStandard({
    id: standardId,
    curriculumSourceId,
    curriculumVersionId,
    code: lesson.code,
    title: lesson.title,
    description: lesson.description,
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    checksum: `dev-e2e-standard-checksum-${lesson.slug}`,
  });
  await repo.savePedagogicalAnalysis({
    pedagogicalAnalysisId: analysisId,
    standardId,
    curriculumSourceId,
    curriculumVersionId,
    standardCode: lesson.code,
    language,
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    prerequisites: ['Understand a whole can be partitioned into equal parts.'],
    targetSkills: [lesson.targetSkill],
    vocabularyTerms: lesson.vocabularyTerms,
    misconceptions: [lesson.misconception],
    assessmentEvidence: ['Student explains the idea using a visual model and a short written explanation.'],
    languageProfile: {
      band: 'grade-4',
      sentenceComplexity: 'short compound sentences',
      vocabularySupport: 'define academic vocabulary before using it',
      scaffolding: 'use visuals before abstract notation',
    },
    validationStatus: 'valid',
    promptTemplateVersionIds: ['prompt-analysis-dev-e2e'],
    sourceGenerationRequestId: 'request-analysis-dev-e2e',
    status: 'ready',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
  await repo.saveLessonSpecification({
    id: lessonSpecificationId,
    lessonId: `lesson-grade-4-math-real-${lesson.slug}`,
    schoolId,
    courseMapId,
    courseId,
    unitId: unitPlanId,
    title: lesson.title,
    order: index + 1,
    estimatedDuration: '20m',
    difficultyLevel: index === 0 ? 'introductory' : 'core',
    language,
    generationStatus: 'not_generated',
    publishedContentId: null,
    status: 'active',
    standardIds: [standardId],
    pedagogicalAnalysisIds: [analysisId],
    learningObjectiveIds: [`objective-dev-e2e-${lesson.slug}`],
    masteryDefinitionIds: [`mastery-dev-e2e-${lesson.slug}`],
    assessmentBlueprintIds: [`assessment-dev-e2e-${lesson.slug}`],
    lessonBlueprintIds: [`lesson-blueprint-dev-e2e-${lesson.slug}`],
    targetSkills: [lesson.targetSkill],
    vocabularyTargets: lesson.vocabularyTerms,
    misconceptionTargets: [lesson.misconception],
    prerequisiteLessonIds: previousLesson ? [lessonSpecificationIdForSeedLesson(previousLesson)] : [],
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : 'Failed to seed Flutter real AI E2E emulator data.');
    process.exitCode = 1;
  });
}
