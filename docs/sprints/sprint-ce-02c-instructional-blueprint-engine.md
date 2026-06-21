# Sprint CE-02C - Instructional Blueprint Engine

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the Instructional Blueprint Engine for the TeoryX Content Engine.

This layer converts an approved `PedagogicalAnalysis` into generation-ready blueprints that later drive lesson, assessment, tutor, media, and presentation generation.

This sprint defines blueprints only. It does not generate final lesson content, assessment questions, tutor prompts, media assets, or presentation contracts.

## Scope

This sprint designs:

- `LearningObjective`
- `MasteryDefinition`
- `EvidenceRequirement`
- `AssessmentBlueprint`
- `LessonBlueprint`
- `TutorBlueprint`
- `MediaBlueprint`
- Firestore collection proposal
- validation rules
- failure scenarios
- CE-02D recommendation

## Non-Scope

This sprint does not implement:

- Content Engine code
- AI generation
- lesson content
- assessment items
- tutor prompt text
- generated media
- Firestore writes
- Student App changes
- School Admin Portal changes

## UbD Sequence

The Instructional Blueprint Engine follows Understanding by Design.

The required order is:

```text
Desired Results
-> Acceptable Evidence
-> Learning Plan
```

Mapped to TeoryX:

```text
LearningObjective / MasteryDefinition
-> EvidenceRequirement / AssessmentBlueprint
-> LessonBlueprint / TutorBlueprint / MediaBlueprint
```

`AssessmentBlueprint` must be produced before `LessonBlueprint`.

The lesson plan must be shaped by the evidence of mastery, not the other way around.

## Position In Content Engine

The broader Content Engine sequence becomes:

```text
Official Curriculum Standard
-> Pedagogical Analysis
-> Learning Objective
-> Mastery Definition
-> Evidence Requirements
-> Assessment Blueprint
-> Lesson Blueprint
-> Tutor Blueprint
-> Media Blueprint
-> future generation artifacts
```

Future generation artifacts may include:

- generated lesson content
- generated assessment questions
- generated tutor prompt
- generated media requests
- generated presentation contract

This sprint stops at the blueprint layer.

## Desired Results

Desired Results define what students should understand and be able to do.

Inputs:

```text
pedagogicalAnalysisId
standardId
curriculumSourceId
curriculumVersionId
gradeLevelId
subjectId
language
languageProfileId
```

Outputs:

```text
LearningObjective
MasteryDefinition
```

### LearningObjective

Defines the student-facing learning target derived from the standard and pedagogical analysis.

Fields:

```text
id
pedagogicalAnalysisId
standardId
curriculumSourceId
curriculumVersionId
standardCode
gradeLevelId
subjectId
language
statement
studentFriendlyStatement
essentialUnderstanding
targetSkillIds
academicVocabularyTerms
languageProfileId
status
createdAt
updatedAt
```

Rules:

1. Must derive from `PedagogicalAnalysis`.
2. Must preserve official curriculum intent.
3. Must be measurable.
4. Must be grade-level appropriate.
5. Must not include lesson content.

### MasteryDefinition

Defines what mastery means for a learning objective.

Fields:

```text
id
learningObjectiveId
pedagogicalAnalysisId
standardId
masteryStatement
successCriteria
performanceIndicators
minimumEvidenceRequirements
commonNonMasterySignals
status
createdAt
updatedAt
```

Rules:

1. Must define observable mastery.
2. Must map to target skills from `PedagogicalAnalysis`.
3. Must support assessment blueprinting.
4. Must not define specific assessment questions.

## Acceptable Evidence

Acceptable Evidence defines how mastery can be proven.

Inputs:

```text
LearningObjective
MasteryDefinition
PedagogicalAnalysis.assessmentEvidence
PedagogicalAnalysis.misconceptions
```

Outputs:

```text
EvidenceRequirement
AssessmentBlueprint
```

### EvidenceRequirement

Defines the evidence needed to show mastery.

Fields:

```text
id
learningObjectiveId
masteryDefinitionId
pedagogicalAnalysisId
standardId
evidenceType
description
successCriteria
targetSkillIds
misconceptionIds
acceptableResponseSignals
reviewRequirement
status
createdAt
updatedAt
```

