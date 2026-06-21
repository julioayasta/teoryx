# Sprint CE-03A - Content Engine MVP Execution Pipeline

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the MVP runtime execution pipeline for the TeoryX Content Engine.

The execution pipeline coordinates generation requests, orchestration, workers, queues, status transitions, retry behavior, validation, publication, Student App pending/ready flow, and School Portal authoring flow.

This sprint is documentation only.

## Scope

This sprint designs:

- generation request lifecycle
- orchestrator responsibilities
- worker architecture
- queue model
- status transitions
- failure handling
- retry policy
- publication flow
- Student App pending/ready/failed flow
- School Portal authoring/review flow
- Firestore collection proposal
- CE-03B recommendation

## Non-Scope

This sprint does not implement:

- Content Engine code
- Cloud Functions
- queue infrastructure
- Firestore writes
- AI provider calls
- Student App changes
- School Portal changes
- publication UI

## Pipeline Inputs

The execution pipeline starts from:

```text
ContentGenerationRequest
```

Required context:

```text
schoolId
curriculumSourceId
curriculumVersionId
curriculumId
gradeLevelId
subjectId
standardId
language
source
intent
editAllowed
publicationMode
requestedByUserId
idempotencyKey
```

The pipeline depends on prior CE design layers:

```text
CE-02A Curriculum Source Registry
CE-02B Pedagogical Analysis Engine
CE-02C Instructional Blueprint Engine
CE-02D Generation Artifact Contracts
```

## Invocation Paths

### Student App

Student App is a read-only consumption workflow.

Default request:

```text
source = student_app
intent = fill_missing
editAllowed = false
publicationMode = auto_publish_after_validation or require_review by policy
```

Student App may:

- request missing content
- receive `pending`
- receive `ready`
- receive `failed`
- consume `publishedLessonContent`

Student App must not:

- edit generated content
- approve content
- publish content
- modify curriculum selection
- call AI directly
- see draft artifacts
- see authoring states

### School Portal

School Portal is an authoring and review workflow.

Default request:

```text
source = school_admin_portal
editAllowed = true
publicationMode = require_review
```

School Portal may:

- request creation
- request update/regeneration
- view draft artifacts
- edit editable artifacts through authorized workflows
- submit for validation
- submit for review/publication

### Super Admin

Super Admin is a governance workflow.

Super Admin may:

- request global or tenant-specific generation
- approve publication policies
- regenerate stale content
- support migration after curriculum version changes

### System

System workflows are background maintenance workflows.

System may:

- repair missing artifacts
- regenerate stale artifacts
- retry failed transient work
- prepare content for review

## Existing Content Check

Existing published content must be returned before generating duplicate content.

The pipeline checks:

```text
publishedLessonContent
```

by:

```text
schoolId
curriculumSourceId
curriculumVersionId
standardId
language
status = published
```

If matching content exists:

- Student App receives `ready`
- response includes `publishedContentId`
- no duplicate generation is started

If no matching content exists:

- request enters generation lifecycle
- idempotency prevents duplicate in-flight work

## Orchestrator

### ContentGenerationOrchestrator

The orchestrator coordinates the request from creation through completion.

Responsibilities:

1. Validate request source, intent, tenant, language, and publication policy.
2. Build or verify idempotency key.
3. Check existing published content before generation.
4. Resolve curriculum context.
5. Resolve or request pedagogical analysis.
6. Resolve or request instructional blueprints.
7. Dispatch artifact workers.
8. Dispatch validation worker.
9. Dispatch publication worker according to `publicationMode`.
10. Update request status for caller-facing state.
11. Record failure and retry metadata.
12. Prevent invalid stage jumps.

The orchestrator does not directly call the Student App or School Portal UI.

It updates durable request and job state that products can observe.

## Worker Architecture

```text
ContentGenerationOrchestrator
  -> RequestContextResolver
  -> CurriculumContextWorker
  -> PedagogicalAnalysisWorker
  -> BlueprintResolverWorker
  -> LessonArtifactWorker
  -> AssessmentArtifactWorker
  -> TutorArtifactWorker
  -> MediaArtifactWorker
  -> PresentationArtifactWorker
  -> ValidationWorker
  -> PublicationWorker
  -> NotificationStatusWorker
```

