# Sprint CE-03C - Emulator-First Content Engine Contract Tests

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the emulator-first validation strategy for the Content Engine MVP before CE-04 implementation begins.

CE-03C is the final validation design before implementation. CE-04 must not start until these contract tests are defined, reviewed, and accepted.

## Scope

This sprint designs:

- test principles
- emulator architecture
- seed data strategy
- fake worker strategy
- permission matrix tests
- idempotency tests
- course availability tests
- `LessonSpecification` tests
- Student App pending/ready/failed tests
- audit/provenance tests
- publication workflow tests
- failure and retry tests
- CE-04 acceptance criteria

## Non-Scope

This sprint does not implement:

- app code
- Cloud Functions
- Firestore writes
- AI provider calls
- worker runtime
- queue runtime
- Student App changes
- School Portal changes
- Super Admin Portal changes

## Test Principles

### Emulator First

Content Engine API and workflow contracts should be validated in the Firebase Emulator Suite before production infrastructure is implemented.

The emulator test suite becomes the executable contract for CE-04.

### Contract Before Implementation

The tests should define expected behavior before Cloud Functions are implemented.

CE-04 implementation should satisfy these tests rather than reinterpret the architecture.

### No Real AI Calls

All generation, validation, publication, and queue behavior must be simulated with deterministic fakes.

Tests must not call external AI providers.

### Role-Aware Outputs

The same request or status record may expose different information depending on caller role.

Student App must see only:

```text
pending
ready
failed
```

School Portal may see authoring/review states.

Super Admin may see governance and audit detail.

### Mutations Must Be Auditable

Every mutating callable function must be tested for required audit/provenance side effects.

Mutating functions include:

- `requestCoursePlanGeneration`
- `publishCourseOffering`
- `requestLessonContent`
- `requestSchoolLessonGeneration`
- `requestArtifactRegeneration`
- `approveArtifactForPublication`
- `publishValidatedArtifact`

### Published Content Before Duplicate Generation

Existing `publishedLessonContent` must be returned before creating duplicate generation work.

This rule must be tested for Student App and School Portal flows.

## Emulator Architecture

Use Firebase Emulator Suite as the local contract validation environment.

Recommended emulators:

```text
Firestore Emulator
Auth Emulator
Functions Emulator
```

CE-03C does not implement Cloud Functions, but the contract test design assumes CE-04 will run callable functions against these emulators.

## Emulator Components

### Firestore Emulator

Stores seeded test documents for:

- schools
- curriculum selections
- curriculum sources and versions
- curriculum standards
- course offerings
- course maps
- unit plans
- lesson specifications
- generation requests
- jobs
- artifacts
- validation artifacts
- publication records
- published lesson content
- audit records
- provenance records
- version history records
- cost records
- prompt execution records

### Auth Emulator

Provides deterministic users and custom claims for:

- Student App caller
- School Portal planner
- School Portal publisher
- School Portal reviewer
- Super Admin
- System/service identity
- unauthorized user
- cross-school user

### Functions Emulator

Runs callable function contracts in CE-04.

In CE-03C, the expected functions are:

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

## Seed Data Strategy

Seed data should be deterministic, small, and intentionally varied.

Each seed scenario should be named and documented so failed tests point to a contract decision, not a mystery fixture.

## Core Seed Set

### Schools

```text
school-demo
school-other
```

### Users

```text
student-demo-001
school-planner-001
school-reviewer-001
school-publisher-001
super-admin-001
system-worker-001
unauthorized-001
cross-school-user-001
```

### Curriculum

Seed:

- active curriculum source
- active curriculum version
- active curriculum standard
- school curriculum selection

Required fields:

```text
curriculumSourceId
curriculumVersionId
standardId
standardCode
sourceVersion
sourceReference
status
```

### Course Availability Scenarios

Seed these scenarios:

