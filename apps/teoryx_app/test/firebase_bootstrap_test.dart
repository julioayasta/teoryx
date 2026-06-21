import 'package:flutter_test/flutter_test.dart';
import 'package:teoryx_app/app/app_bootstrap.dart';
import 'package:teoryx_app/core/configuration/firebase_app_config.dart';

void main() {
  testWidgets('Firebase bootstrap falls back when Firebase is unavailable', (
    tester,
  ) async {
    final dependencies = await initializeAppDependencies();

    if (FirebaseAppConfig.isEnabled) {
      expect(dependencies.firebaseStatus.isFallbackActive, isTrue);
      expect(dependencies.firebaseStatus.message, contains('Falling back'));
      expect(dependencies.schoolThemeConfig.schoolName, 'K2S');
      expect(
        dependencies.studentRepository.getCurrentStudent().firstName,
        'Sofia',
      );
      expect(
        dependencies.courseRepository.getAvailableCourses('en'),
        hasLength(4),
      );
      expect(
        dependencies.lessonRepository.getLessonsForCourse('grade-4-math', 'en'),
        isNotEmpty,
      );
      expect(
        dependencies.progressRepository
            .getStudentProgress('student-001', 'en')
            .currentLessonId,
        'comparing-fractions',
      );
    } else {
      expect(dependencies.firebaseStatus.isFallbackActive, isFalse);
      expect(dependencies.firebaseStatus.isFirebaseRequested, isFalse);
      expect(dependencies.schoolThemeConfig.schoolName, 'K2S');
      expect(
        dependencies.studentRepository.getCurrentStudent().firstName,
        'Sofia',
      );
      expect(
        dependencies.courseRepository.getAvailableCourses('en'),
        hasLength(4),
      );
      expect(
        dependencies.lessonRepository.getLessonsForCourse('grade-4-math', 'en'),
        isNotEmpty,
      );
      expect(
        dependencies.progressRepository
            .getStudentProgress('student-001', 'en')
            .currentLessonId,
        'comparing-fractions',
      );
    }
  });
}
