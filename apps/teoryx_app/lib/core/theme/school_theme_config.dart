import 'package:flutter/material.dart';

import 'app_colors.dart';

class SchoolThemeConfig {
  const SchoolThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
  });

  factory SchoolThemeConfig.defaultConfig() {
    return const SchoolThemeConfig(
      primaryColor: AppColors.fallbackPrimary,
      secondaryColor: AppColors.fallbackSecondary,
    );
  }

  final Color primaryColor;
  final Color secondaryColor;
  final String? logoUrl;
}
