import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../app/responsive_app_shell.dart';
import '../../../app/router.dart';
import '../models/auth_state.dart';
import '../models/session_models.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthSessionScope.of(context);

    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final authState = authController.state;

        return ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 2,
          destinations: _destinations(context),
          actions: [
            TextButton.icon(
              onPressed:
                  authState.isBootstrapping
                      ? null
                      : authController.refreshAuthenticatedState,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            TextButton.icon(
              onPressed:
                  authState.isSubmittingLogin
                      ? null
                      : () async {
                        await authController.logout();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRouter.login);
                        }
                      },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (authState.isBootstrapping)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!authState.isAuthenticated ||
                  authState.session == null ||
                  authState.user == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session unavailable',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          authState.lastError?.message ??
                              'No authenticated session is currently available.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed:
                              () => Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRouter.login),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                _StatusCard(authState: authState),
                const SizedBox(height: 20),
                _SessionCard(session: authState.session!),
                const SizedBox(height: 20),
                _UserCard(user: authState.user!),
                if (authState.whoAmI != null) ...[
                  const SizedBox(height: 20),
                  _WhoAmICard(authState: authState),
                ],
              ],
            ],
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
    ];
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auth Integration Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'HTTP Authenticated',
              value: authState.isAuthenticated.toString(),
            ),
            _Field(label: 'WS Status', value: authState.wsStatus.name),
            _Field(
              label: 'WS Ping At',
              value: authState.wsPingAt?.toIso8601String() ?? '',
            ),
            _Field(
              label: 'HTTP Error',
              value: authState.lastError?.message ?? '',
            ),
            _Field(label: 'WS Error', value: authState.wsError?.message ?? ''),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionView session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolved Session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Authenticated',
              value: session.authenticated.toString(),
            ),
            _Field(label: 'User ID', value: session.userId),
            _Field(label: 'Email', value: session.email ?? ''),
            _Field(label: 'Token Type', value: session.tokenType),
            _Field(label: 'Auth Method', value: session.authMethod),
            _Field(label: 'Wallet ID', value: session.walletId ?? ''),
            _Field(label: 'Wallet Address', value: session.walletAddress ?? ''),
            _Field(label: 'Chain', value: session.chain ?? ''),
            _Field(label: 'Subject', value: session.subject ?? ''),
            _Field(label: 'Issuer', value: session.issuer ?? ''),
            _Field(
              label: 'Expires At',
              value: session.expiresAt?.toIso8601String() ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserView user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolved User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _Field(label: 'ID', value: user.id),
            _Field(label: 'Email', value: user.email),
            _Field(
              label: 'Created At',
              value: user.createdAt?.toIso8601String() ?? '',
            ),
            _Field(
              label: 'Updated At',
              value: user.updatedAt?.toIso8601String() ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class _WhoAmICard extends StatelessWidget {
  const _WhoAmICard({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final whoAmI = authState.whoAmI!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolved WhoAmI (WS)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Authenticated',
              value: whoAmI.authenticated.toString(),
            ),
            _Field(label: 'User ID', value: whoAmI.userId),
            _Field(label: 'Email', value: whoAmI.email ?? ''),
            _Field(label: 'Wallet ID', value: whoAmI.walletId ?? ''),
            _Field(label: 'Wallet Address', value: whoAmI.walletAddress ?? ''),
            _Field(label: 'Auth Method', value: whoAmI.authMethod ?? ''),
            _Field(label: 'Chain', value: whoAmI.chain ?? ''),
            _Field(label: 'Subject', value: whoAmI.subject ?? ''),
            _Field(label: 'Issuer', value: whoAmI.issuer ?? ''),
            _Field(
              label: 'Expires At',
              value: whoAmI.expiresAt?.toIso8601String() ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SelectableText('$label: $value'),
    );
  }
}
