import 'package:equatable/equatable.dart';

import 'learning_objective.dart';

class Lesson extends Equatable {
  const Lesson({
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

  @override
  List<Object?> get props => [
        id,
        schoolId,
        curriculumId,
        gradeLevelId,
        subjectId,
        standardId,
        standardCode,
        language,
        title,
        bigIdea,
        essentialQuestion,
        learningObjective,
        lessonContent,
        guidedPractice,
        independentPractice,
        summary,
      ];
}
