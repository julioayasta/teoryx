# TeoryX MVP Vision v0.1

## Project Name

TeoryX

## Product Vision

TeoryX es una plataforma educativa multi-tenant impulsada por inteligencia artificial que ayuda a estudiantes K-12 a aprender mediante tutoría personalizada, generación de lecciones alineadas al currículo y seguimiento continuo del progreso académico.

La plataforma permite la participación de estudiantes, padres y escuelas dentro de un ecosistema seguro y escalable.

## Initial Target Market

K-12 Schools
California, USA

## Primary Users

### Student

- Accede a lecciones
- Interactúa con el tutor IA
- Realiza evaluaciones
- Consulta su progreso

### Parent

- Supervisa el progreso académico
- Consulta reportes
- Identifica áreas de mejora

### School Administrator

- Administra estudiantes
- Consulta métricas institucionales
- Configura identidad visual básica

### Super Admin (TeoryX)

- Administra todas las escuelas
- Gestiona contenidos globales
- Gestiona configuración global
- Supervisa métricas generales

## Core MVP Features

### Authentication

- Login seguro
- Roles y permisos

### Student Profile

- Información básica
- Grado académico

### Curriculum Navigation

- Grado
- Materia
- Unidad
- Lección

### AI Tutor

- Conversación contextual
- Explicaciones adaptadas
- Apoyo al aprendizaje

### Assessments

- Quizzes automáticos
- Retroalimentación inmediata

### Progress Tracking

- Avance por materia
- Resultados de evaluaciones
- Indicadores de dominio

### Parent Dashboard

- Visualización de progreso
- Alertas académicas

## Multi-Tenant Strategy

Cada escuela tendrá:

- Logo
- Colores institucionales
- Usuarios propios
- Datos aislados

Todos los registros estarán asociados a un schoolId.

## Internationalization

Idiomas iniciales:

- English
- Spanish

Arquitectura preparada para múltiples idiomas.

## AI Content Strategy

Las lecciones serán generadas a partir de:

Curriculum Standards
+
Learning Objectives
+
Prompt Engineering
+
LLM

Principio:

Curriculum First
AI Second

## Technical Stack

Frontend:
- Flutter

Backend:
- Firebase

Database:
- Cloud Firestore

Authentication:
- Firebase Auth

Storage:
- Firebase Storage

Cloud:
- Google Cloud Platform

## Non Goals For MVP

- Attendance
- Messaging interno
- Video clases
- Integraciones SIS
- Marketplace
- Corporate Training

## Success Criteria

El estudiante puede:

1. Iniciar sesión
2. Seleccionar materia
3. Acceder a una lección
4. Conversar con el tutor IA
5. Resolver una evaluación
6. Registrar progreso

El padre puede:

1. Iniciar sesión
2. Consultar progreso académico

La escuela puede:

1. Consultar métricas básicas
2. Gestionar estudiantes