### RequestContextResolver

Validates:

- source
- intent
- tenant
- requested user
- language
- `editAllowed`
- `publicationMode`
- idempotency key
- permission policy

### CurriculumContextWorker

Resolves:

- active school curriculum selection
- official curriculum source
- curriculum version
- normalized curriculum standard
- standard/source/version traceability

Rejects generation if curriculum context cannot be resolved.

### PedagogicalAnalysisWorker

Loads an existing approved or valid `PedagogicalAnalysis`.

If policy allows future generation of analysis, this worker may enqueue analysis generation. For MVP execution, missing analysis may fail or route to a preparation workflow.

### BlueprintResolverWorker

Loads or prepares CE-02C blueprints:

- `LearningObjective`
- `MasteryDefinition`
- `EvidenceRequirement`
- `AssessmentBlueprint`
- `LessonBlueprint`
- `TutorBlueprint`
- `MediaBlueprint`

Blueprints must exist before artifact generation.

### LessonArtifactWorker

Generates `LessonArtifact` from `LessonBlueprint`.

Output:

```text
lessonArtifacts/{lessonArtifactId}
```

### AssessmentArtifactWorker

Generates `AssessmentArtifact` from `AssessmentBlueprint`.

Output:

```text
assessmentArtifacts/{assessmentArtifactId}
```

### TutorArtifactWorker

Generates `TutorArtifact` from `TutorBlueprint`.

Output:

```text
tutorArtifacts/{tutorArtifactId}
```

### MediaArtifactWorker

Generates or resolves `MediaArtifact` from `MediaBlueprint`.

Output:

```text
mediaArtifacts/{mediaArtifactId}
```

### PresentationArtifactWorker

Builds `PresentationArtifact` from generated content artifacts.

Output:

```text
presentationArtifacts/{presentationArtifactId}
```

### ValidationWorker

Creates `ValidationArtifact`.

Validates:

- curriculum alignment
- blueprint alignment
- source grounding
- schema validity
- age appropriateness
- language appropriateness
- assessment alignment
- tutor safety
- media accessibility
- presentation compatibility
- tenant boundary
- publication readiness

Invalid artifacts are blocked from publication.

### PublicationWorker

PublicationWorker maps valid `PresentationArtifact` into:

```text
publishedLessonContent/{publishedContentId}
```

PublicationWorker must respect `publicationMode`:

```text
draft:
  produce draft artifacts only
  do not publish
  do not move to ready_for_review unless explicitly submitted later

require_review:
  move artifacts/request to ready_for_review
  do not publish

auto_publish_after_validation:
  publish only if validation passes
  map valid PresentationArtifact into publishedLessonContent
```

### NotificationStatusWorker

Updates product-facing status.

Student App visible states:

```text
pending
ready
failed
```

School Portal visible states:

```text
draft
generating
validation_failed
ready_for_review
approved
published
failed
```

## Queue Model

The MVP queue model should support durable, idempotent stage execution.

Proposed runtime collections:

```text
contentGenerationRequests/{requestId}
contentGenerationJobs/{jobId}
contentGenerationRequests/{requestId}/stageExecutions/{stageExecutionId}
generationFailureEvents/{failureEventId}
generationRetryEvents/{retryEventId}
```

### contentGenerationJobs/{jobId}

Fields:

```text
id
requestId
jobType
stage
status
attempt
maxAttempts
lockedByWorkerId
lockedAt
availableAt
payload
failureReason
createdAt
updatedAt
completedAt
```

Allowed job statuses:

```text
queued
locked
processing
completed
failed
retry_scheduled
dead_lettered
cancelled
```

### StageExecution

Tracks each execution attempt for a stage.

Fields:

```text
id
requestId
stage
workerType
attempt
status
inputRefs
outputRefs
startedAt
completedAt
failureReason
createdAt
```

