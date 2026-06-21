import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';
import { AIExecutionService } from './ai-execution-service.js';
import { ModelRoutingPolicy } from './model-routing-policy.js';
import { PromptResolver } from './prompt-resolver.js';
import { RealOpenAIProvider } from './real-openai-provider.js';
import { SafeFakeAIProvider } from './safe-fake-ai-provider.js';
import type { AIProvider } from './types.js';

export interface AIProviderEnvironment {
  CONTENT_ENGINE_ENABLE_REAL_AI?: string;
  CONTENT_ENGINE_AI_PROVIDER?: string;
  CONTENT_ENGINE_AI_FALLBACK_TO_FAKE?: string;
  OPENAI_API_KEY?: string;
  CONTENT_ENGINE_OPENAI_MODEL?: string;
  CONTENT_ENGINE_OPENAI_ENDPOINT?: string;
}

export interface AIProviderRuntime {
  service: AIExecutionService;
  providerName: string;
  realAIEnabled: boolean;
  fallbackToFake: boolean;
}

export function createAIProviderRuntime(
  repo: ContentEngineRepository,
  env: AIProviderEnvironment = process.env,
  providerOverride?: AIProvider,
): AIProviderRuntime {
  const fallbackToFake = env.CONTENT_ENGINE_AI_FALLBACK_TO_FAKE === 'true';
  const realAIRequested =
    env.CONTENT_ENGINE_ENABLE_REAL_AI === 'true' &&
    env.CONTENT_ENGINE_AI_PROVIDER === 'openai';
  const provider = providerOverride ?? selectProvider(env, realAIRequested);
  const providers = new Map<string, AIProvider>([[provider.providerName, provider]]);
  const service = new AIExecutionService(
    repo,
    new PromptResolver(repo),
    new ModelRoutingPolicy({
      provider: provider.providerName,
      model: provider.model,
      reason: realAIRequested && provider.providerName === 'openai'
        ? 'Real OpenAI provider enabled by Content Engine environment flags.'
        : 'Safe fake provider selected because real AI is disabled or unavailable.',
    }),
    providers,
  );

  return {
    service,
    providerName: provider.providerName,
    realAIEnabled: realAIRequested && provider.providerName === 'openai',
    fallbackToFake,
  };
}

function selectProvider(env: AIProviderEnvironment, realAIRequested: boolean): AIProvider {
  if (!realAIRequested || !env.OPENAI_API_KEY) {
    return new SafeFakeAIProvider();
  }

  return new RealOpenAIProvider({
    apiKey: env.OPENAI_API_KEY,
    model: env.CONTENT_ENGINE_OPENAI_MODEL ?? 'gpt-4.1-mini',
    endpoint: env.CONTENT_ENGINE_OPENAI_ENDPOINT,
  });
}
