export interface AIRetryMetadata {
  attempt: number;
  maxRetries: number;
}

export interface AIRequest {
  schoolId: string;
  taskType: string;
  requestId?: string;
  artifactId?: string;
  source?: string;
  intent?: string;
  language?: string;
  variables: Record<string, unknown>;
  promptTemplateVersionId?: string;
  timeoutMs?: number;
  retry?: AIRetryMetadata;
}

export interface AIResponse {
  content: string;
  rawOutput?: unknown;
  estimatedInputTokens?: number;
  estimatedOutputTokens?: number;
  estimatedCostUsd?: number;
}

export class AIProviderError extends Error {
  constructor(
    message: string,
    readonly code: string,
    readonly retryable: boolean,
  ) {
    super(message);
    this.name = 'AIProviderError';
  }
}

export interface AIProvider {
  readonly providerName: string;
  readonly model: string;
  generate(request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse>;
}
