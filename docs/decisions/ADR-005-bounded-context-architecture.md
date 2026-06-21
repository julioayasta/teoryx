# ADR-005: Bounded Context Architecture

## Status

Accepted

## Date

2026-06

## Context

As TeoryX evolves, the domain has become too large to be represented as a single unified model.

The platform includes:

* Authentication
* Schools
* Curriculum
* Standards
* Lessons
* Assessments
* AI Tutor
* Student Progress
* Analytics

Using a single domain model would increase coupling and reduce maintainability.

Domain-Driven Design recommends dividing complex systems into Bounded Contexts.

---

# Decision

TeoryX will be divided into four primary bounded contexts.

## Identity Context

Responsible for identity, authorization and tenant ownership.

Entities:

* School
* User
* Parent
* Student
* Role

Responsibilities:

* Authentication
* Authorization
* Tenant isolation
* User lifecycle

Does NOT own:

* Curriculum
* Lessons
* Assessments

---

## Curriculum Context

Responsible for official academic standards.

Entities:

* Curriculum
* GradeLevel
* Subject
* Standard
* Unit

Responsibilities:

* Academic structure
* Curriculum imports
* Standards management

Source of truth for learning requirements.

Does NOT own:

* Student progress
* Tutor interactions

---

## Learning Context

Responsible for instructional content.

Entities:

* LearningObjective
* Lesson
* Assessment
* Question
* TutorPrompt

Responsibilities:

* Lesson generation
* Assessment generation
* AI tutor configuration
* Content publishing

Consumes:

* Curriculum Context

Does NOT own:

* Student mastery

---

## Student Context

Responsible for student learning records.

Entities:

* Progress
* AssessmentAttempt
* TutorSession

Responsibilities:

* Progress tracking
* Mastery calculation
* Learning analytics
* Student history

Consumes:

* Learning Context
* Curriculum Context

Does NOT own:

* Standards
* Lessons

---

# Context Relationships

Curriculum Context
↓
Learning Context
↓
Student Context

Identity Context
↘
(all contexts)

Identity provides security and tenant ownership.

Curriculum provides academic truth.

Learning provides instructional content.

Student provides evidence of learning.

---

# Firestore Implications

Collections should be grouped according to context ownership.

Examples:

Identity

* schools
* users
* parents
* students

Curriculum

* curriculums
* grade_levels
* subjects
* standards
* units

Learning

* lessons
* assessments
* questions
* tutor_prompts

Student

* progress
* assessment_attempts
* tutor_sessions

---

# Flutter Implications

Feature modules should eventually align with contexts.

Examples:

features/

* auth
* school
* curriculum
* lesson
* assessment
* progress

Avoid cross-context dependencies.

---

# AI Implications

AI services belong to Learning Context.

AI may consume:

* standards
* objectives
* assessments

AI may NOT become the source of truth.

Official standards remain authoritative.

---

# Multi-Tenant Rule

All student-owned records must contain:

* schoolId

Curriculum content remains global.

Progress remains tenant-specific.

---

# Benefits

* Reduced coupling
* Better scalability
* Easier maintenance
* Cleaner Firestore model
* Clear ownership boundaries

---

# Risks

* Additional architectural complexity
* More explicit integrations required

These risks are acceptable given the long-term goals of TeoryX.

---

# Strategic Principle

TeoryX is organized around domains, not technologies.

Bounded Contexts define the system structure.

Flutter, Firebase and AI must adapt to the domain model, not the opposite.
