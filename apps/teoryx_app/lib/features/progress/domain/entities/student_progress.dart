import 'package:equatable/equatable.dart';

enum MasteryLevel { notStarted, inProgress, developing, proficient, mastered }

enum LessonProgressStatus {
  studying,
  assessmentStarted,
  assessmentCompleted,
  readyForNextLesson,
}

class StudentProgress extends Equatable {
  const StudentProgress({
    required this.studentId,
    required this.courseId,
    required this.currentLessonId,
    required this.currentLessonTitle,
    required this.currentLessonStatus,
    required this.nextLessonId,
    required this.nextLessonTitle,
    required this.lessonProgressLabel,
    required this.masteryLevel,
    this.lastAssessmentScorePercentage,
    this.pendingReviewCount = 0,
    this.hasPendingReview = false,
  });

  final String studentId;
  final String courseId;
  final String currentLessonId;
  final String currentLessonTitle;
  final LessonProgressStatus currentLessonStatus;
  final String nextLessonId;
  final String nextLessonTitle;
  final String lessonProgressLabel;
  final MasteryLevel masteryLevel;
  final int? lastAssessmentScorePercentage;
  final int pendingReviewCount;
  final bool hasPendingReview;

  @override
  List<Object?> get props => [
    studentId,
    courseId,
    currentLessonId,
    currentLessonTitle,
    currentLessonStatus,
    nextLessonId,
    nextLessonTitle,
    lessonProgressLabel,
    masteryLevel,
    lastAssessmentScorePercentage,
    pendingReviewCount,
    hasPendingReview,
  ];
}
