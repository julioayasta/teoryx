# Sprint CE-17A: Hardening and Real End-to-End Validation

## Purpose

CE-17A validates and hardens the runtime path created by CE-16:

```text
Flutter Student App
-> Firebase Emulator
-> Content Engine callable
-> AI provider path
-> publishedLessonContent
-> Flutter lesson render
```

This sprint is validation and operational readiness only. It does not add new pedagogical features, Asset Registry, Media Generation, Assessment Generation, or School Portal workflow expansion.

## Scope

Included:

- Project state update
- Emulator configuration review
- Backend build and test validation
- Flutter analyze and test validation
- Real AI feature-flag validation
- Flutter E2E runbook validation
- Audit/provenance/version record validation
- Failure scenario review
- Security and permission review

Excluded:

- New curriculum or pedagogy features
- New generated content types
- Media or image generation
- Assessment generation
- School Portal workflow expansion
- Production deployment
- Real AI in automated tests

## Runtime Under Review

Current Content Engine runtime supports:

- Normalized curriculum import
- Pedagogical analysis generation
- Analysis-backed course planning
- LessonSpecification-based lesson generation
- Safe fake AI provider by default
- Optional real OpenAI provider behind feature flags
- Publication into `publishedLessonContent`
- Student App callable integration for missing lesson content

## Emulator Configuration

Configured in `firebase.json`:

| Service | Port |
| --- | --- |
| Firestore Emulator | `8080` |
| Functions Emulator | `5001` |
| Auth Emulator | `9099` |
| Emulator UI | `4000` |

Expected startup:

```bash
firebase emulators:start
```

Expected backend seed:

```bash
cd functions
npm run seed:flutter-real-ai-e2e
```

## Flutter Emulator Configuration

Mock mode remains default:

```bash
flutter run
```

Firebase emulator mode:

```bash
cd apps/teoryx_app
flutter run -d linux \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true \
  --dart-define=TEORYX_USE_FIREBASE_EMULATORS=true \
  --dart-define=TEORYX_FIREBASE_EMULATOR_HOST=localhost
```

Optional port overrides:

```bash
--dart-define=TEORYX_FIRESTORE_EMULATOR_PORT=8080
--dart-define=TEORYX_FUNCTIONS_EMULATOR_PORT=5001
--dart-define=TEORYX_AUTH_EMULATOR_PORT=9099
```

## Real AI Validation

