# Sprint CE-17C: Local Emulator Environment Fix and Repeatable Student Test Seed

## Purpose

CE-17C makes the local/dev E2E path repeatable for a real human student test.

It addresses two CE-17B blockers:

- Firebase Emulator Suite could not start because Java was missing from `PATH`.
- The Flutter real AI E2E seed created only one `LessonSpecification`.

Scope is local/dev tooling and seed data only. No new pedagogical models, Asset Registry, Media Generation, Assessment Generation, School Portal workflow, UI redesign, or production deployment is included.

## Java And Firebase Emulator Prerequisites

Firebase Emulator Suite requires Java.

Recommended local Java:

```text
JDK 17 or newer
```

Verify:

```bash
java -version
firebase --version
```

If Java is missing on Windows:

1. Install JDK 17 or newer.
2. Set `JAVA_HOME` to the JDK installation directory.
3. Add `%JAVA_HOME%\bin` to `PATH`.
4. Open a new terminal.
5. Run `java -version`.

If Java is missing in WSL:

1. Install Java inside WSL, or run Firebase CLI from Windows.
2. Verify `java -version` in the same shell used for Firebase CLI.
3. Avoid mixing a Windows Firebase CLI with a WSL shell unless both path and Java behavior are verified.

Emulator startup checklist:

```bash
java -version
firebase --version
firebase emulators:start
```

Expected ports:

```text
Firestore: localhost:8080
Functions: localhost:5001
Auth: localhost:9099
Emulator UI: localhost:4000
```

## Five-Lesson Seed Expansion

The Flutter real AI E2E seed now creates five Grade 4 Math fraction lesson specifications for:

- Explain Equivalent Fractions
- Compare Fractions With Different Denominators
- Add Fractions With Like Denominators
- Multiply Fractions By Whole Numbers
- Add Tenths And Hundredths

Each seeded lesson includes:

- `LessonSpecification`
- linked `CurriculumStandard`
- linked `PedagogicalAnalysis`
- `publishedContentId: null`
- `generationStatus: not_generated`
- active status
- stable IDs

The seed keeps the same visible course setup:

```text
schoolId: school-demo
courseId: grade-4-math-real
language: en
courseOfferingId: offering-school-demo-grade-4-math-real-en
courseMapId: course-map-school-demo-grade-4-math-real-2025-en
```

## Seed Commands

Seed the Firebase emulator:

```bash
cd functions
npm run seed:flutter-real-ai-e2e
```

Verify the seed contract without real AI or emulator startup:

```bash
cd functions
npm run seed:verify:flutter-real-ai-e2e
```

The verification command confirms:

- five `LessonSpecifications` are visible through the student-facing course listing contract
- the course offering is enabled and visible
- each spec starts without `publishedContentId`
- each spec references a curriculum standard
- each spec references a pedagogical analysis
- one content generation request can update `publishedContentId`

Automated verification uses `SafeFakeAIProvider`; it does not require real AI credentials.

## Real AI Optional Path

Real AI remains optional.

To run the Functions emulator with OpenAI enabled:

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=true
CONTENT_ENGINE_AI_PROVIDER=openai
OPENAI_API_KEY=your_api_key_here
firebase emulators:start
```

Optional:

```bash
CONTENT_ENGINE_OPENAI_MODEL=gpt-4.1-mini
CONTENT_ENGINE_AI_FALLBACK_TO_FAKE=true
```

Rules:

- Do not commit `.env` files.
- Do not log `OPENAI_API_KEY`.
- Automated tests must not call real AI.

## Manual Student Test Flow

1. Verify Java:

```bash
java -version
```

2. Start emulators:

```bash
firebase emulators:start
```

3. Seed data:

```bash
cd functions
npm run seed:flutter-real-ai-e2e
```

4. Run Flutter:

```bash
cd apps/teoryx_app
flutter run -d linux \
  --dart-define=TEORYX_FIREBASE_ENABLED=true \
  --dart-define=TEORYX_FIREBASE_CONFIGURED=true \
  --dart-define=TEORYX_USE_FIREBASE_EMULATORS=true \
  --dart-define=TEORYX_FIREBASE_EMULATOR_HOST=localhost
```

5. Open the Grade 4 Math Real AI E2E course.
6. Open one seeded missing-content lesson.
7. Confirm loading state appears.
8. Confirm the lesson is generated and rendered.
9. Repeat with the remaining seeded lessons.

## Verification

Required automated verification:

```bash
cd functions
npm run build
npm test

cd ../apps/teoryx_app
flutter analyze
flutter test
```

Focused seed verification:

```bash
cd functions
npm run seed:verify:flutter-real-ai-e2e
```

## Readiness

CE-17C makes the local student test seed repeatable once Java and Firebase Emulator Suite are available in the local environment.

Next recommended milestone:

```text
CE-17D Live Manual Emulator Student Run
```
