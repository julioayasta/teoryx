# Sprint CE-02B - Pedagogical Analysis Engine

## Status

Proposal for review.

No implementation has been done for this sprint.

## Objective

Design the Pedagogical Analysis Engine, Knowledge Source Library, and Prompt Registry for the TeoryX Content Engine.

The Pedagogical Analysis Engine transforms an official curriculum standard into structured pedagogical understanding before any lesson, assessment, tutor guidance, remediation, media plan, or presentation contract is generated.

The mandatory sequence becomes:

```text
Official Curriculum Standard
-> Pedagogical Analysis
-> Learning Objective
-> Assessment Blueprint
-> Lesson
-> Tutor Prompt
-> Presentation Contract
```

The Content Engine must never skip directly from a standard to a lesson.

## Scope

This sprint designs:

- pedagogical analysis model
- knowledge source library
- source hierarchy rules
- grade-level language profiles
- prompt template registry
- school prompt overrides
- Firestore collection proposal
- validation and failure scenarios
- CE-02C recommendation

## Non-Scope

This sprint does not implement:

- Content Engine code
- AI generation
- Firestore writes
- Student App changes
- School Admin Portal changes
- prompt execution
- curriculum import tooling
- lesson generation
- assessment generation
- tutor generation

## Design Principles

### Analyze Before Generating

Every generated content artifact must be based on a completed pedagogical analysis.

The analysis explains:

- what the standard means
- what the student must understand
- what the student must be able to do
- what prior knowledge is required
- what vocabulary must be taught
- what misconceptions are likely
- what evidence proves mastery
- what language complexity is appropriate

### Curriculum Alignment Cannot Be Overridden

Official curriculum intent remains the highest authority.

No prompt, school override, AI output, or school preference may change:

- official standard meaning
- curriculum source hierarchy
- required curriculum traceability
- assessment alignment
- required output schema
- safety constraints

### Reusable Analysis

A single pedagogical analysis should be reusable across many generated artifacts.

Examples:

- initial lesson
- remediation lesson
- quiz
- tutor behavior rules
- media plan
- presentation contract
- translated content
- future differentiated versions

### Auditable Prompting

Prompt templates must be versioned and auditable.

A generated artifact must be able to record which prompt template versions influenced it.

Prompt text should not be silently mutated. New prompt behavior requires a new immutable `PromptTemplateVersion`.

## Position In Content Engine

CE-02A defines:

```text
CurriculumSource
-> CurriculumVersion
-> CurriculumStandard
-> SchoolCurriculumSelection
```

CE-02B adds:

```text
CurriculumStandard
-> PedagogicalAnalysis
-> prompt-governed generation inputs
```

Future generation should use:

```text
ContentGenerationRequest
-> SchoolCurriculumSelection
-> CurriculumStandard
-> PedagogicalAnalysis
-> LearningObjective
-> AssessmentBlueprint
-> Lesson
-> TutorPrompt
-> PresentationContract
```

The Student App remains a read-only consumption workflow. It may request missing content, but it cannot modify curriculum selection, pedagogical analysis, prompt templates, or prompt overrides.

The School Admin Portal may request generation or regeneration and may edit approved prompt overrides, but it cannot override curriculum alignment, safety, source hierarchy, or output schemas.

## Pedagogical Analysis Engine

The Pedagogical Analysis Engine derives a structured understanding of a standard.

Input:

```text
standardId
curriculumSourceId
curriculumVersionId
gradeLevelId
subjectId
language
schoolId optional
```

Output:

```text
PedagogicalAnalysis
```

### Student Understanding

Defines the concepts a student must understand to master the standard.

Example fields:

```text
concepts
bigIdeas
studentFriendlyExplanation
conceptualBoundaries
```

### Student Performance

Defines what the student must be able to do.

Example fields:

```text
observableActions
performanceVerbs
successCriteria
acceptableEvidence
```

