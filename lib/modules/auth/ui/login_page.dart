import 'package:flutter/material.dart';
import 'package:scavo_exchange_frontend/app/app.dart';
import 'package:scavo_exchange_frontend/app/responsive_app_shell.dart';
import 'package:scavo_exchange_frontend/app/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dev@scavo.local');
  final _passwordController = TextEditingController(text: 'devpassword');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthSessionScope.of(context);

    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final authState = authController.state;

        return ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 1,
          destinations: _destinations(context),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer login',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Phase 0.2 keeps the existing backend-confirmed HTTP login while consolidating session state into a single application controller.',
                        ),
                        const SizedBox(height: 20),
                        if (authState.lastError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authState.lastError!.message,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (authState.isAuthenticated) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Active authenticated session detected for ${authState.user?.email ?? authState.session?.email ?? authState.session?.userId ?? 'current user'}.',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'dev@scavo.local',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed:
                                  authState.isSubmittingLogin ? null : _submit,
                              icon:
                                  authState.isSubmittingLogin
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.login),
                              label: Text(
                                authState.isSubmittingLogin
                                    ? 'Signing in...'
                                    : 'Sign In',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed:
                                  authState.isAuthenticated
                                      ? () => Navigator.of(
                                        context,
                                      ).pushReplacementNamed(AppRouter.session)
                                      : null,
                              icon: const Icon(Icons.badge_outlined),
                              label: const Text('Open Session View'),
                            ),
                            TextButton(
                              onPressed:
                                  authState.isSubmittingLogin
                                      ? null
                                      : authController.clearVisibleErrors,
                              child: const Text('Clear Errors'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<ShellDestination> _destinations(BuildContext context) {
    return [
      ShellDestination(
        label: 'Bootstrap',
        icon: Icons.home_outlined,
        onTap:
            () =>
                Navigator.of(context).pushReplacementNamed(AppRouter.bootstrap),
      ),
      ShellDestination(
        label: 'Login',
        icon: Icons.login,
        onTap:
            () => Navigator.of(context).pushReplacementNamed(AppRouter.login),
      ),
      ShellDestination(
        label: 'Session',
        icon: Icons.badge_outlined,
        onTap:
            () => Navigator.of(context).pushReplacementNamed(AppRouter.session),
      ),
      ShellDestination(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        onTap:
            () => Navigator.of(context).pushReplacementNamed(AppRouter.wallet),
      ),
    ];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = AuthSessionScope.of(context);
    await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (authController.state.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRouter.session);
    }
  }
}
