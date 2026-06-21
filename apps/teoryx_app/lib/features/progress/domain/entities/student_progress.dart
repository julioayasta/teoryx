import 'package:equatable/equatable.dart';

enum MasteryLevel { notStarted, inProgress, developing, proficient, mastered }

class StudentProgress extends Equatable {
  const StudentProgress({
    required this.studentId,
    required this.courseId,
    required this.lessonId,
    required this.currentLessonTitle,
    required this.lessonProgressLabel,
    required this.masteryLevel,
    this.lastAssessmentScorePercentage,
    this.hasPendingReview = false,
  });

  final String studentId;
  final String courseId;
  final String lessonId;
  final String currentLessonTitle;
  final String lessonProgressLabel;
  final MasteryLevel masteryLevel;
  final int? lastAssessmentScorePercentage;
  final bool hasPendingReview;

  @override
  List<Object?> get props => [
    studentId,
    courseId,
    lessonId,
    currentLessonTitle,
    lessonProgressLabel,
    masteryLevel,
    lastAssessmentScorePercentage,
    hasPendingReview,
  ];
}
