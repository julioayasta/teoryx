import 'package:flutter/material.dart';

@immutable
class SchoolBrandTheme extends ThemeExtension<SchoolBrandTheme> {
  const SchoolBrandTheme({
    required this.schoolName,
    required this.fullSchoolName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    this.logoAssetPath,
  });

  final String schoolName;
  final String fullSchoolName;
  final Color primaryColor;
  final Color secondaryColor;
  final String fontFamily;
  final String? logoAssetPath;

  @override
  SchoolBrandTheme copyWith({
    String? schoolName,
    String? fullSchoolName,
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    String? logoAssetPath,
  }) {
    return SchoolBrandTheme(
      schoolName: schoolName ?? this.schoolName,
      fullSchoolName: fullSchoolName ?? this.fullSchoolName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      logoAssetPath: logoAssetPath ?? this.logoAssetPath,
    );
  }

  @override
  SchoolBrandTheme lerp(ThemeExtension<SchoolBrandTheme>? other, double t) {
    if (other is! SchoolBrandTheme) {
      return this;
    }

    return SchoolBrandTheme(
      schoolName: t < 0.5 ? schoolName : other.schoolName,
      fullSchoolName: t < 0.5 ? fullSchoolName : other.fullSchoolName,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      logoAssetPath: t < 0.5 ? logoAssetPath : other.logoAssetPath,
    );
  }
}
