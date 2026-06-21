import 'package:equatable/equatable.dart';

import '../../../progress/domain/entities/student_progress.dart';
import 'assessment_answer.dart';

class AssessmentResult extends Equatable {
  const AssessmentResult({
    required this.attemptId,
    required this.assessmentId,
    required this.lessonId,
    required this.autoGradedScorePercentage,
    required this.finalScorePercentage,
    required this.correctCount,
    required this.incorrectCount,
    required this.pendingReviewCount,
    required this.masteryLevel,
    required this.answers,
  });

  final String attemptId;
  final String assessmentId;
  final String lessonId;
  final int autoGradedScorePercentage;
  final int? finalScorePercentage;
  final int correctCount;
  final int incorrectCount;
  final int pendingReviewCount;
  final MasteryLevel masteryLevel;
  final List<AssessmentAnswer> answers;

  bool get hasPendingReview => pendingReviewCount > 0;

  @override
  List<Object?> get props => [
    attemptId,
    assessmentId,
    lessonId,
    autoGradedScorePercentage,
    finalScorePercentage,
    correctCount,
    incorrectCount,
    pendingReviewCount,
    masteryLevel,
    answers,
  ];
}
