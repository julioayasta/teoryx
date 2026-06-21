export interface PedagogicalAnalysisContract {
  prerequisites: string[];
  targetSkills: string[];
  vocabularyTerms: string[];
  misconceptions: string[];
  assessmentEvidence: string[];
  languageProfile: {
    band: string;
    sentenceComplexity: string;
    vocabularySupport: string;
    scaffolding: string;
  };
}

export class PedagogicalAnalysisContractError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'PedagogicalAnalysisContractError';
  }
}

export function parsePedagogicalAnalysisContract(content: string): PedagogicalAnalysisContract {
  let parsed: unknown;
  try {
    parsed = JSON.parse(content);
  } catch {
    throw new PedagogicalAnalysisContractError('Pedagogical analysis output was not valid JSON.', 'invalid_json');
  }

  return validatePedagogicalAnalysisContract(parsed);
}

export function validatePedagogicalAnalysisContract(value: unknown): PedagogicalAnalysisContract {
  if (!isRecord(value)) {
    throw new PedagogicalAnalysisContractError('Pedagogical analysis output must be an object.', 'invalid_contract');
  }

  return {
    prerequisites: requiredStringArray(value, 'prerequisites'),
    targetSkills: requiredStringArray(value, 'targetSkills'),
    vocabularyTerms: requiredStringArray(value, 'vocabularyTerms'),
    misconceptions: requiredStringArray(value, 'misconceptions'),
    assessmentEvidence: requiredStringArray(value, 'assessmentEvidence'),
    languageProfile: validateLanguageProfile(value.languageProfile),
  };
}

function validateLanguageProfile(value: unknown): PedagogicalAnalysisContract['languageProfile'] {
  if (!isRecord(value)) {
    throw new PedagogicalAnalysisContractError('Pedagogical analysis output must include languageProfile.', 'missing_language_profile');
  }

  return {
    band: requiredString(value, 'band'),
    sentenceComplexity: requiredString(value, 'sentenceComplexity'),
    vocabularySupport: requiredString(value, 'vocabularySupport'),
    scaffolding: requiredString(value, 'scaffolding'),
  };
}

function requiredStringArray(record: Record<string, unknown>, key: string): string[] {
  const value = record[key];
  if (!Array.isArray(value)) {
    throw new PedagogicalAnalysisContractError(`Pedagogical analysis output must include ${key}.`, 'missing_required_array');
  }
  const strings = value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0);
  if (strings.length === 0) {
    throw new PedagogicalAnalysisContractError(`Pedagogical analysis ${key} must not be empty.`, 'empty_required_array');
  }

  return strings;
}

function requiredString(record: Record<string, unknown>, key: string): string {
  const value = record[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new PedagogicalAnalysisContractError(`Pedagogical analysis languageProfile is missing ${key}.`, 'missing_language_profile_field');
  }

  return value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}
