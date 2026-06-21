import type { PromptTemplateVersion } from '../contracts.js';
import type { ContentEngineRepository } from '../repositories/content-engine-repository.js';

export interface PromptResolutionInput {
  taskType: string;
  promptTemplateVersionId?: string;
}

export interface PromptResolution {
  template: PromptTemplateVersion;
  renderedPrompt: string;
}

export class PromptResolver {
  constructor(private readonly repo: ContentEngineRepository) {}

  async resolve(input: PromptResolutionInput, variables: Record<string, unknown>): Promise<PromptResolution> {
    const template = input.promptTemplateVersionId
      ? await this.repo.getPromptTemplateVersion(input.promptTemplateVersionId)
      : await this.findActiveTemplate(input.taskType);

    const resolvedTemplate = template ?? defaultTemplate(input.taskType);

    if (!template) {
      await this.repo.savePromptTemplateVersion(resolvedTemplate);
    }

    return {
      template: resolvedTemplate,
      renderedPrompt: renderPrompt(resolvedTemplate.promptText, variables),
    };
  }

  private async findActiveTemplate(taskType: string): Promise<PromptTemplateVersion | undefined> {
    const templates = await this.repo.listPromptTemplateVersions({
      taskType,
      status: 'active',
    });

    return templates[0];
  }
}

function defaultTemplate(taskType: string): PromptTemplateVersion {
  const now = new Date().toISOString();
  return {
    id: `prompt-template-${taskType}-v1`,
    templateId: `prompt-template-${taskType}`,
    version: '1.0.0',
    taskType,
    status: 'active',
    promptText: 'Generate deterministic Content Engine output for {{taskType}} using {{input}}.',
    outputSchemaId: `schema-${taskType}-v1`,
    createdAt: now,
  };
}

function renderPrompt(promptText: string, variables: Record<string, unknown>): string {
  const input = stableStringify(variables);
  return promptText
    .replaceAll('{{taskType}}', String(variables.taskType ?? 'unknown_task'))
    .replaceAll('{{input}}', input);
}

function stableStringify(value: unknown): string {
  return JSON.stringify(sortForStableStringify(value));
}

function sortForStableStringify(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortForStableStringify);
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortForStableStringify(nested)]),
    );
  }

  return value;
}
