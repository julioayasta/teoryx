import 'package:equatable/equatable.dart';

import 'assessment_question_type.dart';

enum AssessmentGradingStatus { autoGraded, pendingReview, notGraded }

class AssessmentAnswer extends Equatable {
  const AssessmentAnswer({
    required this.questionId,
    required this.questionType,
    required this.gradingStatus,
    this.selectedOptionId,
    this.answerValue,
    this.textResponse,
    this.documentAttached = false,
    this.documentName,
    this.isCorrect,
    this.pointsEarned = 0,
  });

  final String questionId;
  final AssessmentQuestionType questionType;
  final AssessmentGradingStatus gradingStatus;
  final String? selectedOptionId;
  final String? answerValue;
  final String? textResponse;
  final bool documentAttached;
  final String? documentName;
  final bool? isCorrect;
  final int pointsEarned;

  @override
  List<Object?> get props => [
    questionId,
    questionType,
    gradingStatus,
    selectedOptionId,
    answerValue,
    textResponse,
    documentAttached,
    documentName,
    isCorrect,
    pointsEarned,
  ];
}
