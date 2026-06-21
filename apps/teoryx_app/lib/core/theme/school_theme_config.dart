import 'package:flutter/material.dart';

import 'app_colors.dart';

class SchoolThemeConfig {
  const SchoolThemeConfig({
    required this.schoolName,
    required this.fullSchoolName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoAssetPath,
    required this.fontFamily,
  });

  factory SchoolThemeConfig.defaultConfig() {
    return const SchoolThemeConfig(
      schoolName: 'TeoryX',
      fullSchoolName: 'TeoryX',
      primaryColor: AppColors.fallbackPrimary,
      secondaryColor: AppColors.fallbackSecondary,
      logoAssetPath: null,
      fontFamily: 'Atkinson Hyperlegible',
    );
  }

  factory SchoolThemeConfig.k2s() {
    return const SchoolThemeConfig(
      schoolName: 'K2S',
      fullSchoolName: 'Knowledge for Success',
      primaryColor: Color(0xFFED1C24),
      secondaryColor: Color(0xFFFFE600),
      logoAssetPath: 'assets/schools/k2s/k2s_logo.png',
      fontFamily: 'Atkinson Hyperlegible',
    );
  }

  final String schoolName;
  final String fullSchoolName;
  final Color primaryColor;
  final Color secondaryColor;
  final String? logoAssetPath;
  final String fontFamily;
}
