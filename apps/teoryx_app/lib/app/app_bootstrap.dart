import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../core/configuration/firebase_app_config.dart';
import '../core/configuration/firebase_bootstrap_status.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/theme/school_theme_config.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/data/repositories/mock_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/lesson/data/repositories/firestore_course_repository.dart';
import '../features/lesson/data/repositories/mock_course_repository.dart';
import '../features/lesson/domain/repositories/course_repository.dart';
import '../features/progress/data/repositories/firestore_progress_repository.dart';
import '../features/progress/data/repositories/mock_progress_repository.dart';
import '../features/progress/domain/repositories/progress_repository.dart';
import '../features/school/data/repositories/firestore_school_theme_repository.dart';
import '../features/school/domain/repositories/school_theme_repository.dart';
import '../features/student/data/repositories/firestore_student_repository.dart';
import '../features/student/data/repositories/mock_student_repository.dart';
import '../features/student/domain/repositories/student_repository.dart';
import 'teoryx_app.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.firebaseStatus,
    required this.schoolThemeConfig,
    required this.studentRepository,
    required this.courseRepository,
    required this.progressRepository,
  });

  final AuthRepository authRepository;
  final FirebaseBootstrapStatus firebaseStatus;
  final SchoolThemeConfig schoolThemeConfig;
  final StudentRepository studentRepository;
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
}

Future<AppDependencies> initializeAppDependencies() async {
  const schoolId = 'school-demo';
  const studentId = 'student-001';

  if (FirebaseAppConfig.isEnabled) {
    if (!FirebaseAppConfig.hasGeneratedConfiguration) {
      final message =
          'Firebase was requested with TEORYX_FIREBASE_ENABLED=true, but this '
          'project does not have FlutterFire configuration enabled. Falling '
          'back to mock authentication. Run `flutterfire configure`, verify '
          '`lib/firebase_options.dart` and platform plugin registration, then '
          'start Firebase mode with TEORYX_FIREBASE_CONFIGURED=true.';

      debugPrint('TeoryX Firebase fallback: $message');

      return AppDependencies(
        authRepository: MockAuthRepository(),
        firebaseStatus: FirebaseBootstrapStatus.fallback(message),
        schoolThemeConfig: SchoolThemeConfig.k2s(),
        studentRepository: const MockStudentRepository(),
        courseRepository: const MockCourseRepository(),
        progressRepository: const MockProgressRepository(),
      );
    }

    try {
      await Firebase.initializeApp().timeout(
        FirebaseAppConfig.initializationTimeout,
      );
      debugPrint('TeoryX Firebase: initialized successfully.');
      final schoolThemeConfig = await _resolveSchoolThemeConfig(
        schoolId: schoolId,
        repository: FirestoreSchoolThemeRepository(),
      );
      final studentRepository = FirestoreStudentRepository(
        schoolId: schoolId,
        studentId: studentId,
      );
      await _preloadStudentProfile(
        schoolId: schoolId,
        studentId: studentId,
        repository: studentRepository,
      );
      final courseRepository = FirestoreCourseRepository(schoolId: schoolId);
      await _preloadCourseCatalog(repository: courseRepository);
      final progressRepository = FirestoreProgressRepository(
        schoolId: schoolId,
        studentId: studentId,
      );
      await _preloadStudentProgress(repository: progressRepository);

      return AppDependencies(
        authRepository: FirebaseAuthRepository(),
        firebaseStatus: const FirebaseBootstrapStatus.available(),
        schoolThemeConfig: schoolThemeConfig,
        studentRepository: studentRepository,
        courseRepository: courseRepository,
        progressRepository: progressRepository,
      );
    } on Object catch (error, stackTrace) {
      final message =
          'Firebase was requested with TEORYX_FIREBASE_ENABLED=true, but '
          'Firebase is not available for this build/platform configuration. '
          'Falling back to mock authentication. For Linux desktop, run '
          '`flutterfire configure` and verify generated Firebase options and '
          'Linux plugin registration before enabling Firebase mode.';

      debugPrint('TeoryX Firebase fallback: $message');
      debugPrint('TeoryX Firebase initialization error: $error');
      debugPrintStack(
        label: 'TeoryX Firebase initialization stack',
        stackTrace: stackTrace,
      );

      return AppDependencies(
        authRepository: MockAuthRepository(),
        firebaseStatus: FirebaseBootstrapStatus.fallback(message),
        schoolThemeConfig: SchoolThemeConfig.k2s(),
        studentRepository: const MockStudentRepository(),
        courseRepository: const MockCourseRepository(),
        progressRepository: const MockProgressRepository(),
      );
    }
  }

  return AppDependencies(
    authRepository: MockAuthRepository(),
    firebaseStatus: const FirebaseBootstrapStatus.mockMode(),
    schoolThemeConfig: SchoolThemeConfig.k2s(),
    studentRepository: const MockStudentRepository(),
    courseRepository: const MockCourseRepository(),
    progressRepository: const MockProgressRepository(),
  );
}

