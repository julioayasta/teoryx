# Sprint CE-17B: First Real Student Experience

## Purpose

CE-17B focuses on evidence, not new architecture.

Target student experience:

```text
Open Flutter
-> see an available course
-> open a lesson
-> request missing lesson content
-> receive generated content
-> read the lesson in the app
```

Scope remained limited to dev/emulator validation, hardening, and reporting. No new pedagogical models, Asset Registry, Media Generation, Assessment Generation, School Portal workflow, or architecture redesign were added.

## AI Provider Used

Real AI was not used.

Reason:

```text
OPENAI_API_KEY was not available in the execution environment.
```

CE-17B therefore used `SafeFakeAIProvider` for the provider-backed generation path after a blocker fix described below.

## E2E Validation Result

### Automated Runtime Path

Validated:

```text
LessonSpecification
-> requestLessonContent runtime handler
-> Content Engine
-> SafeFakeAIProvider
-> LessonArtifact
-> PresentationArtifact
-> ValidationArtifact
-> publishedLessonContent
-> LessonSpecification.publishedContentId
```

Result:

```text
PASS with SafeFakeAIProvider
```

Generated lesson count:

```text
5
```

Generated records:

```text
publishedLessonContent: 5
updated LessonSpecifications: 5
PromptExecutionRecord: 5
CostTrackingRecord: 5
GenerationAuditEntry: 10
ProvenanceRecord: 15
VersionHistory: 10
```

Supported step types were preserved:

```text
story
imagePlaceholder
explanation
question
practice
summary
```

### Live Firebase Emulator Path

Attempted:

```text
firebase emulators:exec --only firestore,functions,auth ...
```

Result:

```text
BLOCKED
```

The Firebase CLI could not start emulators because Java was not available on `PATH`.

## Five Generated Lessons

The five generated lessons used Grade 4 Math fraction standards and matching pedagogical analyses in the validation harness.

| LessonSpecification | Published Content | Title |
| --- | --- | --- |
| `lesson-spec-grade-4-math-real-4-nf-a-1` | `published-content-lesson-spec-grade-4-math-real-4-nf-a-1` | Explain Equivalent Fractions |
| `lesson-spec-grade-4-math-real-4-nf-a-2` | `published-content-lesson-spec-grade-4-math-real-4-nf-a-2` | Compare Fractions With Different Denominators |
| `lesson-spec-grade-4-math-real-4-nf-b-3` | `published-content-lesson-spec-grade-4-math-real-4-nf-b-3` | Add Fractions With Like Denominators |
| `lesson-spec-grade-4-math-real-4-nf-b-4` | `published-content-lesson-spec-grade-4-math-real-4-nf-b-4` | Multiply Fractions By Whole Numbers |
| `lesson-spec-grade-4-math-real-4-nf-c-5` | `published-content-lesson-spec-grade-4-math-real-4-nf-c-5` | Add Tenths And Hundredths |

## Lesson Quality Observations

Evaluated as a learner.

### Clarity

The lessons are easy to understand at a surface level. Each lesson tells the student what the topic is, gives a simple objective, and moves through a predictable sequence.

Concern:

The explanations are too generic. A learner would know the topic, but would not yet receive enough mathematical modeling to feel confident.

### Engagement

The lesson flow is friendly and non-intimidating.

Concern:

The SafeFake lessons are repetitive. They do not yet feel like rich student-facing content. They need concrete examples, visual descriptions, and more natural language to feel engaging.

### Difficulty

The generated text is not too difficult for Grade 4.

Concern:

The difficulty is currently too low because the examples are placeholders. Students who need real instruction would need worked examples and guided reasoning.

### Flow

The step sequence works well:

```text
story
imagePlaceholder
explanation
question
practice
summary
```

This is a good rendering contract for the Student App.

Concern:

The practice step is too thin. It asks the student to try an example, but does not provide a real example.

### Usefulness

Useful for validating the app/runtime flow.

Not yet useful as real instructional content when using SafeFakeAIProvider.

Real AI or a richer deterministic provider is needed before judging actual lesson quality.

## Blockers Found

### Blocker 1: Firebase Emulator Cannot Start

Risk:

```text
High
```

