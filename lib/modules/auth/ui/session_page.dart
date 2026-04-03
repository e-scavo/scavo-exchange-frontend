import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../app/responsive_app_shell.dart';
import '../../../app/router.dart';
import '../../../core/errors/app_error.dart';
import '../models/session_models.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final Future<_SessionViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SessionViewData> _load() async {
    final services = AppServicesScope.of(context);
    final token = await services.sessionStorage.readToken();
    if (token == null || token.trim().isEmpty) {
      throw AppError(message: 'No active session token found.', code: 'missing_token');
    }

    final session = await services.authApi.getSession();
    final me = await services.authApi.getMe();

    return _SessionViewData(session: session.session, user: me.user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionViewData>(
      future: _future,
      builder: (context, snapshot) {
        return ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 2,
          destinations: _destinations(context),
          actions: [
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (snapshot.connectionState != ConnectionState.done)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(),
                ))
              else if (snapshot.hasError)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session unavailable', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(snapshot.error.toString()),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRouter.login),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                _SessionCard(session: snapshot.requireData.session),
                const SizedBox(height: 20),
                _UserCard(user: snapshot.requireData.user),
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

  Future<void> _logout() async {
    final services = AppServicesScope.of(context);
    await services.sessionStorage.clearToken();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }
}

class _SessionViewData {
  const _SessionViewData({required this.session, required this.user});

  final SessionView session;
  final UserView user;
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
            Text('Resolved Session', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _Field(label: 'Authenticated', value: session.authenticated.toString()),
            _Field(label: 'User ID', value: session.userId),
            _Field(label: 'Email', value: session.email ?? ''),
            _Field(label: 'Token Type', value: session.tokenType),
            _Field(label: 'Auth Method', value: session.authMethod),
            _Field(label: 'Wallet ID', value: session.walletId ?? ''),
            _Field(label: 'Wallet Address', value: session.walletAddress ?? ''),
            _Field(label: 'Chain', value: session.chain ?? ''),
            _Field(label: 'Subject', value: session.subject ?? ''),
            _Field(label: 'Issuer', value: session.issuer ?? ''),
            _Field(label: 'Expires At', value: session.expiresAt?.toIso8601String() ?? ''),
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
            Text('Resolved User', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _Field(label: 'ID', value: user.id),
            _Field(label: 'Email', value: user.email),
            _Field(label: 'Created At', value: user.createdAt?.toIso8601String() ?? ''),
            _Field(label: 'Updated At', value: user.updatedAt?.toIso8601String() ?? ''),
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
