import 'package:flutter/material.dart';

import 'school_theme_config.dart';
import 'theme_extensions.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(SchoolThemeConfig schoolThemeConfig) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: schoolThemeConfig.primaryColor,
      brightness: Brightness.light,
    );

    return _themeData(colorScheme, schoolThemeConfig);
  }

  static ThemeData dark(SchoolThemeConfig schoolThemeConfig) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: schoolThemeConfig.primaryColor,
      brightness: Brightness.dark,
    );

    return _themeData(colorScheme, schoolThemeConfig);
  }

  static ThemeData _themeData(
    ColorScheme colorScheme,
    SchoolThemeConfig schoolThemeConfig,
  ) {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: schoolThemeConfig.fontFamily,
      useMaterial3: true,
      extensions: [
        SchoolBrandTheme(
          schoolName: schoolThemeConfig.schoolName,
          fullSchoolName: schoolThemeConfig.fullSchoolName,
          primaryColor: schoolThemeConfig.primaryColor,
          secondaryColor: schoolThemeConfig.secondaryColor,
          fontFamily: schoolThemeConfig.fontFamily,
          logoAssetPath: schoolThemeConfig.logoAssetPath,
        ),
      ],
    );
  }
}
