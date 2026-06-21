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
    return FirestoreSchoolThemeModel(
      schoolName: data['name'] as String? ?? 'TeoryX',
      fullSchoolName:
          data['fullName'] as String? ?? data['name'] as String? ?? 'TeoryX',
      primaryColor: _colorFromHex(
        data['primaryColor'] as String?,
        const Color(0xFF3057D5),
      ),
      secondaryColor: _colorFromHex(
        data['secondaryColor'] as String?,
        const Color(0xFFFFC107),
      ),
      logoAssetPath: data['logoAssetPath'] as String?,
      fontFamily: data['fontFamily'] as String? ?? 'Atkinson Hyperlegible',
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
