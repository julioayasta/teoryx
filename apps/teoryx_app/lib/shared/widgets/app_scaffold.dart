import 'package:flutter/material.dart';

import 'app_shell.dart';

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
    return AppShell(
      title: title,
      leading: leading,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
