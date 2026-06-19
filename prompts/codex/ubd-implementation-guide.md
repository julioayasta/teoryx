# TeoryX - UbD Implementation Guide for Codex

## Objective

Implement the TeoryX learning engine following Backward Design principles.

---

# Rule 1

Lesson generation cannot start from content.

Lesson generation must start from:

LearningObjective

Example:

{
"learningObjective": "Understand fractions"
}

---

# Rule 2

Every lesson must contain:

{
"bigIdea": "",
"essentialQuestion": "",
"learningObjective": ""
}

These fields are mandatory.

---

# Rule 3

Assessment must be generated before lesson content.

Pipeline:

Learning Objective
→ Assessment
→ Lesson
→ Tutor Prompt

---

# Rule 4

Progress Tracking

Progress cannot be based on:

* login count
* time spent

Progress must be based on:

* assessment attempts
* mastery score
* lesson completion

---

# Rule 5

Firestore Entities

Lesson

{
id,
gradeLevelId,
subjectId,
bigIdea,
essentialQuestion,
learningObjective,
lessonContent
}

Assessment

{
id,
lessonId,
passingScore
}

Progress

{
id,
studentId,
lessonId,
masteryLevel,
completionPercentage
}

---

# Rule 6

AI Generation Pipeline

Input:

Grade
Subject
Standard

Output:

Assessment
Lesson
Tutor Prompt

Generation order is mandatory.

---

# Rule 7

Future Compatibility

All lesson content must support:

* multiple languages
* multiple schools
* multiple curriculum standards

No hardcoded curriculum assumptions.

Store:

curriculumId
language
schoolId

when applicable.

---

# Success Criteria

Student can:

1. Receive AI-generated lesson.
2. Complete assessment.
3. Obtain mastery score.
4. Continue to next lesson.

Parent can:

1. View mastery progress.

School can:

1. View aggregated mastery metrics.
