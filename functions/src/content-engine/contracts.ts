export type CallerRole =
  | 'student'
  | 'school_planner'
  | 'school_reviewer'
  | 'school_publisher'
  | 'super_admin'
  | 'system'
  | 'unauthorized';

export type VisibleStatus = 'pending' | 'ready' | 'failed';

export type SchoolPortalStatus =
  | 'draft'
  | 'generating'
  | 'validation_failed'
  | 'ready_for_review'
  | 'approved'
  | 'published'
  | 'failed';

export type CallableName =
  | 'requestCoursePlanGeneration'
  | 'getCoursePlanStatus'
  | 'publishCourseOffering'
  | 'getLessonSpecificationsForCourse'
  | 'requestLessonContent'
  | 'getContentGenerationStatus'
  | 'requestSchoolLessonGeneration'
  | 'requestArtifactRegeneration'
  | 'approveArtifactForPublication'
  | 'publishValidatedArtifact'
  | 'importCurriculumSource'
  | 'requestPedagogicalAnalysis'
  | 'getPedagogicalAnalysisStatus';

export interface CallerContext {
  userId: string;
  role: CallerRole;
  schoolId?: string;
}

export interface CallableRequest {
  [key: string]: unknown;
}

export interface CallableResponse {
  status: string;
  message?: string;
  errorCode?: string;
  [key: string]: unknown;
}

export interface CourseOffering {
  id: string;
  schoolId: string;
  courseId: string;
  courseMapId: string;
  language: string;
  status: 'draft' | 'enabled' | 'disabled' | 'archived' | 'superseded';
  enabledForStudents: boolean;
}

export interface CourseMap {
  id: string;
  schoolId: string;
  courseId: string;
  language: string;
  curriculumVersionId?: string;
  gradeLevelId?: string;
  subjectId?: string;
  title?: string;
  status: 'draft' | 'in_review' | 'approved' | 'active' | 'archived' | 'superseded';
}

export interface UnitPlan {
  id: string;
  schoolId: string;
  courseMapId: string;
  courseId: string;
  order: number;
  status: 'draft' | 'in_review' | 'approved' | 'active' | 'archived' | 'superseded';
}

export interface LessonSpecification {
  id: string;
  lessonId: string;
  schoolId: string;
  courseMapId: string;
  courseId: string;
  unitId: string;
  title: string;
  order: number;
  estimatedDuration: string;
  difficultyLevel: string;
  language: string;
  generationStatus:
    | 'not_generated'
    | 'generation_pending'
    | 'generation_failed'
    | 'ready_for_review'
    | 'published'
    | 'superseded';
  publishedContentId: string | null;
  status: 'draft' | 'in_review' | 'approved' | 'active' | 'archived' | 'superseded';
  standardIds: string[];
  pedagogicalAnalysisIds: string[];
  learningObjectiveIds: string[];
  masteryDefinitionIds: string[];
  assessmentBlueprintIds: string[];
  lessonBlueprintIds: string[];
  targetSkills?: string[];
  vocabularyTargets?: string[];
  misconceptionTargets?: string[];
  prerequisiteLessonIds?: string[];
}

export interface ContentGenerationJob {
  id: string;
  requestId: string;
  schoolId: string;
  jobType: string;
  stage: string;
  status: 'queued' | 'locked' | 'processing' | 'completed' | 'failed' | 'retry_scheduled' | 'dead_lettered' | 'cancelled';
  attempt: number;
  maxAttempts: number;
  payload: Record<string, unknown>;
  createdAt: string;
  updatedAt: string;
  completedAt?: string;
}

