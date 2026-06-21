import 'package:flutter/material.dart';

@immutable
class SchoolBrandTheme extends ThemeExtension<SchoolBrandTheme> {
  const SchoolBrandTheme({
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final String? logoUrl;

  @override
  SchoolBrandTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    String? logoUrl,
  }) {
    return SchoolBrandTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  SchoolBrandTheme lerp(ThemeExtension<SchoolBrandTheme>? other, double t) {
    if (other is! SchoolBrandTheme) {
      return this;
    }

    return SchoolBrandTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      logoUrl: t < 0.5 ? logoUrl : other.logoUrl,
    );
  }
}
