import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../app/responsive_app_shell.dart';
import '../../../app/router.dart';
import '../../../core/errors/app_error.dart';
import '../models/login_models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@scavo.exchange');
  final _passwordController = TextEditingController(text: 'dev');

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppShell(
      title: 'SCAVO Exchange',
      selectedIndex: 1,
      destinations: _destinations(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dev sign in', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        const Text(
                          'This screen uses the current backend dev login contract. It is a bootstrap integration surface, not the final production auth UX.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
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
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required.';
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_submitting ? 'Signing in...' : 'Sign In'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ShellDestination> _destinations(BuildContext context) {
    return [
      ShellDestination(
        label: 'Bootstrap',
        icon: Icons.home_outlined,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.bootstrap),
      ),
      ShellDestination(
        label: 'Login',
        icon: Icons.login,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.login),
      ),
      ShellDestination(
        label: 'Session',
        icon: Icons.badge_outlined,
        onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.session),
      ),
    ];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final services = AppServicesScope.of(context);
      final response = await services.authApi.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      await services.sessionStorage.writeToken(response.accessToken);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRouter.session);
    } on AppError catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}
