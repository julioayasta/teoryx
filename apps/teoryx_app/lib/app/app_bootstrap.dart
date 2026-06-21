import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../core/configuration/firebase_app_config.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/theme/school_theme_config.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/data/repositories/mock_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import 'teoryx_app.dart';

class AppDependencies {
  const AppDependencies({required this.authRepository});

  final AuthRepository authRepository;
}

Future<AppDependencies> initializeAppDependencies() async {
  if (FirebaseAppConfig.isEnabled) {
    await Firebase.initializeApp();

    return AppDependencies(authRepository: FirebaseAuthRepository());
  }

  return AppDependencies(authRepository: MockAuthRepository());
}

Widget buildTeoryXApp({AppDependencies? dependencies}) {
  final resolvedDependencies =
      dependencies ?? AppDependencies(authRepository: MockAuthRepository());

  return TeoryXApp(
    authRepository: resolvedDependencies.authRepository,
    localeController: AppLocaleController(),
    schoolThemeConfig: SchoolThemeConfig.k2s(),
  );
}