```text
available_course:
  CourseOffering enabled
  CourseMap valid
  UnitPlans valid
  LessonSpecifications valid

course_record_only:
  Course exists
  no CourseOffering

offering_without_course_map:
  CourseOffering enabled
  CourseMap missing

course_map_without_units:
  CourseOffering enabled
  CourseMap valid
  UnitPlans missing

course_map_without_lesson_specs:
  CourseOffering enabled
  CourseMap valid
  UnitPlans valid
  LessonSpecifications missing

disabled_offering:
  CourseOffering disabled
  planning records valid

wrong_language_offering:
  CourseOffering valid
  language does not match request
```

### Lesson Specification Scenarios

Seed:

```text
published_lesson_spec:
  valid LessonSpecification
  publishedContentId present
  publishedLessonContent exists

missing_content_lesson_spec:
  valid LessonSpecification
  publishedContentId null

invalid_lesson_spec:
  missing required blueprint references

inactive_lesson_spec:
  status not active/approved

cross_course_lesson_spec:
  valid specification belonging to another course
```

### Generation Request Scenarios

Seed:

```text
pending_student_request
ready_student_request
failed_student_request
ready_for_review_school_request
validation_failed_school_request
published_school_request
```

### Artifact Package Scenarios

Seed:

```text
valid_minimum_publishable_package:
  LessonArtifact valid
  PresentationArtifact valid
  ValidationArtifact valid

missing_lesson_artifact_package:
  PresentationArtifact valid
  ValidationArtifact valid
  LessonArtifact missing

invalid_presentation_package:
  PresentationArtifact invalid
  ValidationArtifact invalid

unsupported_student_app_block_package:
  PresentationArtifact contains unsupported unsafe block
```

## Fake Worker Strategy

Fake workers simulate the CE-03A runtime pipeline without AI calls or real queue infrastructure.

### Fake Course Plan Worker

Simulates:

- CourseMap creation
- UnitPlan creation
- LessonSpecification creation
- validation success
- validation failure
- partial failure

Outputs deterministic records into emulator data.

### Fake Content Generation Worker

Simulates:

- `LessonArtifact`
- optional `AssessmentArtifact`
- optional `TutorArtifact`
- optional `MediaArtifact`
- `PresentationArtifact`

It must create deterministic artifact ids and versions.

### Fake Validation Worker

Simulates:

- valid package
- valid with allowed warnings
- invalid package
- unsupported presentation contract
- unsafe tutor artifact
- missing minimum publishable package

### Fake Publication Worker

Simulates:

- mapping valid `PresentationArtifact` into `publishedLessonContent`
- updating `LessonSpecification.publishedContentId`
- writing `ArtifactPublicationRecord`
- writing audit/provenance/version records
- publication failure

### Fake Retry Worker

Simulates:

- retryable transient failure
- non-retryable contract failure
- max attempts reached
- dead-letter state

## Permission Matrix Tests

Permission tests must validate every callable function by caller type.

Expected matrix:

```text
Function                         Student App  School Portal  Super Admin  System
requestCoursePlanGeneration      denied       allowed        allowed      optional
getCoursePlanStatus              denied       allowed        allowed      allowed
publishCourseOffering            denied       role-based     allowed      denied
getLessonSpecificationsForCourse allowed      allowed        allowed      denied
requestLessonContent             allowed      denied         denied       denied
getContentGenerationStatus       filtered     allowed        allowed      allowed
requestSchoolLessonGeneration    denied       allowed        allowed      optional
requestArtifactRegeneration      denied       allowed        allowed      allowed
approveArtifactForPublication    denied       role-based     allowed      denied
publishValidatedArtifact         denied       role-based     allowed      policy-only
```

Tests must include:

- unauthenticated caller
- authenticated but unauthorized caller
- cross-school caller
- student attempting School Portal functions
- School Portal caller attempting Student App-only function
- user with read permission but no publish permission
- Super Admin governance access

## Idempotency Tests

