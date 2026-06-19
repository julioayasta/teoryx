# TeoryX Domain Model v0.1

## School

Representa una institución educativa.

Attributes:

- id
- name
- logoUrl
- primaryColor
- secondaryColor
- status
- createdAt

Relationships:

- has many Users
- has many Students
- has many Parents

---

## User

Representa una identidad autenticada.

Attributes:

- id
- schoolId
- email
- role
- status

Roles:

- super_admin
- school_admin
- parent
- student

---

## Student

Representa un estudiante.

Attributes:

- id
- schoolId
- userId
- firstName
- lastName
- gradeLevelId
- preferredLanguage

Relationships:

- belongs to School
- belongs to GradeLevel
- has many Progress Records
- has many Assessment Attempts

---

## Parent

Representa un padre o tutor.

Attributes:

- id
- schoolId
- userId
- firstName
- lastName

Relationships:

- belongs to School
- has many Students

---

## GradeLevel

Representa un grado académico.

Examples:

- Kindergarten
- Grade 1
- Grade 2
- Grade 3
- ...
- Grade 12

Attributes:

- id
- code
- name

---

## Subject

Representa una materia.

Examples:

- Math
- Science
- English
- History

Attributes:

- id
- code
- name

---

## Lesson

Representa una lección académica.

Attributes:

- id
- gradeLevelId
- subjectId
- title
- learningObjective
- language
- aiGenerated
- version

Relationships:

- belongs to GradeLevel
- belongs to Subject

---

## Assessment

Representa una evaluación.

Attributes:

- id
- lessonId
- title
- passingScore

Relationships:

- belongs to Lesson

---

## Question

Representa una pregunta.

Attributes:

- id
- assessmentId
- questionText
- answerOptions
- correctAnswer

Relationships:

- belongs to Assessment

---

## AssessmentAttempt

Representa un intento de evaluación.

Attributes:

- id
- studentId
- assessmentId
- score
- completedAt

Relationships:

- belongs to Student
- belongs to Assessment

---

## Progress

Representa el progreso académico.

Attributes:

- id
- studentId
- lessonId
- completionPercentage
- masteryLevel
- lastActivityAt

Relationships:

- belongs to Student
- belongs to Lesson
