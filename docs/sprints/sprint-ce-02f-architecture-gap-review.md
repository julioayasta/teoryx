# Sprint CE-02F - Content Engine Architecture Gap Review

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Review CE-01 through CE-02E and close architectural gaps before CE-03B API and Cloud Function contract design.

This document consolidates decisions that the API layer must treat as stable.

## Scope

This sprint reviews and resolves gaps around:

- `CourseOffering` vs `CourseMap`
- `CourseMap`, `UnitPlan`, and `LessonSpecification` versioning
- language policy
- global reusable content vs school-specific overrides
- asset registry and reuse
- cost and rate limits
- review policy by risk
- minimum publishable package
- partial generation failure handling
- auditability and provenance

## Non-Scope

This sprint does not implement:

- app code
- Firestore writes
- Cloud Functions
- API contracts
- AI generation
- Student App changes
- School Admin Portal changes

## Reviewed Architecture

Reviewed documents:

- `docs/sprints/sprint-ce-01-content-engine-architecture.md`
- `docs/sprints/sprint-ce-02a-curriculum-source-registry.md`
- `docs/sprints/sprint-ce-02b-pedagogical-analysis-engine.md`
- `docs/sprints/sprint-ce-02c-instructional-blueprint-engine.md`
- `docs/sprints/sprint-ce-02d-generation-artifact-contracts.md`
- `docs/sprints/sprint-ce-02e-course-planning-and-lesson-specification.md`

Current design flow:

```text
CurriculumSource
-> CurriculumVersion
-> CurriculumStandard
-> PedagogicalAnalysis
-> Instructional Blueprints
-> CourseMap / UnitPlan / LessonSpecification
-> Generation Artifacts
-> PresentationArtifact
-> publishedLessonContent
```

The key missing piece before API implementation is not another generation model. It is a set of lifecycle, availability, reuse, cost, review, and failure rules.

## Gap 1 - CourseOffering vs CourseMap

### Decision

`CourseOffering` and `CourseMap` are separate concepts.

`CourseOffering` is the student-visible course availability/enrollment/catalog record.

`CourseMap` is the instructional planning structure that organizes units and lesson specifications.

### CourseOffering

Purpose:

- controls whether a course appears in Student App
- connects school catalog/enrollment to a valid course plan
- stores student-facing availability state

Suggested fields:

```text
id
schoolId
courseId
courseMapId
courseMapVersion
gradeLevelId
subjectId
language
title
description
status
availableFrom
availableUntil
enabledForStudents
createdAt
updatedAt
```

Allowed statuses:

```text
draft
enabled
disabled
archived
superseded
```

### CourseMap

Purpose:

- stores instructional plan
- organizes `UnitPlan` and `LessonSpecification`
- drives generation and sequencing
- may exist before a course is enabled for students

### Availability Rule

A course appears in Student App only when:

```text
CourseOffering.enabledForStudents = true
CourseOffering.status = enabled
CourseOffering.courseMapId points to valid CourseMap
CourseMap status is active or approved
CourseMap has valid UnitPlans
CourseMap has valid LessonSpecifications
```

The existence of a course catalog record is not enough.

## Gap 2 - CourseMap Versioning

### Decision

`CourseMap`, `UnitPlan`, and `LessonSpecification` must be versioned.

Editing published or enabled planning records creates a new version or draft revision. It must not mutate historical planning state silently.

### Versioned Planning Records

Recommended version fields:

```text
version
previousVersionId
revisionReason
changeSummary
checksum
status
createdAt
updatedAt
approvedAt
publishedAt
supersededById
```

### Versioning Rules

1. Published/enabled planning versions are immutable.
2. School Admin edits create a draft revision or new version.
3. New versions must be validated before becoming active.
4. `CourseOffering` points to the active `CourseMap` version.
5. Historical `LessonSpecification` records remain traceable to generated artifacts.
6. Updating a `CourseMap` does not mutate existing `publishedLessonContent`.
7. Regeneration from a new course map version creates new generation artifacts.

## Gap 3 - Language Policy

### Decision

Language is a first-class generation dimension.

Each language should have independently validated specifications and artifacts.

### Language Rules

1. `CurriculumStandard` preserves official source text and source language.
2. `PedagogicalAnalysis` is language-specific when student-facing interpretation is generated.
3. `LearningObjective`, blueprints, `LessonSpecification`, and artifacts are language-specific.
4. Translation creates a new localized record or artifact version.
5. Translated records must preserve source-language provenance.
6. Student App should only show course offerings and lesson specifications matching the active student language, unless fallback policy is explicitly defined.
7. Missing translation should produce a controlled unavailable/pending state, not silent mixed-language content.

