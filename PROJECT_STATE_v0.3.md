# TeoryX Project State v0.3

Date: 2026-06-21

This document is the current handoff state for TeoryX after Sprint 05.1 and Sprint 05.2. It summarizes product direction, architecture status, repository boundaries, Firebase fallback behavior, Firestore structure, completed work, and remaining roadmap.

## Vision

TeoryX is a multi-tenant educational platform for K-12 schools.

The platform combines:

- Curriculum-based learning
- AI-generated lessons
- AI tutoring
- Assessments
- Progress tracking
- Parent and school visibility

The product principle remains:

```text
Curriculum First
AI Second
```

AI must never be the source of truth for curriculum. Official academic standards drive lessons, assessments, tutor prompts, and progress tracking.

## MVP Scope

The MVP seed/content scope remains:

- Grade 3
- Grade 4
- Grade 5
- Math
- ELA
- English
- Spanish
- California Common Core Standards
- California, USA

Important distinction:

The architecture must support K-12 from the beginning. Grades 3-5 are seed/content scope only, not a system limitation.

## Current Architecture Status

Frontend:

- Flutter

Backend target:

- Firebase
- Firestore
- Firebase Auth
- Firebase Storage
- Google Cloud Platform

Current implementation:

- Flutter Student App prototype
- Mock mode remains the default runtime path
- Firebase Auth foundation exists behind repository boundaries
- Firestore repository foundation exists behind repository boundaries
- No Content Engine implementation yet
- No real AI lesson generation yet
- No UI flow has been switched wholesale to Firestore

Frontend architecture:

- Clean Architecture
- Feature-first structure
- Domain / Data / Presentation layers per feature
- Centralized routing
- Centralized theme system
- Centralized localization
- Repository boundaries for Auth, Student, School Theme, Course Catalog, and Lessons
- Mock repositories remain the default source for screens

Key app paths:

```text
apps/teoryx_app/
  lib/app/
  lib/core/
  lib/shared/
  lib/features/
  lib/l10n/
```

Feature modules currently include:

- student
- lesson
- tutor
- auth
- parent
- assessment
- progress
- school
- admin

## Non-Negotiable Architectural Decisions

1. Multi-tenant architecture is mandatory.

Every school-owned entity must include `schoolId` when persisted or modeled for persistence.

2. Curriculum-first design is mandatory.

Lessons, assessments, and tutor interactions must trace back to:

- `curriculumId`
- `gradeLevelId`
- `subjectId`
- `standardId`

3. Backward Design / UbD pipeline is mandatory.

The required generation order is:

```text
Curriculum Standard
-> Learning Objective
-> Assessment Blueprint
-> Lesson Content
-> Tutor Prompt
-> Progress Tracking
```

4. AI must be abstracted.

Future AI services must use interfaces such as lesson/tutor/assessment generators. UI and domain logic must not couple directly to Gemini, OpenAI, Claude, or any provider.

5. Firebase must be isolated.

Presentation must never call Firebase directly. Firebase SDK usage belongs behind data sources/repositories.

6. Internationalization is required from day one.

No hardcoded student-facing strings in UI. English and Spanish are currently supported.

7. School branding must be configurable.

Branding must flow through `SchoolThemeConfig` or equivalent theme configuration, not hardcoded screen colors.

8. Student-facing lesson rendering is driven by `LessonStep`.

The guided lesson sequence is the primary student experience. UbD metadata is preserved but secondary/collapsed.

## Completed Sprints

### Sprint 01 - Foundation

Completed:

- Flutter project foundation
- Clean Architecture folder structure
- Feature-first modules
- Localization foundation
- Theme foundation
- Routing foundation
- Minimal approved dependencies
- Smoke widget test

### Sprint 02 - Student Experience

Completed:

- Student App mock login screen
- Student dashboard
- Continue Studying section
- Mock enrolled course: Grade 4 Math
- Course catalog flow
- Grade selection: K through Grade 12
- Course selection by grade
- Lesson list
- Lesson detail
- Guided narrative lesson rendering using `LessonStep`
- Tutor overlay attached to Lesson Detail
- Mock tutor responses in English and Spanish
- Language switcher in app shell
- English/Spanish UI and mock lesson content
- Breadcrumb navigation
- K2S mock school branding

### Sprint 02.1 - Test Stability

Completed:

- Stabilized widget tests
- Preserved main student journey coverage
- Kept Material splash behavior compatible with local test/runtime tooling

### Sprint 03 - Assessment + Results + Progress

Completed:

- Assessment domain model
- Mock assessment flow
- Assessment question/answer entities
- Results screen
- Auto-graded score display
- Pending review state
- Progress state updates after assessment completion

### Sprint 04 - Progress Dashboard + Recommendations

Completed:

- Progress dashboard screen
- Course progress model
- Lesson progress model
- Mastery summary
- Latest assessment summary
- Progress recommendation model
- Recommendation display in dashboard/progress flows

