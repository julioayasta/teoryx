# CODEX_STARTUP.md

# TeoryX Startup Instructions

Before making any code changes, follow this process exactly.

---

## Step 1: Understand The Project

Read the following files in order:

1. README.md

2. docs/project/PROJECT_STATE_v0.2.md

3. prompts/codex/master-development-prompt.md

4. prompts/codex/ddd-implementation-guide.md

5. prompts/codex/ubd-implementation-guide.md

6. docs/decisions/

Read all ADR files.

---

## Step 2: Build Project Understanding

Produce a short summary containing:

* Project vision
* Current architecture
* Current sprint status
* Completed functionality
* Pending functionality
* Risks and technical debt

Do NOT modify code yet.

Wait for user approval.

---

## Step 3: Architectural Rules

TeoryX is curriculum-first.

Never generate educational content directly.

Always follow:

Standard
→ Learning Objective
→ Assessment
→ Lesson
→ Tutor Guidance
→ Progress Tracking

This rule is mandatory.

---

## Step 4: DDD Rules

Respect bounded contexts.

Current bounded contexts include:

* Student
* Lesson
* Assessment
* Progress
* Tutor
* Curriculum
* School
* Administration

Do not mix responsibilities between contexts.

---

## Step 5: Clean Architecture Rules

Dependencies always point inward.

Presentation
→ Domain
→ Data

UI must never directly depend on Firebase.

UI must never directly depend on AI providers.

Use repository abstractions.

---

## Step 6: Multi-Tenant Rules

TeoryX is multi-tenant.

Every school can have:

* logo
* colors
* fonts
* branding

The Student App renders themes only.

Theme editing belongs to the School Admin Portal.

---

## Step 7: Product Boundaries

TeoryX consists of multiple products.

### Student App

Responsibilities:

* Courses
* Lessons
* Assessments
* Tutor
* Progress

### Parent Portal

Responsibilities:

* Progress visibility
* Recommendations
* Reports

### School Admin Portal

Responsibilities:

* Branding
* User management
* Enrollment
* School configuration

### Super Admin Portal

Responsibilities:

* Tenant management
* School activation
* Global configuration
* Curriculum governance

### Content Engine

Responsibilities:

* Standards
* Objectives
* Assessments
* Lessons
* Tutor prompts
* Presentation contracts

### Data Platform

Responsibilities:

* Firestore
* Cloud Functions
* Analytics
* Integrations

---

## Step 8: Lesson Design Rules

Lessons are student experiences.

Lessons should feel like:

"A teacher guiding a student who missed class."

Lessons may contain:

* Story
* Images
* Explanations
* Questions
* Guided Practice
* Independent Practice
* Summary

Lessons are NOT documentation.

---

## Step 9: Presentation Contract Vision

Content Engine will eventually produce:

* lesson content
* presentation contract

The Student App renders the presentation contract.

Never hardcode lesson-specific UI behavior when a presentation contract can solve it.

Future examples:

* Story Lesson
* Math Lesson
* Reading Lesson
* Science Experiment
* Holiday Theme
* Remediation Lesson

---

## Step 10: Engineering Rules

Before closing any sprint:

flutter analyze must pass.

flutter test must pass.

No exceptions.

---

## Step 11: Documentation Rule

Do not generate documentation for its own sake.

Documentation exists only when it:

* preserves architecture
* improves implementation quality
* enables project continuity

The goal is a working educational product.

Not a document collection.

---

## Step 12: Current Status

Read PROJECT_STATE_v0.2.md.

Use it as the source of truth for:

* current sprint
* completed work
* next priorities

If information conflicts, ask for clarification before implementing.