### Suggested Language Fields

```text
language
sourceLanguage
translatedFromId
translationStatus
translationValidationStatus
```

Allowed translation statuses:

```text
not_translated
translation_pending
translated
translation_failed
validated
rejected
```

## Gap 4 - Global Reuse vs School-Specific Overrides

### Decision

TeoryX should support global reusable curriculum intelligence while keeping school-specific availability, overrides, edits, and publication state tenant-scoped.

### Globally Reusable

Potentially reusable across schools:

- `CurriculumSource`
- `CurriculumVersion`
- `CurriculumStandard`
- `PedagogicalAnalysis`
- `LanguageProfile`
- generic `LearningObjective`
- generic `MasteryDefinition`
- generic `EvidenceRequirement`
- generic `AssessmentBlueprint`
- generic `LessonBlueprint`
- generic `TutorBlueprint`
- generic `MediaBlueprint`
- approved asset registry entries
- approved prompt template versions

### School-Specific

School-scoped by default:

- `SchoolCurriculumSelection`
- `CourseOffering`
- `CourseMap` when edited or generated for school context
- `UnitPlan`
- `LessonSpecification`
- `SchoolPromptOverride`
- school-edited artifacts
- publication decisions
- `publishedLessonContent`
- student progress
- assessment attempts

### Override Rules

School-specific overrides may adjust:

- local examples
- tone
- school terminology
- pacing
- unit grouping
- lesson sequence
- optional media preference

School-specific overrides may not alter:

- official curriculum meaning
- curriculum source hierarchy
- required traceability
- safety constraints
- output schemas
- validation requirements

## Gap 5 - Asset Registry and Reuse

### Decision

`AssetRegistry` must be separate from `MediaArtifact`.

`MediaArtifact` is a generated or selected artifact for a specific lesson context.

`AssetRegistry` is a reusable library of approved media assets.

### AssetRegistry

Suggested collection:

```text
assetRegistry/{assetId}
```

Suggested fields:

```text
id
assetType
title
description
storagePath
assetUrl
source
license
credit
altText
caption
applicableGrades
applicableSubjects
tags
curriculumSourceIds
standardIds
qualityStatus
accessibilityStatus
createdAt
updatedAt
```

Allowed asset sources:

```text
generated
selected_library_asset
school_uploaded
external_oer
internal_teoryx
placeholder
```

### Reuse Rules

1. Reusable assets live in `assetRegistry`.
2. `MediaArtifact` references `assetRegistry` entries when reuse is possible.
3. Generated media may become reusable only after validation and licensing checks.
4. School-uploaded assets remain school-scoped unless explicitly approved for broader reuse.
5. Accessibility metadata is required before student-facing publication.

## Gap 6 - Cost and Rate Limits

### Decision

Generation must be governed by explicit cost and rate policies.

Student App missing-content requests must be deduplicated and throttled aggressively.

### CostPolicy

Suggested collection:

```text
generationCostPolicies/{policyId}
```

Suggested fields:

```text
id
scope
schoolId
source
intent
dailyRequestLimit
monthlyRequestLimit
maxConcurrentRequests
maxRetryAttempts
maxEstimatedCost
requiresApprovalAboveCost
status
createdAt
updatedAt
```

Allowed scopes:

```text
global
school
source
intent
```

### Rate Limit Rules

1. Reuse existing published content before generation.
2. Reuse pending requests by idempotency key.
3. Student App `fill_missing` requests should have strict throttles.
4. School Portal bulk generation should require quotas and progress tracking.
5. Retry attempts count against retry limits.
6. High-cost generation should require approval or batching.
7. Cost/rate failures return controlled status, not raw provider errors.

## Gap 7 - Review Policy by Risk

### Decision

Review policy should be risk-based.

Not all generated outputs require the same review level.

### Risk Levels

Allowed risk levels:

```text
low
medium
high
critical
```

### ReviewPolicy

Suggested collection:

```text
reviewPolicies/{reviewPolicyId}
```

Suggested fields:

```text
id
artifactType
riskLevel
source
intent
publicationMode
requiresHumanReview
allowedAutoPublish
requiredReviewerRole
validationRequirements
status
createdAt
updatedAt
```

### Suggested Risk Defaults

Low risk:

- `CourseMap`
- `UnitPlan`
- `LessonSpecification`
- non-student-facing planning records

Medium risk:

