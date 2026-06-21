import 'package:equatable/equatable.dart';

import 'lesson_progress.dart';
import 'progress_recommendation.dart';

class CourseProgress extends Equatable {
  const CourseProgress({
    required this.courseId,
    required this.courseTitle,
    required this.completedLessonCount,
    required this.totalLessonCount,
    required this.currentRecommendation,
    required this.lessons,
    required this.latestAssessmentSummary,
    required this.recommendation,
  });

  final String courseId;
  final String courseTitle;
  final int completedLessonCount;
  final int totalLessonCount;
  final String currentRecommendation;
  final List<LessonProgress> lessons;
  final AssessmentProgressSummary latestAssessmentSummary;
  final ProgressRecommendation recommendation;

  @override
  List<Object?> get props => [
    courseId,
    courseTitle,
    completedLessonCount,
    totalLessonCount,
    currentRecommendation,
    lessons,
    latestAssessmentSummary,
    recommendation,
  ];
}

class AssessmentProgressSummary extends Equatable {
  const AssessmentProgressSummary({
    required this.lessonId,
    required this.lessonTitle,
    required this.autoGradedScorePercentage,
    required this.finalScoreLabel,
    required this.pendingReviewCount,
  });

  final String lessonId;
  final String lessonTitle;
  final int autoGradedScorePercentage;
  final String finalScoreLabel;
  final int pendingReviewCount;

  @override
  List<Object?> get props => [
    lessonId,
    lessonTitle,
    autoGradedScorePercentage,
    finalScoreLabel,
    pendingReviewCount,
  ];
}