Allowed stage statuses:

```text
pending
running
completed
failed
skipped
retrying
```

## Generation Request Lifecycle

Full internal lifecycle:

```text
created
-> validating_request
-> resolving_curriculum
-> checking_existing_content
-> resolving_pedagogical_analysis
-> resolving_blueprints
-> generating_lesson_artifact
-> generating_assessment_artifact
-> generating_tutor_artifact
-> generating_media_artifact
-> generating_presentation_artifact
-> validating_artifacts
-> ready_for_review | publishing | failed
-> published | ready | failed
```

### Student App Simplified Lifecycle

Student App only sees:

```text
pending
ready
failed
```

Mapping:

```text
created through validating_artifacts -> pending
published with publishedContentId -> ready
ready with existing publishedContentId -> ready
terminal generation failure -> failed
```

If publication policy requires review, Student App may remain `pending` or receive a friendly unavailable state until content is published.

It must not see `draft`, `ready_for_review`, or editable artifact states.

### School Portal Authoring Lifecycle

School Portal sees authoring/review states:

```text
draft
generating
validation_failed
ready_for_review
approved
published
failed
```

School Portal may view or edit only artifacts allowed by workflow policy.

## Status Transitions

Allowed request status transitions:

```text
created -> validating_request
validating_request -> resolving_curriculum | failed
resolving_curriculum -> checking_existing_content | failed
checking_existing_content -> ready | resolving_pedagogical_analysis | failed
resolving_pedagogical_analysis -> resolving_blueprints | failed
resolving_blueprints -> generating_lesson_artifact | failed
generating_lesson_artifact -> generating_assessment_artifact | failed
generating_assessment_artifact -> generating_tutor_artifact | failed
generating_tutor_artifact -> generating_media_artifact | failed
generating_media_artifact -> generating_presentation_artifact | failed
generating_presentation_artifact -> validating_artifacts | failed
validating_artifacts -> ready_for_review | publishing | failed
ready_for_review -> approved | failed
approved -> publishing | failed
publishing -> published | failed
published -> ready
```

Duplicate generation check may short-circuit:

```text
checking_existing_content -> ready
```

Draft mode may stop at:

```text
validating_artifacts -> draft
```

## Failure Handling

Failure categories:

```text
missing_required_context
permission_denied
curriculum_selection_not_found
standard_not_found
pedagogical_analysis_not_found
blueprint_not_found
generation_failed
validation_failed
publication_failed
transient_provider_failure
queue_timeout
worker_timeout
duplicate_request_conflict
```

### Retryable Failures

Retryable:

- transient provider failure
- queue timeout
- worker timeout
- temporary Firestore read/write failure
- temporary publication mapping failure

### Non-Retryable Failures

Non-retryable:

- permission denied
- missing required context
- standard not found
- curriculum selection not found
- invalid publication mode
- unsupported Student App request
- validation failure due to unsafe or misaligned content

## Retry Policy

Default retry policy:

```text
maxAttempts = 3
backoff = exponential
jitter = true
deadLetterAfterMaxAttempts = true
```

Rules:

1. Retry creates a new stage execution attempt.
2. Retry must not mutate published artifacts.
3. Retry must preserve request and job history.
4. Non-retryable failures fail fast.
5. Dead-lettered jobs require admin/system intervention.

## Publication Flow

Publication requires:

- valid `PresentationArtifact`
- valid `ValidationArtifact`
- publication policy allows publication
- no unresolved safety errors
- Student App compatible presentation contract

Flow:

```text
ValidationArtifact valid
-> PublicationWorker
-> ArtifactPublicationRecord
-> publishedLessonContent
-> request status ready/published
```

Publication maps valid `PresentationArtifact` into:

```text
publishedLessonContent/{publishedContentId}
```

Publishing a new version must preserve historical publication records.

## Student App Pending/Ready Flow

When a Student App requests missing content:

