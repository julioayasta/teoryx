# DDD Analysis for TeoryX

## Purpose

This document translates Domain-Driven Design Quickly into architectural guidance for TeoryX.

---

# Phase 1 — Deep Analysis

## Core Lesson

The software must reflect the domain.

The domain is more important than:

* database design
* framework selection
* APIs
* infrastructure

For TeoryX, the domain is:

Curriculum
→ Learning
→ Mastery

Everything else is supporting infrastructure.

---

## Ubiquitous Language

A shared vocabulary must exist between:

* Product Owner
* Architect
* Developer
* AI Systems

TeoryX language:

* Curriculum
* Grade Level
* Subject
* Standard
* Unit
* Learning Objective
* Lesson
* Assessment
* Progress
* Mastery
* Tutor Session

These terms must appear consistently in:

* documentation
* code
* database
* prompts

---

## Entities

Entities have identity.

TeoryX Entities:

* School
* User
* Student
* Parent
* Curriculum
* Standard
* Unit
* Lesson
* Assessment
* Progress

Identity matters more than attributes.

Example:

StudentId defines a student.

Not name.

---

## Value Objects

Objects defined by attributes rather than identity.

TeoryX Value Objects:

* Language
* Email
* SchoolTheme
* GradeCode
* StandardCode
* Score
* MasteryLevel

These should be immutable whenever possible.

---

## Services

Behavior that does not naturally belong to an Entity.

Examples:

* LessonGenerationService
* AssessmentGenerationService
* ProgressCalculationService
* MasteryEvaluationService
* CurriculumImportService

---

## Repositories

Repositories isolate persistence.

Domain should never know Firestore.

Examples:

* StudentRepository
* LessonRepository
* StandardRepository
* ProgressRepository

---

## Aggregates

Aggregate Roots control consistency.

Candidate aggregates:

Student
└─ Progress

Lesson
└─ Assessment
└─ TutorPrompt

Curriculum
└─ Standard
└─ Unit

---

## Bounded Contexts

Proposed TeoryX contexts:

Identity Context

* User
* Role
* School

Curriculum Context

* Curriculum
* GradeLevel
* Subject
* Standard
* Unit

Learning Context

* LearningObjective
* Lesson
* Assessment
* Question
* TutorPrompt

Student Context

* Progress
* AssessmentAttempt
* TutorSession

---

# Phase 2 — Risks and Weaknesses

## Risk 1

Applying full DDD too early.

Mitigation:

Use only concepts that simplify decisions.

---

## Risk 2

Firestore is not relational.

Mitigation:

Adapt DDD concepts to document storage.

---

## Risk 3

Over-modeling curriculum.

Mitigation:

Architect for K-12.

Seed content only for Grades 3–5.

---

## Risk 4

Treating AI as the domain.

Mitigation:

AI remains a service.

Curriculum remains the core domain.

---

# Phase 3 — Final Conclusions

## Core Domain

Curriculum
→ Learning
→ Mastery

This is where most design effort should be invested.

---

## Supporting Domains

Identity
Administration
Analytics
Messaging
Branding

---

## Strategic Principle

Official Standards First.

AI exists to operationalize standards.

AI does not define standards.

---

## Recommended Next ADR

ADR-005

Bounded Context Architecture.