Allowed evidence types:

```text
selected_response
short_answer
constructed_response
performance_task
oral_explanation
worked_example
project_artifact
teacher_review
```

### AssessmentBlueprint

Defines assessment structure, not final assessment questions.

`AssessmentBlueprint` comes before `LessonBlueprint`.

Fields:

```text
id
learningObjectiveId
masteryDefinitionId
pedagogicalAnalysisId
standardId
curriculumSourceId
curriculumVersionId
gradeLevelId
subjectId
language
assessmentPurpose
assessmentMode
itemSpecs
evidenceRequirementIds
misconceptionCoverage
passingCriteria
reviewPolicy
status
createdAt
updatedAt
```

Allowed assessment purposes:

```text
diagnostic
formative
summative
remediation_check
```

Allowed assessment modes:

```text
auto_graded
teacher_review
hybrid
```

Rules:

1. Must map to `EvidenceRequirement`.
2. Must map to `MasteryDefinition`.
3. Must include misconception coverage where relevant.
4. Must define item specifications only.
5. Must not contain final assessment questions or answer keys.

### AssessmentItemSpec

Defines a future assessment item requirement.

Fields:

```text
id
assessmentBlueprintId
order
itemType
targetSkillIds
evidenceRequirementId
misconceptionIds
difficulty
languageComplexity
scoringApproach
requiresTeacherReview
```

Allowed item types:

```text
multiple_choice
multi_select
short_answer
constructed_response
worked_example
matching
ordering
performance_task
```

## Learning Plan

The Learning Plan defines the shape of instruction after evidence has been defined.

Outputs:

```text
LessonBlueprint
TutorBlueprint
MediaBlueprint
```

These are planning artifacts only. They do not contain final generated lesson text, tutor prompt text, or generated media.

## LessonBlueprint

Defines instructional structure, not lesson content.

Fields:

```text
id
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
pedagogicalAnalysisId
standardId
curriculumSourceId
curriculumVersionId
gradeLevelId
subjectId
language
lessonType
instructionalSequence
segmentPlans
vocabularyPlan
misconceptionPlan
practicePlan
reflectionPlan
status
createdAt
updatedAt
```

Allowed lesson types:

```text
concept_introduction
guided_practice
remediation
review
extension
application
```

Rules:

1. Must be based on `AssessmentBlueprint`.
2. Must address the required evidence of mastery.
3. Must plan instruction without writing final lesson content.
4. Must preserve the student experience goal: a teacher guiding a student who missed class.

### LessonSegmentPlan

Defines a planned instructional segment.

Fields:

```text
id
lessonBlueprintId
order
segmentType
purpose
targetSkillIds
vocabularyTerms
misconceptionIds
estimatedDuration
interactionType
```

Allowed segment types:

```text
hook
concept_explanation
worked_example
guided_practice
independent_practice
check_for_understanding
reflection
summary
```

## TutorBlueprint

Defines tutor behavior boundaries, not tutor prompt text.

The future `TutorPrompt` should be generated from `TutorBlueprint`, but this sprint does not create that prompt.

Fields:

```text
id
learningObjectiveId
masteryDefinitionId
assessmentBlueprintId
lessonBlueprintId
pedagogicalAnalysisId
standardId
gradeLevelId
subjectId
language
allowedSupportMoves
restrictedSupportMoves
misconceptionResponses
hintPolicy
answerPolicy
safetyBoundaries
escalationRules
status
createdAt
updatedAt
```

Rules:

1. Must define what the tutor may and may not do.
2. Must preserve student safety.
3. Must not provide final tutor prompt text.
4. Must not allow the tutor to change curriculum intent.
5. Must align support to the `LessonBlueprint` and `AssessmentBlueprint`.

### TutorInterventionRule

Defines a planned tutor intervention.

Fields:

```text
id
tutorBlueprintId
trigger
allowedResponseType
targetSkillIds
misconceptionIds
scaffoldingLevel
escalationRequired
```

Allowed response types:

```text
hint
clarifying_question
worked_step
analogy
vocabulary_support
misconception_correction
encouragement
teacher_escalation
```