1. Request is validated.
2. Existing published content is checked first.
3. If published content exists, return `ready`.
4. If missing, create or reuse a pending request.
5. Student App receives `pending`.
6. Student App listens to request status or fetches status later.
7. If content is published, Student App receives `ready`.
8. If generation fails, Student App receives `failed`.

Student App must not receive:

- draft artifacts
- editable artifacts
- authoring state
- raw worker errors
- AI provider details

## School Portal Authoring Flow

When School Portal requests content:

1. Request is validated with authoring permissions.
2. Existing content is checked.
3. Admin chooses create/update/regenerate path when policy allows.
4. Pipeline generates artifacts.
5. If `publicationMode = draft`, artifacts remain draft.
6. If `publicationMode = require_review`, artifacts move to `ready_for_review`.
7. School Admin may edit editable artifacts through authorized workflows.
8. Edited artifacts are revalidated.
9. Approved artifacts may be published by policy.

School Portal may see workflow detail that Student App cannot see.

## Firestore Collection Proposal

Runtime collections:

```text
contentGenerationRequests/{requestId}
contentGenerationJobs/{jobId}
contentGenerationRequests/{requestId}/stageExecutions/{stageExecutionId}
generationFailureEvents/{failureEventId}
generationRetryEvents/{retryEventId}
artifactPublicationRecords/{publicationRecordId}
publishedLessonContent/{publishedContentId}
```

### contentGenerationRequests/{requestId}

Fields:

```text
id
schoolId
curriculumSourceId
curriculumVersionId
curriculumId
gradeLevelId
subjectId
standardId
language
source
intent
editAllowed
publicationMode
requestedByUserId
requestedByClient
idempotencyKey
status
studentVisibleStatus
schoolPortalVisibleStatus
publishedContentId
activeJobId
failureReason
createdAt
updatedAt
completedAt
```

Recommended indexes:

```text
schoolId + idempotencyKey + status
schoolId + source + status + createdAt
schoolId + standardId + language + status
```

### contentGenerationJobs/{jobId}

Stores queued and running work.

Recommended indexes:

```text
status + availableAt
stage + status + availableAt
requestId + status
```

### stageExecutions

Subcollection under request for detailed stage history.

### generationFailureEvents/{failureEventId}

Fields:

```text
id
requestId
jobId
stage
failureCategory
retryable
message
metadata
createdAt
```

### generationRetryEvents/{retryEventId}

Fields:

```text
id
requestId
jobId
stage
attempt
nextAttemptAt
reason
createdAt
```

## Operational Guardrails

1. Student App never calls AI directly.
2. Student App only sees `pending`, `ready`, or `failed`.
3. School Portal sees authoring/review states.
4. Existing published content must be returned before generating duplicate content.
5. All generated artifacts must trace to curriculum, analysis, and blueprints.
6. Publication maps valid `PresentationArtifact` into `publishedLessonContent`.
7. Missing or invalid curriculum context must fail before generation.
8. Published history must not be mutated by retries or regeneration.
9. Firebase/Firestore details remain behind backend/data boundaries.

## CE-03B Recommendation

Recommended next sprint:

```text
CE-03B - Content Engine API and Cloud Function Contracts
```

Scope:

- define callable API contracts for Student App and School Portal
- define request/response schemas
- define Cloud Function entry points
- define backend permission checks
- define idempotency behavior
- define status subscription/read model contracts
- define emulator/local development strategy
- define test strategy for orchestration without real AI generation

Do not implement app code in CE-03B.

## Open Questions

1. Should MVP use Firestore as a simple queue first, or introduce Cloud Tasks/Pub/Sub immediately?
2. Should Student App pending state wait indefinitely for review-required content, or receive a friendly unavailable state after a timeout?
3. Should artifact workers run strictly sequentially in MVP, or can assessment/tutor/media workers run in parallel after required prerequisites exist?
4. Should `PedagogicalAnalysisWorker` generate missing analysis in CE-03A scope later, or fail until CE-02B outputs exist?
5. Should `ready_for_review` be visible to teachers, school admins, or only curriculum/content admins?
6. Should idempotency be scoped by school/standard/language only, or include course and lesson context?
