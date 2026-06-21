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
import '../features/school/data/repositories/firestore_school_theme_repository.dart';
import '../features/school/domain/repositories/school_theme_repository.dart';
import 'teoryx_app.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.firebaseStatus,
    required this.schoolThemeConfig,
  });

  final AuthRepository authRepository;
  final FirebaseBootstrapStatus firebaseStatus;
  final SchoolThemeConfig schoolThemeConfig;
}

Future<AppDependencies> initializeAppDependencies() async {
  const schoolId = 'school-demo';

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

      return AppDependencies(
        authRepository: FirebaseAuthRepository(),
        firebaseStatus: const FirebaseBootstrapStatus.available(),
        schoolThemeConfig: schoolThemeConfig,
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
      );
    }
  }

  return AppDependencies(
    authRepository: MockAuthRepository(),
    firebaseStatus: const FirebaseBootstrapStatus.mockMode(),
    schoolThemeConfig: SchoolThemeConfig.k2s(),
  );
}

Widget buildTeoryXApp({AppDependencies? dependencies}) {
  final resolvedDependencies =
      dependencies ??
      AppDependencies(
        authRepository: MockAuthRepository(),
        firebaseStatus: const FirebaseBootstrapStatus.mockMode(),
        schoolThemeConfig: SchoolThemeConfig.k2s(),
      );

  return TeoryXApp(
    authRepository: resolvedDependencies.authRepository,
    firebaseStatus: resolvedDependencies.firebaseStatus,
    localeController: AppLocaleController(),
    schoolThemeConfig: resolvedDependencies.schoolThemeConfig,
  );
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
