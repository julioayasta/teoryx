import type {
  CallerContext,
  ContentGenerationRequest,
  CurriculumStandard,
  PedagogicalAnalysis,
} from '../contracts.js';
import { createAIProviderRuntime, type AIProviderEnvironment } from '../ai/provider-factory.js';
import type { AIProvider } from '../ai/types.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';
import {
  PedagogicalAnalysisContractError,
  parsePedagogicalAnalysisContract,
} from './pedagogical-analysis-contract.js';

export interface PedagogicalAnalysisRequest {
  standardId: string;
  language: string;
  schoolId?: string;
}

export interface PedagogicalAnalysisServiceOptions {
  env?: AIProviderEnvironment;
  aiProvider?: AIProvider;
}

export class PedagogicalAnalysisGenerationError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'PedagogicalAnalysisGenerationError';
  }
}

export class PedagogicalAnalysisService {
  constructor(
    private readonly repo: ContentEngineRepository,
    private readonly options: PedagogicalAnalysisServiceOptions = {},
  ) {}

  async requestAnalysis(input: PedagogicalAnalysisRequest, caller: CallerContext): Promise<PedagogicalAnalysis> {
    const standard = await this.repo.getCurriculumStandard(input.standardId);
    if (!standard) {
      throw new PedagogicalAnalysisGenerationError('Curriculum standard was not found.', 'standard_not_found');
    }

    const existing = await this.repo.findPedagogicalAnalysis({
      standardId: standard.id,
      curriculumVersionId: standard.curriculumVersionId,
      language: input.language,
    });
    if (existing?.status === 'ready') {
      return existing;
    }

    const generationRequest = await this.createOrReuseRequest(standard, input, caller);
    const runtime = createAIProviderRuntime(this.repo, this.options.env, this.options.aiProvider);
    const execution = await runtime.service.execute({
      schoolId: input.schoolId ?? 'global',
      requestId: generationRequest.id,
      artifactId: analysisId(standard.id, standard.curriculumVersionId, input.language),
      taskType: 'pedagogical_analysis_generation',
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent: 'create_new',
      language: input.language,
      variables: {
        standardId: standard.id,
        standardCode: standard.code,
        title: standard.title,
        description: standard.description,
        curriculumSourceId: standard.curriculumSourceId,
        curriculumVersionId: standard.curriculumVersionId,
        gradeLevelId: standard.gradeLevelId,
        subjectId: standard.subjectId,
      },
      timeoutMs: 30000,
      retry: { attempt: 1, maxRetries: 0 },
    });

    if (!execution.response) {
      await this.markRequestFailed(generationRequest);
      throw new PedagogicalAnalysisGenerationError('Pedagogical analysis provider failed safely.', 'ai_provider_failed');
    }

    try {
      const contract = parsePedagogicalAnalysisContract(execution.response.content);
      const now = new Date().toISOString();
      const analysis: PedagogicalAnalysis = {
        pedagogicalAnalysisId: analysisId(standard.id, standard.curriculumVersionId, input.language),
        standardId: standard.id,
        curriculumSourceId: standard.curriculumSourceId,
        curriculumVersionId: standard.curriculumVersionId,
        standardCode: standard.code,
        language: input.language,
        gradeLevelId: standard.gradeLevelId,
        subjectId: standard.subjectId,
        prerequisites: contract.prerequisites,
        targetSkills: contract.targetSkills,
        vocabularyTerms: contract.vocabularyTerms,
        misconceptions: contract.misconceptions,
        assessmentEvidence: contract.assessmentEvidence,
        languageProfile: contract.languageProfile,
        validationStatus: 'valid',
        promptTemplateVersionIds: [execution.promptExecutionRecord.promptTemplateVersionId],
        sourceGenerationRequestId: generationRequest.id,
        status: 'ready',
        createdAt: now,
        updatedAt: now,
      };

      await this.repo.savePedagogicalAnalysis(analysis);
      await this.repo.saveGenerationRequest({
        ...generationRequest,
        status: 'ready',
        studentVisibleStatus: 'ready',
        schoolPortalVisibleStatus: 'approved',
      });
      await this.writeAuditProvenance(caller, analysis);
      return analysis;
    } catch (error) {
      await this.markRequestFailed(generationRequest);
      const code = error instanceof PedagogicalAnalysisContractError ? error.code : 'invalid_analysis_output';
      throw new PedagogicalAnalysisGenerationError('Pedagogical analysis output failed validation.', code);
    }
  }

  private async createOrReuseRequest(
    standard: CurriculumStandard,
    input: PedagogicalAnalysisRequest,
    caller: CallerContext,
  ): Promise<ContentGenerationRequest> {
    const idempotencyKey = `pedagogy:${standard.id}:${standard.curriculumVersionId}:${input.language}`;
    const existing = await this.repo.findPendingRequestByIdempotency({
      schoolId: input.schoolId ?? 'global',
      idempotencyKey,
    });
    if (existing) return existing;

    const count = await this.repo.countGenerationRequests();
    const request: ContentGenerationRequest = {
      id: `request-${count + 1}`,
      schoolId: input.schoolId ?? 'global',
      idempotencyKey,
      source: caller.role === 'super_admin' ? 'super_admin' : 'school_admin_portal',
      intent: 'create_new',
      publicationMode: 'require_review',
      status: 'generating_pedagogical_analysis',
      studentVisibleStatus: 'pending',
      schoolPortalVisibleStatus: 'generating',
      publishedContentId: null,
    };
    await this.repo.saveGenerationRequest(request);
    return request;
  }

  private async markRequestFailed(request: ContentGenerationRequest): Promise<void> {
    await this.repo.saveGenerationRequest({
      ...request,
      status: 'failed',
      studentVisibleStatus: 'failed',
      schoolPortalVisibleStatus: 'failed',
    });
  }

  private async writeAuditProvenance(caller: CallerContext, analysis: PedagogicalAnalysis): Promise<void> {
    const createdAt = new Date().toISOString();
    const suffix = `pedagogicalAnalysis-${analysis.pedagogicalAnalysisId}`;
    await this.repo.saveAudit({
      id: `audit-${suffix}`,
      schoolId: 'global',
      eventType: 'pedagogical_analysis_generated',
      actorUserId: caller.userId,
      targetType: 'pedagogicalAnalysis',
      targetId: analysis.pedagogicalAnalysisId,
      createdAt,
    });
    await this.repo.saveProvenance({
      id: `provenance-${suffix}`,
      schoolId: 'global',
      targetType: 'pedagogicalAnalysis',
      targetId: analysis.pedagogicalAnalysisId,
      sourceIds: [
        analysis.standardId,
        analysis.curriculumSourceId,
        analysis.curriculumVersionId,
        analysis.sourceGenerationRequestId,
        ...analysis.promptTemplateVersionIds,
      ],
      createdAt,
    });
    await this.repo.saveVersionHistory({
      id: `version-${suffix}`,
      schoolId: 'global',
      entityType: 'pedagogicalAnalysis',
      entityId: analysis.pedagogicalAnalysisId,
      changeType: 'generated',
      createdAt,
    });
  }
}

export function analysisId(standardId: string, curriculumVersionId: string, language: string): string {
  return `pedagogical-analysis-${standardId}-${curriculumVersionId}-${language}`;
}
