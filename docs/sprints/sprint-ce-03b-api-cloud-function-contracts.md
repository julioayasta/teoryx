# Sprint CE-03B - API and Cloud Function Contracts

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design API and Cloud Function contracts for the Content Engine MVP.

This sprint defines callable functions, request schemas, response schemas, permission checks, idempotency rules, status read models, audit/provenance requirements, and emulator/testing strategy.

## Scope

This sprint designs:

- callable functions
- request schemas
- response schemas
- permission checks
- idempotency rules
- status read models
- audit/provenance requirements
- emulator/testing strategy

## Non-Scope

This sprint does not implement:

- app code
- Cloud Functions
- Firestore writes
- AI provider calls
- Student App changes
- School Portal changes
- Super Admin Portal changes

## API Principles

### Course Availability

A course record alone is never enough for Student App availability.

Student App may see a course only when the backend confirms:

```text
CourseOffering.enabledForStudents = true
CourseOffering.status = enabled
CourseOffering.courseMapId points to valid CourseMap
CourseMap has valid UnitPlans
CourseMap has valid LessonSpecifications
```

### Student App Boundary

Student App can:

- read available courses
- read `LessonSpecification` read models
- request missing lesson content
- read `pending`, `ready`, or `failed` status
- consume `publishedLessonContent`

Student App cannot:

- edit content
- approve content
- publish content
- change curriculum
- edit course plans
- edit lesson specifications
- call AI directly
- read draft artifacts
- read internal authoring states

### School Portal Boundary

School Portal owns:

- course plan generation
- course plan review
- course plan editing
- lesson specification editing
- school lesson generation requests
- authorized artifact regeneration requests
- publish/enable course offering workflows

### Super Admin Boundary

Super Admin owns:

- global governance
- review policy
- curriculum governance
- publication governance
- high-risk approval workflows

### Auditability

Every mutating function must write audit/provenance records.

Depending on action, mutating functions may write:

- `GenerationAuditEntry`
- `ProvenanceRecord`
- `VersionHistory`
- `CostTrackingRecord`
- `PromptExecutionRecord`

## Shared Request Metadata

All callable functions should receive auth context from Firebase Auth or backend service identity.

All mutating requests should include:

```text
schoolId
requestedByUserId from auth context
source
idempotencyKey
```

The client may send `idempotencyKey`, but the backend must validate or derive the canonical key.

## Shared Response Envelope

Standard success response shape:

```json
{
  "status": "ready",
  "message": "Operation completed.",
  "data": {}
}
```

Standard pending response shape:

```json
{
  "status": "pending",
  "requestId": "request-id",
  "message": "Request is being processed.",
  "data": {}
}
```

Standard failure response shape:

```json
{
  "status": "failed",
  "errorCode": "permission_denied",
  "message": "You do not have permission to perform this action."
}
```

Student App responses must expose only:

```text
pending
ready
failed
```

## Function List

MVP callable functions:

```text
requestCoursePlanGeneration
getCoursePlanStatus
publishCourseOffering
getLessonSpecificationsForCourse
requestLessonContent
getContentGenerationStatus
requestSchoolLessonGeneration
requestArtifactRegeneration
approveArtifactForPublication
publishValidatedArtifact
```

## Function Contracts

### 1. requestCoursePlanGeneration

Caller:

- School Portal
- Super Admin when acting on behalf of a school

Purpose:

Request generation of:

- `CourseMap`
- `UnitPlan` records
- `LessonSpecification` records

Request:

```json
{
  "schoolId": "school-demo",
  "courseId": "grade-4-math",
  "curriculumSourceId": "ca-common-core-math",
  "curriculumVersionId": "ca-common-core-math-2025",
  "gradeLevelId": "grade-4",
  "subjectId": "math",
  "language": "en",
  "publicationMode": "require_review",
  "idempotencyKey": "school-demo:course-plan:grade-4-math:en"
}
```

Response:

```json
{
  "status": "pending",
  "requestId": "course-plan-request-id",
  "courseMapId": null,
  "message": "Course plan generation has started."
}
```

