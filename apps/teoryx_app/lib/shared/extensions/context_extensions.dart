import 'package:flutter/material.dart';
import 'package:teoryx_app/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