export interface PublishedLessonContent {
  id: string;
  publishedContentId?: string;
  schoolId: string;
  courseId: string;
  lessonSpecificationId: string;
  curriculumId?: string;
  gradeLevelId?: string;
  subjectId?: string;
  standardId?: string;
  standardCode?: string;
  language: string;
  status: 'published' | 'retracted' | 'superseded';
  title: string;
  bigIdea?: string;
  essentialQuestion?: string;
  learningObjectiveId?: string;
  learningObjective?: string;
  lessonContent?: string;
  guidedPractice?: string;
  independentPractice?: string;
  summary?: string;
  steps?: PublishedLessonStep[];
  version?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface PublishedLessonStep {
  id: string;
  lessonId: string;
  order: number;
  type: 'story' | 'imagePlaceholder' | 'explanation' | 'question' | 'practice' | 'summary';
  title: string;
  body: string;
  prompt?: string;
  expectedAnswer?: string;
  imageDescription?: string;
}

export interface ContentGenerationRequest {
  id: string;
  schoolId: string;
  courseId?: string;
  lessonSpecificationId?: string;
  idempotencyKey: string;
  source: 'student_app' | 'school_admin_portal' | 'super_admin' | 'system';
  intent: string;
  publicationMode?: 'draft' | 'auto_publish_after_validation' | 'require_review';
  status: string;
  studentVisibleStatus: VisibleStatus;
  schoolPortalVisibleStatus?: SchoolPortalStatus;
  publishedContentId?: string | null;
}

export interface PresentationArtifact {
  id: string;
  schoolId: string;
  lessonSpecificationId: string;
  version: string;
  status: 'draft' | 'generated' | 'validation_failed' | 'ready_for_review' | 'approved' | 'published';
  validationArtifactId?: string;
  lessonArtifactId?: string;
  publishedContentId?: string;
  blocks?: PublishedLessonStep[];
}

export interface ValidationArtifact {
  id: string;
  schoolId: string;
  validationStatus: 'valid' | 'valid_with_warnings' | 'invalid';
  validatedArtifactIds: string[];
}

export interface LessonArtifact {
  id: string;
  schoolId: string;
  lessonSpecificationId?: string;
  title?: string;
  bigIdea?: string;
  essentialQuestion?: string;
  learningObjective?: string;
  lessonContent?: string;
  guidedPractice?: string;
  independentPractice?: string;
  summary?: string;
  status: 'draft' | 'generated' | 'validation_failed' | 'ready_for_review' | 'approved' | 'published';
}

export interface AuditRecord {
  id: string;
  schoolId: string;
  eventType: string;
  actorUserId: string;
  targetType: string;
  targetId: string;
  createdAt: string;
}

export interface ProvenanceRecord {
  id: string;
  schoolId: string;
  targetType: string;
  targetId: string;
  sourceIds: string[];
  createdAt: string;
}

export interface VersionHistoryRecord {
  id: string;
  schoolId: string;
  entityType: string;
  entityId: string;
  changeType: string;
  createdAt: string;
}

export interface PublicationRecord {
  id: string;
  schoolId: string;
  presentationArtifactId: string;
  publishedContentId: string;
  status: 'pending' | 'published' | 'failed';
}

export interface CurriculumSource {
  id: string;
  name: string;
  jurisdiction: string;
  framework: string;
  officialSourceUrl: string;
  updatedAt: string;
}

export interface CurriculumVersion {
  id: string;
  curriculumSourceId: string;
  sourceVersion: string;
  effectiveDate: string;
  retiredDate?: string;
  importDate: string;
  checksum: string;
  officialSourceUrl: string;
}

export interface CurriculumStandard {
  id: string;
  curriculumSourceId: string;
  curriculumVersionId: string;
  code: string;
  title: string;
  description: string;
  gradeLevelId: string;
  subjectId: string;
  checksum: string;
}

export interface CurriculumImportBatch {
  id: string;
  curriculumSourceId: string;
  curriculumVersionId: string;
  checksum: string;
  status: 'completed' | 'completed_with_rejections' | 'failed';
  importedCount: number;
  rejectedCount: number;
  rejectedRecords: Array<{
    index: number;
    reason: string;
  }>;
  createdAt: string;
}

export interface PedagogicalAnalysis {
  pedagogicalAnalysisId: string;
  standardId: string;
  curriculumSourceId: string;
  curriculumVersionId: string;
  standardCode: string;
  language: string;
  gradeLevelId: string;
  subjectId: string;
  prerequisites: string[];
  targetSkills: string[];
  vocabularyTerms: string[];
  misconceptions: string[];
  assessmentEvidence: string[];
  languageProfile: {
    band: string;
    sentenceComplexity: string;
    vocabularySupport: string;
    scaffolding: string;
  };
  validationStatus: 'valid' | 'invalid';
  promptTemplateVersionIds: string[];
  sourceGenerationRequestId: string;
  status: 'ready' | 'failed';
  createdAt: string;
  updatedAt: string;
}

export interface PromptTemplateVersion {
  id: string;
  templateId: string;
  version: string;
  taskType: string;
  status: 'draft' | 'active' | 'retired';
  promptText: string;
  outputSchemaId?: string;
  createdAt: string;
}

export interface PromptExecutionRecord {
  id: string;
  schoolId: string;
  requestId?: string;
  artifactId?: string;
  provider: string;
  model: string;
  promptTemplateVersionId: string;
  inputHash: string;
  outputHash?: string;
  estimatedInputTokens?: number;
  estimatedOutputTokens?: number;
  estimatedCostUsd?: number;
  status: 'succeeded' | 'failed';
  error?: {
    code: string;
    message: string;
    retryable: boolean;
  };
  timeoutMs?: number;
  retryAttempt: number;
  maxRetries: number;
  createdAt: string;
  completedAt: string;
}

export interface CostTrackingRecord {
  id: string;
  schoolId: string;
  requestId?: string;
  promptExecutionRecordId: string;
  provider: string;
  model: string;
  estimatedInputTokens: number;
  estimatedOutputTokens: number;
  estimatedCostUsd: number;
  createdAt: string;
}

export interface ContentEngineStore {
  courseOfferings: Map<string, CourseOffering>;
  courseMaps: Map<string, CourseMap>;
  unitPlans: Map<string, UnitPlan>;
  lessonSpecifications: Map<string, LessonSpecification>;
  publishedLessonContent: Map<string, PublishedLessonContent>;
  generationRequests: Map<string, ContentGenerationRequest>;
  generationJobs?: Map<string, ContentGenerationJob>;
  lessonArtifacts: Map<string, LessonArtifact>;
  presentationArtifacts: Map<string, PresentationArtifact>;
  validationArtifacts: Map<string, ValidationArtifact>;
  auditRecords: AuditRecord[];
  provenanceRecords: ProvenanceRecord[];
  versionHistoryRecords: VersionHistoryRecord[];
  publicationRecords: PublicationRecord[];
  promptTemplateVersions: Map<string, PromptTemplateVersion>;
  promptExecutionRecords: PromptExecutionRecord[];
  costTrackingRecords: CostTrackingRecord[];
  curriculumSources: Map<string, CurriculumSource>;
  curriculumVersions: Map<string, CurriculumVersion>;
  curriculumStandards: Map<string, CurriculumStandard>;
  curriculumImportBatches: Map<string, CurriculumImportBatch>;
  pedagogicalAnalyses: Map<string, PedagogicalAnalysis>;
}
