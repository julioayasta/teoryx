# TeoryX Project State v0.3

Date: 2026-06-23

This document is the current handoff state for TeoryX after Student App Sprint 05 and Content Engine CE-17A automated validation.

## Product Principle

```text
Curriculum First
AI Second
```

Official curriculum standards are the source of truth. AI may generate lessons, tutor guidance, assessment drafts, and supporting material only from approved curriculum-aligned inputs.

## MVP Scope

Seed/content scope:

- Grades 3-5
- Math and ELA
- English and Spanish
- California Common Core Standards
- California, USA

The architecture must continue to support K-12, additional subjects, additional jurisdictions, and multiple schools.

## Current Architecture Status

Frontend:

- Flutter Student App
- Clean Architecture
- Feature-first modules
- Domain / Data / Presentation separation
- Central app bootstrap and dependency wiring
- Firebase and Firestore isolated outside presentation widgets
- Mock mode remains the default runtime path

Backend:

- Firebase Functions workspace exists under `functions/`
- Firestore-backed Content Engine repository exists
- Firebase Emulator-first backend tests exist
- Content Engine callable skeleton and runtime handlers exist
- Safe fake AI provider remains the default
- Real OpenAI provider path exists behind explicit feature flags
- No production deployment has been performed from this runtime

Firebase:

- Firebase Auth, Firestore, Cloud Functions, and emulator support are wired for dev validation
- Firebase mode remains opt-in through dart defines
- Missing FlutterFire configuration falls back safely to mock mode
- Student App can connect to local emulators when explicitly enabled

## Non-Negotiable Architecture Rules

1. Multi-tenant modeling is mandatory.

School-owned entities must carry or resolve `schoolId`.

2. Curriculum-first design is mandatory.

Generated instructional content must trace back to official curriculum standards and versions.

3. Backward Design / UbD remains the target instructional flow.

Target generation order:

```text
Curriculum Standard
-> Pedagogical Analysis
-> Learning Objective
-> Assessment Blueprint
-> Lesson Blueprint
-> Lesson Content
-> Tutor Guidance
-> Progress Tracking
```

4. AI must stay abstracted.

Provider-specific logic belongs behind the AI provider and AI execution service boundaries.

5. Firebase must stay isolated.

Presentation files must not import `firebase_core`, `firebase_auth`, `cloud_firestore`, or `cloud_functions`.

6. Mock mode must remain the default.

Firebase, Firestore, Cloud Functions, and real AI are opt-in for dev/runtime validation.

7. Student App is read/request only for Content Engine.

The Student App may read published content, read lesson specifications, request missing content, and see pending/ready/failed status. It cannot edit, approve, publish, change curriculum, or call AI directly.

## Completed Student App Sprints

### Sprint 01 - Foundation

Completed Flutter project foundation, clean architecture structure, feature modules, localization, theme, routing, minimal dependencies, and smoke widget testing.

### Sprint 02 - Student Experience

Completed mock login, dashboard, continue studying, course catalog, grade/course selection, lesson list/detail, guided lesson rendering, tutor overlay, language switcher, breadcrumbs, and K2S branding.

### Sprint 02.1 - Test Stability

Stabilized widget tests and preserved the main student journey coverage.

### Sprint 03 - Assessment + Results + Progress

Completed assessment domain model, mock assessment flow, results screen, score display, pending review, and progress updates.

### Sprint 04 - Progress Dashboard + Recommendations

Completed progress dashboard, course/lesson progress models, mastery summary, latest assessment summary, and recommendations.

### Sprint 05.1 - Firebase Auth Foundation

Added Firebase packages, auth repository boundary, mock default, Firebase Auth repository, Firestore user lookup, auth controller/scope, gated initialization, and graceful fallback.

### Sprint 05.2 - Firestore Repository Foundation

Added Firestore paths, repository contracts and mappers for student profile, school theme, course catalog, and published lesson read models. Published lessons are read-only from the Student App.

### Sprint 05.3 - School Theme From Firestore

Connected school theme/branding through `SchoolThemeRepository` with K2S fallback.

### Sprint 05.4 - Student Profile From Firestore

Connected student profile through `StudentRepository` with mock fallback.

### Sprint 05.5 - Course Catalog From Firestore

Connected course catalog through `CourseRepository` with preload/cache and mock fallback.

### Sprint 05.6 - Student Progress From Firestore

Connected progress through `ProgressRepository` with read-only Firestore access and mock fallback.

### Sprint 05.7 - Published Lessons Read Path

Connected published lesson content through `LessonRepository`, using read-only Firestore access and mock fallback.

## Content Engine Status

Architecture:

```text
COMPLETE
```

Execution Design:

```text
COMPLETE
```

API Contracts:

```text
COMPLETE
```

Contract Validation Design:

```text
COMPLETE
```

Implementation Status:

```text
MVP BACKEND RUNTIME IN PROGRESS
```

### Completed Content Engine Milestones

- CE-01 Content Engine Architecture
- CE-02A Curriculum Source Registry
- CE-02B Pedagogical Analysis Engine + Knowledge Source Library + Prompt Registry
- CE-02C Instructional Blueprint Engine
- CE-02D Generation Artifact Contracts
- CE-02E Course Planning and Lesson Specification
- CE-02F Architecture Gap Review
- CE-03A Content Engine MVP Execution Pipeline
- CE-03B API and Cloud Function Contracts
- CE-03C Emulator-First Contract Tests
- CE-04 Emulator Contract Harness and Minimal Function Skeleton
- CE-05 Firestore-Backed Fake Runtime
- CE-06 Minimal Course Plan Generation Runtime
- CE-07 Minimal Lesson Content Generation Runtime
- CE-08 Student App Content Engine Callable Integration
- CE-09 AI Provider Abstraction Layer
- CE-10 First Real AI Lesson Generation Path Behind Feature Flags
- CE-11 Real AI Smoke Test Script and Documentation
- CE-12 Curriculum Ingestion MVP
- CE-13 Pedagogical Analysis Generation MVP
- CE-14 Course Planning From Pedagogical Analysis
- CE-15 Lesson Generation From Pedagogical Analysis
- CE-16 Flutter Real AI E2E Dev Test Path

### Content Engine Runtime Capabilities

Current backend supports:

- Curriculum source/version/standard import from normalized JSON
- Super Admin-only curriculum import callable behavior in handler tests
- Pedagogical analysis generation from imported standards
- Prompt resolver and prompt template version references
- AI execution service with prompt/cost records
- Safe fake AI provider by default
- Real OpenAI provider behind explicit environment flags
- Deterministic course plan generation
- Analysis-backed CourseMap, UnitPlan, and LessonSpecification generation
- Student-safe `requestLessonContent`
- Published lesson generation from LessonSpecification, CurriculumStandard, and PedagogicalAnalysis context
- Publication into `publishedLessonContent`
- Audit, provenance, version, prompt execution, and cost tracking records

### Content Engine Callable Exposure

Runtime handlers exist for the CE API surface. Firebase callable exports currently expose the Student App path:

- `requestLessonContent`
- `getContentGenerationStatus`

Other CE API handlers are available in the backend runtime/tests but are not yet all exported as Firebase callables.

## Current Repository Boundaries

Flutter Student App:

```text
AuthRepository
  MockAuthRepository
  FirebaseAuthRepository

StudentRepository
  MockStudentRepository
  FirestoreStudentRepository

SchoolThemeRepository
  FirestoreSchoolThemeRepository

CourseRepository
  MockCourseRepository
  FirestoreCourseRepository

LessonRepository
  MockLessonRepository
  FirestorePublishedLessonRepository

LessonSpecificationRepository
  MockLessonSpecificationRepository
  FirestoreLessonSpecificationRepository

ContentGenerationRepository
  MockContentGenerationRepository
  FirebaseContentGenerationRepository

ProgressRepository
  MockProgressRepository
  FirestoreProgressRepository
```

Content Engine backend:

```text
ContentEngineRepository
  FirestoreContentEngineRepository

DocumentStore
  MemoryDocumentStore
  FirestoreAdminDocumentStore

AIProvider
  SafeFakeAIProvider
  RealOpenAIProvider

AIExecutionService
PromptResolver
ModelRoutingPolicy
```

## Firebase And Emulator Status

Mock mode:

```text
flutter run
```

Firebase mode:

```text
flutter run \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true
```

Firebase emulator mode:

```text
flutter run \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true \
  --dart-define=TEORYX_USE_FIREBASE_EMULATORS=true \
  --dart-define=TEORYX_FIREBASE_EMULATOR_HOST=localhost
```

Configured emulator ports:

- Firestore: `8080`
- Functions: `5001`
- Auth: `9099`
- Emulator UI: `4000`

Known configuration note:

- Firebase mode still depends on valid FlutterFire/platform configuration.
- If configuration is missing or initialization fails, the app falls back to mock repositories and logs a clear message.

## Current Firestore Collections

Student App collections:

```text
schools/{schoolId}
schools/{schoolId}/students/{studentId}
schools/{schoolId}/courses/{courseId}
schools/{schoolId}/studentProgress/{studentId}
publishedLessonContent/{publishedContentId}
lessonSpecifications/{lessonSpecificationId}
```

Content Engine collections:

```text
curriculumSources/{sourceId}
curriculumSources/{sourceId}/versions/{versionId}
curriculumStandards/{standardId}
curriculumImportBatches/{batchId}
pedagogicalAnalyses/{analysisId}
contentGenerationRequests/{requestId}
contentGenerationJobs/{jobId}
courseOfferings/{offeringId}
courseMaps/{courseMapId}
unitPlans/{unitPlanId}
lessonSpecifications/{lessonSpecificationId}
lessonArtifacts/{artifactId}
presentationArtifacts/{artifactId}
validationArtifacts/{artifactId}
publishedLessonContent/{publishedContentId}
generationAuditEntries/{auditId}
provenanceRecords/{provenanceId}
versionHistory/{versionId}
promptTemplateVersions/{promptTemplateVersionId}
promptExecutionRecords/{recordId}
costTrackingRecords/{recordId}
```

## Current End-to-End Flow

Designed CE-16 dev flow:

```text
Flutter Student App
-> Firestore lessonSpecifications
-> missing publishedContentId
-> requestLessonContent callable
-> Content Engine runtime
-> AIExecutionService
-> SafeFakeAIProvider or opt-in RealOpenAIProvider
-> LessonArtifact
-> PresentationArtifact
-> ValidationArtifact
-> publishedLessonContent
-> Flutter lesson render
```

## Real AI Flags

Real AI is disabled by default.

Required for real OpenAI path:

```text
CONTENT_ENGINE_ENABLE_REAL_AI=true
CONTENT_ENGINE_AI_PROVIDER=openai
OPENAI_API_KEY=...
```

Optional:

```text
CONTENT_ENGINE_OPENAI_MODEL=gpt-4.1-mini
CONTENT_ENGINE_OPENAI_ENDPOINT=...
CONTENT_ENGINE_AI_FALLBACK_TO_FAKE=true
```

Rules:

- Do not commit `.env` files or API keys.
- Do not log `OPENAI_API_KEY`.
- Automated tests must not call real AI.
- Missing API key must not crash the backend.

## Known Gaps

- CE-17A hardening and real E2E validation is still in progress.
- Project has a CE-16 manual E2E path, but real Flutter emulator validation must be executed and documented.
- Not all designed CE API handlers are exported as Firebase callable functions.
- Firestore security rules and callable permission behavior need emulator-level validation.
- Audit/provenance/version records exist, but append-only governance, complete trace coverage, and collision-resistant identifiers need hardening.
- Cost tracking currently records estimates; real provider cost computation remains placeholder-level.
- CourseOffering and Student App school course catalog data must remain synchronized by seed/admin workflow.
- Instructional Blueprint runtime models from CE-02C are designed but not implemented.
- Assessment generation is not implemented.
- Asset Registry and Media Planning are not implemented.
- School Portal authoring/review workflow is not implemented.
- Production deployment readiness has not been validated.

## Current Verification Status

CE-17A automated verification passed on 2026-06-23.

```text
cd functions
npm run build
npm test

cd ../apps/teoryx_app
flutter analyze
flutter test
```

Results:

```text
npm run build: PASS
npm test: PASS
Node tests: 79 passed
flutter analyze: PASS
flutter test: PASS
Flutter tests: 15 passed
```

Environment note:

- The validation machine uses Windows Flutter/npm against a WSL workspace.
- Raw `\\wsl$` working directories can cause `cmd.exe` to fall back to a Windows default directory.
- Passing validation used a temporary mapped drive with `subst`.

Manual E2E verification:

```text
firebase emulators:start
cd functions
npm run seed:flutter-real-ai-e2e
cd ../apps/teoryx_app
flutter run -d linux \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true \
  --dart-define=TEORYX_USE_FIREBASE_EMULATORS=true \
  --dart-define=TEORYX_FIREBASE_EMULATOR_HOST=localhost
```

## Next Recommended Milestone

```text
CE-17B Real Emulator Smoke Closure
```

After CE-17B, recommended next step:

```text
CE-18 Instructional Blueprint Runtime MVP
```

Rationale:

- Automated validation is green.
- The remaining hardening gap is live emulator/manual real AI smoke execution, not new feature design.
- Instructional Blueprint runtime should follow only after the runtime path is proven end to end in a local emulator environment.

## Guardrails For Future Sessions

- Do not add new pedagogical features during CE-17A.
- Do not add Asset Registry, Media Generation, Assessment Generation, or School Portal workflow expansion during CE-17A.
- Do not bypass repository boundaries.
- Do not import Firebase SDK packages in presentation files.
- Do not make Student App capable of editing, approving, publishing, changing curriculum, or calling AI directly.
- Do not run real AI from automated tests.
- Do not log or commit API keys.
- Keep mock mode as the default.
- Run backend and Flutter verification before handoff.