### Sprint 05.1 - Firebase Auth Foundation

Completed:

- Added Firebase package foundation
- Added auth domain entity and repository contract
- Added mock auth repository as default
- Added Firebase Auth repository behind the auth repository boundary
- Added Firestore user profile lookup for authenticated users
- Added auth controller and auth scope
- Login now goes through auth controller instead of direct navigation
- Mock login behavior remains the default for prototype/testing
- Firebase initialization is gated by dart defines
- Firebase unavailable/config missing path falls back gracefully to mock auth

### Sprint 05.2 - Firestore Repository Foundation

Completed:

- Added Firestore collection path helper
- Added repository interfaces for:
  - Student profile
  - School theme/branding
  - Course catalog
  - Published lesson read model
- Existing mock repositories now implement repository contracts
- Added Firestore mappers for:
  - Student profile
  - School theme
  - Course
  - Published lesson content
- Added Firestore repository implementations in data layer only
- Published lesson content is read-only from the Student App perspective
- Main student UX remains on mock repositories
- Added tests for repository boundaries, mappers, collection paths, and presentation-layer Firebase import safety
- Added Firestore structure documentation

## Current Repository Boundaries

Auth:

```text
AuthRepository
  MockAuthRepository
  FirebaseAuthRepository
```

Student:

```text
StudentRepository
  MockStudentRepository
  FirestoreStudentRepository
```

School Theme:

```text
SchoolThemeRepository
  FirestoreSchoolThemeRepository
```

Course Catalog:

```text
CourseRepository
  MockCourseRepository
  FirestoreCourseRepository
```

Lessons:

```text
LessonRepository
  MockLessonRepository
  FirestorePublishedLessonRepository
```

Rules:

- UI must not import `firebase_core`, `firebase_auth`, or `cloud_firestore`.
- Firebase and Firestore SDK usage must remain in data/infrastructure code.
- Mock repositories remain default unless Firebase is explicitly enabled, configured, and successfully initialized.
- Firestore repositories are infrastructure-only at this stage.
- No screen has been redesigned to depend directly on Firestore.

## Firebase Fallback Behavior

Mock mode is default.

Default mode:

```text
flutter run
```

uses mock repositories.

Firebase mode is requested with:

```text
flutter run --dart-define=TEORYX_FIREBASE_ENABLED=true
```

If FlutterFire configuration is not marked present, the app does not call Firebase platform channels. It falls back to mock auth and logs a clear explanation.

Real Firebase initialization requires both:

```text
--dart-define=TEORYX_FIREBASE_ENABLED=true
--dart-define=TEORYX_FIREBASE_CONFIGURED=true
```

If initialization fails or times out, the app falls back to mock auth instead of crashing.

Current known Firebase configuration status:

- `lib/firebase_options.dart` is not present
- Linux Firebase plugin registration was not configured in the inspected project state
- FlutterFire configuration is still required before Firebase mode should be considered fully active

Required setup command:

```text
flutterfire configure
```

Expected generated/updated files include:

- `apps/teoryx_app/lib/firebase_options.dart`
- platform Firebase configuration for selected targets
- generated platform plugin registration files

See:

```text
docs/firebase/flutterfire-configuration.md
```

## Firestore Collection Structure

Current proposed structure:

```text
schools/{schoolId}
schools/{schoolId}/students/{studentId}
schools/{schoolId}/courses/{courseId}
schools/{schoolId}/studentProgress/{studentId}
publishedLessonContent/{publishedContentId}
```

### schools/{schoolId}

Tenant branding and configuration:

```text
name
fullName
logoUrl
logoAssetPath
primaryColor
secondaryColor
fontFamily
status
createdAt
updatedAt
```

### schools/{schoolId}/students/{studentId}

Tenant-owned student profile:

```text
firstName
lastName
gradeLevelId
gradeLevelName
subjectName
preferredLanguage
status
createdAt
updatedAt
```

### schools/{schoolId}/courses/{courseId}

Tenant-visible course catalog entries:

```text
curriculumId
gradeLevelId
gradeLevelName
subjectId
subjectName
title
status
order
createdAt
updatedAt
```

### schools/{schoolId}/studentProgress/{studentId}

Tenant-owned student progress summary:

```text
studentId
currentCourseId
currentLessonId
masteryLevel
completionPercentage
lastActivityAt
updatedAt
```

### publishedLessonContent/{publishedContentId}

Read-only published lesson content for the Student App:

```text
schoolId
courseId
curriculumId
gradeLevelId
subjectId
standardId
standardCode
language
title
bigIdea
essentialQuestion
learningObjectiveId
learningObjective
lessonContent
guidedPractice
independentPractice
summary
steps
status
version
createdAt
updatedAt
```

Each `steps` item uses:

```text
id
lessonId
order
type
title
body
prompt
expectedAnswer
imageDescription
```

