import '../../domain/entities/course_progress.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/entities/progress_recommendation.dart';
import '../../domain/entities/student_progress.dart';
import '../../domain/repositories/progress_repository.dart';

class MockProgressRepository implements ProgressRepository {
  const MockProgressRepository();

  static LessonProgressStatus _status = LessonProgressStatus.studying;
  static int? _lastAssessmentScorePercentage;
  static int _pendingReviewCount = 0;

  @override
  StudentProgress getStudentProgress(String studentId, String languageCode) {
    return getCurrentProgress(languageCode);
  }

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

  @override
  CourseProgress getCourseProgress(
    String studentId,
    String courseId,
    String languageCode,
  ) {
    return getCourseProgressForLanguage(languageCode);
  }

  CourseProgress getCourseProgressForLanguage(String languageCode) {
    final isSpanish = languageCode == 'es';
    final currentProgress = getCurrentProgress(languageCode);
    final pendingReviewCount = currentProgress.pendingReviewCount > 0
        ? currentProgress.pendingReviewCount
        : 2;
    final score = currentProgress.lastAssessmentScorePercentage ?? 67;

    return CourseProgress(
      courseId: 'grade-4-math',
      courseTitle: isSpanish ? 'Grado 4 Matematicas' : 'Grade 4 Math',
      completedLessonCount: 2,
      totalLessonCount: 8,
      currentRecommendation: isSpanish
          ? 'Continuar con Fracciones equivalentes'
          : 'Continue with Equivalent Fractions',
      lessons: [
        LessonProgress(
          lessonId: 'fractions-parts-whole',
          lessonTitle: isSpanish
              ? 'Fracciones como partes de un entero'
              : 'Fractions as Parts of a Whole',
          status: LessonProgressStatus.readyForNextLesson,
          masteryLevel: MasteryLevel.proficient,
        ),
        LessonProgress(
          lessonId: 'comparing-fractions',
          lessonTitle: isSpanish
              ? 'Comparar fracciones'
              : 'Comparing Fractions',
          status: LessonProgressStatus.assessmentCompleted,
          masteryLevel: MasteryLevel.developing,
        ),
        LessonProgress(
          lessonId: 'equivalent-fractions',
          lessonTitle: isSpanish
              ? 'Fracciones equivalentes'
              : 'Equivalent Fractions',
          status: LessonProgressStatus.studying,
          masteryLevel: MasteryLevel.notStarted,
        ),
      ],
      latestAssessmentSummary: AssessmentProgressSummary(
        lessonId: 'comparing-fractions',
        lessonTitle: isSpanish ? 'Comparar fracciones' : 'Comparing Fractions',
        autoGradedScorePercentage: score,
        finalScoreLabel: isSpanish ? 'Revision pendiente' : 'Pending Review',
        pendingReviewCount: pendingReviewCount,
      ),
      recommendation: ProgressRecommendation(
        title: isSpanish ? 'Recomendacion' : 'Recommendation',
        message: isSpanish
            ? 'Como tu trabajo escrito aun esta pendiente de revision, puedes continuar con la siguiente leccion, pero recomendamos repasar Comparar fracciones con el tutor si no te sientes seguro.'
            : 'Because your written work is still pending review, you can continue to the next lesson, but we recommend reviewing Comparing Fractions with the tutor if you feel unsure.',
        recommendedLessonId: 'equivalent-fractions',
        recommendedActionLabel: isSpanish
            ? 'Continuar con Fracciones equivalentes'
            : 'Continue with Equivalent Fractions',
      ),
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
