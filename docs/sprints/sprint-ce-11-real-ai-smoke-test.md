# Sprint CE-11: Real AI Smoke Test in Emulator

## Purpose

CE-11 adds a manual smoke test for one controlled real AI-backed lesson generation run in development. It verifies that the CE-10 OpenAI provider path can generate one lesson through the existing Content Engine runtime:

LessonSpecification -> requestLessonContent -> AIExecutionService -> LessonArtifact -> PresentationArtifact -> ValidationArtifact -> publishedLessonContent.

This smoke test is not part of the default test suite and must be run explicitly.

## Safety Rules

- Do not run this script in production.
- Do not commit `.env` files or API keys.
- Do not paste or log `OPENAI_API_KEY`.
- SafeFakeAIProvider remains the default for normal runtime and tests.
- Real AI is used only when all required environment variables are explicitly set.
- The script runs one LessonSpecification only.
- The script does not generate images, assessments, or media assets.

## Required Environment Variables

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=true
CONTENT_ENGINE_AI_PROVIDER=openai
OPENAI_API_KEY=your_api_key_here
```

Optional:

```bash
CONTENT_ENGINE_OPENAI_MODEL=gpt-4.1-mini
CONTENT_ENGINE_OPENAI_ENDPOINT=https://api.openai.com/v1/responses
```

## How To Run

From the functions workspace:

```bash
cd functions
CONTENT_ENGINE_ENABLE_REAL_AI=true \
CONTENT_ENGINE_AI_PROVIDER=openai \
OPENAI_API_KEY=your_api_key_here \
npm run smoke:real-ai-lesson
```

On Windows PowerShell, set environment variables for the current shell before running the script:

```powershell
$env:CONTENT_ENGINE_ENABLE_REAL_AI="true"
$env:CONTENT_ENGINE_AI_PROVIDER="openai"
$env:OPENAI_API_KEY="your_api_key_here"
npm run smoke:real-ai-lesson
```

## Expected Output

The script prints a short success summary:

```text
Real AI lesson smoke test passed.
publishedContentId: published-content-lesson-spec-smoke-001
title: ...
steps: 6
provider: openai
model: ...
promptTemplateVersionId: ...
estimatedInputTokens: ...
estimatedOutputTokens: ...
estimatedCostUsd: ...
```

The script verifies:

- `requestLessonContent` returns `ready`.
- `publishedLessonContent` exists.
- Published lesson steps use supported Student App step types only.
- `PromptExecutionRecord` exists.
- `CostTrackingRecord` exists.

## Safe Exit Behavior

If any required flag or API key is missing, the script exits safely before making a provider call:

```text
Real AI smoke test skipped safely: OPENAI_API_KEY is required and was not provided.
```

The API key is never printed.

## Cost Warning

This script can make a real OpenAI API call and may incur cost. Run it only when an operator intentionally wants a single real-provider smoke test.

Normal verification remains:

```bash
npm run build
npm test
```

Those commands do not run the real AI smoke test.

## How To Disable Real AI

Unset or change any required variable:

```bash
unset CONTENT_ENGINE_ENABLE_REAL_AI
unset CONTENT_ENGINE_AI_PROVIDER
unset OPENAI_API_KEY
```

Or set:

```bash
CONTENT_ENGINE_ENABLE_REAL_AI=false
```

With real AI disabled, Content Engine continues to use `SafeFakeAIProvider` by default.
