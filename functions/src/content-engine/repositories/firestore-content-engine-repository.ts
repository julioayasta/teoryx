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
import { collections, curriculumVersionCollection } from '../firestore/paths.js';
import type { DocumentStore } from '../firestore/document-store.js';
import type { ContentEngineRepository } from './content-engine-repository.js';

type Plain = object;

export class FirestoreContentEngineRepository implements ContentEngineRepository {
  constructor(private readonly store: DocumentStore) {}

  async getCourseOffering(id: string): Promise<CourseOffering | undefined> {
    return this.get<CourseOffering>(collections.courseOfferings, id);
  }

  async findCourseOffering(input: { schoolId: string; courseId: string; language: string }): Promise<CourseOffering | undefined> {
    return (await this.list<CourseOffering>(collections.courseOfferings)).find((offering) =>
      offering.schoolId === input.schoolId &&
      offering.courseId === input.courseId &&
      offering.language === input.language
    );
  }

  async saveCourseOffering(offering: CourseOffering): Promise<void> {
    await this.set(collections.courseOfferings, offering.id, offering);
  }

  async getCourseMap(id: string): Promise<CourseMap | undefined> {
    return this.get<CourseMap>(collections.courseMaps, id);
  }

  async saveCourseMap(courseMap: CourseMap): Promise<void> {
    await this.set(collections.courseMaps, courseMap.id, courseMap);
  }

  async listUnitPlans(input: { schoolId: string; courseId: string; courseMapId: string }): Promise<UnitPlan[]> {
    return (await this.list<UnitPlan>(collections.unitPlans)).filter((unit) =>
      unit.schoolId === input.schoolId &&
      unit.courseId === input.courseId &&
      unit.courseMapId === input.courseMapId
    );
  }

  async saveUnitPlan(unitPlan: UnitPlan): Promise<void> {
    await this.set(collections.unitPlans, unitPlan.id, unitPlan);
  }

  async getLessonSpecification(id: string): Promise<LessonSpecification | undefined> {
    return this.get<LessonSpecification>(collections.lessonSpecifications, id);
  }

  async listLessonSpecifications(input: { schoolId: string; courseId: string; courseMapId: string; language: string }): Promise<LessonSpecification[]> {
    return (await this.list<LessonSpecification>(collections.lessonSpecifications))
      .filter((lesson) =>
        lesson.schoolId === input.schoolId &&
        lesson.courseId === input.courseId &&
        lesson.courseMapId === input.courseMapId &&
        lesson.language === input.language
      )
      .sort((a, b) => a.order - b.order);
  }

  async updateLessonSpecification(id: string, data: Partial<LessonSpecification>): Promise<void> {
    await this.store.update(collections.lessonSpecifications, id, data as Plain);
  }

  async saveLessonSpecification(lesson: LessonSpecification): Promise<void> {
    await this.set(collections.lessonSpecifications, lesson.id, lesson);
  }

  async getPublishedLessonContent(id: string): Promise<PublishedLessonContent | undefined> {
    return this.get<PublishedLessonContent>(collections.publishedLessonContent, id);
  }

  async savePublishedLessonContent(content: PublishedLessonContent): Promise<void> {
    await this.set(collections.publishedLessonContent, content.id, content);
  }

  async findPendingRequestByIdempotency(input: { schoolId: string; idempotencyKey: string }): Promise<ContentGenerationRequest | undefined> {
    return (await this.list<ContentGenerationRequest>(collections.contentGenerationRequests)).find((request) =>
      request.schoolId === input.schoolId &&
      request.idempotencyKey === input.idempotencyKey &&
      request.studentVisibleStatus === 'pending'
    );
  }

  async getGenerationRequest(id: string): Promise<ContentGenerationRequest | undefined> {
    return this.get<ContentGenerationRequest>(collections.contentGenerationRequests, id);
  }

  async saveGenerationRequest(request: ContentGenerationRequest): Promise<void> {
    await this.set(collections.contentGenerationRequests, request.id, request);
  }

  async countGenerationRequests(): Promise<number> {
    return (await this.list<ContentGenerationRequest>(collections.contentGenerationRequests)).length;
  }

  async saveContentGenerationJob(job: ContentGenerationJob): Promise<void> {
    await this.set(collections.contentGenerationJobs, job.id, job);
  }

