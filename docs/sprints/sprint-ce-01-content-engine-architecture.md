# Sprint CE-01 - Content Engine Architecture

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the first functional architecture for the TeoryX Content Engine.

The Content Engine is a backend process responsible for checking, generating, validating, persisting, publishing, and returning references to curriculum-aligned learning content.

This sprint does not implement:

- AI
- Firebase
- Firestore
- Student App changes
- School Admin Portal changes

The goal is architecture, contracts, and workflow definition only.

## Invocation Sources

The Content Engine must be invocable by:

1. School Admin Portal
2. Student App when a requested lesson does not exist
3. Super Admin workflows
4. System/background jobs

The Student App must never call AI directly.

The Student App may only:

- request content
- receive an existing published content reference
- receive a pending generation request reference
- listen for readiness
- render content once ready

## Invocation Model

The Content Engine is an information generation system.

It can be invoked from different TeoryX products, but permissions and workflow differ by source.

Every `ContentGenerationRequest` must include:

```text
source
intent
editAllowed
publicationMode
```

Allowed `source` values:

```text
school_admin_portal
student_app
super_admin
system
```

Allowed `intent` values:

```text
create_new
update_existing
fill_missing
regenerate
translate
improve
```

Allowed `publicationMode` values:

```text
draft
auto_publish_after_validation
require_review
```

### Source-Based Behavior

#### School Admin Portal

The School Admin Portal is an authoring workflow.

It may:

- request creation of a new lesson
- request updates or regeneration of an existing lesson
- edit generated lesson content
- save drafts
- submit generated content for review/publication

Default request behavior:

```text
source = school_admin_portal
editAllowed = true
publicationMode = require_review
```

Allowed intents:

```text
create_new
update_existing
regenerate
translate
improve
```

School Admin Portal may produce `draft` or `ready_for_review` artifacts, but should not silently bypass publication policy.

#### Student App

The Student App is a read-only consumption workflow.

It may:

- request missing lesson content only
- receive pending/ready/failed state
- render published/ready content once available

It must not:

- edit generated content
- approve content
- publish content
- modify curriculum selection
- choose arbitrary standards
- call AI directly

Default request behavior:

```text
source = student_app
intent = fill_missing
editAllowed = false
publicationMode = auto_publish_after_validation
```

If policy does not allow auto-publication, the Student App receives `pending`, `ready`, or `failed` state but does not enter an authoring workflow.

Student App requests must be constrained to the already selected curriculum context:

```text
schoolId
curriculumId
gradeLevelId
subjectId
standardId
language
```

The Student App cannot change these identifiers during a missing-content request.

#### Super Admin

Super Admin workflows are governance workflows.

They may:

- create global or tenant-specific generation requests
- regenerate content
- translate content
- improve content
- approve or publish according to governance policy

Default request behavior:

```text
source = super_admin
editAllowed = true
publicationMode = require_review
```

Allowed intents:

```text
create_new
update_existing
regenerate
translate
improve
```

Super Admin may override broader publication policy only through explicit governance rules.

#### System

System workflows are background/maintenance workflows.

They may:

- regenerate stale content
- translate approved content
- improve content quality
- repair missing derived artifacts

Default request behavior:

```text
source = system
editAllowed = false
publicationMode = require_review
```

Allowed intents:

```text
fill_missing
regenerate
translate
improve
```

System-generated changes should remain reviewable unless explicitly covered by a safe auto-publication policy.

### Invocation Policy Matrix

```text
source               allowed workflow        editAllowed  publication default
school_admin_portal  authoring               true         require_review
student_app          read-only consumption    false        auto_publish_after_validation or require_review by policy
super_admin          governance              true         require_review
system               background maintenance  false        require_review
```

### CE Behavior by Invocation Source

The same Content Engine pipeline is used for all sources:

```text
Standard
-> Learning Objective
-> Assessment Blueprint
-> Lesson
-> Tutor Prompt
-> Presentation Contract
-> Validation
-> Persist
-> Publish or Review State
```

But source controls:

- which intents are allowed
- whether generated content can be edited
- whether the result can become a draft
- whether publication can be automatic after validation
- whether the caller receives an authoring artifact or only request status
- whether curriculum identifiers are caller-selected or pre-constrained

The Student App must receive only:

```text
pending
ready
failed
```

It must never receive an editable draft workflow.

## Bounded Context

Bounded context:

```text
Content Engine Context
```

Responsibilities:

- Verify content existence
- Generate missing content through an approved generation pipeline
- Validate generated content
- Persist generated artifacts
- Publish or mark content ready for review
- Return published content references
- Track asynchronous generation requests

The Content Engine is separate from:

- Student App
- School Admin Portal
- Curriculum Management UI
- AI provider integrations

AI provider calls, when implemented later, must be hidden behind generator interfaces.

