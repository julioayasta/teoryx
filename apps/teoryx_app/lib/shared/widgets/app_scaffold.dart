import 'package:flutter/material.dart';

import 'app_shell.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
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
    return AppShell(
      title: title,
      breadcrumbs: breadcrumbs,
      leading: leading,
      actions: actions,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
