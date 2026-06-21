import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../features/auth/presentation/controllers/auth_scope.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class MockLoginScreen extends StatefulWidget {
  const MockLoginScreen({super.key});

  @override
  State<MockLoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends State<MockLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authController = AuthScope.of(context);
    final didSignIn = await authController.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || !didSignIn) {
      return;
    }

    context.goNamed(RouteNames.studentDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<SchoolBrandTheme>();
    final logoAssetPath = brand?.logoAssetPath;
    final authController = AuthScope.of(context);

    return AppScaffold(
      title: context.l10n.appTitle,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (logoAssetPath != null)
                      Image.asset(logoAssetPath, height: 112)
                    else
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                    const SizedBox(height: 20),
                    Text(
                      brand?.fullSchoolName ?? context.l10n.welcomeTitle,
                      style: context.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.roleSelectionMessage,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: context.l10n.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (authController.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authController.errorMessage!,
                        style: TextStyle(color: context.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: authController.isLoading ? null : _signIn,
                      icon: authController.isLoading
                          ? SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(context.l10n.signIn),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
