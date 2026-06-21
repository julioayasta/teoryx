import 'package:flutter/material.dart';

import '../../app/teoryx_app.dart';
import '../../core/constants/supported_locales.dart';
import '../extensions/context_extensions.dart';

class AppBreadcrumb {
  const AppBreadcrumb({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class AppShell extends StatelessWidget {
  const AppShell({
    required this.body,
    this.title,
    this.breadcrumbs = const [],
    this.leading,
    this.actions = const [],
    this.floatingActionButton,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<AppBreadcrumb> breadcrumbs;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: _ShellTitle(title: title, breadcrumbs: breadcrumbs),
        actions: [...actions, const _LanguageSelector()],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _ShellTitle extends StatelessWidget {
  const _ShellTitle({required this.title, required this.breadcrumbs});

  final String? title;
  final List<AppBreadcrumb> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    if (breadcrumbs.isEmpty) {
      return Text(title ?? context.l10n.appTitle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < breadcrumbs.length; index++) ...[
            _BreadcrumbItem(breadcrumb: breadcrumbs[index]),
            if (index < breadcrumbs.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  const _BreadcrumbItem({required this.breadcrumb});

  final AppBreadcrumb breadcrumb;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      breadcrumb.label,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.titleMedium?.copyWith(
        color: breadcrumb.onTap == null
            ? context.colorScheme.onSurface
            : context.colorScheme.primary,
      ),
    );

    if (breadcrumb.onTap == null) {
      return text;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: breadcrumb.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: text,
      ),
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
