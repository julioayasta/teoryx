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
} as const;

export type CollectionName = typeof collections[keyof typeof collections];
