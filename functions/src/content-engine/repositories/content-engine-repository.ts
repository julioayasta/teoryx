import type {
  AuditRecord,
  ContentGenerationRequest,
  CourseMap,
  CourseOffering,
  LessonArtifact,
  LessonSpecification,
  PresentationArtifact,
  ProvenanceRecord,
  PublishedLessonContent,
  PublicationRecord,
  UnitPlan,
  ValidationArtifact,
  VersionHistoryRecord,
} from '../contracts.js';

export interface ContentEngineRepository {
  getCourseOffering(id: string): Promise<CourseOffering | undefined>;
  findCourseOffering(input: { schoolId: string; courseId: string; language: string }): Promise<CourseOffering | undefined>;
  saveCourseOffering(offering: CourseOffering): Promise<void>;

  getCourseMap(id: string): Promise<CourseMap | undefined>;
  saveCourseMap(courseMap: CourseMap): Promise<void>;

  listUnitPlans(input: { schoolId: string; courseId: string; courseMapId: string }): Promise<UnitPlan[]>;
  saveUnitPlan(unitPlan: UnitPlan): Promise<void>;

  getLessonSpecification(id: string): Promise<LessonSpecification | undefined>;
  listLessonSpecifications(input: { schoolId: string; courseId: string; courseMapId: string; language: string }): Promise<LessonSpecification[]>;
  updateLessonSpecification(id: string, data: Partial<LessonSpecification>): Promise<void>;
  saveLessonSpecification(lesson: LessonSpecification): Promise<void>;

  getPublishedLessonContent(id: string): Promise<PublishedLessonContent | undefined>;
  savePublishedLessonContent(content: PublishedLessonContent): Promise<void>;

  findPendingRequestByIdempotency(input: { schoolId: string; idempotencyKey: string }): Promise<ContentGenerationRequest | undefined>;
  getGenerationRequest(id: string): Promise<ContentGenerationRequest | undefined>;
  saveGenerationRequest(request: ContentGenerationRequest): Promise<void>;
  countGenerationRequests(): Promise<number>;

  getLessonArtifact(id: string): Promise<LessonArtifact | undefined>;
  saveLessonArtifact(artifact: LessonArtifact): Promise<void>;
  getPresentationArtifact(id: string): Promise<PresentationArtifact | undefined>;
  savePresentationArtifact(artifact: PresentationArtifact): Promise<void>;
  getValidationArtifact(id: string): Promise<ValidationArtifact | undefined>;
  saveValidationArtifact(artifact: ValidationArtifact): Promise<void>;

  saveAudit(record: AuditRecord): Promise<void>;
  saveProvenance(record: ProvenanceRecord): Promise<void>;
  saveVersionHistory(record: VersionHistoryRecord): Promise<void>;
  savePublicationRecord(record: PublicationRecord): Promise<void>;

  listAuditRecords(): Promise<AuditRecord[]>;
  listProvenanceRecords(): Promise<ProvenanceRecord[]>;
  listPublishedLessonContent(): Promise<PublishedLessonContent[]>;
  listPublicationRecords(): Promise<PublicationRecord[]>;
}
