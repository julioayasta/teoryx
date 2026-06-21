import 'package:flutter/material.dart';
import 'package:teoryx_app/l10n/app_localizations.dart';

import '../core/constants/supported_locales.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/school_theme_config.dart';

class TeoryXApp extends StatelessWidget {
  const TeoryXApp({
    required this.localeController,
    required this.schoolThemeConfig,
    super.key,
  });

  final AppLocaleController localeController;
  final SchoolThemeConfig schoolThemeConfig;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, child) {
        return AppLocaleScope(
          controller: localeController,
          child: MaterialApp.router(
            title: 'TeoryX',
            debugShowCheckedModeBanner: false,
            locale: locale,
            theme: AppTheme.light(schoolThemeConfig),
            darkTheme: AppTheme.dark(schoolThemeConfig),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: SupportedLocales.values,
            routerConfig: AppRouter.router,
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
