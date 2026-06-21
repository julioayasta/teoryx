export interface CurriculumImportPayload {
  source: {
    id: string;
    name: string;
    jurisdiction: string;
    framework: string;
    officialSourceUrl: string;
  };
  version: {
    id: string;
    sourceVersion: string;
    effectiveDate: string;
    retiredDate?: string;
  };
  standards: Array<{
    code: string;
    title: string;
    description: string;
    gradeLevelId: string;
    subjectId: string;
  }>;
}

export interface StandardValidationResult {
  validStandards: CurriculumImportPayload['standards'];
  rejectedRecords: Array<{
    index: number;
    reason: string;
  }>;
}

export class CurriculumImportSchemaError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
    this.name = 'CurriculumImportSchemaError';
  }
}

export function validateCurriculumImportPayload(value: unknown): CurriculumImportPayload {
  if (!isRecord(value)) {
    throw new CurriculumImportSchemaError('Curriculum import payload must be an object.', 'invalid_payload');
  }
  if (!isRecord(value.source)) {
    throw new CurriculumImportSchemaError('Curriculum import source is required.', 'invalid_source');
  }
  if (!isRecord(value.version)) {
    throw new CurriculumImportSchemaError('Curriculum import version is required.', 'invalid_version');
  }
  if (!Array.isArray(value.standards)) {
    throw new CurriculumImportSchemaError('Curriculum import standards must be an array.', 'invalid_standards');
  }

  return {
    source: {
      id: requiredString(value.source, 'id', 'invalid_source'),
      name: requiredString(value.source, 'name', 'invalid_source'),
      jurisdiction: requiredString(value.source, 'jurisdiction', 'invalid_source'),
      framework: requiredString(value.source, 'framework', 'invalid_source'),
      officialSourceUrl: requiredString(value.source, 'officialSourceUrl', 'invalid_source'),
    },
    version: {
      id: requiredString(value.version, 'id', 'invalid_version'),
      sourceVersion: requiredString(value.version, 'sourceVersion', 'invalid_version'),
      effectiveDate: requiredString(value.version, 'effectiveDate', 'invalid_version'),
      retiredDate: optionalString(value.version.retiredDate),
    },
    standards: value.standards.map((standard) => {
      if (!isRecord(standard)) {
        return {
          code: '',
          title: '',
          description: '',
          gradeLevelId: '',
          subjectId: '',
        };
      }

      return {
        code: optionalString(standard.code) ?? '',
        title: optionalString(standard.title) ?? '',
        description: optionalString(standard.description) ?? '',
        gradeLevelId: optionalString(standard.gradeLevelId) ?? '',
        subjectId: optionalString(standard.subjectId) ?? '',
      };
    }),
  };
}

export function validateStandards(standards: CurriculumImportPayload['standards']): StandardValidationResult {
  const validStandards: CurriculumImportPayload['standards'] = [];
  const rejectedRecords: StandardValidationResult['rejectedRecords'] = [];

  standards.forEach((standard, index) => {
    const missing = ['code', 'title', 'description', 'gradeLevelId', 'subjectId']
      .filter((key) => !standard[key as keyof typeof standard]);
    if (missing.length > 0) {
      rejectedRecords.push({
        index,
        reason: `Missing required standard fields: ${missing.join(', ')}`,
      });
      return;
    }

    validStandards.push(standard);
  });

  return { validStandards, rejectedRecords };
}

function requiredString(record: Record<string, unknown>, key: string, code: string): string {
  const value = record[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new CurriculumImportSchemaError(`Missing required field: ${key}`, code);
  }

  return value;
}

function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.trim().length > 0 ? value : undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}
