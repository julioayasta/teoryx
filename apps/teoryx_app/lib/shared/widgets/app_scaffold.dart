import 'package:flutter/material.dart';

import '../../app/teoryx_app.dart';
import '../../core/constants/supported_locales.dart';
import '../extensions/context_extensions.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.leading,
    this.floatingActionButton,
    super.key,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: title == null ? null : Text(title!),
        actions: const [_LanguageSelector()],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final controller = AppLocaleScope.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: Localizations.localeOf(context),
          icon: const Icon(Icons.language),
          borderRadius: BorderRadius.circular(8),
          onChanged: (locale) {
            if (locale != null) {
              controller.setLocale(locale);
            }
          },
          items: [
            DropdownMenuItem(
              value: SupportedLocales.english,
              child: Text(context.l10n.languageEnglish),
            ),
            DropdownMenuItem(
              value: SupportedLocales.spanish,
              child: Text(context.l10n.languageSpanish),
            ),
          ],
        ),
      ),
    );
  }
}
