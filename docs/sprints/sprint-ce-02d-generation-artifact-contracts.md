# Sprint CE-02D - Generation Artifact Contracts

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the Generation Artifact Contracts for the TeoryX Content Engine.

Generation artifacts are the concrete generated outputs produced from CE-02C instructional blueprints.

This sprint defines artifact contracts only. It does not implement AI generation, Firestore writes, publication workflow, Student App changes, or School Admin Portal changes.

## Scope

This sprint designs:

- `LessonArtifact`
- `AssessmentArtifact`
- `TutorArtifact`
- `MediaArtifact`
- `PresentationArtifact`
- `ValidationArtifact`
- shared artifact versioning rules
- artifact edit and regeneration rules
- publication mapping to `publishedLessonContent`
- Firestore collection proposal
- failure scenarios
- CE-02E recommendation

## Non-Scope

This sprint does not implement:

- Content Engine code
- AI provider calls
- lesson generation
- assessment generation
- tutor generation
- media generation
- Firestore writes
- Student App changes
- School Admin Portal changes
- publication workflow UI

## Pipeline Placement

The Content Engine sequence becomes:

```text
CurriculumStandard
-> PedagogicalAnalysis
-> Instructional Blueprints
-> Generation Artifacts
-> Validation
-> Publication
-> publishedLessonContent
```

Artifacts are generated outputs from CE-02C blueprints.

The blueprint-to-artifact mapping is:

```text
LessonBlueprint -> LessonArtifact
AssessmentBlueprint -> AssessmentArtifact
TutorBlueprint -> TutorArtifact
MediaBlueprint -> MediaArtifact
LessonArtifact + MediaArtifact + TutorArtifact + AssessmentArtifact -> PresentationArtifact
PresentationArtifact + ValidationArtifact -> publishedLessonContent
```

The Student App consumes only `publishedLessonContent`.

## Artifact Principles

### Generated Outputs

Artifacts contain generated output, not just planning structure.

Examples:

- lesson text
- guided practice content
- assessment items
- tutor prompt package
- media asset references
- presentation blocks

### Versioned History

Artifacts are versioned.

Regeneration creates a new version. It must not mutate published history.

Existing published artifacts remain traceable and readable even after newer versions are generated.

### Traceability

Every artifact must trace back to:

- official curriculum source
- curriculum version
- curriculum standard
- pedagogical analysis
- CE-02C blueprints
- prompt template versions
- generation request
- validation artifact

### Controlled Editing

School Admin editing applies only through authorized editable artifact workflows.

School Admin may edit approved/editable artifacts when policy allows.

School Admin edits must:

- create an edit record
- preserve provenance
- trigger validation before publication
- never override curriculum alignment
- never bypass safety rules
- never mutate published history silently

Student App cannot edit artifacts.

### Published Read Model

The Student App must not consume draft artifacts, editable artifacts, or validation artifacts directly.

The Student App consumes:

```text
publishedLessonContent/{publishedContentId}
```

`PresentationArtifact` maps into `publishedLessonContent` after validation and publication.

## Shared Artifact Contract

All artifact types share a common contract.

### GenerationArtifactBase

Fields:

```text
artifactId
artifactType
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
standardCode
sourceVersion
pedagogicalAnalysisId
learningObjectiveId
masteryDefinitionId
evidenceRequirementIds
assessmentBlueprintId
lessonBlueprintId
tutorBlueprintId
mediaBlueprintId
language
gradeLevelId
subjectId
promptTemplateVersionIds
sourceGenerationRequestId
validationArtifactId
status
editable
createdBy
updatedBy
createdAt
updatedAt
publishedAt
supersededByArtifactId
```

Allowed artifact types:

```text
lesson
assessment
tutor
media
presentation
validation
```

Allowed statuses:

```text
draft
generated
edited
validation_failed
ready_for_review
approved
published
archived
superseded
```

### ArtifactVersion

Represents immutable version metadata for an artifact.

Fields:

```text
artifactId
artifactType
version
previousVersion
regenerationReason
changeSummary
checksum
createdAt
createdBy
sourceGenerationRequestId
```

Rules:

1. Published versions are immutable.
2. Regeneration creates a new version.
3. Editing an artifact creates a new edited version or draft revision, depending on workflow policy.
4. Version history must remain queryable for audit.
5. Each version must include a checksum.

## LessonArtifact

`LessonArtifact` is generated from `LessonBlueprint`.

It contains the generated instructional content that may later be rendered through a `PresentationArtifact`.

Fields:

```text
artifactId
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
pedagogicalAnalysisId
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
lessonBlueprintId
language
title
bigIdea
essentialQuestion
learningObjectiveText
lessonContent
guidedPractice
independentPractice
summary
lessonSteps
vocabularySupport
misconceptionSupport
status
editable
validationArtifactId
createdAt
updatedAt
```

