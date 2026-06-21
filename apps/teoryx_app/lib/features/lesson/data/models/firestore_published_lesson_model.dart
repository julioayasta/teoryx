import '../../domain/entities/learning_objective.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_step.dart';

class FirestorePublishedLessonModel {
  const FirestorePublishedLessonModel({
    required this.id,
    required this.courseId,
    required this.schoolId,
    required this.curriculumId,
    required this.gradeLevelId,
    required this.subjectId,
    required this.standardId,
    required this.standardCode,
    required this.language,
    required this.title,
    required this.bigIdea,
    required this.essentialQuestion,
    required this.learningObjective,
    required this.lessonContent,
    required this.guidedPractice,
    required this.independentPractice,
    required this.summary,
    required this.steps,
    required this.status,
    required this.hasUnsupportedSteps,
  });

  final String id;
  final String courseId;
  final String schoolId;
  final String curriculumId;
  final String gradeLevelId;
  final String subjectId;
  final String standardId;
  final String standardCode;
  final String language;
  final String title;
  final String bigIdea;
  final String essentialQuestion;
  final LearningObjective learningObjective;
  final String lessonContent;
  final String guidedPractice;
  final String independentPractice;
  final String summary;
  final List<LessonStep> steps;
  final String status;
  final bool hasUnsupportedSteps;

  bool get isValid {
    return id.isNotEmpty &&
        courseId.isNotEmpty &&
        curriculumId.isNotEmpty &&
        gradeLevelId.isNotEmpty &&
        subjectId.isNotEmpty &&
        standardId.isNotEmpty &&
        standardCode.isNotEmpty &&
        language.isNotEmpty &&
        title.isNotEmpty &&
        bigIdea.isNotEmpty &&
        essentialQuestion.isNotEmpty &&
        learningObjective.statement.isNotEmpty &&
        lessonContent.isNotEmpty &&
        guidedPractice.isNotEmpty &&
        independentPractice.isNotEmpty &&
        summary.isNotEmpty &&
        steps.isNotEmpty &&
        !hasUnsupportedSteps &&
        (status == 'active' || status == 'published');
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      schoolId: schoolId,
      curriculumId: curriculumId,
      gradeLevelId: gradeLevelId,
      subjectId: subjectId,
      standardId: standardId,
      standardCode: standardCode,
      language: language,
      title: title,
      bigIdea: bigIdea,
      essentialQuestion: essentialQuestion,
      learningObjective: learningObjective,
      lessonContent: lessonContent,
      guidedPractice: guidedPractice,
      independentPractice: independentPractice,
      summary: summary,
      steps: steps,
    );
  }

  static FirestorePublishedLessonModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final stepsResult = _stepsFromFirestore(id, data['steps']);

    return FirestorePublishedLessonModel(
      id: data['publishedContentId'] as String? ?? id,
      courseId: data['courseId'] as String? ?? '',
      schoolId: data['schoolId'] as String? ?? '',
      curriculumId: data['curriculumId'] as String? ?? '',
      gradeLevelId: data['gradeLevelId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      standardId: data['standardId'] as String? ?? '',
      standardCode: data['standardCode'] as String? ?? '',
      language: data['language'] as String? ?? 'en',
      title: data['title'] as String? ?? '',
      bigIdea: data['bigIdea'] as String? ?? '',
      essentialQuestion: data['essentialQuestion'] as String? ?? '',
      learningObjective: LearningObjective(
        id: data['learningObjectiveId'] as String? ?? '$id-objective',
        statement: data['learningObjective'] as String? ?? '',
      ),
      lessonContent: data['lessonContent'] as String? ?? '',
      guidedPractice: data['guidedPractice'] as String? ?? '',
      independentPractice: data['independentPractice'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      steps: stepsResult.steps,
      status: data['status'] as String? ?? '',
      hasUnsupportedSteps: stepsResult.hasUnsupportedSteps,
    );
  }

  static _LessonStepsParseResult _stepsFromFirestore(
    String lessonId,
    Object? value,
  ) {
    if (value is! List) {
      return const _LessonStepsParseResult(
        steps: [],
        hasUnsupportedSteps: false,
      );
    }

    var hasUnsupportedSteps = false;
    final steps = <LessonStep>[];

    for (final stepData in value.whereType<Map<String, dynamic>>()) {
      final step = _stepFromFirestore(lessonId, stepData);

      if (step == null) {
        hasUnsupportedSteps = true;
      } else {
        steps.add(step);
      }
    }

    steps.sort((a, b) => a.order.compareTo(b.order));

    return _LessonStepsParseResult(
      steps: steps,
      hasUnsupportedSteps: hasUnsupportedSteps,
    );
  }

  static LessonStep? _stepFromFirestore(
    String lessonId,
    Map<String, dynamic> data,
  ) {
    final order = data['order'];
    final type = _stepTypeFromFirestore(data['type'] as String?);

    if (type == null) {
      return null;
    }

    return LessonStep(
      id: data['id'] as String? ?? '$lessonId-step-${order ?? 0}',
      lessonId: data['lessonId'] as String? ?? lessonId,
      order: order is int ? order : 0,
      type: type,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      prompt: data['prompt'] as String?,
      expectedAnswer: data['expectedAnswer'] as String?,
      imageDescription: data['imageDescription'] as String?,
    );
  }

  static LessonStepType? _stepTypeFromFirestore(String? value) {
    return switch (value) {
      'imagePlaceholder' => LessonStepType.imagePlaceholder,
      'explanation' => LessonStepType.explanation,
      'question' => LessonStepType.question,
      'practice' => LessonStepType.practice,
      'summary' => LessonStepType.summary,
      'story' => LessonStepType.story,
      _ => null,
    };
  }
}

class _LessonStepsParseResult {
  const _LessonStepsParseResult({
    required this.steps,
    required this.hasUnsupportedSteps,
  });

  final List<LessonStep> steps;
  final bool hasUnsupportedSteps;
}