  async listContentGenerationJobs(input?: { requestId?: string; schoolId?: string }): Promise<ContentGenerationJob[]> {
    return (await this.list<ContentGenerationJob>(collections.contentGenerationJobs)).filter((job) =>
      (!input?.requestId || job.requestId === input.requestId) &&
      (!input?.schoolId || job.schoolId === input.schoolId)
    );
  }

  async getLessonArtifact(id: string): Promise<LessonArtifact | undefined> {
    return this.get<LessonArtifact>(collections.lessonArtifacts, id);
  }

  async findLessonArtifactBySpecification(input: { schoolId: string; lessonSpecificationId: string }): Promise<LessonArtifact | undefined> {
    return (await this.list<LessonArtifact>(collections.lessonArtifacts)).find((artifact) =>
      artifact.schoolId === input.schoolId &&
      artifact.lessonSpecificationId === input.lessonSpecificationId
    );
  }

  async saveLessonArtifact(artifact: LessonArtifact): Promise<void> {
    await this.set(collections.lessonArtifacts, artifact.id, artifact);
  }

  async getPresentationArtifact(id: string): Promise<PresentationArtifact | undefined> {
    return this.get<PresentationArtifact>(collections.presentationArtifacts, id);
  }

  async findPresentationArtifactBySpecification(input: { schoolId: string; lessonSpecificationId: string }): Promise<PresentationArtifact | undefined> {
    return (await this.list<PresentationArtifact>(collections.presentationArtifacts)).find((artifact) =>
      artifact.schoolId === input.schoolId &&
      artifact.lessonSpecificationId === input.lessonSpecificationId
    );
  }

  async savePresentationArtifact(artifact: PresentationArtifact): Promise<void> {
    await this.set(collections.presentationArtifacts, artifact.id, artifact);
  }

  async getValidationArtifact(id: string): Promise<ValidationArtifact | undefined> {
    return this.get<ValidationArtifact>(collections.validationArtifacts, id);
  }

  async saveValidationArtifact(artifact: ValidationArtifact): Promise<void> {
    await this.set(collections.validationArtifacts, artifact.id, artifact);
  }

  async saveAudit(record: AuditRecord): Promise<void> {
    await this.set(collections.generationAuditEntries, record.id, record);
  }

  async saveProvenance(record: ProvenanceRecord): Promise<void> {
    await this.set(collections.provenanceRecords, record.id, record);
  }

  async saveVersionHistory(record: VersionHistoryRecord): Promise<void> {
    await this.set(collections.versionHistories, record.id, record);
  }

  async savePublicationRecord(record: PublicationRecord): Promise<void> {
    await this.set(collections.artifactPublicationRecords, record.id, record);
  }

  async getPromptTemplateVersion(id: string): Promise<PromptTemplateVersion | undefined> {
    return this.get<PromptTemplateVersion>(collections.promptTemplateVersions, id);
  }

  async listPromptTemplateVersions(input?: { taskType?: string; status?: PromptTemplateVersion['status'] }): Promise<PromptTemplateVersion[]> {
    return (await this.list<PromptTemplateVersion>(collections.promptTemplateVersions))
      .filter((template) =>
        (!input?.taskType || template.taskType === input.taskType) &&
        (!input?.status || template.status === input.status)
      )
      .sort((a, b) => b.version.localeCompare(a.version));
  }

  async savePromptTemplateVersion(template: PromptTemplateVersion): Promise<void> {
    await this.set(collections.promptTemplateVersions, template.id, template);
  }

  async savePromptExecutionRecord(record: PromptExecutionRecord): Promise<void> {
    await this.set(collections.promptExecutionRecords, record.id, record);
  }

  async saveCostTrackingRecord(record: CostTrackingRecord): Promise<void> {
    await this.set(collections.costTrackingRecords, record.id, record);
  }

  async getCurriculumSource(id: string): Promise<CurriculumSource | undefined> {
    return this.get<CurriculumSource>(collections.curriculumSources, id);
  }

  async saveCurriculumSource(source: CurriculumSource): Promise<void> {
    await this.set(collections.curriculumSources, source.id, source);
  }

  async getCurriculumVersion(input: { sourceId: string; versionId: string }): Promise<CurriculumVersion | undefined> {
    return this.get<CurriculumVersion>(curriculumVersionCollection(input.sourceId), input.versionId);
  }