Permission checks:

- caller must belong to school or have Super Admin authority
- caller must have course planning permission
- selected curriculum version must be allowed for school

Idempotency:

```text
schoolId:course-plan:courseId:curriculumVersionId:language
```

Audit/provenance:

- create `GenerationAuditEntry`
- create or update `VersionHistory` when planning records are produced
- create `ProvenanceRecord` for generated planning outputs

### 2. getCoursePlanStatus

Caller:

- School Portal
- Super Admin

Purpose:

Read status for course plan generation.

Request:

```json
{
  "schoolId": "school-demo",
  "requestId": "course-plan-request-id"
}
```

Response:

```json
{
  "status": "ready_for_review",
  "requestId": "course-plan-request-id",
  "courseMapId": "course-map-id",
  "courseMapVersion": "1.0",
  "unitPlanCount": 4,
  "lessonSpecificationCount": 24,
  "message": "Course plan is ready for review."
}
```

Permission checks:

- caller must have school planning/review permission or Super Admin authority

### 3. publishCourseOffering

Caller:

- School Portal authorized publisher
- Super Admin

Purpose:

Enable a course for Student App after valid planning records exist.

Request:

```json
{
  "schoolId": "school-demo",
  "courseId": "grade-4-math",
  "courseMapId": "course-map-id",
  "courseMapVersion": "1.0",
  "language": "en",
  "idempotencyKey": "school-demo:publish-course-offering:grade-4-math:en"
}
```

Response:

```json
{
  "status": "published",
  "courseOfferingId": "course-offering-id",
  "enabledForStudents": true,
  "message": "Course is now available to students."
}
```

Validation:

- valid `CourseMap`
- valid `UnitPlans`
- valid `LessonSpecifications`
- course offering matches school/grade/subject/language

Permission checks:

- caller must have publish/enable course permission

Audit/provenance:

- create `GenerationAuditEntry` for publication/enable event
- create `ProvenanceRecord` for `CourseOffering`
- create `VersionHistory` for course offering state change

### 4. getLessonSpecificationsForCourse

Caller:

- Student App
- School Portal
- Super Admin

Purpose:

Return `LessonSpecification` read models for an available course.

This function returns `LessonSpecification` read models, not full lesson content.

Request:

```json
{
  "schoolId": "school-demo",
  "courseOfferingId": "course-offering-id",
  "courseId": "grade-4-math",
  "language": "en"
}
```

Student App response:

```json
{
  "status": "ready",
  "courseId": "grade-4-math",
  "courseOfferingId": "course-offering-id",
  "lessons": [
    {
      "lessonSpecificationId": "lesson-spec-001",
      "lessonId": "lesson-001",
      "title": "Comparing Fractions",
      "order": 1,
      "estimatedDuration": "20m",
      "difficultyLevel": "core",
      "generationStatus": "published",
      "publishedContentId": "published-content-id"
    }
  ]
}
```

Rules:

- course must be available through `CourseOffering`
- course must have valid planning records
- Student App response must omit internal authoring fields
- no full lesson content is returned

### 5. requestLessonContent

Caller:

- Student App

Purpose:

Request missing lesson content for a lesson specification.

`requestLessonContent` must use `lessonSpecificationId` as the primary input.

`lessonId` may exist as a display/domain alias, but generation starts from `LessonSpecification`.

Request:

```json
{
  "schoolId": "school-demo",
  "courseOfferingId": "course-offering-id",
  "courseId": "grade-4-math",
  "lessonSpecificationId": "lesson-spec-001",
  "lessonId": "lesson-001",
  "language": "en",
  "idempotencyKey": "school-demo:lesson-content:lesson-spec-001:en"
}
```

Response if already published:

```json
{
  "status": "ready",
  "requestId": null,
  "publishedContentId": "published-content-id",
  "message": "Lesson is ready."
}
```

Response if generation starts:

```json
{
  "status": "pending",
  "requestId": "content-request-id",
  "publishedContentId": null,
  "message": "Getting your lesson ready."
}
```

Permission checks:

