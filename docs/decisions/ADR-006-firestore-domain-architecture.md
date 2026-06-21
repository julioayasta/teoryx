# ADR-006: Firestore Domain Architecture

## Status

Accepted

## Date

2026-06

## Context

TeoryX will use Firebase Firestore as its primary database.

The domain architecture has already defined:

- Multi-tenant SaaS model
- Curriculum-first learning model
- AI-generated lessons
- Bounded Contexts
- K-12 ready curriculum architecture

Firestore must reflect the domain model without exposing infrastructure concerns to the UI or domain layer.

---

# Decision

Firestore collections will be organized according to TeoryX bounded contexts.

The database model must support:

- global curriculum content
- tenant-specific school data
- student-specific progress
- AI-generated learning content
- multi-language content
- future scalability

---

# Firestore Ownership Model

## Global Data

Global data is shared across all schools.

Examples:

- curriculums
- grade_levels
- subjects
- standards
- units
- global lessons
- global assessments
- tutor prompts

Global data does not belong to a specific school.

---

## Tenant Data

Tenant data belongs to a school.

All tenant-owned records must include:

- schoolId

Examples:

- users
- students
- parents
- progress
- assessment_attempts
- tutor_sessions

---

# Proposed Collections

## Identity Context

### schools

Represents tenant schools.

Fields:

- id
- name
- logoUrl
- primaryColor
- secondaryColor
- status
- createdAt
- updatedAt

---

### users

Represents authenticated application users.

Fields:

- id
- schoolId
- email
- role
- status
- createdAt
- updatedAt

Roles:

- super_admin
- school_admin
- parent
- student

---

### students

Represents student profiles.

Fields:

- id
- schoolId
- userId
- firstName
- lastName
- gradeLevelId
- preferredLanguage
- status
- createdAt
- updatedAt

---

### parents

Represents parent or guardian profiles.

Fields:

- id
- schoolId
- userId
- firstName
- lastName
- studentIds
- status
- createdAt
- updatedAt

---

# Curriculum Context

### curriculums

Fields:

- id
- name
- country
- state
- version
- status
- createdAt
- updatedAt

---

### grade_levels

Fields:

- id
- code
- name
- order
- status

Examples:

- K
- G1
- G2
- G3
- ...
- G12

---

### subjects

Fields:

- id
- code
- name
- status

Examples:

- math
- ela
- science
- history

---

### standards

Fields:

- id
- curriculumId
- gradeLevelId
- subjectId
- code
- description
- strand
- domain
- cluster
- status

Example:

- CCSS.MATH.4.NF.A.1

---

### units

Fields:

- id
- curriculumId
- gradeLevelId
- subjectId
- title
- description
- standardIds
- order
- status

---

# Learning Context

### learning_objectives

Fields:

- id
- standardId
- objectiveText
- language
- difficultyLevel
- status
- createdAt
- updatedAt

---

### lessons

Fields:

- id
- curriculumId
- gradeLevelId
- subjectId
- standardId
- learningObjectiveId
- language
- title
- bigIdea
- essentialQuestion
- desiredUnderstanding
- explanation
- examples
- guidedPractice
- independentPractice
- summary
- aiGenerated
- version
- status
- createdAt
- updatedAt

Status:

- draft
- review
- published
- archived

---

### assessments

Fields:

- id
- lessonId
- learningObjectiveId
- title
- assessmentType
- passingScore
- masteryThreshold
- status
- createdAt
- updatedAt

---

### questions

Fields:

- id
- assessmentId
- questionText
- questionType
- answerOptions
- correctAnswer
- explanation
- difficultyLevel
- createdAt
- updatedAt

---

### tutor_prompts

Fields:

- id
- lessonId
- language
- systemPrompt
- behaviorRules
- safetyRules
- version
- status
- createdAt
- updatedAt

---

# Student Context

### progress

Fields:

- id
- schoolId
- studentId
- curriculumId
- gradeLevelId
- subjectId
- standardId
- lessonId
- assessmentId
- completionPercentage
- masteryLevel
- lastScore
- attemptsCount
- lastActivityAt
- createdAt
- updatedAt

Mastery Levels:

- not_started
- in_progress
- developing
- proficient
- mastered

---

### assessment_attempts

Fields:

- id
- schoolId
- studentId
- assessmentId
- lessonId
- standardId
- score
- answers
- completedAt
- createdAt

---

### tutor_sessions

Fields:

- id
- schoolId
- studentId
- lessonId
- standardId
- language
- startedAt
- endedAt
- summary
- createdAt

---

# Collection Naming Rule

Use lowercase snake_case for Firestore collections.

Examples:

Good:

- grade_levels
- learning_objectives
- assessment_attempts

Bad:

- gradeLevels
- LearningObjectives
- assessmentAttempts

---

# Document ID Strategy

Use generated IDs for most records.

Use official standard code as a field, not as the document ID.

Reason:

- standard codes may contain dots
- future curricula may use different formats
- document IDs should remain stable and system-controlled

---

# Query Strategy

All tenant queries must filter by:

- schoolId

Example:

Find progress by student:

progress
where schoolId == currentSchoolId
where studentId == currentStudentId

---

# Security Rule Principle

Client-side role checks are not enough.

Firestore Security Rules must enforce:

- school ownership
- user role access
- super_admin global access
- parent access only to linked students
- student access only to own data

---

# Denormalization Strategy

Firestore is document-oriented.

Some denormalization is acceptable.

Examples:

Progress stores:

- curriculumId
- gradeLevelId
- subjectId
- standardId
- lessonId

Reason:

- easier queries
- fewer reads
- better dashboard performance

---

# Avoid

Do not create deeply nested collections for core entities during MVP.

Avoid:

schools/{schoolId}/students/{studentId}/progress/{progressId}

Prefer top-level collections with schoolId fields for easier querying and future analytics.

---

# Future Considerations

- BigQuery export
- Analytics pipelines
- Curriculum import tooling
- Firestore composite indexes
- Cloud Functions for secure writes
- Content versioning
- School-specific lesson overrides

---

# Guiding Principle

Firestore serves the domain.

The domain must not be redesigned around Firestore limitations.

Use Firestore pragmatically while preserving TeoryX domain boundaries.