## MediaBlueprint

Defines media needs, not generated media assets.

The future media system may use this blueprint to request or select images, diagrams, audio, video, interactives, or simulations.

Fields:

```text
id
learningObjectiveId
lessonBlueprintId
pedagogicalAnalysisId
standardId
gradeLevelId
subjectId
language
mediaRequirements
accessibilityRequirements
visualSupportPurpose
culturalSafetyNotes
status
createdAt
updatedAt
```

Rules:

1. Must identify needed media support.
2. Must not generate, store, or select final assets.
3. Must include accessibility expectations.
4. Must align media needs to lesson segments and target skills.

### MediaRequirement

Defines one future media need.

Fields:

```text
id
mediaBlueprintId
lessonSegmentPlanId
mediaType
purpose
description
targetSkillIds
accessibilityNotes
required
```

Allowed media types:

```text
image
diagram
audio
video
interactive
simulation
manipulative
```

## Traceability Rules

Every blueprint must store:

```text
standardId
curriculumSourceId
curriculumVersionId
pedagogicalAnalysisId
language
gradeLevelId
subjectId
promptTemplateVersionIds
validationStatus
status
createdAt
updatedAt
```

Generated artifacts must later preserve references to the blueprints used.

Example:

```text
PublishedLessonContent
-> LessonBlueprint
-> AssessmentBlueprint
-> MasteryDefinition
-> LearningObjective
-> PedagogicalAnalysis
-> CurriculumStandard
```

## Firestore Collection Proposal

Proposed top-level collections:

```text
learningObjectives/{learningObjectiveId}
masteryDefinitions/{masteryDefinitionId}
evidenceRequirements/{evidenceRequirementId}
assessmentBlueprints/{assessmentBlueprintId}
lessonBlueprints/{lessonBlueprintId}
tutorBlueprints/{tutorBlueprintId}
mediaBlueprints/{mediaBlueprintId}
blueprintValidationReports/{validationReportId}
```

Optional subcollections:

```text
assessmentBlueprints/{assessmentBlueprintId}/itemSpecs/{itemSpecId}
lessonBlueprints/{lessonBlueprintId}/segmentPlans/{segmentPlanId}
tutorBlueprints/{tutorBlueprintId}/interventionRules/{ruleId}
mediaBlueprints/{mediaBlueprintId}/requirements/{requirementId}
```

### learningObjectives/{learningObjectiveId}

Recommended indexes:

```text
standardId + pedagogicalAnalysisId + language + status
curriculumSourceId + curriculumVersionId + gradeLevelId + subjectId + status
```

### masteryDefinitions/{masteryDefinitionId}

Recommended indexes:

```text
learningObjectiveId + status
standardId + language + status
```

### evidenceRequirements/{evidenceRequirementId}

Recommended indexes:

```text
learningObjectiveId + masteryDefinitionId + status
standardId + evidenceType + status
```

### assessmentBlueprints/{assessmentBlueprintId}

Recommended indexes:

```text
learningObjectiveId + status
standardId + language + assessmentPurpose + status
```

### lessonBlueprints/{lessonBlueprintId}

Recommended indexes:

```text
assessmentBlueprintId + status
standardId + language + lessonType + status
```

### tutorBlueprints/{tutorBlueprintId}

Recommended indexes:

```text
lessonBlueprintId + status
standardId + language + status
```

### mediaBlueprints/{mediaBlueprintId}

Recommended indexes:

```text
lessonBlueprintId + status
standardId + language + status
```

### blueprintValidationReports/{validationReportId}

Fields:

```text
id
blueprintType
blueprintId
status
errors
warnings
validatedBy
validatedAt
createdAt
```

Allowed statuses:

```text
valid
valid_with_warnings
invalid
```

## Validation Rules

### UbD Order Validation

Validation must confirm:

- `LearningObjective` exists before `MasteryDefinition`
- `MasteryDefinition` exists before `EvidenceRequirement`
- `EvidenceRequirement` exists before `AssessmentBlueprint`
- `AssessmentBlueprint` exists before `LessonBlueprint`
- `LessonBlueprint` exists before `TutorBlueprint` and `MediaBlueprint`