- `LessonArtifact`
- `PresentationArtifact`
- translated lesson content

High risk:

- `AssessmentArtifact`
- `TutorArtifact`
- school-edited generated content
- content for younger students when tutor guidance is involved

Critical risk:

- safety-sensitive tutor behavior
- policy-sensitive content
- content with external media or uncertain licensing

### Review Rules

1. `auto_publish_after_validation` may apply only when review policy allows it.
2. `require_review` blocks publication until authorized approval.
3. School-edited artifacts must be revalidated.
4. Invalid artifacts cannot be approved.
5. Higher-risk artifacts require stricter validation and reviewer roles.

## Gap 8 - Minimum Publishable Package

### Decision

Student App lesson consumption requires a minimum publishable package.

The minimum package is:

```text
LessonArtifact
PresentationArtifact
ValidationArtifact
publishedLessonContent
```

Optional artifacts:

```text
TutorArtifact
MediaArtifact
AssessmentArtifact
```

Optional artifacts become required when referenced by the `PresentationArtifact` or when the lesson flow requires them.

### Minimum Publishable Package Rules

1. `LessonArtifact` must be valid.
2. `PresentationArtifact` must be valid and Student App compatible.
3. `ValidationArtifact` must be valid or valid with allowed warnings.
4. `publishedLessonContent` must preserve curriculum, analysis, blueprint, and artifact provenance.
5. `TutorArtifact` is required if the published lesson enables tutor-specific guidance.
6. `MediaArtifact` is required if the presentation contract references required media.
7. `AssessmentArtifact` is required only when the published lesson includes assessment content or assessment entry points.
8. Missing optional artifacts should not block publication unless referenced by the presentation contract.

## Gap 9 - Partial Generation Failure Handling

### Decision

Partial generation results should be persisted safely, but not published unless the minimum publishable package is valid.

### Partial Failure Rules

1. Save successful artifacts as `generated` or `draft`.
2. Mark failed stage status explicitly.
3. Write failure events with retryability.
4. Do not publish partial packages.
5. Retry only failed stages when safe.
6. If a failed stage invalidates downstream artifacts, mark downstream artifacts stale.
7. Student App sees only `pending`, `ready`, or `failed`.
8. School Portal may see detailed partial failure state.
9. Partial artifacts remain editable/reviewable only through authorized workflows.

### Stale Artifact Rule

When an upstream artifact changes or regenerates:

```text
downstream artifacts become stale until revalidated or regenerated
```

Examples:

- new `LessonBlueprint` makes existing `LessonArtifact` stale
- new `LessonArtifact` makes existing `PresentationArtifact` stale
- changed `MediaArtifact` may require presentation revalidation

## Gap 10 - Auditability and Provenance

### Decision

Every generated artifact, publication event, approval event, curriculum decision, prompt execution, and manual edit must be auditable and traceable.

Auditability is not optional metadata. It is a core Content Engine requirement because TeoryX must be able to explain:

- what was generated
- why it was generated
- which curriculum source/version it used
- which prompt template/version was executed
- who approved or edited it
- what it cost
- which published student-facing content resulted

### GenerationAuditEntry

Records major generation lifecycle events.

Suggested collection:

```text
generationAuditEntries/{auditEntryId}
```

Suggested fields:

```text
id
schoolId
requestId
eventType
actorType
actorUserId
source
intent
artifactType
artifactId
artifactVersion
stage
status
metadata
createdAt
```

Allowed event types:

```text
request_created
generation_started
stage_completed
stage_failed
artifact_generated
artifact_edited
artifact_validated
artifact_approved
artifact_published
artifact_superseded
artifact_retracted
```

### ProvenanceRecord

Records the source lineage for an artifact or published read model.

Suggested collection:

```text
provenanceRecords/{provenanceRecordId}
```

Suggested fields:

```text
id
schoolId
targetType
targetId
targetVersion
curriculumSourceId
curriculumVersionId
standardIds
pedagogicalAnalysisIds
learningObjectiveIds
masteryDefinitionIds
assessmentBlueprintIds
lessonBlueprintIds
tutorBlueprintIds
mediaBlueprintIds
promptTemplateVersionIds
knowledgeSourceReferenceIds
assetIds
sourceArtifactIds
createdAt
```

Rules:

1. Every generated artifact must have a provenance record.
2. Every `publishedLessonContent` record must have a provenance record.
3. Provenance must preserve curriculum source and version forever.
4. Provenance must include prompt template versions when AI or prompt-governed generation was used.

### VersionHistory

Records version lineage for mutable planning records and generated artifacts.

