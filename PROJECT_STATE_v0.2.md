# TeoryX Project State v0.2

Date: 2026-06-21

This document is the handoff state for a new Codex session. It summarizes the current product direction, architecture, implemented functionality, constraints, and recommended next work.

## Vision

TeoryX is a multi-tenant educational platform for K-12 schools.

The platform combines:

- Curriculum-based learning
- AI-generated lessons
- AI tutoring
- Assessments
- Progress tracking
- Parent and school visibility

The product principle is:

```text
Curriculum First
AI Second
```

AI must never be the source of truth for curriculum. Official academic standards drive lessons, assessments, tutor prompts, and progress tracking.

## MVP Scope

The MVP implementation/content seed scope remains:

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

## Architecture

Frontend:

- Flutter

Backend target:

- Firebase
- Firestore
- Firebase Auth
- Firebase Storage
- Google Cloud Platform

Current implementation:

- Local/mock Flutter prototype only
- No Firebase
- No Firestore
- No AI API
- No backend service

Frontend architecture:

- Clean Architecture
- Feature-first structure
- Domain / Data / Presentation layers per feature
- Centralized routing
- Centralized theme system
- Centralized localization
- Mock repositories for prototype data

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

## Implemented Functionality

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

### Sprint 02 - Vertical Slice Prototype

Completed:

- Student App mock login screen
- Student dashboard
- Continue Studying section
- Mock enrolled course: Grade 4 Math
- Current lesson state: Comparing Fractions, Lesson 2 of 8
- Course catalog flow:
  - Grade selection: K through Grade 12
  - Course selection by grade
  - Mock courses:
    - Grade 4 Math
    - Grade 4 ELA
    - Grade 5 Math
    - Grade 5 ELA
- Lesson list
- Lesson detail
- Guided narrative lesson rendering using `LessonStep`
- Lesson step types:
  - story
  - imagePlaceholder
  - explanation
  - question
  - practice
  - summary
- Tutor overlay as a floating action button attached to Lesson Detail
- Mock tutor responses in English and Spanish
- Language switcher in app shell
- English/Spanish UI and mock lesson content
- App shell prepared for future mobile/tablet/desktop/web navigation
- Breadcrumb navigation in app bar
- K2S mock school branding

### K2S Branding

Mock school:

- Name: K2S
- Full name: Knowledge for Success
- Logo: `apps/teoryx_app/assets/schools/k2s/k2s_logo.png`

Branding is configured through:

```text
lib/core/theme/school_theme_config.dart
```

Current K2S theme values:

- Primary: red from logo, `#ED1C24`
- Secondary: yellow from logo, `#FFE600`
- Font family placeholder: `Atkinson Hyperlegible`

The font family is defined cleanly in theme configuration so bundled font assets can be added later without changing screens.

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

Navigation:

- App bar back arrow returns to previous screen.
- App bar Dashboard/Home action returns directly to Student Dashboard.
- Breadcrumbs show navigation context, for example:
  - Dashboard
  - Dashboard > Grade 4 Math
  - Dashboard > Grade 4 Math > Comparing Fractions

## Current Status

Sprint status:

- Sprint 01: Complete
- Sprint 02: Complete
- Sprint 02.1 stability fix: Complete

Latest verification:

```text
flutter analyze
PASS

flutter test
PASS
```

Known important stability fix:

The app theme uses:

```dart
splashFactory: InkRipple.splashFactory
```

This avoids a test/runtime issue where Material 3 `InkSparkle` can try to load `shaders/ink_sparkle.frag` and fail with an unsupported runtime stages format version on some local toolchains.

## Current Mock Data

Current mock student:

- Sofia

Current enrolled course:

- Grade 4 Math

Current lesson:

- Comparing Fractions

Current guided lesson prototype content:

- Fractions as Parts of a Whole
- Comparing Fractions
- Equivalent Fractions

English and Spanish mock lesson data exist locally in the mock lesson repository.

## Lessons Learned

1. The student-facing lesson should not expose UbD metadata as the main structure.

Students need a guided learning experience first. Curriculum metadata belongs in secondary/collapsed details.

2. Tutor must stay attached to the lesson.

The tutor experience works better as a floating action and bottom sheet overlay than as a separate full-screen route.

3. Course selection should not be skipped.

Students need to understand the path:

```text
Dashboard -> Grade -> Course -> Lesson -> Lesson Detail
```

4. Continue Studying should resume exact progress.

The Continue button should go directly to the current lesson, not to a generic lesson list.

5. Branding must remain tenant-configurable.

School logo, colors, and names should come from theme/configuration, not from individual screens.

6. App shell is worth centralizing early.

Breadcrumbs, language switching, future top navigation, and multi-platform behavior should live in shared shell components.

7. Widget tests should cover the main user journey, not every deep scroll state.

Very long lesson content makes tests fragile if they depend on scrolling to deep collapsed sections. Keep smoke tests focused on the critical path.

## Next Sprint Recommendation

Sprint 03 should not jump directly into AI generation.

Recommended Sprint 03 theme:

Authentication and Firebase Architecture Proposal, then implementation only after approval.

Suggested Sprint 03 scope:

1. Present architecture proposal for:
   - Firebase initialization
   - Firebase Auth isolation
   - User/session domain model
   - Role model
   - Tenant resolution using `schoolId`
   - Repository/data source boundaries
   - Security rule principles

2. Add Firebase dependencies only after approval.

3. Implement authentication foundation:
   - real sign-in shell
   - session persistence
   - role identification
   - no direct Firebase calls from UI

4. Keep mock lesson/tutor content until the auth/tenant layer is stable.

Alternative Sprint 03 if authentication is deferred:

- Add progress domain model and local mock progress tracking.
- Add assessment domain model and local mock assessment flow.
- Still no AI or backend until architecture review.

## Important Files For New Sessions

Read these before changing architecture:

- `README.md`
- `PROJECT_STATE_v0.2.md`
- `docs/vision/teoryx_mvp_vision.md`
- `docs/decisions/ADR-001-multi-tenant-architecture.md`
- `docs/decisions/ADR-002-ai-content-generation-architecture.md`
- `docs/decisions/ADR-003-curriculum-strategy.md`
- `architecture/domain/domain-model-v0.1.md`
- `docs/requirements/mvp-backlog-v0.1.md`
- `docs/sprints/sprint-01-foundation.md`
- `prompts/codex/flutter-firebase-development-rules.md`
- `prompts/codex/ubd-implementation-guide.md`
- `prompts/codex/ddd-implementation-guide.md`
- `prompts/codex/master-development-prompt.md`

## Guardrails For Future Codex Sessions

- Do not add Firebase, Firestore, AI APIs, or backend services without explicit architecture approval.
- Do not hardcode Grades 3-5 as a platform limitation.
- Do not bypass `SchoolThemeConfig` for school branding.
- Do not put Firebase logic in presentation widgets.
- Do not make AI the source of truth for standards.
- Do not remove English/Spanish localization.
- Do not remove widget test coverage.
- Run both before handoff:

```text
flutter analyze
flutter test
```