Rules:

1. Must derive from an approved or valid `LessonBlueprint`.
2. Must preserve alignment to `AssessmentBlueprint`.
3. Must preserve traceability to curriculum and analysis.
4. May be editable only through authorized School Admin workflows.
5. Must be validated before publication.

## AssessmentArtifact

`AssessmentArtifact` is generated from `AssessmentBlueprint`.

It contains generated assessment content, including item definitions, scoring guidance, and review policy.

Fields:

```text
artifactId
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
pedagogicalAnalysisId
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
language
assessmentPurpose
assessmentMode
items
scoringPolicy
passingCriteria
teacherReviewGuidance
status
editable
validationArtifactId
createdAt
updatedAt
```

Rules:

1. Must derive from `AssessmentBlueprint`.
2. Must map each item to evidence requirements.
3. Must preserve misconception coverage where relevant.
4. Must not be exposed to the Student App unless published through an assessment-specific consumption path.
5. Must be validated before use.

### AssessmentItemArtifact

Fields:

```text
id
assessmentArtifactId
order
itemType
prompt
answerOptions
correctAnswer
rubric
targetSkillIds
evidenceRequirementId
misconceptionIds
requiresTeacherReview
scoringApproach
```

## TutorArtifact

`TutorArtifact` is generated from `TutorBlueprint`.

It contains the tutor prompt package or behavior configuration needed by a future tutor service.

Fields:

```text
artifactId
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
pedagogicalAnalysisId
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
lessonBlueprintId
tutorBlueprintId
language
systemPrompt
behaviorRules
safetyRules
hintPolicy
answerPolicy
misconceptionResponses
escalationRules
status
editable
validationArtifactId
createdAt
updatedAt
```

Rules:

1. Must derive from `TutorBlueprint`.
2. Must preserve tutor behavior boundaries.
3. Must not allow answer leakage unless allowed by policy.
4. Must not modify curriculum intent.
5. Must pass safety validation before use.

## MediaArtifact

`MediaArtifact` is generated from `MediaBlueprint`.

It may contain generated media references, selected existing assets, or external asset references.

Fields:

```text
artifactId
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
pedagogicalAnalysisId
learningObjectiveId
lessonBlueprintId
mediaBlueprintId
language
assetReferences
accessibilityMetadata
usageGuidance
licenseMetadata
status
editable
validationArtifactId
createdAt
updatedAt
```

Rules:

1. Must derive from `MediaBlueprint`.
2. Must map assets to instructional needs.
3. Must include accessibility metadata when media is required.
4. Must include license/provenance metadata.
5. Must not include decorative assets unless they support learning.

### MediaAssetReference

Fields:

```text
id
mediaArtifactId
mediaRequirementId
mediaType
assetSource
assetUrl
storagePath
altText
caption
license
credit
accessibilityNotes
status
```

Allowed asset sources:

```text
generated
selected_library_asset
school_uploaded
external_oer
placeholder
```

## PresentationArtifact

`PresentationArtifact` is generated from content artifacts and presentation requirements.

It represents the renderable contract that can be published to the Student App read model.

`PresentationArtifact` maps into:

```text
publishedLessonContent/{publishedContentId}
```

Fields:

```text
artifactId
version
schoolId
curriculumSourceId
curriculumVersionId
standardId
standardCode
pedagogicalAnalysisId
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
lessonBlueprintId
tutorBlueprintId
mediaBlueprintId
lessonArtifactId
assessmentArtifactId
tutorArtifactId
mediaArtifactId
language
contractVersion
templateType
title
layout
blocks
interactions
learningDetails
mediaReferences
status
editable
validationArtifactId
createdAt
updatedAt
```

Rules:

1. Must map to Student App supported rendering contracts.
2. Must preserve curriculum and artifact provenance.
3. Must not reference unpublished unsafe artifacts.
4. Must pass validation before publication.
5. Must be transformed or copied into `publishedLessonContent` for Student App consumption.

### PresentationBlockArtifact

Fields:

```text
id
presentationArtifactId
order
type
title
body
interaction
mediaReferenceIds
sourceLessonStepId
supportedByStudentApp
```

Student App currently supports a subset of block types. Unsupported block types must be rejected, transformed safely, or held from publication.

## ValidationArtifact

`ValidationArtifact` records validation results for generated artifacts.

Fields:

```text
artifactId
version
validatedArtifactIds
schoolId
curriculumSourceId
curriculumVersionId
standardId
pedagogicalAnalysisId
blueprintIds
validationStatus
validationCategories
errors
warnings
validatedBy
validatedAt
createdAt
```

Allowed validation statuses:

```text
valid
valid_with_warnings
invalid
```

Validation categories:

```text
curriculum_alignment
blueprint_alignment
source_grounding
schema_validity
age_appropriateness
language_appropriateness
assessment_alignment
tutor_safety
media_accessibility
presentation_compatibility
tenant_boundary
publication_readiness
```

Rules:

1. Invalid artifacts must not be published.
2. Validation must include curriculum and blueprint alignment.
3. Presentation validation must check Student App compatibility.
4. Validation results must remain auditable.

## Editing And Regeneration

### School Admin Editing

School Admin may edit artifacts only through authorized editable artifact workflows.

Editable workflows must enforce:

- role permission
- artifact status permission
- edit audit record
- validation after editing
- publication approval before Student App consumption

School Admin may not edit:

- official curriculum source meaning
- curriculum alignment requirements
- source hierarchy
- safety constraints
- required output schema
- immutable published history

### Regeneration

Regeneration creates a new artifact version.

It must not mutate:

- previously published artifacts
- prior validation artifacts
- prior publication records
- historical `publishedLessonContent` records

Regeneration may be triggered by:

- School Admin request
- Super Admin request
- system migration
- source version change
- validation failure recovery
- prompt version change
- translation or improvement request

### ArtifactEditRecord

Fields:

```text
id
artifactId
artifactType
version
schoolId
editedByUserId
editReason
fieldChanges
createdAt
```

### RegenerationRequest

Fields:

```text
id
schoolId
sourceArtifactId
sourceArtifactVersion
artifactType
reason
requestedByUserId
source
intent
status
newArtifactId
newVersion
createdAt
updatedAt
```

Allowed statuses:

```text
pending
processing
completed
failed
cancelled
```

## Publication Mapping

The Student App consumes only:

```text
publishedLessonContent/{publishedContentId}
```

Publication maps a validated `PresentationArtifact` into `publishedLessonContent`.

Mapping:

```text
PresentationArtifact
-> ArtifactPublicationRecord
-> publishedLessonContent
```

The published read model should include:

```text
publishedContentId
presentationArtifactId
lessonArtifactId
assessmentArtifactId
tutorArtifactId
mediaArtifactId
schoolId
courseId
curriculumId
curriculumSourceId
curriculumVersionId
gradeLevelId
subjectId
standardId
standardCode
language
title
bigIdea
essentialQuestion
learningObjective
lessonContent
guidedPractice
independentPractice
summary
steps
presentationContract
status
version
publishedAt
publishedByUserId
```

Rules:

1. Only validated presentation artifacts may map to `publishedLessonContent`.
2. `publishedLessonContent` must preserve artifact provenance.
3. Student App must not read draft or editable artifacts directly.
4. Publishing a new version creates or updates the active read model while preserving historical publication records.
5. Published content must remain traceable to curriculum, analysis, blueprints, and artifacts.

### ArtifactPublicationRecord

Fields:

```text
id
schoolId
presentationArtifactId
presentationArtifactVersion
publishedContentId
publishedByUserId
publicationMode
status
publishedAt
supersedesPublicationRecordId
createdAt
```

Allowed statuses:

```text
pending
published
superseded
retracted
failed
```

## Firestore Collection Proposal

Proposed collections:

```text
lessonArtifacts/{lessonArtifactId}
assessmentArtifacts/{assessmentArtifactId}
assessmentArtifacts/{assessmentArtifactId}/items/{assessmentItemArtifactId}
tutorArtifacts/{tutorArtifactId}
mediaArtifacts/{mediaArtifactId}
mediaArtifacts/{mediaArtifactId}/assetReferences/{assetReferenceId}
presentationArtifacts/{presentationArtifactId}
presentationArtifacts/{presentationArtifactId}/blocks/{presentationBlockId}
validationArtifacts/{validationArtifactId}
artifactEditRecords/{editRecordId}
artifactPublicationRecords/{publicationRecordId}
regenerationRequests/{regenerationRequestId}
publishedLessonContent/{publishedContentId}
```

### lessonArtifacts/{lessonArtifactId}

Recommended indexes:

```text
schoolId + standardId + language + status
lessonBlueprintId + version
sourceGenerationRequestId + status
```

### assessmentArtifacts/{assessmentArtifactId}

Recommended indexes:

```text
schoolId + standardId + language + status
assessmentBlueprintId + version
```

### tutorArtifacts/{tutorArtifactId}

Recommended indexes:

```text
schoolId + standardId + language + status
tutorBlueprintId + version
```

### mediaArtifacts/{mediaArtifactId}

Recommended indexes:

```text
schoolId + standardId + language + status
mediaBlueprintId + version
```

### presentationArtifacts/{presentationArtifactId}

Recommended indexes:

```text
schoolId + standardId + language + status
lessonArtifactId + version
validationArtifactId + status
```

### validationArtifacts/{validationArtifactId}

Recommended indexes:

```text
standardId + validationStatus + createdAt
schoolId + validationStatus + createdAt
```

### artifactEditRecords/{editRecordId}

Recommended indexes:

```text
artifactId + artifactType + createdAt
schoolId + editedByUserId + createdAt
```

### artifactPublicationRecords/{publicationRecordId}

Recommended indexes:

```text
schoolId + publishedContentId + status
presentationArtifactId + presentationArtifactVersion
```

### regenerationRequests/{regenerationRequestId}

Recommended indexes:

```text
schoolId + status + createdAt
sourceArtifactId + sourceArtifactVersion
```

### publishedLessonContent/{publishedContentId}

Student App read model.

Recommended indexes:

```text
schoolId + courseId + language + status
schoolId + curriculumSourceId + curriculumVersionId + standardId + language + status
presentationArtifactId + version
```

## Validation Rules

### Curriculum Traceability

Validation must confirm:

- artifact references valid curriculum source
- artifact references valid curriculum version
- artifact references valid standard
- generated content does not alter official standard meaning

### Blueprint Traceability

Validation must confirm:

- artifact references required CE-02C blueprints
- artifact content matches blueprint intent
- assessment artifact matches assessment blueprint
- lesson artifact matches lesson blueprint
- tutor artifact matches tutor blueprint
- media artifact matches media blueprint

### Version Integrity

Validation must confirm:

- version is unique for artifact family
- checksum exists
- regenerated artifact links to previous version when applicable
- published history is not mutated

### Edit Integrity

Validation must confirm:

- edits were performed through authorized workflow
- edit record exists
- edited artifact was revalidated
- edits did not break curriculum or safety rules

### Publication Readiness

Validation must confirm:

- presentation artifact is valid
- required child artifacts are valid
- Student App supported block types are used
- media accessibility is present
- tutor safety rules are present
- artifact status allows publication

## Failure Scenarios

### Missing Blueprint

Cause:

- artifact generation is requested without a required CE-02C blueprint

Result:

- reject generation
- reason: `missing_blueprint`

### Invalid Generated Artifact

Cause:

- generated output violates schema, curriculum alignment, or blueprint intent

Result:

- mark artifact `validation_failed`
- write `ValidationArtifact`

### Unsafe Tutor Artifact

Cause:

- tutor artifact allows answer leakage, unsafe guidance, or curriculum modification

Result:

- reject tutor artifact
- reason: `unsafe_tutor_artifact`

### Invalid Media Artifact

Cause:

- media is inaccessible, unlicensed, decorative-only, or not tied to a media requirement

Result:

- reject or warn
- reason: `invalid_media_artifact`

### Unsupported Presentation Contract

Cause:

- presentation artifact uses unsupported Student App block types or invalid contract shape

Result:

- reject publication
- reason: `unsupported_presentation_contract`

### Unauthorized Edit

Cause:

- edit attempted outside authorized School Admin workflow

Result:

- reject edit
- reason: `permission_denied`

### Published History Mutation Attempt

Cause:

- workflow attempts to overwrite prior published artifact version

Result:

- reject operation
- reason: `published_history_immutable`

### Publication Mapping Failure

Cause:

- validated `PresentationArtifact` cannot map safely into `publishedLessonContent`

Result:

- reject publication
- reason: `publication_mapping_failed`

## Governance Rules

1. Artifacts are generated outputs from CE-02C blueprints.
2. Regeneration creates a new version, not mutation of published history.
3. Student App consumes only `publishedLessonContent`.
4. School Admin editing applies only through authorized editable artifact workflows.
5. `PresentationArtifact` maps into `publishedLessonContent`.
6. Invalid artifacts must not be published.
7. Published artifact history must remain auditable.
8. Every published read model must preserve curriculum, analysis, blueprint, and artifact provenance.

## CE-02E Recommendation

Recommended next sprint:

```text
CE-02E - Publication Workflow and Review Policy
```

Scope:

- define artifact review workflow
- define approval roles and permissions
- define publication modes
- define auto-publish policy constraints
- define retraction and supersession behavior
- define Student App missing-content state transitions
- define how `publishedLessonContent` is activated, superseded, or retracted
- define audit trail requirements for publication

Do not implement app code in CE-02E.

## Open Questions

1. Should artifact collections be globally shared with school publication references, or school-scoped from the start?
2. Should `publishedLessonContent` store a full denormalized copy of the `PresentationArtifact`, or a renderable subset plus references?
3. Should School Admin edits create a new artifact version immediately, or a draft revision that becomes a version only after validation?
4. Should assessment artifacts be published together with lesson content, or separately through an assessment publication workflow?
5. Should media artifacts support generated assets in v1, or begin with placeholders and selected library assets only?
6. Should regeneration requests be tied directly to `ContentGenerationRequest` or remain a separate workflow concept?