## Mandatory Generation Sequence

The Content Engine must always respect:

```text
Standard
-> Learning Objective
-> Assessment Blueprint
-> Lesson
-> Tutor Prompt
-> Presentation Contract
```

It must never generate a Lesson directly.

Requests that do not include enough curriculum context must be rejected.

Required identifiers:

- `schoolId`
- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`
- `language`

## Domain Model

Core domain concepts:

- `ContentGenerationRequest`
- `CurriculumStandardReference`
- `LearningObjective`
- `AssessmentBlueprint`
- `GeneratedLesson`
- `TutorPrompt`
- `PresentationContract`
- `ContentValidationReport`
- `LessonContentArtifact`
- `PublishedLessonContent`

Conceptual flow:

```text
ContentGenerationRequest
-> CurriculumStandardReference
-> LearningObjective
-> AssessmentBlueprint
-> GeneratedLesson
-> TutorPrompt
-> PresentationContract
-> ContentValidationReport
-> PublishedLessonContent
```

## Aggregate Roots

### ContentGenerationRequest

Tracks a generation process from request to completion/failure.

Fields:

- `id`
- `schoolId`
- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`
- `language`
- `source`
- `intent`
- `editAllowed`
- `publicationMode`
- `requestedByUserId`
- `requestedByClient`
- `idempotencyKey`
- `status`
- `estimatedStateMessage`
- `publishedLessonId`
- `publishedContentId`
- `failureReason`
- `createdAt`
- `updatedAt`
- `completedAt`

Statuses:

- `pending`
- `checking_existing_content`
- `generating_learning_objective`
- `generating_assessment_blueprint`
- `generating_lesson`
- `generating_tutor_prompt`
- `generating_presentation_contract`
- `validating`
- `ready`
- `ready_for_review`
- `published`
- `failed`

### LessonContentArtifact

Stores the generated versioned content artifact before or after publication.

Fields:

- `id`
- `schoolId`
- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`
- `language`
- `learningObjective`
- `assessmentBlueprint`
- `lesson`
- `tutorPrompt`
- `presentationContract`
- `validationReportId`
- `version`
- `status`
- `createdAt`
- `updatedAt`

Statuses:

- `draft`
- `validation_failed`
- `ready_for_review`
- `published`
- `archived`

### PublishedLessonContent

Represents the content reference consumable by the Student App.

Fields:

- `id`
- `artifactId`
- `schoolId`
- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`
- `language`
- `version`
- `status`
- `publishedAt`
- `publishedByUserId`

## Entities

### LearningObjective

- `id`
- `standardId`
- `statement`
- `successCriteria`
- `desiredUnderstanding`
- `language`

### AssessmentBlueprint

- `id`
- `learningObjectiveId`
- `assessmentType`
- `passingScore`
- `successCriteria`
- `questionSpecs`

### GeneratedLesson

- `id`
- `learningObjectiveId`
- `title`
- `bigIdea`
- `essentialQuestion`
- `lessonContent`
- `guidedPractice`
- `independentPractice`
- `summary`
- `lessonSteps`

### TutorPrompt

- `id`
- `lessonId`
- `systemPrompt`
- `behaviorRules`
- `safetyRules`
- `language`

### PresentationContract

- `id`
- `lessonId`
- `contractVersion`
- `templateType`
- `layout`
- `blocks`
- `interactions`
- `mediaRequirements`

### ContentValidationReport

- `id`
- `artifactId`
- `status`
- `errors`
- `warnings`
- `validatedAt`

## Value Objects

Recommended value objects:

- `SchoolId`
- `CurriculumId`
- `GradeLevelId`
- `SubjectId`
- `StandardId`
- `StandardCode`
- `LanguageCode`
- `ContentVersion`
- `GenerationStatus`
- `ArtifactStatus`
- `PublicationStatus`
- `LessonTemplateType`
- `ValidationSeverity`
- `IdempotencyKey`

## Services

### ContentExistenceChecker

Checks for matching published content by:

