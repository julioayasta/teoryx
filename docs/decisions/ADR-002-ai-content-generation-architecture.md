# ADR-002: AI Content Generation Architecture

## Status

Accepted

## Date

2025-06

## Context

TeoryX generará lecciones mediante inteligencia artificial.

El riesgo principal es permitir que la IA genere contenido libremente sin estructura pedagógica, lo cual puede producir lecciones inconsistentes, desalineadas al currículo o difíciles de evaluar.

## Decision

TeoryX usará un motor de generación basado en Backward Design.

La IA no debe comenzar generando contenido de lección.

Debe seguir este orden obligatorio:

Curriculum Standard
↓
Learning Objective
↓
Assessment Blueprint
↓
Lesson Content
↓
Tutor Prompt
↓
Progress Tracking

## Core Principle

Curriculum First  
AI Second

## Generation Pipeline

### Stage 1: Desired Results

Input:

- gradeLevel
- subject
- curriculumStandard
- language

Output:

- bigIdea
- essentialQuestion
- learningObjective
- desiredUnderstanding

### Stage 2: Assessment Blueprint

Input:

- learningObjective
- desiredUnderstanding

Output:

- assessmentType
- successCriteria
- passingScore
- questions

### Stage 3: Lesson Generation

Input:

- learningObjective
- essentialQuestion
- assessmentBlueprint
- language

Output:

- lessonTitle
- explanation
- examples
- guidedPractice
- independentPractice
- summary

### Stage 4: Tutor Prompt Generation

Input:

- lessonContent
- learningObjective
- studentGradeLevel
- language

Output:

- tutorSystemPrompt
- tutorBehaviorRules
- safetyRules

### Stage 5: Progress Tracking

Input:

- lessonCompletion
- assessmentAttempt
- tutorInteractionSummary

Output:

- masteryLevel
- completionPercentage
- recommendedNextAction

## Required Lesson Fields

Every AI-generated lesson must include:

- schoolId
- curriculumId
- gradeLevelId
- subjectId
- language
- bigIdea
- essentialQuestion
- learningObjective
- desiredUnderstanding
- lessonContent
- assessmentId
- aiGenerated
- version
- status

## Multi-Language Requirement

All generated content must include a language field.

Initial supported languages:

- en
- es

Future languages must not require data model redesign.

## Safety Requirement

AI-generated educational content must be reviewable before publication.

Lesson status values:

- draft
- review
- published
- archived

## Human Review Strategy

For MVP, TeoryX may allow Super Admin to publish generated lessons.

Future versions may allow School Admin review.

## Progress Principle

Progress is not based only on time spent.

Progress must be based on:

- lesson completion
- assessment score
- mastery level
- repeated practice
- improvement over time

## Implications

### Positive

- Lessons are aligned to learning goals
- Assessments are meaningful
- Progress tracking becomes measurable
- AI output is structured
- Supports multi-language content

### Negative

- More complex generation pipeline
- Requires storing intermediate artifacts
- Requires prompt templates
- Requires content review workflow

## Future Considerations

- RAG with curriculum standards
- Versioned curriculum libraries
- Teacher approval workflow
- Adaptive lesson generation
- Personalized remediation paths
- AI safety audits