### Prerequisites

Defines required prior knowledge and prior skills.

Prerequisites may reference:

- earlier standards
- concept names
- skill names
- vocabulary
- informal prior experience

### Target Skills

Skills are classified by type:

```text
conceptual
procedural
analytical
communication
```

Each target skill should include:

```text
skillId
type
description
masteryIndicator
relatedPrerequisiteIds
```

### Academic Vocabulary

Defines terms students must learn or use.

Each term should include:

```text
term
studentFriendlyDefinition
formalDefinition
exampleUsage
language
requiredForMastery
```

### Misconceptions

Defines common errors or misunderstandings.

Each misconception should include:

```text
description
likelyCause
diagnosticSignal
correctionStrategy
relatedSkillIds
```

### Concrete Examples

Defines age-appropriate examples that can support lesson generation.

Examples should be:

- grade-appropriate
- culturally safe
- aligned to the standard
- usable in lesson, tutor, assessment, or remediation workflows

### Abstract Concepts

Identifies ideas that require scaffolding.

Examples:

- equivalence
- proportionality
- inference
- evidence
- cause and effect
- systems

### Transfer Opportunities

Defines where the learning can transfer.

Types:

```text
real_world_application
cross_disciplinary
future_learning
student_life_context
```

### Assessment Evidence

Defines evidence that mastery occurred.

Evidence should connect to:

- success criteria
- target skills
- expected student work
- assessment item types
- rubric signals when needed

### Grade-Level Language Requirements

Defines the language profile used for generated content.

The profile controls:

- sentence complexity
- vocabulary load
- reading level
- scaffolding
- abstraction tolerance
- visual support expectations

## Domain Model

### PedagogicalAnalysis

Aggregate root for the analysis of one official standard in a specific curriculum version and language.

Fields:

```text
id
standardId
curriculumSourceId
curriculumVersionId
standardCode
sourceVersion
gradeLevelId
subjectId
language
languageProfileId
studentUnderstanding
studentPerformance
prerequisites
targetSkills
academicVocabulary
misconceptions
concreteExamples
abstractConcepts
transferOpportunities
assessmentEvidence
knowledgeSourceReferenceIds
promptTemplateVersionIds
validationReportId
status
createdAt
updatedAt
approvedAt
approvedByUserId
```

Allowed statuses:

```text
draft
generated
validated
approved
rejected
superseded
```

### Prerequisite

Fields:

```text
id
type
description
requiredLevel
relatedStandardIds
relatedVocabularyTerms
```

Allowed types:

```text
prior_knowledge
prior_skill
vocabulary
conceptual_foundation
```

### TargetSkill

Fields:

```text
id
type
description
masteryIndicator
relatedPrerequisiteIds
```

Allowed types:

```text
conceptual
procedural
analytical
communication
```

### AcademicVocabularyTerm

Fields:

```text
term
studentFriendlyDefinition
formalDefinition
exampleUsage
language
requiredForMastery
```

### Misconception

Fields:

```text
id
description
likelyCause
diagnosticSignal
correctionStrategy
relatedSkillIds
```

### TransferOpportunity

Fields:

```text
id
type
description
exampleContext
relatedSkillIds
```

### AssessmentEvidence

Fields:

```text
id
description
evidenceType
successCriteria
relatedSkillIds
suggestedAssessmentItemTypes
```

### LanguageProfile

Defines grade-band language constraints for generated content.

Fields:

```text
id
gradeBand
language
sentenceComplexity
vocabularyExpectations
scaffoldingRequirements
abstractionTolerance
visualSupportExpectations
readingLevelGuidance
status
createdAt
updatedAt
```

## Grade-Level Language Profiles

### K-2

Guidance:

- short sentences
- concrete nouns and verbs
- high visual support
- repeated vocabulary
- minimal abstraction
- frequent comprehension checks
- story and object-based examples

### 3-5

Guidance:

- simple and compound sentences
- explicit academic vocabulary instruction
- moderate visual support
- concrete-to-abstract progression
- guided examples before independent work
- limited cognitive load per step

### 6-8

Guidance:

- varied sentence structure
- stronger disciplinary vocabulary
- explicit reasoning language
- moderate abstraction
- examples that connect concepts across topics
- structured argument and explanation support

### 9-12

Guidance:

- discipline-specific language
- abstract reasoning
- multi-step explanations
- evidence-based argument
- lower visual dependency unless subject requires it
- preparation for independent reading and analysis

## Knowledge Source Library

The Knowledge Source Library stores the approved educational sources that may support analysis and generation.

Source types:

```text
official_curriculum
pedagogy_reference
internal_teoryx_guide
school_material
open_educational_resource
ai_synthesis
```

### KnowledgeSource

Fields:

```text
sourceId
type
authority
title
version
citation
license
qualityRating
applicableGrades
applicableSubjects
ingestionStatus
sourceUrl
checksum
createdAt
updatedAt
```

Allowed ingestion statuses:

```text
pending_review
approved
rejected
retired
superseded
```

### KnowledgeSourceReference

Represents a specific cited use of a source.

Fields:

```text
id
sourceId
standardId
analysisId
referenceType
citation
locator
excerptHash
notes
createdAt
```

The `excerptHash` allows traceability without requiring TeoryX to store licensed excerpts when that is not allowed.

## Source Hierarchy

The Content Engine uses this priority order:

```text
official curriculum
> pedagogy references
> internal TeoryX guidance
> school material
> open educational resources
> AI synthesis
```

Rules:

1. Official curriculum defines the standard intent.
2. Pedagogy references may guide teaching strategy.
3. Internal TeoryX guidance may guide product consistency and instructional style.
4. School material may provide local context only when it does not conflict with official curriculum.
5. Open educational resources may support examples and practice design.
6. AI synthesis may organize, explain, or bridge gaps, but it cannot override higher-priority sources.

## Prompt Registry

The Prompt Registry stores approved prompt templates used by Content Engine services.

Prompted tasks may include:

- pedagogical analysis generation
- learning objective generation
- assessment blueprint generation
- lesson generation
- tutor prompt generation
- remediation guidance
- media planning
- presentation contract generation
- validation review

### PromptTemplate

Represents the stable identity and purpose of a prompt.

Fields:

```text
id
name
taskType
description
requiredInputs
outputSchemaId
alignmentConstraints
safetyConstraints
status
createdAt
updatedAt
```

Allowed task types:

```text
pedagogical_analysis
learning_objective
assessment_blueprint
lesson_generation
tutor_prompt
remediation
media_plan
presentation_contract
validation
```

### PromptTemplateVersion

Represents an immutable, auditable prompt version.

Fields:

```text
id
promptTemplateId
version
promptText
modelFamily
parameters
inputSchema
outputSchema
checksum
authorUserId
reviewedByUserId
approvalStatus
changeSummary
createdAt
approvedAt
retiredAt
```

Rules:

1. `PromptTemplateVersion` is immutable after approval.
2. Any prompt text, schema, parameter, or constraint change requires a new version.
3. Generated artifacts must record the prompt template versions used.
4. Retired prompt versions remain queryable for audit and reproducibility.
5. Prompt versions must include a checksum.
6. Prompt versions must be reviewed before production use.

Allowed approval statuses:

```text
draft
in_review
approved
retired
rejected
```

### SchoolPromptOverride

Represents a school-specific override for allowed prompt variables or style preferences.

Stored under:

```text
schools/{schoolId}/promptOverrides/{overrideId}
```

Fields:

```text
id
schoolId
promptTemplateId
appliesToTaskType
allowedVariableOverrides
styleGuidance
localContextGuidance
languagePreferences
status
editedByUserId
reviewedByUserId
createdAt
updatedAt
approvedAt
```

