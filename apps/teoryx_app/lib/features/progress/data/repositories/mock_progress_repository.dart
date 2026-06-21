import '../../domain/entities/student_progress.dart';

class MockProgressRepository {
  const MockProgressRepository();

  static LessonProgressStatus _status = LessonProgressStatus.studying;
  static int? _lastAssessmentScorePercentage;
  static int _pendingReviewCount = 0;

  StudentProgress getCurrentProgress(String languageCode) {
    final isSpanish = languageCode == 'es';
    final hasCompletedAssessment =
        _status == LessonProgressStatus.assessmentCompleted ||
        _status == LessonProgressStatus.readyForNextLesson;

    return StudentProgress(
      studentId: 'student-001',
      courseId: 'grade-4-math',
      currentLessonId: 'comparing-fractions',
      currentLessonTitle: isSpanish
          ? 'Comparar fracciones'
          : 'Comparing Fractions',
      currentLessonStatus: _status,
      nextLessonId: 'equivalent-fractions',
      nextLessonTitle: isSpanish
          ? 'Fracciones equivalentes'
          : 'Equivalent Fractions',
      lessonProgressLabel: isSpanish ? 'Leccion 2 de 8' : 'Lesson 2 of 8',
      masteryLevel: hasCompletedAssessment
          ? MasteryLevel.developing
          : MasteryLevel.inProgress,
      lastAssessmentScorePercentage: _lastAssessmentScorePercentage,
      pendingReviewCount: _pendingReviewCount,
      hasPendingReview: _pendingReviewCount > 0,
    );
  }

  void markAssessmentStarted() {
    if (_status == LessonProgressStatus.studying) {
      _status = LessonProgressStatus.assessmentStarted;
    }
  }

  void markAssessmentCompleted({
    required int autoGradedScorePercentage,
    required int pendingReviewCount,
  }) {
    _status = LessonProgressStatus.assessmentCompleted;
    _lastAssessmentScorePercentage = autoGradedScorePercentage;
    _pendingReviewCount = pendingReviewCount;
  }
}