- `schoolId`
- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`
- `language`
- `status = published`

### LearningObjectiveGenerator

Input:

- standard reference
- grade level
- subject
- language

Output:

- `LearningObjective`

### AssessmentBlueprintGenerator

Input:

- `LearningObjective`
- desired understanding

Output:

- `AssessmentBlueprint`

### LessonGenerator

Input:

- `CurriculumStandardReference`
- `LearningObjective`
- `AssessmentBlueprint`
- language

Output:

- `GeneratedLesson`

### TutorPromptGenerator

Input:

- `GeneratedLesson`
- `LearningObjective`
- grade level
- language

Output:

- `TutorPrompt`

### PresentationContractGenerator

Input:

- `GeneratedLesson`
- lesson template type
- subject
- grade level
- language

Output:

- `PresentationContract`

### ContentValidator

Validates:

- curriculum traceability
- UbD sequence
- required fields
- language consistency
- age appropriateness
- assessment alignment
- tutor safety rules
- presentation contract schema

### ContentPublisher

Publishes or marks content ready depending on workflow rules.

Initial CE-01 recommendation:

- School Admin may request content.
- Student App may request missing content.
- Publishing policy should be configurable.
- For MVP safety, generated content may be marked `ready_for_review` unless auto-publish is explicitly approved.

## Repositories

Repository contracts:

- `ContentGenerationRequestRepository`
- `LessonContentArtifactRepository`
- `PublishedLessonContentRepository`
- `CurriculumStandardRepository`
- `ContentValidationReportRepository`
- `PresentationContractRepository`

Key methods:

```text
findPublishedContent(query)
createGenerationRequest(request)
getGenerationRequest(requestId)
updateGenerationRequestStatus(requestId, status)
saveArtifact(artifact)
saveValidationReport(report)
publishArtifact(artifactId)
markArtifactReadyForReview(artifactId)
```

## Proposed Firestore Collections

Proposed collections:

```text
contentGenerationRequests
lessonContentArtifacts
publishedLessonContent
contentValidationReports
curriculumStandards
presentationContracts
```

Every school-scoped generated record must include:

```text
schoolId
```

Suggested indexes:

```text
publishedLessonContent:
schoolId + curriculumId + gradeLevelId + subjectId + standardId + language + status

contentGenerationRequests:
schoolId + idempotencyKey + status

