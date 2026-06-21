# Sprint CE-02A - Curriculum Source Registry Design

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the Curriculum Source Registry for the TeoryX Content Engine.

The registry defines how TeoryX tracks official curriculum sources, curriculum versions, school curriculum selections, and normalized standards used by content generation.

The core rule is:

```text
Generated lessons must always trace back to an official curriculum source and source version.
```

## Scope

This sprint designs:

- official curriculum source registry
- curriculum versioning
- school curriculum selection
- normalized curriculum standard model
- Firestore collection proposal
- failure scenarios
- CE-02B recommendation

## Non-Scope

This sprint does not implement:

- Content Engine code
- curriculum import tooling
- Firestore writes
- AI generation
- Student App changes
- School Admin Portal changes
- Super Admin Portal changes

## Design Principles

### Official Sources Only

Curriculum sources must be official, traceable, and reviewable.

Examples:

- California Common Core State Standards
- Nevada Academic Content Standards
- NGSS
- future state standards
- future country-specific official frameworks

Unofficial scraped, inferred, or AI-created curriculum must not become a source of truth.

### Curriculum First

The Content Engine must start from an official standard.

```text
Official Source
-> Source Version
-> Standard
-> Learning Objective
-> Assessment Blueprint
-> Lesson
-> Tutor Prompt
-> Presentation Contract
```

### Versioned Traceability

A generated artifact must store:

```text
curriculumSourceId
curriculumVersionId
standardId
standardCode
sourceVersion
sourceReference
```

This allows TeoryX to explain exactly which official source and version a lesson was generated from.

### Multi-Jurisdiction Support

The registry must support:

- California
- Nevada
- future US states
- future countries
- K-12
- multiple subjects
- multiple frameworks

### School Selection Drives Generation

Schools select which curriculum source/version they use.

The Content Engine must use the school's active curriculum selection when resolving standards for generation requests.

The Student App must not modify curriculum selection.

## Curriculum Source Registry

### CurriculumSource

Represents an official authority or framework source.

Examples:

- California Common Core Mathematics
- California Common Core ELA
- Nevada Academic Content Standards Science
- NGSS

Fields:

```text
id
name
country
region
jurisdictionType
jurisdictionCode
framework
subjectId
gradeBand
officialSourceUrl
publisher
status
createdAt
updatedAt
```

Example:

```json
{
  "id": "ca-common-core-math",
  "name": "California Common Core State Standards - Mathematics",
  "country": "US",
  "region": "CA",
  "jurisdictionType": "state",
  "jurisdictionCode": "CA",
  "framework": "common_core",
  "subjectId": "math",
  "gradeBand": "K-12",
  "officialSourceUrl": "https://www.cde.ca.gov/",
  "publisher": "California Department of Education",
  "status": "active"
}
```

Allowed statuses:

```text
active
inactive
retired
deprecated
```

## Curriculum Versioning Model

### CurriculumVersion

Represents a specific imported/reviewed version of a curriculum source.

Fields:

```text
id
curriculumSourceId
sourceVersion
displayName
effectiveDate
retiredDate
importDate
checksum
sourceReference
importBatchId
status
createdAt
updatedAt
```

Required provenance fields:

```text
sourceVersion
effectiveDate
retiredDate
importDate
checksum
sourceReference
```

Example:

```json
{
  "id": "ca-common-core-math-2025",
  "curriculumSourceId": "ca-common-core-math",
  "sourceVersion": "2025",
  "displayName": "California Common Core Mathematics 2025",
  "effectiveDate": "2025-07-01",
  "retiredDate": null,
  "importDate": "2026-06-21",
  "checksum": "sha256:...",
  "sourceReference": {
    "kind": "official_url",
    "url": "https://www.cde.ca.gov/...",
    "retrievedAt": "2026-06-21"
  },
  "status": "active"
}
```

Allowed statuses:

```text
draft_import
active
retired
superseded
rejected
```

### Versioning Rules

1. Standards must never exist without a `curriculumVersionId`.
2. A retired version remains queryable for historical generated lessons.
3. New lessons should use the school's active selected version.
4. Existing generated lessons continue to point to the version used at generation time.
5. Updating a curriculum source/version does not mutate existing published lessons.

## School Curriculum Selection

### SchoolCurriculumSelection

Represents the curriculum/version a school uses for a grade, subject, and framework.

Stored under the school tenant:

```text
schools/{schoolId}/curriculumSelections/{selectionId}
```

Fields:

```text
id
schoolId
curriculumSourceId
curriculumVersionId
country
region
framework
subjectId
gradeLevelId
gradeBand
effectiveDate
retiredDate
status
selectedByUserId
createdAt
updatedAt
```

Example:

