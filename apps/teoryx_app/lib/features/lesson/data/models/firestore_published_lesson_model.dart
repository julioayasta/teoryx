import '../../domain/entities/learning_objective.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_step.dart';

class FirestorePublishedLessonModel {
  const FirestorePublishedLessonModel({
    required this.id,
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
  });

  final String id;
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
    return FirestorePublishedLessonModel(
      id: id,
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
      steps: _stepsFromFirestore(id, data['steps']),
    );
  }

  static List<LessonStep> _stepsFromFirestore(String lessonId, Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((stepData) => _stepFromFirestore(lessonId, stepData))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static LessonStep _stepFromFirestore(
    String lessonId,
    Map<String, dynamic> data,
  ) {
    final order = data['order'];

    return LessonStep(
      id: data['id'] as String? ?? '$lessonId-step-${order ?? 0}',
      lessonId: data['lessonId'] as String? ?? lessonId,
      order: order is int ? order : 0,
      type: _stepTypeFromFirestore(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      prompt: data['prompt'] as String?,
      expectedAnswer: data['expectedAnswer'] as String?,
      imageDescription: data['imageDescription'] as String?,
    );
  }

  static LessonStepType _stepTypeFromFirestore(String? value) {
    return switch (value) {
      'imagePlaceholder' => LessonStepType.imagePlaceholder,
      'explanation' => LessonStepType.explanation,
      'question' => LessonStepType.question,
      'practice' => LessonStepType.practice,
      'summary' => LessonStepType.summary,
      'story' || _ => LessonStepType.story,
    };
  }
}