Future<void> _preloadStudentProfile({
  required String schoolId,
  required String studentId,
  required StudentRepository repository,
}) async {
  try {
    await repository.getStudentProfile(
      schoolId: schoolId,
      studentId: studentId,
    );
  } on Object catch (error, stackTrace) {
    debugPrint(
      'TeoryX Firebase fallback: could not load student profile for '
      '$schoolId/$studentId. Using mock student profile. Error: $error',
    );
    debugPrintStack(
      label: 'TeoryX student profile Firestore stack',
      stackTrace: stackTrace,
    );
  }
}

Widget buildTeoryXApp({AppDependencies? dependencies}) {
  final resolvedDependencies =
      dependencies ??
      AppDependencies(
        authRepository: MockAuthRepository(),
        firebaseStatus: const FirebaseBootstrapStatus.mockMode(),
        schoolThemeConfig: SchoolThemeConfig.k2s(),
        studentRepository: const MockStudentRepository(),
        courseRepository: const MockCourseRepository(),
        progressRepository: const MockProgressRepository(),
      );

  return TeoryXApp(
    authRepository: resolvedDependencies.authRepository,
    firebaseStatus: resolvedDependencies.firebaseStatus,
    studentRepository: resolvedDependencies.studentRepository,
    courseRepository: resolvedDependencies.courseRepository,
    progressRepository: resolvedDependencies.progressRepository,
    localeController: AppLocaleController(),
    schoolThemeConfig: resolvedDependencies.schoolThemeConfig,
  );
}

Future<void> _preloadStudentProgress({
  required FirestoreProgressRepository repository,
}) async {
  try {
    await repository.preloadStudentProgress('en');
  } on Object catch (error, stackTrace) {
    debugPrint(
      'TeoryX Firebase fallback: could not load student progress. '
      'Using mock progress. Error: $error',
    );
    debugPrintStack(
      label: 'TeoryX student progress Firestore stack',
      stackTrace: stackTrace,
    );
  }
}

Future<void> _preloadCourseCatalog({
  required FirestoreCourseRepository repository,
}) async {
  try {
    await repository.preloadCourses();
  } on Object catch (error, stackTrace) {
    debugPrint(
      'TeoryX Firebase fallback: could not load course catalog. '
      'Using mock courses. Error: $error',
    );
    debugPrintStack(
      label: 'TeoryX course catalog Firestore stack',
      stackTrace: stackTrace,
    );
  }
}

Future<SchoolThemeConfig> _resolveSchoolThemeConfig({
  required String schoolId,
  required SchoolThemeRepository repository,
}) async {
  try {
    final schoolThemeConfig = await repository.getSchoolThemeConfig(schoolId);

    return schoolThemeConfig ?? SchoolThemeConfig.k2s();
  } on Object catch (error, stackTrace) {
    debugPrint(
      'TeoryX Firebase fallback: could not load school theme for $schoolId. '
      'Using K2S local theme. Error: $error',
    );
    debugPrintStack(
      label: 'TeoryX school theme Firestore stack',
      stackTrace: stackTrace,
    );

    return SchoolThemeConfig.k2s();
  }
}