```json
{
  "id": "school-demo-grade-4-math-ca-common-core-2025",
  "schoolId": "school-demo",
  "curriculumSourceId": "ca-common-core-math",
  "curriculumVersionId": "ca-common-core-math-2025",
  "country": "US",
  "region": "CA",
  "framework": "common_core",
  "subjectId": "math",
  "gradeLevelId": "grade-4",
  "gradeBand": "K-12",
  "effectiveDate": "2025-07-01",
  "retiredDate": null,
  "status": "active"
}
```

Allowed statuses:

```text
active
scheduled
retired
inactive
```

### Selection Rules

1. A school may have one active curriculum selection per grade/subject/framework.
2. School Admin Portal may request generation/update based on selected curriculum.
3. Super Admin may manage global source/version availability.
4. Student App cannot modify curriculum selection.
5. Student App missing-content requests must use the already selected curriculum context.

## Normalized Curriculum Standard Model

### CurriculumStandard

Top-level collection:

```text
curriculumStandards/{standardId}
```

Each standard explicitly stores:

```text
curriculumSourceId
curriculumVersionId
```

Fields:

```text
id
curriculumSourceId
curriculumVersionId
country
region
jurisdictionType
jurisdictionCode
framework
subjectId
gradeLevelId
gradeBand
code
canonicalCode
title
description
strand
domain
cluster
standardType
parentStandardId
prerequisiteStandardIds
relatedStandardIds
sourceReference
sourceVersion
effectiveDate
retiredDate
status
createdAt
updatedAt
```

Example:

```json
{
  "id": "ca-common-core-math-2025-grade-4-nf-a-1",
  "curriculumSourceId": "ca-common-core-math",
  "curriculumVersionId": "ca-common-core-math-2025",
  "country": "US",
  "region": "CA",
  "jurisdictionType": "state",
  "jurisdictionCode": "CA",
  "framework": "common_core",
  "subjectId": "math",
  "gradeLevelId": "grade-4",
  "gradeBand": "K-12",
  "code": "CCSS.MATH.4.NF.A.1",
  "canonicalCode": "ccss-math-4-nf-a-1",
  "title": "Equivalent Fractions",
  "description": "Explain why a fraction a/b is equivalent to a fraction (n x a)/(n x b)...",
  "strand": "Number and Operations - Fractions",
  "domain": "NF",
  "cluster": "Extend understanding of fraction equivalence and ordering.",
  "standardType": "standard",
  "sourceVersion": "2025",
  "effectiveDate": "2025-07-01",
  "retiredDate": null,
  "status": "active"
}
```

Allowed statuses:

```text
active
retired
deprecated
superseded
invalid
```

### Normalization Rules

1. `code` preserves the official source code.
2. `canonicalCode` is a system-safe normalized form for search and display.
3. Official source text must be stored without AI rewriting.
4. AI may summarize or explain standards later, but those explanations are derived content, not source truth.
5. Each standard must include source/version provenance.

## Traceability Requirements

Every generated lesson, assessment, tutor prompt, and presentation contract must store:

```text
schoolId
curriculumSourceId
curriculumVersionId
standardId
standardCode
sourceVersion
sourceReference
language
generatedAt
```

For generated lesson content:

```text
ContentGenerationRequest
-> SchoolCurriculumSelection
-> CurriculumVersion
-> CurriculumStandard
-> LessonContentArtifact
-> PublishedLessonContent
```

The Content Engine must reject generation if it cannot resolve:

```text
schoolId
curriculumSourceId
curriculumVersionId
standardId
language
```

## Content Engine Integration

### School Admin Portal

School Admin Portal is an authoring workflow.

It may:

- request lesson creation
- request lesson updates/regeneration
- edit generated content
- save drafts
- submit for review/publication

It must generate against the school's active curriculum selection unless an authorized admin explicitly chooses another active selection.

### Student App

Student App is a read-only consumption workflow.

It may:

- request missing content only
- receive pending/ready/failed state
- render published content

It must not:

- edit generated content
- approve generated content
- publish generated content
- modify curriculum selection
- choose arbitrary standards

When a Student App request is received, Content Engine resolves the curriculum context from the school's active selection and the current course/lesson path.

### Super Admin

Super Admin owns governance workflows:

- source activation
- version activation/retirement
- import approval
- global curriculum governance

### System

System jobs may:

- detect retired/superseded versions
- recommend regeneration
- import new versions
- validate checksums

System jobs should not silently rewrite or republish lessons without policy.

## Firestore Collection Proposal

Use top-level `curriculumStandards/{standardId}` with explicit source/version fields.

```text
curriculumSources/{curriculumSourceId}
curriculumSources/{curriculumSourceId}/versions/{curriculumVersionId}
curriculumStandards/{standardId}
schools/{schoolId}/curriculumSelections/{selectionId}
curriculumImportBatches/{importBatchId}
```

### curriculumSources/{curriculumSourceId}

Stores official source authority/framework metadata.

