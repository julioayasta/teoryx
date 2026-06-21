# TeoryX Curriculum Domain Model v0.1

## Purpose

Define the curriculum domain for TeoryX.

This model supports:

* K-12
* official academic standards
* AI-generated lessons
* assessments
* progress tracking
* multi-language content
* multi-tenant schools

---

# Core Principle

Lessons must never be generated freely.

Every lesson must originate from an official academic standard.

Standard
↓
Learning Objective
↓
Assessment Blueprint
↓
Lesson
↓
Tutor Session
↓
Progress

---

# Entities

## Curriculum

Represents an official curriculum framework.

Examples:

* California Common Core
* NGSS
* Texas TEKS

Attributes:

* id
* name
* country
* state
* version
* status
* createdAt
* updatedAt

---

## GradeLevel

Represents a school grade.

Examples:

* Kindergarten
* Grade 1
* Grade 2
* ...
* Grade 12

Attributes:

* id
* code
* name
* order

---

## Subject

Represents an academic subject.

Examples:

* Math
* English Language Arts
* Science
* History

Attributes:

* id
* code
* name
* status

---

## Standard

Represents an official academic standard.

Example:

CCSS.MATH.4.NF.A.1

Attributes:

* id
* curriculumId
* gradeLevelId
* subjectId
* code
* description
* strand
* domain
* cluster
* status

Relationships:

* belongs to Curriculum
* belongs to GradeLevel
* belongs to Subject

---

## Unit

Represents a group of related standards and lessons.

Attributes:

* id
* curriculumId
* gradeLevelId
* subjectId
* title
* description
* order
* status

Relationships:

* has many Standards
* has many Lessons

---

## LearningObjective

Represents a specific measurable learning goal derived from a standard.

Attributes:

* id
* standardId
* objectiveText
* language
* difficultyLevel
* status

Relationships:

* belongs to Standard
* has many Lessons
* has many Assessments

---

## Lesson

Represents teachable content generated from a learning objective.

Attributes:

* id
* standardId
* learningObjectiveId
* gradeLevelId
* subjectId
* language
* title
* bigIdea
* essentialQuestion
* desiredUnderstanding
* explanation
* examples
* guidedPractice
* independentPractice
* summary
* aiGenerated
* version
* status

Status values:

* draft
* review
* published
* archived

---

## Assessment

Represents the evidence used to determine understanding.

Attributes:

* id
* lessonId
* learningObjectiveId
* title
* assessmentType
* passingScore
* masteryThreshold
* status

---

## Question

Represents one assessment question.

Attributes:

* id
* assessmentId
* questionText
* questionType
* answerOptions
* correctAnswer
* explanation
* difficultyLevel

---

## TutorPrompt

Represents the AI tutor behavior for a lesson.

Attributes:

* id
* lessonId
* language
* systemPrompt
* behaviorRules
* safetyRules
* version
* status

---

## Progress

Represents student mastery over a lesson or standard.

Attributes:

* id
* schoolId
* studentId
* standardId
* lessonId
* assessmentId
* completionPercentage
* masteryLevel
* lastScore
* attemptsCount
* lastActivityAt

Mastery levels:

* not_started
* in_progress
* developing
* proficient
* mastered

---

# Multi-Tenant Rule

Curriculum, GradeLevel, Subject and Standard may be global.

Student Progress is always tenant-specific and must include:

* schoolId
* studentId

Schools may consume global curriculum content but cannot access another school's student data.

---

# Multi-Language Rule

Official standards remain the source of truth.

Lessons, assessments and tutor prompts may exist in multiple languages.

Every generated content record must include:

* language

Initial languages:

* en
* es

---

# MVP Scope

Initial seed content:

* California Common Core
* Grade 3
* Grade 4
* Grade 5
* Math
* ELA

Architectural scope:

* K-12
* all official standards
* future subjects
* future curricula

---

# Open Questions

1. Should schools be allowed to customize generated lessons?
2. Should lesson review be done by Super Admin only or also School Admin?
3. Should one standard generate multiple lessons?
4. Should one assessment cover multiple standards?
5. Should remediation lessons be generated automatically?
