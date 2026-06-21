import 'package:flutter/material.dart';
import 'package:teoryx_app/l10n/app_localizations.dart';

import '../core/constants/supported_locales.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/school_theme_config.dart';

class TeoryXApp extends StatelessWidget {
  const TeoryXApp({required this.schoolThemeConfig, super.key});

  final SchoolThemeConfig schoolThemeConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TeoryX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(schoolThemeConfig),
      darkTheme: AppTheme.dark(schoolThemeConfig),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: SupportedLocales.values,
      routerConfig: AppRouter.router,
    );
  }
}