### Curriculum Alignment Validation

Validation must confirm:

- each blueprint references the same `standardId`
- each blueprint references the same `curriculumSourceId`
- each blueprint references the same `curriculumVersionId`
- blueprint content stays within the standard boundary

### Mastery Alignment Validation

Validation must confirm:

- mastery criteria are observable
- mastery criteria map to target skills
- non-mastery signals are represented

### Evidence Alignment Validation

Validation must confirm:

- evidence requirements prove mastery
- assessment blueprint covers required evidence
- assessment item specs cover key skills and misconceptions

### Lesson Readiness Validation

Validation must confirm:

- lesson plan addresses assessment evidence
- segment plans map to target skills
- vocabulary and misconceptions are planned
- lesson plan does not contain final generated lesson content

### Tutor Boundary Validation

Validation must confirm:

- tutor boundaries align with lesson and assessment blueprints
- tutor does not reveal answers when policy forbids it
- tutor safety boundaries are present
- tutor blueprint does not contain final prompt text

### Media Need Validation

Validation must confirm:

- media needs map to lesson segments
- media requirements support learning, not decoration
- accessibility requirements are included
- media blueprint does not contain generated assets

## Failure Scenarios

### Missing Pedagogical Analysis

Cause:

- blueprint generation is requested before `PedagogicalAnalysis` exists or is valid

Result:

- reject blueprint generation
- reason: `missing_pedagogical_analysis`

### Invalid Learning Objective

Cause:

- objective is not measurable or not aligned to the standard

Result:

- reject dependent blueprints
- reason: `invalid_learning_objective`

### Weak Mastery Definition

Cause:

- mastery cannot be observed or evaluated

Result:

- reject evidence and assessment blueprinting
- reason: `invalid_mastery_definition`

### Weak Evidence Requirement

Cause:

- evidence does not prove mastery

Result:

- reject assessment blueprint
- reason: `insufficient_evidence`

### Lesson Blueprint Before Assessment Blueprint

Cause:

- generation attempts to plan the lesson before acceptable evidence exists

Result:

- reject lesson blueprint
- reason: `assessment_blueprint_required`

### Unsafe Tutor Boundary

Cause:

- tutor blueprint allows answer leakage, unsafe behavior, or curriculum modification

Result:

- reject tutor blueprint
- reason: `unsafe_tutor_blueprint`

### Invalid Media Need

Cause:

- media request is decorative, inaccessible, or not tied to learning

Result:

- reject or warn
- reason: `invalid_media_requirement`

## Governance Rules

1. This layer generates blueprints, not final content.
2. `AssessmentBlueprint` must come before `LessonBlueprint`.
3. `MediaBlueprint` identifies media needs, not generated assets.
4. `TutorBlueprint` defines behavior boundaries, not prompt text.
5. Every blueprint must trace back to `PedagogicalAnalysis` and `CurriculumStandard`.
6. Student App cannot edit blueprints.
7. School Admin Portal may request generation workflows, but blueprint approval and publication policy remain governed.
8. Invalid blueprints must not be used for content generation.

## CE-02D Recommendation

Recommended next sprint:

```text
CE-02D - Generation Artifact Contracts
```

Scope:

- define generated lesson artifact contract
- define generated assessment artifact contract
- define generated tutor prompt artifact contract
- define generated media request/artifact contract
- define presentation contract generation inputs
- define artifact validation rules
- define artifact versioning and provenance
- define how artifacts reference CE-02C blueprints

Do not implement AI generation in CE-02D.

## Open Questions

1. Should blueprints be globally reusable by standard/version/language, or school-scoped when prompt overrides are used?
2. Should `AssessmentItemSpec` live as embedded data or a subcollection for large assessments?
3. Should `MediaBlueprint` be created before or after `LessonBlueprint`, or only after lesson segments are known?
4. Should tutor intervention rules be tied to assessment misconceptions, lesson segments, or both?
5. Should mastery definitions allow multiple proficiency levels beyond mastered/not mastered?
6. Should blueprint approval be required before generation, or can low-risk blueprints auto-advance after validation?