- caller must be allowed to access school/course offering
- course offering must be enabled for students
- lesson specification must be valid and active

Rules:

- existing `publishedContentId` must be returned before generation
- Student App cannot choose arbitrary curriculum identifiers
- backend resolves curriculum, standards, blueprints, and generation context from `LessonSpecification`
- Student App must not call AI directly

Idempotency:

```text
schoolId:lesson-content:lessonSpecificationId:language
```

Audit/provenance:

- create `GenerationAuditEntry` when new request is created
- reuse existing pending request when idempotency matches

### 6. getContentGenerationStatus

Caller:

- Student App
- School Portal
- Super Admin

Purpose:

Read generation status with role-appropriate filtering.

Request:

```json
{
  "schoolId": "school-demo",
  "requestId": "content-request-id"
}
```

Student App response:

```json
{
  "status": "pending",
  "requestId": "content-request-id",
  "publishedContentId": null,
  "message": "Getting your lesson ready."
}
```

School Portal response:

```json
{
  "status": "ready_for_review",
  "requestId": "content-request-id",
  "stage": "validating_artifacts",
  "artifactIds": {
    "lessonArtifactId": "lesson-artifact-id",
    "presentationArtifactId": "presentation-artifact-id"
  },
  "validationArtifactId": "validation-artifact-id"
}
```

Rules:

- Student App sees only `pending`, `ready`, or `failed`
- School Portal may see authoring/review status
- Super Admin may see governance and audit status

### 7. requestSchoolLessonGeneration

Caller:

- School Portal
- Super Admin

Purpose:

Request create/update/regenerate lesson generation through authoring workflow.

Request:

```json
{
  "schoolId": "school-demo",
  "courseId": "grade-4-math",
  "lessonSpecificationId": "lesson-spec-001",
  "intent": "create_new",
  "publicationMode": "require_review",
  "idempotencyKey": "school-demo:school-lesson-generation:lesson-spec-001:create_new:en"
}
```

Response:

```json
{
  "status": "pending",
  "requestId": "content-request-id",
  "message": "Lesson generation has started."
}
```

Rules:

- starts from `LessonSpecification`
- supports School Portal authoring states
- may produce draft or ready-for-review artifacts
- cannot silently publish unless policy allows

Audit/provenance:

- create `GenerationAuditEntry`
- create `ProvenanceRecord` for generated artifacts
- create `PromptExecutionRecord` and `CostTrackingRecord` during provider-backed stages

### 8. requestArtifactRegeneration

Caller:

- School Portal
- Super Admin
- System

Purpose:

Request a new version of an artifact.

Request:

```json
{
  "schoolId": "school-demo",
  "artifactType": "lesson",
  "artifactId": "lesson-artifact-id",
  "artifactVersion": "1.0",
  "reason": "school_edit_requested",
  "idempotencyKey": "school-demo:regenerate:lesson-artifact-id:1.0"
}
```

Response:

```json
{
  "status": "pending",
  "regenerationRequestId": "regeneration-request-id",
  "message": "Artifact regeneration has started."
}
```

Rules:

- regeneration creates a new version
- published history is immutable
- downstream artifacts may become stale

Audit/provenance:

- create `GenerationAuditEntry`
- create `VersionHistory`
- create `ProvenanceRecord` for new artifact version

### 9. approveArtifactForPublication

Caller:

- authorized School Portal approver
- Super Admin

Purpose:

Approve a validated artifact for publication.

Request:

```json
{
  "schoolId": "school-demo",
  "artifactType": "presentation",
  "artifactId": "presentation-artifact-id",
  "artifactVersion": "1.0",
  "validationArtifactId": "validation-artifact-id",
  "decision": "approve",
  "reviewNotes": "Approved for Grade 4 Math.",
  "idempotencyKey": "school-demo:approve:presentation-artifact-id:1.0"
}
```

Response:

```json
{
  "status": "approved",
  "artifactId": "presentation-artifact-id",
  "artifactVersion": "1.0",
  "message": "Artifact approved for publication."
}
```

Rules:

