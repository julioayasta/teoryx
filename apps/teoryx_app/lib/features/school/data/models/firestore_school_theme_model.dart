import 'package:flutter/material.dart';

import '../../../../core/theme/school_theme_config.dart';

class FirestoreSchoolThemeModel {
  const FirestoreSchoolThemeModel({
    required this.schoolName,
    required this.fullSchoolName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoAssetPath,
    required this.fontFamily,
  });

  final String schoolName;
  final String fullSchoolName;
  final Color primaryColor;
  final Color secondaryColor;
  final String? logoAssetPath;
  final String fontFamily;

  SchoolThemeConfig toEntity() {
    return SchoolThemeConfig(
      schoolName: schoolName,
      fullSchoolName: fullSchoolName,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      logoAssetPath: logoAssetPath,
      fontFamily: fontFamily,
    );
  }

  static FirestoreSchoolThemeModel fromFirestore(Map<String, dynamic> data) {
    final fallback = SchoolThemeConfig.k2s();
    final logoAssetPath = data['logoAssetPath'] as String?;

    return FirestoreSchoolThemeModel(
      schoolName: data['name'] as String? ?? fallback.schoolName,
      fullSchoolName:
          data['fullName'] as String? ??
          data['name'] as String? ??
          fallback.fullSchoolName,
      primaryColor: _colorFromHex(
        data['primaryColor'] as String?,
        fallback.primaryColor,
      ),
      secondaryColor: _colorFromHex(
        data['secondaryColor'] as String?,
        fallback.secondaryColor,
      ),
      logoAssetPath: logoAssetPath == null || logoAssetPath.isEmpty
          ? fallback.logoAssetPath
          : logoAssetPath,
      fontFamily: data['fontFamily'] as String? ?? fallback.fontFamily,
    );
  }

  static Color _colorFromHex(String? value, Color fallback) {
    if (value == null || value.isEmpty) {
      return fallback;
    }

    final normalized = value.replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final colorValue = int.tryParse(hex, radix: 16);

    if (colorValue == null) {
      return fallback;
    }

    return Color(colorValue);
  }
}
