import 'package:flutter/material.dart';
import 'package:teoryx_app/l10n/app_localizations.dart';

import '../core/constants/supported_locales.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/routing/app_router.dart';
import '../core/configuration/firebase_bootstrap_status.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/school_theme_config.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/controllers/auth_scope.dart';
import '../features/student/domain/repositories/student_repository.dart';
import '../features/student/presentation/controllers/student_repository_scope.dart';

class TeoryXApp extends StatelessWidget {
  TeoryXApp({
    required this.authRepository,
    required this.firebaseStatus,
    required this.studentRepository,
    required this.localeController,
    required this.schoolThemeConfig,
    super.key,
  }) : authController = AuthController(authRepository: authRepository);

  final AuthRepository authRepository;
  final FirebaseBootstrapStatus firebaseStatus;
  final StudentRepository studentRepository;
  final AuthController authController;
  final AppLocaleController localeController;
  final SchoolThemeConfig schoolThemeConfig;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, child) {
        return AppLocaleScope(
          controller: localeController,
          child: AuthScope(
            controller: authController,
            child: StudentRepositoryScope(
              repository: studentRepository,
              child: MaterialApp.router(
                title: 'TeoryX',
                debugShowCheckedModeBanner: false,
                locale: locale,
                theme: AppTheme.light(schoolThemeConfig),
                darkTheme: AppTheme.dark(schoolThemeConfig),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: SupportedLocales.values,
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  return _FirebaseStatusBanner(
                    firebaseStatus: firebaseStatus,
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final AppLocaleController controller;

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

class _FirebaseStatusBanner extends StatelessWidget {
  const _FirebaseStatusBanner({
    required this.firebaseStatus,
    required this.child,
  });

  final FirebaseBootstrapStatus firebaseStatus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final message = firebaseStatus.message;

    if (!firebaseStatus.isFallbackActive || message == null) {
      return child;
    }

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
