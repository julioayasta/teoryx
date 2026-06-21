import 'package:equatable/equatable.dart';

import 'assessment_question.dart';

class Assessment extends Equatable {
  const Assessment({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.passingScore,
    required this.questions,
  });

  final String id;
  final String lessonId;
  final String title;
  final int passingScore;
  final List<AssessmentQuestion> questions;

  @override
  List<Object?> get props => [id, lessonId, title, passingScore, questions];
}
