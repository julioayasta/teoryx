import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'app_scaffold.dart';

class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.appTitle,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 56,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.foundationReadyTitle,
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.foundationReadyMessage,
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
