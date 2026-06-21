import 'package:equatable/equatable.dart';

import 'answer_option.dart';
import 'assessment_question_type.dart';

class AssessmentQuestion extends Equatable {
  const AssessmentQuestion({
    required this.id,
    required this.assessmentId,
    required this.order,
    required this.type,
    required this.prompt,
    required this.points,
    this.answerOptions = const [],
    this.correctAnswerValue,
  });

  final String id;
  final String assessmentId;
  final int order;
  final AssessmentQuestionType type;
  final String prompt;
  final int points;
  final List<AnswerOption> answerOptions;
  final String? correctAnswerValue;

  @override
  List<Object?> get props => [
    id,
    assessmentId,
    order,
    type,
    prompt,
    points,
    answerOptions,
    correctAnswerValue,
  ];
}