- invalid artifacts cannot be approved
- reviewer role must satisfy risk policy
- approval must not publish by itself unless explicitly combined by future policy

Audit/provenance:

- create `GenerationAuditEntry`
- create `VersionHistory` entry

### 10. publishValidatedArtifact

Caller:

- authorized publisher
- Super Admin
- System when policy allows auto-publish

Purpose:

Publish a validated and approved `PresentationArtifact`.

`publishValidatedArtifact` maps `PresentationArtifact` into:

```text
publishedLessonContent/{publishedContentId}
```

Request:

```json
{
  "schoolId": "school-demo",
  "presentationArtifactId": "presentation-artifact-id",
  "presentationArtifactVersion": "1.0",
  "lessonSpecificationId": "lesson-spec-001",
  "publicationMode": "require_review",
  "idempotencyKey": "school-demo:publish:presentation-artifact-id:1.0"
}
```

Response:

```json
{
  "status": "published",
  "publishedContentId": "published-content-id",
  "presentationArtifactId": "presentation-artifact-id",
  "message": "Lesson content has been published."
}
```

Rules:

- publication requires valid minimum publishable package
- publication requires valid `PresentationArtifact`
- publication requires valid `ValidationArtifact`
- publication must respect risk/review policy
- publication updates or creates `publishedLessonContent`
- publication may update `LessonSpecification.publishedContentId`
- publication must preserve historical publication records

Audit/provenance:

- create `GenerationAuditEntry`
- create `ProvenanceRecord`
- create `VersionHistory`

## Permission Matrix

```text
Function                         Student App  School Portal  Super Admin  System
requestCoursePlanGeneration      no           yes            yes          optional
getCoursePlanStatus              no           yes            yes          yes
publishCourseOffering            no           yes            yes          no
getLessonSpecificationsForCourse yes          yes            yes          no
requestLessonContent             yes          no             no           no
getContentGenerationStatus       filtered     yes            yes          yes
requestSchoolLessonGeneration    no           yes            yes          optional
requestArtifactRegeneration      no           yes            yes          yes
approveArtifactForPublication    no           role-based     yes          no
publishValidatedArtifact         no           role-based     yes          policy-only
```

## Idempotency Rules

1. Existing published content must be returned before creating generation work.
2. Active pending requests must be reused when idempotency key matches.
3. Idempotency keys must include `schoolId`, intent/action, primary target id, and language when applicable.
4. Backend must derive or verify canonical idempotency keys.
5. Idempotency must not hide permission failures.

## Status Read Models

### Student App

Allowed statuses:

```text
pending
ready
failed
```

### School Portal

Allowed statuses:

```text
draft
generating
validation_failed
ready_for_review
approved
published
failed
```

### Super Admin

Super Admin may see:

- detailed request status
- stage status
- audit records
- failure records
- publication records
- cost records

## Emulator and Testing Strategy

Use Firebase Emulator Suite for local contract validation.

Testing should include:

- permission checks for all functions
- Student App status filtering
- course availability gating
- `lessonSpecificationId`-based `requestLessonContent`
- idempotency reuse
- audit/provenance writes for mutating functions
- publication minimum package validation
- failure responses
- no real AI provider calls

Recommended fakes:

- fake orchestrator
- fake generation worker
- fake validation worker
- fake publication worker
- seeded Firestore data for course offerings, course maps, lesson specifications, and published content

## Failure Codes

Common failure codes:

```text
permission_denied
missing_required_context
course_not_available
course_plan_not_found
lesson_specification_not_found
invalid_lesson_specification
published_content_not_found
generation_already_pending
rate_limit_exceeded
cost_policy_exceeded
validation_failed
minimum_publishable_package_missing
publication_denied
publication_failed
```

## CE-03C Recommendation

Recommended next sprint:

```text
CE-03C - Emulator-First Content Engine Contract Tests
```

Scope:

- define emulator seed data
- define callable function test cases
- define permission test matrix
- define idempotency tests
- define Student App status filtering tests
- define audit/provenance write tests
- define no-real-AI fake worker strategy

Do not implement app code in CE-03C unless explicitly approved.
