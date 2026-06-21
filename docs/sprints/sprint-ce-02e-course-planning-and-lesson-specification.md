# Sprint CE-02E - Course Planning and Lesson Specification Engine

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the Course Planning and Lesson Specification Engine for the TeoryX Content Engine.

This layer creates course maps, unit plans, lesson sequences, and pre-generation lesson specifications before full lesson content exists.

## Problem Statement

At time zero, a school may have no generated lessons yet.

The Student App still needs to show a course lesson list. That list should not be only static titles. Each lesson entry should be a `LessonSpecification` that tells the Content Engine how to generate the future lesson when needed.

`LessonSpecification` is the pre-generation specification.

It must be able to exist before any of these artifacts exist:

- `LessonArtifact`
- `AssessmentArtifact`
- `TutorArtifact`
- `MediaArtifact`
- `PresentationArtifact`

`LessonSpecification` is not full lesson content. It is a generation-ready planning record.

## Scope

This sprint designs:

- `CourseMap`
- `UnitPlan`
- `LessonSpecification`
- `LessonSequence`
- `LessonGenerationStatus`
- Student App lesson-list read behavior
- School Admin authoring behavior
- Firestore collection proposal
- validation and failure scenarios
- recommended next CE sprint

## Non-Scope

This sprint does not implement:

- app code
- Firestore writes
- lesson generation
- assessment generation
- tutor generation
- media generation
- presentation generation
- School Admin Portal UI
- Student App UI changes

## Pipeline Placement

The course planning layer sits after curriculum/analysis/blueprint design and before generation artifacts.

```text
Curriculum Selection
-> Curriculum Standards
-> Pedagogical Analyses
-> Instructional Blueprints
-> CourseMap
-> UnitPlan
-> LessonSpecification
-> ContentGenerationRequest
-> Generation Artifacts
-> publishedLessonContent
```

`LessonSpecification` drives generation.

When full content is missing, the execution pipeline uses the specification to know what lesson should be generated.

## Product Responsibilities

### Student App

Student App may read `LessonSpecification` records to show lesson lists.

Student App behavior:

1. Load lesson specifications for a course.
2. Show lesson list using specification metadata.
3. If `publishedContentId` exists, open the published lesson.
4. If `publishedContentId` is missing, request generation.
5. Wait for `pending`, `ready`, or `failed`.

Student App cannot:

- edit `CourseMap`
- edit `UnitPlan`
- edit `LessonSpecification`
- modify lesson sequence
- approve generated content
- publish generated content
- call AI directly

### School Admin Portal

School Admin Portal may edit `CourseMap`, `UnitPlan`, and `LessonSpecification` through authorized authoring workflows.

School Admin edits must preserve:

- curriculum alignment
- source/version traceability
- blueprint references
- validation rules
- publication workflow rules

School Admin changes do not automatically mutate already published lesson content.

## Domain Model

### CourseMap

Represents the planned structure of a course for a school, curriculum version, grade, subject, and language.

Fields:

```text
id
schoolId
courseId
curriculumSourceId
curriculumVersionId
curriculumId
gradeLevelId
subjectId
language
title
description
unitPlanIds
lessonSpecificationIds
status
createdByUserId
updatedByUserId
createdAt
updatedAt
```

Allowed statuses:

```text
draft
in_review
approved
active
archived
superseded
```

Rules:

1. Must belong to one school/course/curriculum context.
2. Must trace to curriculum source and version.
3. Must not contain full lesson content.
4. May be edited only through authorized School Admin workflows.
5. Student App may read active course maps indirectly through lesson specifications.

### UnitPlan

Represents a planned unit inside a course map.

Fields:

```text
id
courseMapId
schoolId
courseId
unitId
title
description
order
standardIds
pedagogicalAnalysisIds
lessonSpecificationIds
estimatedDuration
status
createdByUserId
updatedByUserId
createdAt
updatedAt
```

Allowed statuses:

```text
draft
in_review
approved
active
archived
superseded
```

Rules:

1. Must belong to one `CourseMap`.
2. Must contain ordered lesson specification references.
3. Must preserve curriculum traceability.
4. Must not contain full generated lesson content.

### LessonSpecification

Represents one planned lesson before generated lesson content exists.

`LessonSpecification` is the pre-generation specification used by Content Engine to create future artifacts.

Fields:

```text
lessonId
schoolId
courseMapId
courseId
unitId
title
order
standardIds
pedagogicalAnalysisIds
learningObjectiveIds
masteryDefinitionIds
assessmentBlueprintIds
lessonBlueprintIds
estimatedDuration
difficultyLevel
languageProfileId
targetSkills
vocabularyTargets
misconceptionTargets
requiredMediaTypes
prerequisiteLessonIds
generationStatus
publishedContentId
status
createdByUserId
updatedByUserId
createdAt
updatedAt
```