Idempotency tests must validate:

1. Existing `publishedLessonContent` returns `ready` before new generation.
2. Duplicate `requestLessonContent` calls reuse the same pending request.
3. Duplicate course plan requests reuse or reject according to canonical key.
4. Duplicate approval calls do not create duplicate approvals.
5. Duplicate publication calls do not create duplicate active published content.
6. Permission failures are not hidden by idempotency reuse.

Canonical keys should include:

```text
schoolId
action or intent
primary target id
language when applicable
```

For `requestLessonContent`, the primary target id is:

```text
lessonSpecificationId
```

## Course Availability Tests

These tests validate that course records alone never make a course visible to Student App.

Test cases:

1. Course record exists but no `CourseOffering` returns unavailable.
2. `CourseOffering` exists but disabled returns unavailable.
3. `CourseOffering` enabled but missing `CourseMap` returns unavailable.
4. `CourseMap` valid but missing `UnitPlans` returns unavailable.
5. `UnitPlans` valid but missing `LessonSpecifications` returns unavailable.
6. All planning records valid returns course available.
7. Language mismatch returns unavailable.
8. Cross-school offering is hidden.

Student App must never see authoring-only fields while checking availability.

## LessonSpecification Tests

These tests validate `LessonSpecification` as the pre-generation lesson list and generation input.

Test cases:

1. `getLessonSpecificationsForCourse` returns read models, not full lesson content.
2. Returned read models include safe fields such as title, order, duration, difficulty, generation status, and `publishedContentId`.
3. Returned read models omit internal authoring fields, prompt data, raw blueprint detail, and audit records.
4. Inactive specifications are hidden from Student App.
5. Invalid specifications block generation.
6. `requestLessonContent` requires `lessonSpecificationId`.
7. `lessonId` may be accepted only as a display/domain alias.
8. Generation context resolves from `LessonSpecification`, not arbitrary Student App curriculum input.

## Student App Pending/Ready/Failed Tests

Student App status tests must validate strict status filtering.

### requestLessonContent

Cases:

```text
publishedContentId exists -> ready
valid missing content -> pending
invalid lesson specification -> failed
permission denied -> failed with safe message
```

### getContentGenerationStatus

Internal statuses must map to Student App statuses:

```text
created -> pending
validating_request -> pending
resolving_curriculum -> pending
resolving_blueprints -> pending
generating_lesson_artifact -> pending
validating_artifacts -> pending
ready_for_review -> pending or failed by policy
published -> ready
ready -> ready
failed -> failed
```

Student App must not receive:

- draft
- generating
- validation_failed
- ready_for_review
- approved
- published as an authoring state
- artifact ids not needed for consumption
- raw worker errors
- provider details
- cost details
- prompt execution details

## Audit and Provenance Tests

Every mutating function must write required records.

Test expectations:

```text
requestCoursePlanGeneration:
  GenerationAuditEntry
  ProvenanceRecord for planning outputs when produced
  VersionHistory for CourseMap/UnitPlan/LessonSpecification

publishCourseOffering:
  GenerationAuditEntry
  ProvenanceRecord for CourseOffering
  VersionHistory

requestLessonContent:
  GenerationAuditEntry when new request is created
  no duplicate audit entry when pending request is reused unless policy records access

requestSchoolLessonGeneration:
  GenerationAuditEntry
  ProvenanceRecord for generated artifacts
  PromptExecutionRecord when prompt-backed fake worker is simulated
  CostTrackingRecord when provider-backed fake cost is simulated

requestArtifactRegeneration:
  GenerationAuditEntry
  VersionHistory
  ProvenanceRecord

approveArtifactForPublication:
  GenerationAuditEntry
  VersionHistory

publishValidatedArtifact:
  GenerationAuditEntry
  ProvenanceRecord for publishedLessonContent
  VersionHistory
  ArtifactPublicationRecord
```

Audit records must be append-only.

