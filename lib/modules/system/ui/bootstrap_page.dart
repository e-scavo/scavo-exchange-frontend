import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../app/responsive_app_shell.dart';
import '../../../app/router.dart';
import '../../../core/errors/app_error.dart';
import '../models/health_models.dart';
import '../models/version_models.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  late final Future<_BootstrapViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BootstrapViewData> _load() async {
    final services = AppServicesScope.of(context);

    final health = await services.systemApi.getHealth();
    final version = await services.systemApi.getVersion();

    final token = await services.sessionStorage.readToken();
    if (token == null || token.trim().isEmpty) {
      return _BootstrapViewData(
        health: health,
        version: version,
        isAuthenticated: false,
      );
    }

    try {
      final session = await services.authApi.getSession();
      final me = await services.authApi.getMe();
      return _BootstrapViewData(
        health: health,
        version: version,
        isAuthenticated: true,
        sessionJson: _sessionToRows(session.session),
        userJson: _userToRows(me.user),
      );
    } on AppError {
      await services.sessionStorage.clearToken();
      return _BootstrapViewData(
        health: health,
        version: version,
        isAuthenticated: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapViewData>(
      future: _future,
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

        final data = snapshot.requireData;

        return ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 0,
          destinations: _destinations(context),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SummaryHeader(data: data),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _InfoCard(
                    title: 'Environment',
                    content: data.version.environment.isEmpty ? 'unknown' : data.version.environment,
                  ),
                  _InfoCard(
                    title: 'Version',
                    content: data.version.version.isEmpty ? 'unknown' : data.version.version,
                  ),
                  _InfoCard(
                    title: 'Commit',
                    content: data.version.commit.isEmpty ? 'not provided' : data.version.commit,
                  ),
                  _InfoCard(
                    title: 'Session State',
                    content: data.isAuthenticated ? 'Authenticated' : 'Anonymous',
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
                      Text('Current scope', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      const Text(
                        'Phase 0.1 intentionally exposes only backend-confirmed system and authentication flows. No market, trading, or portfolio contracts are assumed yet.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
                            icon: const Icon(Icons.login),
                            label: Text(data.isAuthenticated ? 'Switch Session' : 'Sign In'),
                          ),
                          OutlinedButton.icon(
                            onPressed: data.isAuthenticated
                                ? () => Navigator.of(context).pushNamed(AppRouter.session)
                                : null,
                            icon: const Icon(Icons.badge_outlined),
                            label: const Text('Open Session View'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (data.sessionJson != null) ...[
                const SizedBox(height: 20),
                _JsonCard(title: 'Session Snapshot', data: data.sessionJson!),
              ],
              if (data.userJson != null) ...[
                const SizedBox(height: 20),
                _JsonCard(title: 'User Snapshot', data: data.userJson!),
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
}

class _BootstrapViewData {
  const _BootstrapViewData({
    required this.health,
    required this.version,
    required this.isAuthenticated,
    this.sessionJson,
    this.userJson,
  });

  final HealthResponse health;
  final VersionResponse version;
  final bool isAuthenticated;
  final Map<String, String>? sessionJson;
  final Map<String, String>? userJson;
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.data});

  final _BootstrapViewData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 0.1 frontend baseline', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              data.health.ok
                  ? 'Backend health endpoint responded successfully.'
                  : 'Backend health endpoint did not report ok=true.',
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
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
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
            ...data.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableText('${entry.key}: ${entry.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