lessonContentArtifacts:
schoolId + standardId + language + version + status
```

## Proposed Cloud Functions

### requestLessonContent

Callable by:

- Student App
- School Admin Portal

Responsibilities:

1. Validate request context.
2. Check if published content exists.
3. If content exists, return published reference.
4. If missing, create or reuse a pending `ContentGenerationRequest`.
5. Return pending response with `requestId`.

### processContentGenerationRequest

Triggered asynchronously by:

- request creation
- queue
- pub/sub event

Responsibilities:

- run generation workflow
- persist artifact
- validate artifact
- publish or mark ready
- update request status

### validateContentArtifact

Runs validation workflow and writes `ContentValidationReport`.

### publishContentArtifact

Publishes a validated artifact.

### getPublishedLessonReference

Returns the published lesson/content reference for Student App.

## Student App Missing Lesson Flow

When the Student App requests a lesson and no published lesson exists:

### Step 1: Student App requests content

The Student App calls:

```text
requestLessonContent
```

Required request:

```json
{
  "schoolId": "school-demo",
  "curriculumId": "ca-common-core",
  "gradeLevelId": "grade-4",
  "subjectId": "math",
  "standardId": "ccss-math-4-nf-a-2",
  "language": "en"
}
```

### Step 2: Content Engine checks existing published content

If found:

```json
{
  "status": "ready",
  "publishedLessonId": "published-lesson-id",
  "publishedContentId": "published-content-id"
}
```

If not found:

```json
{
  "status": "pending",
  "requestId": "content-request-id",
  "estimatedState": "generating_lesson",
  "message": "Getting your lesson ready..."
}
```

### Step 3: Student App enters waiting mode

The Student App must show a friendly waiting state:

```text
Getting your lesson...
```

The Student App listens to:

```text
contentGenerationRequests/{requestId}
```

The Student App must not call AI directly.

The Student App only listens for request readiness.

### Step 4: Content Engine processes asynchronously

The Content Engine continues in the backend:

```text
Standard
-> Learning Objective
-> Assessment Blueprint
-> Lesson
-> Tutor Prompt
-> Presentation Contract
-> Validation
-> Persist
-> Publish or Ready
```

### Step 5: Content Engine completes

On success:

```json
{
  "status": "ready",
  "publishedLessonId": "published-lesson-id",
  "publishedContentId": "published-content-id",
  "message": "Your lesson is ready."
}
```

The generated lesson is saved and either:

- published automatically if policy allows, or
- marked ready and referenced when approval policy allows.

### Step 6: Student App renders lesson

The Student App receives the realtime update, loads the published content, and renders it through the Presentation Contract.

### Step 7: Failure handling

On failure:

```json
{
  "status": "failed",
  "requestId": "content-request-id",
  "failureReason": "validation_failed",
  "message": "We could not prepare this lesson yet. Please try again."
}
```

Student App behavior:

- show friendly retry/error state
- do not expose raw technical errors
- allow retry if policy allows
- never call AI directly

## Generation Workflow

```text
1. Receive request
2. Normalize and validate request
3. Build idempotency key
4. Check published content
5. Return existing published content if available
6. Create/reuse ContentGenerationRequest if missing
7. Return pending response to caller
8. Process request asynchronously
9. Load official standard
10. Generate Learning Objective
11. Generate Assessment Blueprint
12. Generate Lesson
13. Generate Tutor Prompt
14. Generate Presentation Contract
15. Persist draft artifact
16. Validate artifact
17. Publish or mark ready_for_review
18. Update request status to ready or failed
```

## Validation Workflow

Validation categories:

1. Required field validation
2. Curriculum alignment validation
3. UbD sequence validation
4. Language validation
5. Presentation Contract schema validation
6. Tutor safety validation
7. Tenant boundary validation

Validation statuses:

- `valid`
- `valid_with_warnings`
- `invalid`

Invalid content must not be published.

## Failure Scenarios

### Missing required context

Cause:

- no `standardId`
- no `language`
- no tenant context

Result:

- reject request
- status: `failed`
- reason: `missing_required_context`

### Standard not found

Result:

- status: `failed`
- reason: `standard_not_found`

### Duplicate generation race

Cause:

- Student App and School Admin Portal request same content at the same time.

Mitigation:

- use idempotency key:

```text
schoolId:curriculumId:gradeLevelId:subjectId:standardId:language
```

### Generation failure

Result:

- persist failed stage
- update request as `failed`
- allow retry from failed stage later

### Validation failure

Result:

- artifact status: `validation_failed`
- request status: `failed`
- validation report persisted
- Student App receives friendly failure state

### Permission failure

Result:

- reject request
- reason: `permission_denied`

### Unsupported Presentation Contract

Result:

- validation fails
- content not published

## Presentation Contract v1

Purpose:

Allow a generated lesson to control its own student-facing layout and learning experience without coupling the Content Engine to Flutter widgets.

The contract must support lesson types such as:

- Story Lesson
- Reading Lesson
- Math Lesson
- Science Experiment
- Holiday Lesson
- Remediation Lesson

### Contract Shape

```json
{
  "contractVersion": "1.0",
  "templateType": "math_lesson",
  "title": "Fractions as Parts of a Whole",
  "language": "en",
  "layout": {
    "mode": "guided_sequence",
    "density": "comfortable",
    "supportsTutorOverlay": true
  },
  "blocks": [
    {
      "id": "step-1",
      "order": 1,
      "type": "story",
      "title": "You Missed The Pizza Lesson",
      "body": "Imagine you were absent..."
    },
    {
      "id": "step-2",
      "order": 2,
      "type": "image_placeholder",
      "title": "Picture The Whole",
      "body": "A pizza before it is cut.",
      "media": {
        "kind": "image",
        "status": "placeholder",
        "description": "A whole pizza on a table."
      }
    },
    {
      "id": "step-3",
      "order": 3,
      "type": "question",
      "title": "Pause And Say It Back",
      "body": "Think about the pizza as one whole.",
      "interaction": {
        "type": "short_answer",
        "prompt": "What fraction did Sofia receive?",
        "expectedAnswer": "1/4"
      }
    }
  ],
  "learningDetails": {
    "standardCode": "CCSS.MATH.4.NF.A.1",
    "bigIdea": "Fractions describe equal parts of one whole.",
    "essentialQuestion": "How can a fraction help us describe part of a whole?",
    "learningObjective": "Understand that a fraction represents equal parts of a whole.",
    "lessonContent": "...",
    "guidedPractice": "...",
    "independentPractice": "...",
    "summary": "..."
  }
}
```

### Supported Template Types v1

- `story_lesson`
- `reading_lesson`
- `math_lesson`
- `science_experiment`
- `holiday_lesson`
- `remediation_lesson`

### Supported Block Types v1

- `story`
- `image_placeholder`
- `explanation`
- `question`
- `practice`
- `summary`
- `reading_passage`
- `vocabulary`
- `experiment_step`
- `reflection`
- `remediation_hint`

Student App currently supports a subset:

- `story`
- `imagePlaceholder`
- `explanation`
- `question`
- `practice`
- `summary`

### Presentation Contract Invariants

1. Every block must include:
   - `id`
   - `order`
   - `type`
   - `title`
2. `order` must be sortable and unique within a contract.
3. Unsupported block types must fail validation or render through a safe fallback.
4. Media must be declared explicitly.
5. Contract must include `contractVersion`.
6. Contract must preserve curriculum traceability.

## Review Questions

1. Should generated artifacts be tenant-specific from the beginning, or should TeoryX support global reusable content plus tenant publication references?
2. Should Student App missing-content requests auto-publish valid generated content, or mark it `ready_for_review` until approval?
3. Should School Admin Portal and Student App share the same `requestLessonContent` function with different permission rules?
4. Is Presentation Contract v1 acceptable as the boundary between Content Engine and Student App?
5. Should retry be available to Student App directly, or only through backend/admin workflow?