Rules:

1. Is not full lesson content.
2. Drives generation.
3. May exist before all CE-02D generation artifacts.
4. Must reference the relevant curriculum, analysis, objective, mastery, assessment, and lesson blueprint records.
5. May be read by Student App for course lesson lists.
6. May be edited only by authorized School Admin workflows.
7. Student App cannot edit it.
8. `publishedContentId` is nullable.
9. If `publishedContentId` exists, it links to `publishedLessonContent/{publishedContentId}`.
10. If `publishedContentId` is missing, Student App can request generation and wait for `pending`, `ready`, or `failed`.

Allowed difficulty levels:

```text
introductory
core
challenging
extension
remediation
```

Allowed statuses:

```text
draft
in_review
approved
active
archived
superseded
```

### LessonSequence

Represents ordering and prerequisite relationships between lesson specifications.

Fields:

```text
id
schoolId
courseMapId
courseId
unitId
lessonIds
sequenceRules
prerequisiteEdges
status
createdAt
updatedAt
```

Rules:

1. Must define stable ordering for Student App lesson lists.
2. Must prevent circular prerequisites.
3. Must support unit-level and course-level sequencing.
4. Must not depend on published content existing.

### LessonGenerationStatus

Represents generation readiness for a lesson specification.

Allowed values:

```text
not_generated
generation_pending
generation_failed
ready_for_review
published
superseded
```

Meaning:

```text
not_generated:
  specification exists, but no generation request is active

generation_pending:
  generation has been requested or is in progress

generation_failed:
  generation failed and may be retried if policy allows

ready_for_review:
  artifacts exist but require review before publication

published:
  publishedContentId exists and points to publishedLessonContent

superseded:
  specification or published content has been replaced by a newer version
```

## Student App Lesson List Flow

The Student App may query lesson specifications for a course.

Example flow:

```text
Course
-> LessonSpecification list
-> selected LessonSpecification
-> if publishedContentId exists, open published lesson
-> if publishedContentId missing, request generation
-> pending/ready/failed
```

The Student App lesson list can show:

- title
- order
- estimated duration
- difficulty level
- generation status
- whether content is available

The Student App must not expose:

- internal artifact ids not needed for reading
- authoring state beyond safe availability status
- raw validation errors
- prompt or AI details

## School Admin Authoring Flow

School Admin Portal may:

1. Create or edit a `CourseMap`.
2. Create or edit `UnitPlan` records.
3. Create or edit `LessonSpecification` records.
4. Reorder lessons.
5. Update prerequisite lesson relationships.
6. Submit plans/specifications for validation.
7. Trigger generation for lesson specifications.
8. Review generated artifacts through later CE workflows.

School Admin edits must be audited.

If a published lesson already exists, changing the specification should not mutate published content. It may instead trigger a new generation or regeneration workflow depending on policy.

## Generation Integration

When `publishedContentId` is missing:

```text
LessonSpecification
-> requestLessonContent
-> ContentGenerationRequest
-> CE-03A Execution Pipeline
-> PresentationArtifact
-> publishedLessonContent
-> LessonSpecification.publishedContentId updated by publication workflow
```

`LessonSpecification` provides the Content Engine with:

- lesson identity
- course/unit placement
- standards
- pedagogical analysis references
- objective/mastery/blueprint references
- target skills
- vocabulary targets
- misconception targets
- media requirements
- prerequisites
- language profile

## Firestore Collection Proposal

Proposed top-level collections:

```text
courseMaps/{courseMapId}
courseMaps/{courseMapId}/unitPlans/{unitPlanId}
lessonSpecifications/{lessonId}
lessonSequences/{lessonSequenceId}
lessonSpecificationRevisions/{revisionId}
courseMapValidationReports/{validationReportId}
```

Optional school-scoped alternative:

```text
schools/{schoolId}/courseMaps/{courseMapId}
schools/{schoolId}/courseMaps/{courseMapId}/unitPlans/{unitPlanId}
schools/{schoolId}/lessonSpecifications/{lessonId}
schools/{schoolId}/lessonSequences/{lessonSequenceId}
```

### courseMaps/{courseMapId}

Recommended indexes:

```text
schoolId + courseId + language + status
schoolId + curriculumSourceId + curriculumVersionId + gradeLevelId + subjectId + status
```

### courseMaps/{courseMapId}/unitPlans/{unitPlanId}

Recommended indexes:

```text
courseId + order + status
unitId + status
```

### lessonSpecifications/{lessonId}

Recommended indexes:

```text
schoolId + courseId + language + order
schoolId + courseId + generationStatus + order
schoolId + unitId + order
publishedContentId
```

