export interface ModelRoutingInput {
  taskType: string;
  source?: string;
  intent?: string;
}

export interface ModelRoutingDecision {
  provider: string;
  model: string;
  reason: string;
}

export class ModelRoutingPolicy {
  constructor(
    private readonly defaultDecision: ModelRoutingDecision = {
      provider: 'safe_fake',
      model: 'safe-fake-deterministic-v1',
      reason: 'Default CE fake provider route.',
    },
  ) {}

  select(input: ModelRoutingInput): ModelRoutingDecision {
    if (input.source === 'student_app') {
      return {
        ...this.defaultDecision,
        reason: 'Student App missing-content requests use the fake route until real providers are explicitly enabled.',
      };
    }

    if (input.intent === 'regenerate') {
      return {
        ...this.defaultDecision,
        reason: 'Regeneration is routed through the injectable fake provider in CE-09.',
      };
    }

    return this.defaultDecision;
  }
}
