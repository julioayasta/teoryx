export const collections = {
  contentGenerationRequests: 'contentGenerationRequests',
  contentGenerationJobs: 'contentGenerationJobs',
  courseOfferings: 'courseOfferings',
  courseMaps: 'courseMaps',
  unitPlans: 'unitPlans',
  lessonSpecifications: 'lessonSpecifications',
  lessonArtifacts: 'lessonArtifacts',
  presentationArtifacts: 'presentationArtifacts',
  validationArtifacts: 'validationArtifacts',
  publishedLessonContent: 'publishedLessonContent',
  generationAuditEntries: 'generationAuditEntries',
  provenanceRecords: 'provenanceRecords',
  versionHistories: 'versionHistories',
  artifactPublicationRecords: 'artifactPublicationRecords',
  promptTemplateVersions: 'promptTemplateVersions',
  promptExecutionRecords: 'promptExecutionRecords',
  costTrackingRecords: 'costTrackingRecords',
  curriculumSources: 'curriculumSources',
  curriculumStandards: 'curriculumStandards',
  curriculumImportBatches: 'curriculumImportBatches',
  pedagogicalAnalyses: 'pedagogicalAnalyses',
} as const;

export function curriculumVersionCollection(sourceId: string): string {
  return `${collections.curriculumSources}/${sourceId}/versions`;
}

export type CollectionName = typeof collections[keyof typeof collections];
