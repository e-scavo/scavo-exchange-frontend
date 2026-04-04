import 'package:flutter/material.dart';
import 'package:scavo_exchange_frontend/app/app.dart';
import 'package:scavo_exchange_frontend/app/responsive_app_shell.dart';
import 'package:scavo_exchange_frontend/app/router.dart';
import 'package:scavo_exchange_frontend/modules/auth/controllers/wallet_flow_controller.dart';
import 'package:scavo_exchange_frontend/modules/auth/ui/wallet_challenge_card.dart';
import 'package:scavo_exchange_frontend/modules/auth/ui/wallet_inventory_card.dart';
import 'package:scavo_exchange_frontend/modules/auth/ui/wallet_verify_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletFlowController? _walletController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _walletController ??= WalletFlowController(
      authApi: AppServicesScope.of(context).authApi,
      authSessionController: AppServicesScope.of(context).authSessionController,
      walletSignerResolver: AppServicesScope.of(context).walletSignerResolver,
    );
    _walletController!.refreshSignerState();
  }

  @override
  void dispose() {
    _walletController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthSessionScope.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([authController, _walletController!]),
      builder: (context, _) {
        final authState = authController.state;
        final walletState = _walletController!.state;

        return ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 3,
          destinations: _destinations(context),
          actions: [
            TextButton.icon(
              onPressed: _walletController!.clearMessages,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Wallet Messages'),
            ),
          ],
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phase 0.4 abstract wallet signature integration',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This phase keeps manual verification available while adding an abstract signer strategy, a first MetaMask web implementation, and a prepared contract for a future internal SCAVIUM wallet signer.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _StatusChip(
                            label: 'Session',
                            value:
                                authState.isAuthenticated
                                    ? 'authenticated'
                                    : 'anonymous',
                          ),
                          _StatusChip(
                            label: 'Auth method',
                            value:
                                authState.whoAmI?.authMethod ??
                                authState.session?.authMethod ??
                                'n/a',
                          ),
                          _StatusChip(
                            label: 'Wallet address',
                            value: authState.resolvedWalletAddress ?? 'n/a',
                          ),
                          _StatusChip(
                            label: 'WS',
                            value: authState.wsStatus.name,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (walletState.lastSuccessMessage != null) ...[
                const SizedBox(height: 20),
                _MessageBanner(
                  message: walletState.lastSuccessMessage!,
                  isError: false,
                ),
              ],
              if (walletState.lastError != null) ...[
                const SizedBox(height: 20),
                _MessageBanner(
                  message: walletState.lastError!.message,
                  isError: true,
                ),
              ],
              const SizedBox(height: 20),
              WalletChallengeCard(
                controller: _walletController!,
                state: walletState,
              ),
              const SizedBox(height: 20),
              WalletVerifyCard(
                controller: _walletController!,
                state: walletState,
              ),
              const SizedBox(height: 20),
              WalletInventoryCard(
                controller: _walletController!,
                state: walletState,
                isAuthenticated: authState.isAuthenticated,
              ),
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
      ShellDestination(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        onTap:
            () => Navigator.of(context).pushReplacementNamed(AppRouter.wallet),
      ),
    ];
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? scheme.errorContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