### lessonSequences/{lessonSequenceId}

Recommended indexes:

```text
schoolId + courseId + unitId + status
courseMapId + status
```

### lessonSpecificationRevisions/{revisionId}

Tracks authoring changes to lesson specifications.

Fields:

```text
id
lessonId
schoolId
revisionNumber
changedByUserId
changeSummary
fieldChanges
createdAt
```

### courseMapValidationReports/{validationReportId}

Fields:

```text
id
courseMapId
schoolId
status
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

## Publication Link

`LessonSpecification.publishedContentId` links to:

```text
publishedLessonContent/{publishedContentId}
```

Rules:

1. `publishedContentId` may be null before generation/publication.
2. When content is published, the publication workflow may attach the published content id to the lesson specification.
3. Student App opens `publishedLessonContent` when the link exists.
4. Historical publication records remain separate from the lesson specification.
5. Updating a lesson specification must not overwrite historical published content.

## Validation Rules

### CourseMap Validation

Validation must confirm:

- course map has valid school/course/curriculum context
- curriculum source and version are active or allowed
- unit order is stable
- referenced units exist
- status allows Student App visibility only when appropriate

### UnitPlan Validation

Validation must confirm:

- unit belongs to course map
- unit order is unique within course map
- standards exist and match selected curriculum version
- referenced lesson specifications exist

### LessonSpecification Validation

Validation must confirm:

- `lessonId` is unique
- course/unit references are valid
- order is unique within unit or course sequence
- standard references are valid
- pedagogical analysis references are valid
- objective/mastery/blueprint references are valid
- prerequisite lesson ids do not create cycles
- generation status is valid
- `publishedContentId`, when present, points to published content

### Student App Visibility Validation

Validation must confirm:

- Student App only reads active/approved specifications
- Student App cannot edit specifications
- Student App sees safe availability status only
- Student App does not see internal authoring fields unless explicitly allowed

## Failure Scenarios

### Missing Blueprint References

Cause:

- lesson specification references missing CE-02C blueprint records

Result:

- specification validation fails
- generation blocked
- reason: `missing_blueprint_references`

### Invalid Lesson Sequence

Cause:

- duplicate order
- missing lesson id
- circular prerequisites

Result:

- validation fails
- reason: `invalid_lesson_sequence`

### Missing Published Content

Cause:

- `publishedContentId` is null

Result:

- Student App may request generation
- visible status: `pending` after request, or unavailable until requested

### Invalid Published Content Link

Cause:

- `publishedContentId` points to missing, draft, or unpublished content

Result:

- Student App must not open it
- validation fails
- reason: `invalid_published_content_link`

### Unauthorized Edit

Cause:

- Student App or unauthorized user attempts to edit a course map, unit plan, or lesson specification

Result:

- reject edit
- reason: `permission_denied`

### Specification Changed After Publication

Cause:

- School Admin edits lesson specification after content has been published

Result:

- existing published content remains immutable
- future generation/regeneration may create new artifacts
- reason for regeneration must be recorded if triggered

## Governance Rules

1. `LessonSpecification` is not full lesson content.
2. `LessonSpecification` drives generation.
3. `LessonSpecification` may exist before `LessonArtifact`, `AssessmentArtifact`, `TutorArtifact`, `MediaArtifact`, or `PresentationArtifact`.
4. Student App can read `LessonSpecification` for lesson lists.
5. Student App cannot edit `LessonSpecification`.
6. School Admin Portal may edit `CourseMap`, `UnitPlan`, and `LessonSpecification` through authorized authoring workflows.
7. `LessonSpecification.publishedContentId` links to `publishedLessonContent` when available.
8. If `publishedContentId` is missing, Student App requests generation and waits for `pending`, `ready`, or `failed`.
9. Published lesson content history must remain immutable.

## Recommended Next CE Sprint

Recommended next sprint:

```text
CE-03B - API and Cloud Function Contracts
```

Scope:

- define callable functions
- define request and response schemas
- define permission checks
- define idempotency rules
- define status read models
- define emulator/testing strategy
- include LessonSpecification-aware request behavior

Do not implement app code in the next sprint unless explicitly approved.

## Open Questions

1. Should `lessonSpecifications` be top-level for query simplicity or school-scoped for tenant locality?
2. Should CourseMap and UnitPlan become visible to Student App directly, or should Student App read only flattened LessonSpecification records?
3. Should `publishedContentId` be updated on the specification or resolved through a separate publication lookup?
4. Should a LessonSpecification support multiple standards in MVP, or should v1 encourage one primary standard plus related standards?
5. Should course maps be generated automatically from curriculum standards, authored by School Admin, or both?
6. Should lesson specifications support multiple languages as separate documents or as localized fields?
