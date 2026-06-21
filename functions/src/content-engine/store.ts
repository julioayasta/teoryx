import type {
  ContentEngineStore,
  ContentGenerationRequest,
  CostTrackingRecord,
  CourseMap,
  CourseOffering,
  LessonArtifact,
  LessonSpecification,
  PresentationArtifact,
  PromptExecutionRecord,
  PromptTemplateVersion,
  PublishedLessonContent,
  UnitPlan,
  ValidationArtifact,
} from './contracts.js';

export function createEmptyStore(): ContentEngineStore {
  return {
    courseOfferings: new Map<string, CourseOffering>(),
    courseMaps: new Map<string, CourseMap>(),
    unitPlans: new Map<string, UnitPlan>(),
    lessonSpecifications: new Map<string, LessonSpecification>(),
    publishedLessonContent: new Map<string, PublishedLessonContent>(),
    generationRequests: new Map<string, ContentGenerationRequest>(),
    lessonArtifacts: new Map<string, LessonArtifact>(),
    presentationArtifacts: new Map<string, PresentationArtifact>(),
    validationArtifacts: new Map<string, ValidationArtifact>(),
    auditRecords: [],
    provenanceRecords: [],
    versionHistoryRecords: [],
    publicationRecords: [],
    promptTemplateVersions: new Map<string, PromptTemplateVersion>(),
    promptExecutionRecords: [] as PromptExecutionRecord[],
    costTrackingRecords: [] as CostTrackingRecord[],
  };
}