Student App must not read audit/provenance internals.

## Publication Workflow Tests

Publication tests validate:

1. `draft` mode does not publish.
2. `require_review` moves artifacts to `ready_for_review`, not published.
3. `auto_publish_after_validation` publishes only if validation passes and policy allows.
4. Invalid artifacts cannot be approved.
5. Unapproved artifacts cannot be published when review is required.
6. Publication requires the minimum publishable package.
7. `PresentationArtifact` maps into `publishedLessonContent`.
8. Publication writes an `ArtifactPublicationRecord`.
9. Publication updates `LessonSpecification.publishedContentId` when policy allows.
10. Publication preserves historical records.
11. Re-publication creates a new version or supersession record, not mutation of history.

Minimum publishable package:

```text
LessonArtifact
PresentationArtifact
ValidationArtifact
publishedLessonContent
```

Optional artifacts become required only when referenced:

```text
TutorArtifact
MediaArtifact
AssessmentArtifact
```

## Failure and Retry Tests

Failure tests should cover retryable and non-retryable categories.

### Retryable

Test:

- transient fake worker failure
- temporary Firestore failure simulation
- queue timeout simulation
- publication mapping transient failure

Expected:

- retry event written
- stage execution attempt increments
- request remains pending until terminal outcome
- max attempts creates dead-letter state
- Student App sees only pending or failed

### Non-Retryable

Test:

- permission denied
- missing required context
- missing curriculum selection
- missing standard
- invalid `LessonSpecification`
- validation failure
- minimum publishable package missing
- unsupported presentation contract

Expected:

- no retry scheduled
- failure event written
- request moves to failed or authoring-visible failure
- Student App receives safe failed response
- School Portal receives actionable detail

## Contract Test Inventory

CE-04 should implement tests for:

- all callable function permissions
- all request schemas
- all response schemas
- Student App response filtering
- School Portal authoring status visibility
- Super Admin governance visibility
- course availability gating
- `LessonSpecification` read models
- `lessonSpecificationId` primary generation input
- idempotency reuse
- audit/provenance writes
- publication mode behavior
- minimum publishable package validation
- fake worker success path
- fake worker failure path
- retry and dead-letter behavior

## Acceptance Criteria for CE-04 Implementation

CE-04 may begin only after CE-03C contract tests are defined.

CE-04 implementation is ready when:

1. Emulator seed data is documented and reproducible.
2. Auth test users and claims are documented.
3. Callable function test cases are listed.
4. Student App visibility restrictions are testable.
5. School Portal permissions are testable.
6. Super Admin permissions are testable.
7. Idempotency behavior is testable.
8. Audit/provenance side effects are testable.
9. Publication workflow is testable.
10. Failure/retry behavior is testable.
11. Fake workers avoid all real AI calls.
12. Tests can run locally against emulators.

CE-04 should not introduce production behavior that lacks a corresponding emulator contract test.

## Recommended CE-04 Scope

Recommended next sprint:

```text
CE-04 - Emulator Contract Test Harness and Minimal Callable Function Skeleton
```

Scope:

- configure Firebase Emulator test harness
- create deterministic seed scripts
- create fake auth users/claims
- create callable function skeletons
- implement fake worker adapters
- implement contract tests before real generation
- verify no real AI provider calls are possible

CE-04 should still avoid real AI generation.

## Open Questions

1. Should emulator seed data be stored as JSON fixtures, TypeScript builders, or both?
2. Should CE-04 use Firestore-triggered fake jobs or direct fake worker calls from callable functions?
3. Should Student App `ready_for_review` policy map to long-lived `pending` or a friendly unavailable/failed state after timeout?
4. Should audit/provenance assertions require exact document counts or only required linked records?
5. Should cost tracking be simulated in all fake generation tests or only provider-backed fake stages?
6. Should dead-letter recovery be included in CE-04 or deferred to a later operations sprint?
