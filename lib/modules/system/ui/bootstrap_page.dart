import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../app/responsive_app_shell.dart';
import '../../../app/router.dart';
import '../../../core/errors/app_error.dart';
import '../../auth/models/auth_state.dart';
import '../models/health_models.dart';
import '../models/version_models.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  late final Future<_SystemBootstrapData> _systemFuture;

  @override
  void initState() {
    super.initState();
    _systemFuture = _loadSystemData();
  }

  Future<_SystemBootstrapData> _loadSystemData() async {
    final services = AppServicesScope.of(context);
    final health = await services.systemApi.getHealth();
    final version = await services.systemApi.getVersion();
    return _SystemBootstrapData(health: health, version: version);
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthSessionScope.of(context);

    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final authState = authController.state;

        return FutureBuilder<_SystemBootstrapData>(
          future: _systemFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Bootstrap error: ${snapshot.error}'),
                  ),
                ),
              );
            }

            final system = snapshot.requireData;

            return ResponsiveAppShell(
              title: 'SCAVO Exchange',
              selectedIndex: 0,
              destinations: _destinations(context),
              actions: [
                if (authState.isAuthenticated)
                  TextButton.icon(
                    onPressed:
                        authState.isBootstrapping
                            ? null
                            : authController.refreshAuthenticatedState,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Auth'),
                  ),
              ],
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _SummaryHeader(system: system, authState: authState),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _InfoCard(
                        title: 'Environment',
                        content:
                            system.version.environment.isEmpty
                                ? 'unknown'
                                : system.version.environment,
                      ),
                      _InfoCard(
                        title: 'Version',
                        content:
                            system.version.version.isEmpty
                                ? 'unknown'
                                : system.version.version,
                      ),
                      _InfoCard(
                        title: 'Commit',
                        content:
                            system.version.commit.isEmpty
                                ? 'not provided'
                                : system.version.commit,
                      ),
                      _InfoCard(
                        title: 'Session State',
                        content:
                            authState.isAuthenticated
                                ? 'Authenticated'
                                : 'Anonymous',
                      ),
                      _InfoCard(
                        title: 'WS State',
                        content: authState.wsStatus.name,
                      ),
                      _InfoCard(
                        title: 'WS Ping',
                        content:
                            authState.wsPingAt?.toIso8601String() ??
                            'not available',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current scope',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Phase 0.2 consolidates authentication as an application-level flow. HTTP remains the source for login and baseline session recovery, while WebSocket now complements session and whoami validation without inventing new backend contracts.',
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.login),
                                icon: const Icon(Icons.login),
                                label: Text(
                                  authState.isAuthenticated
                                      ? 'Switch Session'
                                      : 'Sign In',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed:
                                    authState.canOpenProtectedViews
                                        ? () => Navigator.of(
                                          context,
                                        ).pushNamed(AppRouter.session)
                                        : null,
                                icon: const Icon(Icons.badge_outlined),
                                label: const Text('Open Session View'),
                              ),
                              if (authState.isAuthenticated)
                                OutlinedButton.icon(
                                  onPressed:
                                      authState.isBootstrapping
                                          ? null
                                          : authController
                                              .refreshAuthenticatedState,
                                  icon: const Icon(Icons.sync),
                                  label: const Text('Revalidate Auth'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (authState.lastError != null) ...[
                    const SizedBox(height: 20),
                    _ErrorCard(
                      title: 'Auth HTTP Error',
                      error: authState.lastError!,
                    ),
                  ],
                  if (authState.wsError != null) ...[
                    const SizedBox(height: 20),
                    _ErrorCard(
                      title: 'Auth WebSocket Error',
                      error: authState.wsError!,
                    ),
                  ],
                  if (authState.session != null) ...[
                    const SizedBox(height: 20),
                    _JsonCard(
                      title: 'HTTP Session Snapshot',
                      data: _sessionToRows(authState.session!),
                    ),
                  ],
                  if (authState.user != null) ...[
                    const SizedBox(height: 20),
                    _JsonCard(
                      title: 'HTTP User Snapshot',
                      data: _userToRows(authState.user!),
                    ),
                  ],
                  if (authState.whoAmI != null) ...[
                    const SizedBox(height: 20),
                    _JsonCard(
                      title: 'WS WhoAmI Snapshot',
                      data: _whoAmIToRows(authState),
                    ),
                  ],
                ],
              ),
            );
          },
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

  Map<String, String> _sessionToRows(dynamic session) {
    return {
      'authenticated': session.authenticated.toString(),
      'token_type': session.tokenType,
      'user_id': session.userId,
      'email': session.email ?? '',
      'auth_method': session.authMethod,
      'wallet_id': session.walletId ?? '',
      'wallet_address': session.walletAddress ?? '',
      'chain': session.chain ?? '',
      'subject': session.subject ?? '',
      'issuer': session.issuer ?? '',
      'expires_at': session.expiresAt?.toIso8601String() ?? '',
    };
  }

  Map<String, String> _userToRows(dynamic user) {
    return {
      'id': user.id,
      'email': user.email,
      'created_at': user.createdAt?.toIso8601String() ?? '',
      'updated_at': user.updatedAt?.toIso8601String() ?? '',
    };
  }

  Map<String, String> _whoAmIToRows(AuthState state) {
    final whoAmI = state.whoAmI!;
    return {
      'authenticated': whoAmI.authenticated.toString(),
      'user_id': whoAmI.userId,
      'email': whoAmI.email ?? '',
      'wallet_id': whoAmI.walletId ?? '',
      'wallet_address': whoAmI.walletAddress ?? '',
      'auth_method': whoAmI.authMethod ?? '',
      'chain': whoAmI.chain ?? '',
      'subject': whoAmI.subject ?? '',
      'issuer': whoAmI.issuer ?? '',
      'expires_at': whoAmI.expiresAt?.toIso8601String() ?? '',
      'ws_status': state.wsStatus.name,
      'ws_ping_at': state.wsPingAt?.toIso8601String() ?? '',
    };
  }
}

class _SystemBootstrapData {
  const _SystemBootstrapData({required this.health, required this.version});

  final HealthResponse health;
  final VersionResponse version;
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.system, required this.authState});

  final _SystemBootstrapData system;
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
              'Phase 0.2 auth integration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              system.health.ok
                  ? 'Backend health endpoint responded successfully.'
                  : 'Backend health endpoint returned a degraded response.',
            ),
            const SizedBox(height: 8),
            Text(
              authState.isBootstrapping
                  ? 'Authentication bootstrap is in progress.'
                  : authState.isAuthenticated
                  ? 'Authentication state was restored and consolidated across HTTP + WS.'
                  : 'No authenticated session is currently active.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }
}

class _JsonCard extends StatelessWidget {
  const _JsonCard({required this.title, required this.data});

  final String title;
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final entry in data.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectableText('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title, required this.error});

  final String title;
  final AppError error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('message: ${error.message}'),
            const SizedBox(height: 6),
            Text('code: ${error.code ?? ''}'),
            const SizedBox(height: 6),
            Text('status_code: ${error.statusCode?.toString() ?? ''}'),
          ],
        ),
      ),
    );
  }
}
