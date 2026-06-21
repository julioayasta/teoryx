import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.appTitle,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.mockLoginTitle,
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.mockLoginMessage,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () =>
                        context.goNamed(RouteNames.studentDashboard),
                    icon: const Icon(Icons.person_outline),
                    label: Text(context.l10n.continueAsStudent),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.family_restroom_outlined),
                    label: Text(context.l10n.continueAsParent),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(context.l10n.continueAsSchoolAdmin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