Root cause:

Firebase CLI requires Java for the emulators, but `java` is not available on `PATH`.

Observed error:

```text
Could not spawn `java -version`. Please make sure Java is installed and on your system PATH.
```

File/module involved:

```text
firebase.json
local developer environment
Firebase CLI emulator runtime
```

Minimal fix:

Install a supported JDK and ensure `java -version` works from the same shell used to run Firebase CLI.

Status:

```text
Addressed in CE-17C documentation
```

### Blocker 2: SafeFakeAIProvider Did Not Produce Lesson JSON

Risk:

```text
High
```

Root cause:

When real AI credentials were unavailable, CE-17B needed to use `SafeFakeAIProvider`. The provider recorded AI execution, but for `lesson_content_generation` it returned a deterministic placeholder string instead of the structured JSON required by the lesson content contract.

File/module involved:

```text
functions/src/content-engine/ai/safe-fake-ai-provider.ts
functions/test/content-engine/ai-provider.test.ts
```

Minimal fix:

Updated `SafeFakeAIProvider` so `lesson_content_generation` returns deterministic structured lesson JSON compatible with the current Student App published lesson contract.

Status:

```text
Fixed
```

### Blocker 3: CE-16 Seed Has Only One LessonSpecification

Risk:

```text
Medium
```

Root cause:

The CE-16 emulator seed creates one missing-content lesson specification. CE-17B required five lesson generations.

File/module involved:

```text
functions/src/content-engine/seed/seed-flutter-real-ai-e2e.ts
```

Minimal fix:

Expand the dev seed to include at least five LessonSpecifications with matching CurriculumStandard and PedagogicalAnalysis records, or generate the five from the existing course-planning runtime before manual testing.

Status:

```text
Fixed in CE-17C
```

CE-17B used a temporary validation harness outside the repository to seed five in-memory lesson specifications for evidence gathering. CE-17C expanded the repository seed to five LessonSpecifications and added a focused seed verification command.

## Fixes Applied

Runtime fix:

- `SafeFakeAIProvider` now emits valid structured lesson JSON for `lesson_content_generation`.

Test fix:

- SafeFake provider test now parses and validates generated lesson JSON and supported step types.

No Flutter UI changes were made.

## Screenshots Or References

No screenshots were captured.

Reason:

The live Firebase emulator path was blocked before Flutter could be run against emulator data.

References:

- `docs/sprints/sprint-ce-16-flutter-real-ai-e2e-test.md`
- `functions/src/content-engine/ai/safe-fake-ai-provider.ts`
- `functions/test/content-engine/ai-provider.test.ts`

## Verification Results

Backend:

```text
npm run build: PASS
npm test: PASS
Node tests: 79 passed
```

Flutter:

```text
flutter analyze: PASS
flutter test: PASS
Flutter tests: 15 passed
```

Environment note:

The validation environment uses Windows tools against a WSL workspace. Passing commands used a temporary mapped drive with `subst` to avoid raw `\\wsl$` working-directory issues.

## Recommendations

Before repeated manual testing:

1. Install Java and verify:

```bash
java -version
```

2. Rerun:

```bash
firebase emulators:start
```

3. Expand the CE-16 seed to include five missing-content LessonSpecifications, or add a dev-only seed command for CE-17B.

4. Run the Flutter app in emulator mode and capture screenshots of:

- Course list
- Lesson list
- Missing-content loading state
- Generated lesson detail

5. If credentials are available, run one real OpenAI generation and compare quality against the SafeFake lesson.

## Readiness Assessment

Student experience runtime:

```text
PARTIALLY READY
```

Why:

- The Content Engine runtime can generate and publish five lessons with a provider-backed path.
- The generated content contract is compatible with Student App rendering.
- Automated backend and Flutter tests pass.

Not yet fully ready for repeated manual testing because:

- Firebase emulators cannot start until Java is installed.
- The current CE-16 seed provides only one lesson specification.
- Real AI generation was not executed in this environment.

Recommended next milestone:

```text
CE-17C Emulator Environment Closure
```

CE-17C should install/verify Java, expand or add a dev seed for five LessonSpecifications, execute the live Flutter emulator path, and capture screenshots.
