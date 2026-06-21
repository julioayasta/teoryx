import '../../domain/entities/student_progress.dart';

class MockProgressRepository {
  const MockProgressRepository();

  StudentProgress getCurrentProgress(String languageCode) {
    final isSpanish = languageCode == 'es';

    return StudentProgress(
      studentId: 'student-001',
      courseId: 'grade-4-math',
      lessonId: 'comparing-fractions',
      currentLessonTitle: isSpanish
          ? 'Comparar fracciones'
          : 'Comparing Fractions',
      lessonProgressLabel: isSpanish ? 'Leccion 2 de 8' : 'Lesson 2 of 8',
      masteryLevel: MasteryLevel.developing,
      lastAssessmentScorePercentage: 67,
      hasPendingReview: true,
    );
  }
}
