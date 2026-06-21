import type {
  AuditRecord,
  ContentGenerationRequest,
  ContentGenerationJob,
  CostTrackingRecord,
  CourseMap,
  CourseOffering,
  CurriculumImportBatch,
  CurriculumSource,
  CurriculumStandard,
  CurriculumVersion,
  LessonArtifact,
  LessonSpecification,
  PedagogicalAnalysis,
  PresentationArtifact,
  PromptExecutionRecord,
  PromptTemplateVersion,
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
  saveContentGenerationJob(job: ContentGenerationJob): Promise<void>;
  listContentGenerationJobs(input?: { requestId?: string; schoolId?: string }): Promise<ContentGenerationJob[]>;

  getLessonArtifact(id: string): Promise<LessonArtifact | undefined>;
  findLessonArtifactBySpecification(input: { schoolId: string; lessonSpecificationId: string }): Promise<LessonArtifact | undefined>;
  saveLessonArtifact(artifact: LessonArtifact): Promise<void>;
  getPresentationArtifact(id: string): Promise<PresentationArtifact | undefined>;
  findPresentationArtifactBySpecification(input: { schoolId: string; lessonSpecificationId: string }): Promise<PresentationArtifact | undefined>;
  savePresentationArtifact(artifact: PresentationArtifact): Promise<void>;
  getValidationArtifact(id: string): Promise<ValidationArtifact | undefined>;
  saveValidationArtifact(artifact: ValidationArtifact): Promise<void>;

  saveAudit(record: AuditRecord): Promise<void>;
  saveProvenance(record: ProvenanceRecord): Promise<void>;
  saveVersionHistory(record: VersionHistoryRecord): Promise<void>;
  savePublicationRecord(record: PublicationRecord): Promise<void>;
  getPromptTemplateVersion(id: string): Promise<PromptTemplateVersion | undefined>;
  listPromptTemplateVersions(input?: { taskType?: string; status?: PromptTemplateVersion['status'] }): Promise<PromptTemplateVersion[]>;
  savePromptTemplateVersion(template: PromptTemplateVersion): Promise<void>;
  savePromptExecutionRecord(record: PromptExecutionRecord): Promise<void>;
  saveCostTrackingRecord(record: CostTrackingRecord): Promise<void>;
  getCurriculumSource(id: string): Promise<CurriculumSource | undefined>;
  saveCurriculumSource(source: CurriculumSource): Promise<void>;
  getCurriculumVersion(input: { sourceId: string; versionId: string }): Promise<CurriculumVersion | undefined>;
  saveCurriculumVersion(version: CurriculumVersion): Promise<void>;
  getCurriculumStandard(id: string): Promise<CurriculumStandard | undefined>;
  saveCurriculumStandard(standard: CurriculumStandard): Promise<void>;
  listCurriculumStandards(input?: {
    curriculumSourceId?: string;
    curriculumVersionId?: string;
    gradeLevelId?: string;
    subjectId?: string;
  }): Promise<CurriculumStandard[]>;
  getCurriculumImportBatch(id: string): Promise<CurriculumImportBatch | undefined>;
  saveCurriculumImportBatch(batch: CurriculumImportBatch): Promise<void>;
  getPedagogicalAnalysis(id: string): Promise<PedagogicalAnalysis | undefined>;
  findPedagogicalAnalysis(input: {
    standardId: string;
    curriculumVersionId: string;
    language: string;
  }): Promise<PedagogicalAnalysis | undefined>;
  savePedagogicalAnalysis(analysis: PedagogicalAnalysis): Promise<void>;

  listAuditRecords(): Promise<AuditRecord[]>;
  listProvenanceRecords(): Promise<ProvenanceRecord[]>;
  listPublishedLessonContent(): Promise<PublishedLessonContent[]>;
  listPublicationRecords(): Promise<PublicationRecord[]>;
  listPromptExecutionRecords(): Promise<PromptExecutionRecord[]>;
  listCostTrackingRecords(): Promise<CostTrackingRecord[]>;
  listCurriculumImportBatches(): Promise<CurriculumImportBatch[]>;
  listPedagogicalAnalyses(): Promise<PedagogicalAnalysis[]>;
}