See:

```text
docs/firebase/firestore-structure.md
```

## Current Student Flow

Current working app flow:

```text
Welcome to TeoryX
-> Sign In
-> Dashboard
-> Continue Studying
-> Comparing Fractions lesson
-> Tutor overlay
```

Course discovery flow:

```text
Dashboard
-> New Course from Catalog
-> Grade Selection
-> Course Selection
-> Lesson List
-> Lesson Detail
-> Tutor Overlay
```

Assessment/progress flow:

```text
Lesson Detail
-> Assessment
-> Results
-> Dashboard recommendation
-> Progress Dashboard
```

## Current Mock Data

Current mock student:

- Sofia

Current enrolled course:

- Grade 4 Math

Current lessons:

- Fractions as Parts of a Whole
- Comparing Fractions
- Equivalent Fractions

Current assessment/progress state:

- Auto-graded score example
- Pending review example
- Mastery and recommendation examples

English and Spanish mock lesson data exist locally in the mock lesson repository.

## Current Verification Status

Latest verification after Sprint 05.2:

```text
flutter analyze
PASS

flutter test
PASS
```

Additional tests include:

- Repository boundary checks
- Firestore mapper checks
- Firestore path checks
- Presentation-layer Firebase import guard
- Firebase fallback bootstrap behavior

## Known Environment Notes

Linux desktop run could not be verified in the current Windows/WSL environment because Flutter exposed only:

- Windows
- Chrome
- Edge

WSL resolved Flutter to the Windows SDK path:

```text
/mnt/c/flutter/bin/flutter
```

This is an environment/toolchain limitation, not an intentional app limitation.

There is also a Windows `Zone.Identifier` metadata artifact beside the K2S logo that can make `git status` noisy.

## Remaining Roadmap

Recommended next work:

### Sprint 05.3 - Firebase Configuration Completion

- Run `flutterfire configure`
- Generate `lib/firebase_options.dart`
- Verify selected platform support
- Verify Firebase mode on supported targets
- Add minimal Firebase emulator or integration test guidance if appropriate

### Sprint 06 - Auth Session + Tenant Resolution

- Resolve current user profile from Firebase Auth + Firestore
- Resolve active `schoolId`
- Keep role and tenant checks behind auth/session boundaries
- Do not route users to role-specific products until session behavior is stable

### Sprint 07 - Firestore Read Integration Pilot

- Switch one low-risk read path to repository-driven Firestore with mock fallback
- Suggested first candidates:
  - school theme
  - student profile
  - course catalog
- Do not switch published lessons until content quality/versioning rules are ready

### Sprint 08 - Progress Persistence

- Persist assessment attempts
- Persist progress summaries
- Maintain tenant filtering by `schoolId`
- Keep progress based on assessment/mastery/lesson completion, not time spent

### Future - Content Engine

- Implement curriculum import/governance
- Implement standard -> objective -> assessment -> lesson -> tutor prompt pipeline
- Add human review/publish workflow
- Keep AI provider abstracted
- Keep generated content versioned and reviewable

### Future - Parent and School Visibility

- Parent progress visibility
- School admin aggregated mastery views
- School configuration and branding management
- Super admin tenant/curriculum governance

## Important Files For New Sessions

Read these before changing architecture:

- `README.md`
- `PROJECT_STATE_v0.3.md`
- `docs/vision/teoryx_mvp_vision.md`
- `docs/decisions/ADR-001-multi-tenant-architecture.md`
- `docs/decisions/ADR-002-ai-content-generation-architecture.md`
- `docs/decisions/ADR-003-curriculum-strategy.md`
- `docs/decisions/ADR-004-curriculum-domain-architecture.md`
- `docs/decisions/ADR-005-bounded-context-architecture.md`
- `docs/decisions/ADR-006-firestore-domain-architecture.md`
- `architecture/domain/domain-model-v0.1.md`
- `docs/requirements/mvp-backlog-v0.1.md`
- `docs/firebase/flutterfire-configuration.md`
- `docs/firebase/firestore-structure.md`
- `prompts/codex/flutter-firebase-development-rules.md`
- `prompts/codex/ubd-implementation-guide.md`
- `prompts/codex/ddd-implementation-guide.md`
- `prompts/codex/master-development-prompt.md`

## Guardrails For Future Codex Sessions

- Do not hardcode Grades 3-5 as a platform limitation.
- Do not bypass `SchoolThemeConfig` for school branding.
- Do not put Firebase logic in presentation widgets.
- Do not import Firebase SDK packages in presentation files.
- Do not make AI the source of truth for standards.
- Do not remove English/Spanish localization.
- Do not remove widget test coverage.
- Do not switch all mock repositories to Firestore at once.
- Do not let missing Firebase/Firestore config crash mock mode.
- Run both before handoff:

```text
flutter analyze
flutter test
```