  async saveCurriculumVersion(version: CurriculumVersion): Promise<void> {
    await this.set(curriculumVersionCollection(version.curriculumSourceId), version.id, version);
  }

  async getCurriculumStandard(id: string): Promise<CurriculumStandard | undefined> {
    return this.get<CurriculumStandard>(collections.curriculumStandards, id);
  }

  async saveCurriculumStandard(standard: CurriculumStandard): Promise<void> {
    await this.set(collections.curriculumStandards, standard.id, standard);
  }

  async listCurriculumStandards(input?: {
    curriculumSourceId?: string;
    curriculumVersionId?: string;
    gradeLevelId?: string;
    subjectId?: string;
  }): Promise<CurriculumStandard[]> {
    return (await this.list<CurriculumStandard>(collections.curriculumStandards))
      .filter((standard) =>
        (!input?.curriculumSourceId || standard.curriculumSourceId === input.curriculumSourceId) &&
        (!input?.curriculumVersionId || standard.curriculumVersionId === input.curriculumVersionId) &&
        (!input?.gradeLevelId || standard.gradeLevelId === input.gradeLevelId) &&
        (!input?.subjectId || standard.subjectId === input.subjectId)
      )
      .sort((a, b) => a.code.localeCompare(b.code));
  }

  async getCurriculumImportBatch(id: string): Promise<CurriculumImportBatch | undefined> {
    return this.get<CurriculumImportBatch>(collections.curriculumImportBatches, id);
  }

  async saveCurriculumImportBatch(batch: CurriculumImportBatch): Promise<void> {
    await this.set(collections.curriculumImportBatches, batch.id, batch);
  }

  async getPedagogicalAnalysis(id: string): Promise<PedagogicalAnalysis | undefined> {
    return this.get<PedagogicalAnalysis>(collections.pedagogicalAnalyses, id);
  }

  async findPedagogicalAnalysis(input: {
    standardId: string;
    curriculumVersionId: string;
    language: string;
  }): Promise<PedagogicalAnalysis | undefined> {
    return (await this.list<PedagogicalAnalysis>(collections.pedagogicalAnalyses)).find((analysis) =>
      analysis.standardId === input.standardId &&
      analysis.curriculumVersionId === input.curriculumVersionId &&
      analysis.language === input.language
    );
  }

  async savePedagogicalAnalysis(analysis: PedagogicalAnalysis): Promise<void> {
    await this.set(collections.pedagogicalAnalyses, analysis.pedagogicalAnalysisId, analysis);
  }

  async listAuditRecords(): Promise<AuditRecord[]> {
    return this.list<AuditRecord>(collections.generationAuditEntries);
  }

  async listProvenanceRecords(): Promise<ProvenanceRecord[]> {
    return this.list<ProvenanceRecord>(collections.provenanceRecords);
  }

  async listPublishedLessonContent(): Promise<PublishedLessonContent[]> {
    return this.list<PublishedLessonContent>(collections.publishedLessonContent);
  }

  async listPublicationRecords(): Promise<PublicationRecord[]> {
    return this.list<PublicationRecord>(collections.artifactPublicationRecords);
  }

  async listPromptExecutionRecords(): Promise<PromptExecutionRecord[]> {
    return this.list<PromptExecutionRecord>(collections.promptExecutionRecords);
  }

  async listCostTrackingRecords(): Promise<CostTrackingRecord[]> {
    return this.list<CostTrackingRecord>(collections.costTrackingRecords);
  }

  async listCurriculumImportBatches(): Promise<CurriculumImportBatch[]> {
    return this.list<CurriculumImportBatch>(collections.curriculumImportBatches);
  }

  async listPedagogicalAnalyses(): Promise<PedagogicalAnalysis[]> {
    return this.list<PedagogicalAnalysis>(collections.pedagogicalAnalyses);
  }

  private async get<T extends Plain>(collection: string, id: string): Promise<T | undefined> {
    return this.store.get<T>(collection, id);
  }

  private async set<T extends Plain>(collection: string, id: string, data: T): Promise<void> {
    await this.store.set(collection, id, data);
  }

  private async list<T extends Plain>(collection: string): Promise<T[]> {
    return (await this.store.list<T>(collection)).map((doc) => doc.data);
  }
}
