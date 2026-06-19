# ADR-003: Curriculum Strategy

## Status

Accepted

## Date

2025-06

## Context

TeoryX tiene como objetivo generar experiencias educativas mediante inteligencia artificial alineadas a estándares académicos oficiales.

El alcance potencial del proyecto incluye:

* K-12
* College
* University
* Corporate Training
* Multi-language
* Multi-country

Intentar soportar todos estos dominios desde el MVP incrementaría significativamente la complejidad técnica, pedagógica y operativa.

Se requiere una estrategia curricular incremental.

---

## Decision

TeoryX v0.1 se enfocará exclusivamente en:

### Geography

United States

### State

California

### Curriculum

California Common Core Standards

### Grade Levels

* Grade 3
* Grade 4
* Grade 5

### Subjects

* Mathematics
* English Language Arts (ELA)

---

## Rationale

### Educational Focus

Math y ELA representan las áreas académicas con mayor cobertura y relevancia dentro del currículo K-12.

### AI Validation

Permiten validar:

* generación de lecciones
* generación de evaluaciones
* tutoría IA
* seguimiento de progreso
* adaptación de contenido

### Reduced Complexity

Limitar el alcance reduce:

* volumen curricular
* costo de generación
* esfuerzo de validación
* mantenimiento inicial

### Faster MVP Delivery

Permite lanzar una primera versión funcional sin esperar cobertura curricular completa.

---

## Curriculum Hierarchy

Curriculum
↓
Grade Level
↓
Subject
↓
Standard
↓
Unit
↓
Lesson
↓
Assessment

---

## Domain Additions

### Curriculum

Attributes:

* id
* name
* country
* state
* version
* status

Example:

California Common Core 2025

---

### Standard

Attributes:

* id
* curriculumId
* gradeLevelId
* subjectId
* code
* description

Example:

CCSS.MATH.4.NF.A.1

---

## AI Content Generation Inputs

Every lesson generation request must include:

* curriculumId
* gradeLevelId
* subjectId
* standardId
* language

The AI must not generate content without an associated academic standard.

---

## Multi-Language Strategy

Initial supported languages:

* English
* Spanish

The academic standard remains the source of truth regardless of display language.

Example:

Standard:
CCSS.MATH.4.NF.A.1

Lesson Language:
English
Spanish

Both lessons must remain aligned to the same standard.

---

## Future Expansion

### Additional Grades

* Kindergarten
* Grade 1
* Grade 2
* Grade 6-12

### Additional Subjects

* Science
* History
* Social Studies
* Computer Science

### Additional Curricula

* NGSS
* Texas TEKS
* IB
* AP
* Corporate Learning Tracks

### Additional Countries

* Canada
* Mexico
* Brazil
* Spain

---

## Constraints

The MVP must not attempt to support:

* multiple curriculum engines
* curriculum customization by school
* college programs
* university programs
* corporate training

These capabilities will be evaluated after successful validation of the K-12 California Common Core model.

---

## Consequences

### Positive

* Reduced scope
* Faster delivery
* Easier curriculum validation
* Higher quality AI-generated lessons
* Lower operational complexity

### Negative

* Limited initial market
* Requires future curriculum expansion

The benefits outweigh the limitations during MVP development.

---

## Guiding Principle

Depth before Breadth.

TeoryX will first demonstrate high-quality educational outcomes in a limited curricular scope before expanding to additional grades, subjects and markets.
