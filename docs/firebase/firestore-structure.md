# Firestore Structure

Sprint 05.2 prepares read access behind repository boundaries. Mock
repositories remain the default source for screens.

## Collections

```text
schools/{schoolId}
schools/{schoolId}/students/{studentId}
schools/{schoolId}/courses/{courseId}
schools/{schoolId}/studentProgress/{studentId}
publishedLessonContent/{publishedContentId}
```

## schools/{schoolId}

Tenant branding and configuration.

```text
name
fullName
logoUrl
logoAssetPath
primaryColor
secondaryColor
fontFamily
status
createdAt
updatedAt
```

## schools/{schoolId}/students/{studentId}

Tenant-owned student profile data.

```text
firstName
lastName
gradeLevelId
gradeLevelName
subjectName
preferredLanguage
status
createdAt
updatedAt
```

## schools/{schoolId}/courses/{courseId}

Tenant-visible course catalog entries.

```text
curriculumId
gradeLevelId
gradeLevelName
subjectId
subjectName
title
status
order
createdAt
updatedAt
```

## schools/{schoolId}/studentProgress/{studentId}

Tenant-owned student progress summary. Detailed progress can be expanded in a
later sprint.

```text
studentId
currentCourseId
currentLessonId
masteryLevel
completionPercentage
lastActivityAt
updatedAt
```

## publishedLessonContent/{publishedContentId}

Read-only published lesson content for the Student App. The Student App must not
create or modify documents in this collection.

```text
schoolId
courseId
curriculumId
gradeLevelId
subjectId
standardId
standardCode
language
title
bigIdea
essentialQuestion
learningObjectiveId
learningObjective
lessonContent
guidedPractice
independentPractice
summary
steps
status
version
createdAt
updatedAt
```

Each `steps` item uses:

```text
id
lessonId
order
type
title
body
prompt
expectedAnswer
imageDescription
```

## Fallback Rules

- Mock repositories remain default unless Firebase is enabled and configured.
- Firestore repositories live in data layers only.
- Presentation files must not import Firebase packages.
- Missing school theme falls back to the configured K2S theme.
- Missing student/course/lesson content falls back to current mock data where
  appropriate for prototype continuity.
