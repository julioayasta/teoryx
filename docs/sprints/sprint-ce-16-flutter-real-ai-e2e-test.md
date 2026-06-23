# Sprint CE-16: Flutter Real AI E2E Dev Test

## Purpose

CE-16 defines a manual development path for verifying:

Student App -> Firebase Functions emulator -> Content Engine -> OpenAI -> publishedLessonContent -> Student App render.

This is dev/emulator only. It is not part of automated tests and must not be used for production deployment.

## Safety Rules

- Do not deploy this flow to production.
- Do not commit `.env` files or API keys.
- Do not log `OPENAI_API_KEY`.
- Automated tests do not call real AI.
- Real AI requires explicit environment variables.
- Mock mode remains the Flutter default.
- No image generation, media generation, assessment generation, or UI redesign is included.

## Required Local Services

Firebase emulator ports from `firebase.json`:

- Firestore: `localhost:8080`
- Functions: `localhost:5001`
- Auth: `localhost:9099`
- Emulator UI: `localhost:4000`

## Java And Firebase Emulator Prerequisites

Firebase Emulator Suite requires Java. Use a modern JDK compatible with the Firebase CLI; JDK 17 or newer is recommended for local development.

Verify Java before starting emulators:

```bash
java -version
firebase --version
```

If `java -version` fails on Windows:

1. Install a JDK, preferably JDK 17 or newer.
2. Set `JAVA_HOME` to the JDK installation directory.
3. Add `%JAVA_HOME%\bin` to `PATH`.
4. Open a new terminal.
5. Run `java -version` again.

If running Firebase CLI from WSL:

1. Install Java inside WSL, or run Firebase CLI from Windows where Java is already on `PATH`.
2. Verify `java -version` in the same shell that will run `firebase emulators:start`.
3. Verify the project path is accessible to that shell.

Emulator startup checklist:

```bash
java -version
firebase --version
firebase emulators:start
```

Expected emulator ports:

```text
Firestore: 8080
Functions: 5001
Auth: 9099
UI: 4000
```

## Backend Setup

From the repository root:

```bash
cd functions
npm run build
```

Start emulators from the repository root in a separate terminal:

```bash
firebase emulators:start
```

To allow real AI for the Functions emulator, start the emulator shell with these environment variables set:

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=true
CONTENT_ENGINE_AI_PROVIDER=openai
OPENAI_API_KEY=your_api_key_here
```

Optional:

```bash
CONTENT_ENGINE_OPENAI_MODEL=gpt-4.1-mini
```

If these variables are not set, the backend remains on safe fake/default behavior.

## Seed Dev Data

In another terminal:

```bash
cd functions
npm run seed:flutter-real-ai-e2e
```

The seed creates:

- `schools/school-demo`
- `schools/school-demo/courses/grade-4-math-real`
- `schools/school-demo/students/student-001`
- `users/emulator-student-001`
- `courseOfferings/offering-school-demo-grade-4-math-real-en`
- `courseMaps/course-map-school-demo-grade-4-math-real-2025-en`
- one `unitPlans` record
- five `lessonSpecifications`
- five matching `curriculumStandards`
- five matching `pedagogicalAnalyses`

Seeded LessonSpecifications:

- `lesson-spec-grade-4-math-real-4-nf-a-1`
- `lesson-spec-grade-4-math-real-4-nf-a-2`
- `lesson-spec-grade-4-math-real-4-nf-b-3`
- `lesson-spec-grade-4-math-real-4-nf-b-4`
- `lesson-spec-grade-4-math-real-4-nf-c-5`

Each seeded LessonSpecification has:

```text
publishedContentId: null
generationStatus: not_generated
```

Selecting any seeded lesson should trigger `requestLessonContent`.

To verify the seed contract without real AI:

```bash
cd functions
npm run seed:verify:flutter-real-ai-e2e
```

## Flutter Dev Run

Run Flutter with Firebase and emulator mode enabled:

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

## Manual Test Steps

1. Start Firebase emulators.
2. Seed dev data with `npm run seed:flutter-real-ai-e2e`.
3. Run Flutter with Firebase emulator defines.
4. Navigate to Grade 4 Math Real AI E2E.
5. Open the lesson list.
6. Tap one of the five seeded lessons.
7. Confirm the app shows the localized loading state.
8. Confirm `requestLessonContent` runs in the Functions emulator.
9. Confirm `publishedLessonContent` is created in Firestore emulator.
10. Confirm the Student App renders the generated lesson.

## Expected Backend Records

After a successful real AI generation:

- `publishedLessonContent/{publishedContentId}`
- `lessonArtifacts/{lessonArtifactId}`
- `presentationArtifacts/{presentationArtifactId}`
- `validationArtifacts/{validationArtifactId}`
- `promptExecutionRecords/{promptExecutionRecordId}`
- `costTrackingRecords/{costTrackingRecordId}`
- `generationAuditEntries/{auditId}`
- `provenanceRecords/{provenanceId}`

## Expected Student App Behavior

- Lesson list reads `lessonSpecifications`.
- Missing `publishedContentId` triggers `requestLessonContent`.
- When ready, Flutter loads generated `publishedLessonContent`.
- Rendered steps use existing supported types:
  - `story`
  - `imagePlaceholder`
  - `explanation`
  - `question`
  - `practice`
  - `summary`

## Disable Real AI

Unset any real AI variable:

```bash
unset CONTENT_ENGINE_ENABLE_REAL_AI
unset CONTENT_ENGINE_AI_PROVIDER
unset OPENAI_API_KEY
```

Or set:

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=false
```

Flutter mock mode remains the default when `TEORYX_FIREBASE_ENABLED` is not set.

## Automated Verification

These commands must not call real AI:

```bash
cd functions
npm run build
npm test

cd ../apps/teoryx_app
flutter analyze
flutter test
```