### curriculumSources/{curriculumSourceId}/versions/{curriculumVersionId}

Stores source version provenance and lifecycle.

### curriculumStandards/{standardId}

Stores normalized official standards.

Required fields:

```text
curriculumSourceId
curriculumVersionId
code
canonicalCode
description
sourceVersion
sourceReference
status
```

### schools/{schoolId}/curriculumSelections/{selectionId}

Stores school-specific selected curriculum/version.

### curriculumImportBatches/{importBatchId}

Tracks import jobs and source integrity.

Fields:

```text
id
curriculumSourceId
curriculumVersionId
sourceReference
sourceVersion
importedByUserId
importDate
checksum
status
standardCount
validationErrors
createdAt
updatedAt
```

## Indexing / Query Patterns

Recommended indexes:

```text
curriculumStandards:
country + region + framework + gradeLevelId + subjectId + status

curriculumStandards:
curriculumSourceId + curriculumVersionId + gradeLevelId + subjectId + code

curriculumStandards:
curriculumSourceId + curriculumVersionId + canonicalCode

schools/{schoolId}/curriculumSelections:
gradeLevelId + subjectId + framework + status

curriculumImportBatches:
curriculumSourceId + curriculumVersionId + status
```

Common queries:

```text
Find active standards for Grade 4 Math in a selected curriculum version.
Find a standard by canonical code within a source/version.
Find active school curriculum selection for grade/subject/framework.
Find all lessons generated from a retired source version.
```

## Failure Scenarios

### Unofficial Source

Cause:

- source cannot be verified
- missing official URL/reference
- unknown publisher

Result:

- reject source
- do not import standards
- status: `rejected`

### Missing Source Version

Cause:

- standard references `curriculumSourceId` but no active version

Result:

- reject generation
- reason: `missing_curriculum_version`

### Checksum Mismatch

Cause:

- imported source content does not match expected checksum

Result:

- mark import batch failed
- do not activate version
- reason: `checksum_mismatch`

### School Has No Active Selection

Cause:

- no active `SchoolCurriculumSelection` for requested grade/subject/framework

Result:

- Content Engine rejects generation
- Student App receives friendly unavailable/missing setup state
- School Admin Portal receives configuration-required message

### Multiple Active Selections

Cause:

- school has conflicting active selections for same grade/subject/framework

Result:

- reject generation
- reason: `ambiguous_curriculum_selection`
- require admin correction

### Retired Version Requested

Cause:

- request tries to generate new content from retired version

Result:

- reject unless authorized migration/regeneration workflow
- existing lessons remain traceable and readable

### Standard Not Found

Cause:

- selected curriculum version does not contain requested standard

Result:

- reject generation
- reason: `standard_not_found`

### Unsupported Jurisdiction

Cause:

- requested country/region/framework is not active in registry

Result:

- reject request
- reason: `unsupported_curriculum_source`

### Student App Attempts Curriculum Modification

Cause:

- Student App request attempts to specify or change curriculum source/version outside selected context

Result:

- reject request
- reason: `permission_denied`

### Source Superseded

Cause:

- source version is replaced by a newer version

Result:

- existing generated content remains traceable
- new generation uses active school selection
- optional system recommendation for regeneration/migration

## Governance Rules

1. Only Super Admin or authorized curriculum governance workflows may activate official curriculum sources.
2. School Admin may select from approved active curriculum versions.
3. Student App cannot modify curriculum source/version.
4. Content Engine must not generate from unofficial or unversioned standards.
5. Generated lessons must preserve original source/version traceability forever.
6. Retiring a curriculum version must not break historical lesson references.
7. Imports must be repeatable and auditable through checksum/source reference.

## CE-02B Recommendation

Recommended next sprint:

```text
CE-02B - Curriculum Import and Validation Workflow
```

Scope:

- define import pipeline for official standards
- define validation rules for source/version/checksum
- define normalized standard parser contract
- define admin review/activation flow
- define import failure recovery
- define seed strategy for California Common Core Grade 3-5 Math/ELA

Do not implement AI generation in CE-02B.

CE-02B should produce:

- import workflow specification
- validation report schema
- curriculum import batch lifecycle
- initial seed-source checklist
- rules for activating a curriculum version

## Open Questions

1. Should standards be globally shared across all schools, with school selection references only, or should some jurisdictions allow tenant-specific overrides?
2. Should TeoryX store full official standard text, source excerpts, or only normalized references when source licensing is restrictive?
3. Should schools be allowed to schedule future curriculum version changes by date?
4. Should Content Engine automatically recommend lesson regeneration when a school changes curriculum versions?
5. Should international curriculum models require separate `jurisdictionType` values beyond country/state/province?
6. Should `curriculumStandards` include prerequisite graphs in v1, or defer them to a later curriculum intelligence sprint?