Suggested collection:

```text
versionHistories/{versionHistoryId}
```

Suggested fields:

```text
id
entityType
entityId
schoolId
version
previousVersion
nextVersion
changeType
changeSummary
changedByUserId
sourceRequestId
checksum
createdAt
```

Allowed change types:

```text
created
generated
edited
regenerated
translated
approved
published
superseded
retracted
archived
```

### CostTrackingRecord

Records estimated and actual generation cost.

Suggested collection:

```text
costTrackingRecords/{costTrackingRecordId}
```

Suggested fields:

```text
id
schoolId
requestId
jobId
stage
provider
model
inputUnits
outputUnits
estimatedCost
actualCost
currency
costPolicyId
rateLimitPolicyId
createdAt
```

Rules:

1. Cost tracking records must be written for provider-backed generation stages.
2. Cost policy enforcement must be auditable.
3. Failed or retried attempts should still record cost when cost was incurred.
4. Student App must not receive raw cost/provider details.

### PromptExecutionRecord

Records each prompt-governed generation or validation execution.

Suggested collection:

```text
promptExecutionRecords/{promptExecutionRecordId}
```

Suggested fields:

```text
id
schoolId
requestId
jobId
stage
promptTemplateId
promptTemplateVersionId
schoolPromptOverrideId
provider
model
inputHash
outputHash
inputReferenceIds
outputArtifactIds
status
failureReason
costTrackingRecordId
createdAt
completedAt
```

Rules:

1. Prompt inputs and outputs should be referenced or hashed for audit.
2. Sensitive prompt payloads should not be exposed to Student App.
3. Prompt execution must record template version and override usage.
4. Prompt execution failure must link to generation failure events.

### Auditability Rules

1. Every generated artifact must link to `GenerationAuditEntry`, `ProvenanceRecord`, `VersionHistory`, and any relevant `PromptExecutionRecord`.
2. Every publication event must create an audit entry and provenance record for the published read model.
3. Every approval event must record actor, role, timestamp, target artifact, and decision.
4. Every curriculum decision must be traceable to curriculum source/version and school selection when applicable.
5. Every prompt execution must record prompt template version and cost tracking when provider-backed.
6. Every manual edit must create an audit entry and version history entry.
7. Audit records are append-only.
8. Student App must not expose internal audit details, but backend support/admin tools must be able to inspect them.

## Consolidated Architecture Decisions

CE-03B should treat these as stable:

1. `CourseOffering` controls student-visible course availability.
2. `CourseMap` controls instructional planning.
3. Course planning records are versioned.
4. Language-specific records and artifacts are independently validated.
5. Global curriculum intelligence may be reused.
6. School-specific overrides, offerings, publication, and edits are tenant-scoped.
7. `AssetRegistry` is separate from `MediaArtifact`.
8. Generation requires cost and rate governance.
9. Review policy is risk-based.
10. Minimum publishable package is required before `publishedLessonContent`.
11. Partial generation failures do not publish partial student-facing content.
12. Student App consumes only published/enabled read models.
13. Generated artifacts, publication events, approval events, curriculum decisions, prompt executions, and manual edits must be auditable and traceable.

## Impact on CE-03B

CE-03B API and Cloud Function contracts must include:

- `CourseOffering` checks before Student App course availability
- `LessonSpecification` awareness in `requestLessonContent`
- idempotency using lesson/course/standard/language context
- language-specific request validation
- rate-limit and cost-policy rejection responses
- risk-aware review and publication checks
- minimum publishable package validation
- partial failure status for School Portal
- simplified `pending`, `ready`, `failed` status for Student App
- asset registry references in media-related contracts
- audit/provenance writes for generation, approval, publication, prompt execution, cost tracking, and manual edits

## Remaining Open Questions

1. Should `CourseOffering` live under `schools/{schoolId}` or as a top-level collection with `schoolId`?
2. Should global reusable blueprints be copied into school scope before editing, or referenced with override layers?
3. Should translated `LessonSpecification` records share the same `lessonId` with language suffixes or use independent ids?
4. What exact risk level should allow `auto_publish_after_validation` for MVP?
5. Should the first MVP support generated media, or restrict media to placeholders and approved registry assets?
6. Should cost policy be enforced before request creation or during orchestration?
7. Should partial failures allow School Portal to manually continue with missing optional artifacts?
8. Should audit/provenance records be stored as separate top-level collections, subcollections under requests/artifacts, or both?
9. How much prompt input/output detail should be stored versus hashed to balance auditability, privacy, and cost?
