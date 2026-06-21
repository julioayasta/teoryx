import 'package:equatable/equatable.dart';

import 'assessment_answer.dart';

class AssessmentAttempt extends Equatable {
  const AssessmentAttempt({
    required this.id,
    required this.assessmentId,
    required this.studentId,
    required this.lessonId,
    required this.answers,
    required this.submittedAt,
  });

  final String id;
  final String assessmentId;
  final String studentId;
  final String lessonId;
  final List<AssessmentAnswer> answers;
  final DateTime submittedAt;

  @override
  List<Object?> get props => [
    id,
    assessmentId,
    studentId,
    lessonId,
    answers,
    submittedAt,
  ];
}
