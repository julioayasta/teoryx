import type { AIProvider, AIRequest, AIResponse } from './types.js';
import { AIProviderError } from './types.js';

export interface RealOpenAIProviderConfig {
  apiKey: string;
  model: string;
  endpoint?: string;
}

export class RealOpenAIProvider implements AIProvider {
  readonly providerName = 'openai';
  readonly model: string;
  private readonly endpoint: string;

  constructor(private readonly config: RealOpenAIProviderConfig) {
    this.model = config.model;
    this.endpoint = config.endpoint ?? 'https://api.openai.com/v1/responses';
  }

  async generate(request: AIRequest & { prompt: string; promptTemplateVersionId: string }): Promise<AIResponse> {
    const controller = new AbortController();
    const timeout = request.timeoutMs
      ? setTimeout(() => controller.abort(), request.timeoutMs)
      : undefined;

    try {
      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.config.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          input: request.prompt,
          text: {
            format: {
              type: 'json_object',
            },
          },
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new AIProviderError(`OpenAI request failed with status ${response.status}.`, 'openai_request_failed', response.status >= 500);
      }

      const data = await response.json() as OpenAIResponseLike;
      const content = extractText(data);
      if (!content) {
        throw new AIProviderError('OpenAI response did not contain text output.', 'openai_empty_response', false);
      }

      return {
        content,
        rawOutput: data,
        estimatedInputTokens: data.usage?.input_tokens,
        estimatedOutputTokens: data.usage?.output_tokens,
        estimatedCostUsd: 0,
      };
    } catch (error) {
      if (error instanceof AIProviderError) throw error;
      if (error instanceof Error && error.name === 'AbortError') {
        throw new AIProviderError('OpenAI request timed out.', 'openai_timeout', true);
      }
      throw new AIProviderError('OpenAI request failed safely.', 'openai_provider_error', true);
    } finally {
      if (timeout) clearTimeout(timeout);
    }
  }
}

interface OpenAIResponseLike {
  output_text?: string;
  output?: Array<{
    content?: Array<{
      text?: string;
    }>;
  }>;
  usage?: {
    input_tokens?: number;
    output_tokens?: number;
  };
}

function extractText(response: OpenAIResponseLike): string | undefined {
  if (typeof response.output_text === 'string' && response.output_text.length > 0) {
    return response.output_text;
  }

  for (const output of response.output ?? []) {
    for (const content of output.content ?? []) {
      if (typeof content.text === 'string' && content.text.length > 0) {
        return content.text;
      }
    }
  }

  return undefined;
}