School Admin may edit approved override fields such as:

- tone preference
- local examples
- school terminology
- language preference
- allowed instructional style guidance

SchoolPromptOverride cannot override:

- curriculum alignment
- official source meaning
- source hierarchy
- safety constraints
- required output schema
- required traceability fields
- validation rules
- Student App permissions

The Student App cannot edit prompts or prompt overrides.

### PromptAuditEntry

Records prompt lifecycle and usage events.

Fields:

```text
id
promptTemplateId
promptTemplateVersionId
schoolId
eventType
actorUserId
artifactId
analysisId
requestId
metadata
createdAt
```

Allowed event types:

```text
created
submitted_for_review
approved
retired
used_for_generation
override_created
override_updated
override_approved
override_rejected
```

## Validation Rules

### Curriculum Alignment

Validation must confirm:

- `standardId` exists
- `curriculumSourceId` matches the standard
- `curriculumVersionId` matches the standard
- analysis does not alter official standard meaning
- generated claims remain inside the standard boundary

### Source Grounding

Validation must confirm:

- official curriculum source is present
- higher-priority source conflicts are resolved in favor of official curriculum
- AI synthesis is marked as derived support, not authority
- source references are attached where needed

### Prerequisite Completeness

Validation must confirm:

- prior knowledge is represented
- prior skills are represented
- prerequisite standards are referenced when known
- missing prerequisite certainty is flagged

### Vocabulary Completeness

Validation must confirm:

- required academic terms are listed
- definitions are age appropriate
- vocabulary needed for assessment is covered

### Misconception Coverage

Validation must confirm:

- likely misconceptions are listed
- diagnostic signals are included
- correction strategies are aligned to skills

### Assessment Alignment

Validation must confirm:

- assessment evidence maps to target skills
- evidence can prove mastery of the standard
- suggested assessment types fit grade level and subject

### Language Appropriateness

Validation must confirm:

- the correct language profile is used
- sentence complexity is grade appropriate
- vocabulary load is reasonable
- scaffolding expectations are included

### Prompt Governance

Validation must confirm:

- approved prompt template versions were used
- prompt versions are immutable and auditable
- school overrides only modify allowed fields
- school overrides do not alter alignment, safety, source hierarchy, or schema

## Firestore Collection Proposal

Proposed collections:

```text
pedagogicalAnalyses/{analysisId}
knowledgeSources/{sourceId}
knowledgeSourceReferences/{referenceId}
languageProfiles/{profileId}
promptTemplates/{promptTemplateId}
promptTemplates/{promptTemplateId}/versions/{promptTemplateVersionId}
schools/{schoolId}/promptOverrides/{overrideId}
promptAuditEntries/{auditEntryId}
analysisValidationReports/{validationReportId}
```

Relationship with CE-02A:

```text
curriculumStandards/{standardId}
-> pedagogicalAnalyses/{analysisId}
-> future learning objectives
-> future assessment blueprints
-> future lesson content artifacts
```

### pedagogicalAnalyses/{analysisId}

Stores reusable analysis for one standard/version/language context.

Recommended indexes:

```text
standardId + curriculumVersionId + language + status
curriculumSourceId + curriculumVersionId + gradeLevelId + subjectId + status
```

### knowledgeSources/{sourceId}

Stores approved source metadata.

Recommended indexes:

```text
type + ingestionStatus
applicableGrades + applicableSubjects + ingestionStatus
```

### knowledgeSourceReferences/{referenceId}

Stores source links used by analyses and future artifacts.

Recommended indexes:

```text
sourceId + standardId
analysisId + referenceType
```

### languageProfiles/{profileId}

Stores language complexity rules by grade band and language.

Recommended indexes:

```text
gradeBand + language + status
```

### promptTemplates/{promptTemplateId}

Stores stable prompt template identity and task purpose.

### promptTemplates/{promptTemplateId}/versions/{promptTemplateVersionId}