Real AI must remain opt-in:

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=true
CONTENT_ENGINE_AI_PROVIDER=openai
OPENAI_API_KEY=...
```

Optional:

```bash
CONTENT_ENGINE_OPENAI_MODEL=gpt-4.1-mini
CONTENT_ENGINE_OPENAI_ENDPOINT=...
CONTENT_ENGINE_AI_FALLBACK_TO_FAKE=true
```

Validation rules:

- If flags are absent, `SafeFakeAIProvider` is selected.
- If OpenAI is requested but the API key is missing, the backend must not crash.
- Automated tests must not call real AI.
- API keys must not be logged.
- Structured JSON output must validate before publication.
- Invalid or unsupported step types must not publish.

## Flutter E2E Flow

Expected manual flow:

1. Start Firebase emulators.
2. Seed `school-demo` and one missing-content lesson specification.
3. Start Flutter with emulator dart defines.
4. Navigate to Grade 4 Math Real AI E2E.
5. Open `Explain Equivalent Fractions`.
6. Confirm the app shows the localized loading state.
7. Confirm `requestLessonContent` executes in the Functions emulator.
8. Confirm `publishedLessonContent` is created.
9. Confirm the LessonSpecification is updated with `publishedContentId`.
10. Confirm the Student App renders the generated lesson.

## Auditability Validation

A successful lesson-generation path should create or update:

- `promptExecutionRecords/{recordId}`
- `costTrackingRecords/{recordId}`
- `generationAuditEntries/{auditId}`
- `provenanceRecords/{provenanceId}`
- `versionHistory/{versionId}`
- `lessonArtifacts/{artifactId}`
- `presentationArtifacts/{artifactId}`
- `validationArtifacts/{artifactId}`
- `publishedLessonContent/{publishedContentId}`
- `lessonSpecifications/{lessonSpecificationId}`

Required traceability:

- LessonSpecification ID
- CurriculumStandard IDs
- PedagogicalAnalysis IDs
- PromptTemplateVersion ID
- ContentGenerationRequest ID
- ContentGenerationJob ID
- Artifact IDs
- Published content ID

## Failure Validation

Failure scenarios to verify:

- Missing CurriculumStandard fails safely.
- Missing PedagogicalAnalysis fails safely.
- Invalid AI JSON does not publish.
- Unsupported step type does not publish.
- Provider failure records safe error details.
- Student App receives only `pending`, `ready`, or `failed`.
- Unauthorized callers are denied.
- School Admin-only and Super Admin-only operations are not available to Student App.

## Security Review

Current callable exposure:

- `requestLessonContent`
- `getContentGenerationStatus`

Student App restrictions:

- May read available lesson specifications.
- May request missing lesson content.
- May read pending/ready/failed status.
- May read published lesson content.
- Cannot edit artifacts.
- Cannot approve artifacts.
- Cannot publish content.
- Cannot import curriculum.
- Cannot request pedagogical analysis.
- Cannot change curriculum selection.
- Cannot call AI directly.

Security gaps to keep visible:

- Not all designed CE API handlers are exported as Firebase callables.
- Emulator-level callable permission tests should be added before production.
- Firestore rules are not yet validated as a production security boundary.
- Functions use Admin SDK and must enforce role checks themselves.

## Validation Commands

Backend:

```bash
cd functions
npm run build
npm test
```

Flutter:

```bash
cd apps/teoryx_app
flutter analyze
flutter test
```

## Findings

Validation findings:

- `PROJECT_STATE_v0.3.md` was stale and has been updated to reflect CE-04 through CE-16.
- CE-16 runbook exists and describes the manual Flutter/Firebase emulator path.
- Emulator ports are configured in `firebase.json`.
- Backend package scripts exist for build, test, emulator seed, and manual real AI smoke test.
- Real AI remains opt-in and automated tests use fake/mocked paths.
- Student App Firebase mode still depends on valid FlutterFire/platform configuration.
- Backend `npm run build` passes.
- Backend `npm test` passes with 79 passing tests.
- Flutter `flutter analyze` passes with no issues.
- Flutter `flutter test` passes with 15 passing tests.
- Windows Flutter and npm cannot reliably execute from the raw `\\wsl$` UNC working directory. Validation succeeded by mapping the WSL workspace to a temporary Windows drive with `subst`.
- The manual emulator and real AI paths were reviewed, but not executed against a live OpenAI key during automated validation.

## Blockers

Known or likely blockers before production readiness:

- Manual Flutter E2E validation still requires a local emulator run.
- Real AI structured JSON compatibility must be verified during a controlled smoke test with an explicit API key.
- Firestore security rules and callable permission behavior need emulator-level validation.
- Full CE API callable export strategy is not complete.
- Windows/WSL developer environments should use a mapped drive or native Linux Flutter SDK when running Flutter tests from this workspace.

## Fixes Applied

Applied during CE-17A:

- Updated `PROJECT_STATE_v0.3.md` to reflect CE-04 through CE-16 and current CE-17A status.
- Created this CE-17A validation and hardening document.

No runtime code changes have been applied.

## Automated Verification Results

Executed successfully:

```bash
cd functions
npm run build
npm test
```

Result:

```text
npm run build: PASS
npm test: PASS
Node tests: 79 passed
```

Executed successfully:

```bash
cd apps/teoryx_app
flutter analyze
flutter test
```

Result:

```text
flutter analyze: PASS
flutter test: PASS
Flutter tests: 15 passed
```

Environment note:

The validation machine uses a Windows Flutter SDK against a WSL workspace. Running from the raw UNC path can cause `cmd.exe` to fall back to a Windows default directory. The passing validation used a temporary mapped drive:

```bat
subst T: \\wsl$\Ubuntu\home\cc_root\projects\teoryx
```

This is a local tooling workaround and did not require application code changes.

## Unresolved Issues

- Production deployment readiness is not established.
- Real AI smoke execution is manual and requires explicit credentials.
- Cost estimates are recorded, but real provider pricing computation remains placeholder-level.
- Audit/provenance records exist, but complete append-only governance and collision-resistant record IDs need future hardening.
- CourseOffering and school course catalog synchronization remains a seed/admin workflow responsibility.
- Instructional Blueprint runtime models are designed but not implemented.

## Readiness Assessment

CE-17A automated validation is complete:

- Backend build passes.
- Backend tests pass.
- Flutter analyze passes.
- Flutter tests pass.
- Manual emulator E2E steps are documented and actionable.
- No runtime code blocker was found during automated validation.

Recommended next milestone depends on validation results:

- Recommended next: CE-17B Real Emulator Smoke Closure.
- After CE-17B: CE-18 Instructional Blueprint Runtime MVP.

CE-17B should focus on executing the manual emulator path, confirming callable execution through the Functions emulator, validating real OpenAI structured JSON with one explicit API-key smoke test, and documenting any Firebase/FlutterFire setup fixes required for repeatable local development.
