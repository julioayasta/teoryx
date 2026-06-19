# TeoryX Flutter + Firebase Development Rules v0.1

## Purpose

This document defines the mandatory development rules for all TeoryX code.

All implementations must comply with these rules.

---

# Rule 1: Architecture First

Use Clean Architecture principles.

Layers:

Presentation
Domain
Data

Dependencies must flow inward.

Presentation must never access Firebase directly.

---

# Rule 2: Feature-Based Structure

Organize code by feature.

Example:

lib/

features/

auth/

student/

parent/

lesson/

assessment/

progress/

shared/

core/

Avoid organizing by technical type only.

---

# Rule 3: Firebase Isolation

Firebase SDK must be isolated.

Only repositories and data sources may interact with:

* Firebase Auth
* Firestore
* Firebase Storage
* Cloud Functions

UI must never call Firebase directly.

---

# Rule 4: Multi-Tenant Mandatory

All school-owned entities must include:

schoolId

Examples:

* Student
* Parent
* Progress
* Lesson
* Assessment

Queries must always respect tenant boundaries.

---

# Rule 5: Internationalization From Day One

No hardcoded user-facing text.

Use Flutter localization.

Required initial languages:

* English
* Spanish

Every new screen must support localization.

---

# Rule 6: Theme System

No hardcoded colors.

Colors must come from:

School Theme Configuration

Prepare architecture for:

* logo
* primary color
* secondary color

Future themes must not require refactoring.

---

# Rule 7: Firestore Collections

Initial collections:

schools
users
students
parents
gradeLevels
subjects
lessons
assessments
questions
assessmentAttempts
progress

Do not create collections without documented approval.

---

# Rule 8: Security

Never trust client-side role validation.

All permissions must be validated by:

* Firestore Security Rules
* Cloud Functions

Client validation is UX only.

---

# Rule 9: AI Integration

AI services must be abstracted.

Never couple business logic directly to:

* Gemini
* OpenAI
* Claude

Use interfaces.

Example:

LessonGenerator

TutorGenerator

AssessmentGenerator

Allow future provider replacement.

---

# Rule 10: Lesson Generation Pipeline

Must follow ADR-002.

Order:

Curriculum Standard
↓
Learning Objective
↓
Assessment Blueprint
↓
Lesson Generation
↓
Tutor Prompt

Never generate lesson content directly.

---

# Rule 11: Progress Calculation

Progress is based on:

* lesson completion
* assessment score
* mastery level

Not based solely on:

* login count
* screen time

---

# Rule 12: Simplicity Over Complexity

MVP priorities:

* Login
* Student Profile
* Lessons
* AI Tutor
* Assessments
* Progress

Avoid premature implementation of:

* Attendance
* Messaging
* Video Classes
* SIS Integrations

---

# Rule 13: Code Quality

Requirements:

* Meaningful names
* Small functions
* No duplicated logic
* Null safety enabled
* Strong typing preferred

---

# Rule 14: Documentation

Every major feature must include:

* Purpose
* Inputs
* Outputs

Complex decisions must generate an ADR.

---

# Rule 15: Future Scalability

Assume future support for:

* 100,000+ students
* Multiple schools
* Multiple curricula
* Multiple languages
* Multiple AI providers

Design for extension without overengineering the MVP.
