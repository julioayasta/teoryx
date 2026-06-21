# ADR-004: Curriculum Domain Architecture

## Status

Accepted

## Date

2025-06

## Context

TeoryX genera lecciones, evaluaciones y tutoría IA a partir de estándares académicos oficiales.

El dominio curricular debe soportar:

- K-12
- múltiples grados
- múltiples materias
- múltiples currículos oficiales
- contenido multiidioma
- escuelas multi-tenant
- generación de contenido por IA
- seguimiento de progreso académico

## Decision

TeoryX modelará el currículo como un dominio global reutilizable.

Las escuelas consumirán contenido curricular global, pero el progreso de los estudiantes será siempre específico de cada escuela.

## Core Rule

Toda lección debe originarse desde un estándar académico oficial.

Standard
↓
LearningObjective
↓
Assessment
↓
Lesson
↓
TutorPrompt
↓
Progress

## Global Entities

Estas entidades pueden ser compartidas entre escuelas:

- Curriculum
- GradeLevel
- Subject
- Standard
- Unit
- LearningObjective
- Lesson
- Assessment
- Question
- TutorPrompt

## Tenant-Specific Entities

Estas entidades siempre pertenecen a una escuela:

- Student
- Parent
- User
- Progress
- AssessmentAttempt
- TutorSession

Deben incluir:

- schoolId

## AI Generation Constraint

La IA no puede generar lecciones sin:

- curriculumId
- gradeLevelId
- subjectId
- standardId
- language

## Multi-Language Strategy

Los estándares oficiales son la fuente de verdad.

El contenido generado puede tener múltiples versiones por idioma.

Ejemplo:

- Standard: CCSS.MATH.4.NF.A.1
- Lesson EN
- Lesson ES

Ambas versiones deben apuntar al mismo standardId.

## MVP Scope

El MVP usará inicialmente:

- California Common Core
- Grade 3
- Grade 4
- Grade 5
- Math
- ELA
- English
- Spanish

Pero la arquitectura debe soportar K-12 y futuros currículos.

## Consequences

### Positive

- Separación clara entre contenido global y datos escolares
- Mejor reutilización de lecciones
- Mejor soporte multiidioma
- Mejor control de calidad curricular
- Menor duplicación de contenido

### Negative

- Mayor complejidad inicial
- Requiere versionamiento de contenido
- Requiere revisión de contenido generado por IA

## Future Considerations

- School-specific lesson overrides
- Teacher-reviewed lesson versions
- Adaptive remediation lessons
- Curriculum import tools
- Standards alignment verification
- AI content quality scoring

## Guiding Principle

Official Standards First.

TeoryX enseña desde estándares oficiales, no desde prompts libres.
