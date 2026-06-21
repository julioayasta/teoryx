# DDD Implementation Guide for Codex

## Purpose

Apply Domain-Driven Design principles when implementing TeoryX.

---

# Rule 1

Model the domain first.

Do not start from:

* Firestore collections
* APIs
* UI screens

Start from domain concepts.

---

# Rule 2

Respect Bounded Contexts

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

Avoid mixing contexts.

---

# Rule 3

Use Entities correctly

Entities require identity.

Examples:

* Student
* Lesson
* Assessment
* Progress

Do not compare entities by all attributes.

Compare by identity.

---

# Rule 4

Use Value Objects correctly

Examples:

* Language
* Score
* GradeCode
* StandardCode

Prefer immutable implementations.

---

# Rule 5

Repositories isolate persistence

Presentation Layer

MUST NOT access Firestore.

Domain Layer

MUST NOT know Firestore.

Repositories are the only persistence gateway.

---

# Rule 6

AI is a Service

AI must never become the source of truth.

Source of truth:

Curriculum
→ Standard

AI consumes standards.

AI does not create standards.

---

# Rule 7

Keep Aggregate Boundaries Small

Prefer:

Student Aggregate
Lesson Aggregate
Curriculum Aggregate

Avoid giant aggregates.

---

# Rule 8

Use Ubiquitous Language

Use domain terminology consistently.

Examples:

Good:

LearningObjective
Standard
MasteryLevel

Bad:

ContentItem
DataObject
GenericRecord

---

# Rule 9

Multi-Tenant Safety

Tenant data must always include:

schoolId

Never expose one school's student data to another school.

---

# Rule 10

Curriculum First

Every lesson, assessment and tutor interaction must trace back to:

curriculumId
gradeLevelId
subjectId
standardId

No free-form lesson generation.

Official standards first.
