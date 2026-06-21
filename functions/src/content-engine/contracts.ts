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
  | 'publishValidatedArtifact';

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
}

export interface PublishedLessonContent {
  id: string;
  schoolId: string;
  courseId: string;
  lessonSpecificationId: string;
  language: string;
  status: 'published' | 'retracted' | 'superseded';
  title: string;
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

export interface ContentEngineStore {
  courseOfferings: Map<string, CourseOffering>;
  courseMaps: Map<string, CourseMap>;
  unitPlans: Map<string, UnitPlan>;
  lessonSpecifications: Map<string, LessonSpecification>;
  publishedLessonContent: Map<string, PublishedLessonContent>;
  generationRequests: Map<string, ContentGenerationRequest>;
  lessonArtifacts: Map<string, LessonArtifact>;
  presentationArtifacts: Map<string, PresentationArtifact>;
  validationArtifacts: Map<string, ValidationArtifact>;
  auditRecords: AuditRecord[];
  provenanceRecords: ProvenanceRecord[];
  versionHistoryRecords: VersionHistoryRecord[];
  publicationRecords: PublicationRecord[];
}