Stores immutable prompt versions.

Recommended indexes:

```text
promptTemplateId + approvalStatus + version
```

### schools/{schoolId}/promptOverrides/{overrideId}

Stores school-specific allowed override configuration.

Recommended indexes:

```text
promptTemplateId + status
appliesToTaskType + status
```

### promptAuditEntries/{auditEntryId}

Stores lifecycle and usage audit events.

Recommended indexes:

```text
promptTemplateVersionId + eventType + createdAt
schoolId + eventType + createdAt
artifactId + eventType
```

### analysisValidationReports/{validationReportId}

Stores validation results for pedagogical analyses.

Fields:

```text
id
analysisId
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

## Failure Scenarios

### Missing Standard

Cause:

- `standardId` cannot be resolved in `curriculumStandards`

Result:

- reject analysis
- reason: `standard_not_found`

### Missing Curriculum Version

Cause:

- standard does not have a valid `curriculumVersionId`

Result:

- reject analysis
- reason: `missing_curriculum_version`

### Ungrounded Analysis

Cause:

- analysis lacks official curriculum source reference

Result:

- validation fails
- reason: `missing_official_source_grounding`

### Conflicting Sources

Cause:

- school material, OER, or AI synthesis conflicts with official curriculum

Result:

- official curriculum wins
- warning or rejection depending on severity

### Unsupported Language Profile

Cause:

- no active language profile exists for grade band/language

Result:

- reject generation using that profile
- reason: `language_profile_not_found`

### Invalid Prompt Override

Cause:

- override attempts to modify curriculum alignment, safety, source hierarchy, or output schema

Result:

- reject override
- reason: `override_not_allowed`

### Unapproved Prompt Version

Cause:

- generation attempts to use draft, rejected, or retired prompt version

Result:

- reject generation
- reason: `prompt_version_not_approved`

### Student App Attempts Prompt Editing

Cause:

- Student App request attempts to create or modify prompt override

Result:

- reject request
- reason: `permission_denied`

## Governance Rules

1. PedagogicalAnalysis must happen before LearningObjective, AssessmentBlueprint, Lesson, TutorPrompt, and PresentationContract.
2. Official curriculum is the highest authority.
3. PromptTemplateVersion is immutable and auditable after approval.
4. SchoolPromptOverride may only adjust approved variable fields and style guidance.
5. SchoolPromptOverride cannot override curriculum alignment, safety, source hierarchy, or output schema.
6. Student App cannot edit prompts, analyses, curriculum selections, or generated content.
7. School Admin Portal may edit prompt overrides through an authoring/governance workflow.
8. Generated artifacts must record standard/version/source and prompt version provenance.

## CE-02C Recommendation

Recommended next sprint:

```text
CE-02C - Learning Objective and Assessment Blueprint Design
```

Scope:

- define LearningObjective model derived from PedagogicalAnalysis
- define AssessmentBlueprint model derived from LearningObjective and PedagogicalAnalysis
- define mastery evidence mapping
- define assessment item specifications
- define validation rules for UbD alignment
- define Firestore collections for objectives and assessment blueprints
- define how future Lesson generation consumes the approved objective and blueprint

Do not implement lesson generation in CE-02C.

## Open Questions

1. Should PedagogicalAnalysis be globally shared by standard/version/language, or can schools request approved school-specific variants?
2. Should SchoolPromptOverride require Super Admin approval, school admin approval, or both?
3. Should prompt versions be tied to a specific AI provider/model family, or should provider routing remain outside the prompt registry?
4. Should language profiles be global, jurisdiction-specific, or school-adjustable within strict bounds?
5. Should AI synthesis be stored as a `KnowledgeSource`, or only as a generated derivation with source references?
6. Should analyses support confidence scores for prerequisites and misconceptions?
7. Should TeoryX allow teacher-authored school materials to influence analysis before formal review?
