import 'package:flutter/material.dart';
import 'package:scavo_exchange_frontend/modules/auth/controllers/wallet_flow_controller.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_flow_state.dart';

class WalletInventoryCard extends StatelessWidget {
  const WalletInventoryCard({
    required this.controller,
    required this.state,
    required this.isAuthenticated,
    super.key,
  });

  final WalletFlowController controller;
  final WalletFlowState state;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final wallets = state.walletsResponse?.wallets ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Wallet inventory',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      isAuthenticated && !state.isLoadingWallets
                          ? controller.loadWalletInventory
                          : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    state.isLoadingWallets ? 'Refreshing...' : 'Refresh',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isAuthenticated
                  ? 'Inventory uses GET /auth/wallets from the authenticated session. This prepares link, primary, and detach flows without implementing mutations yet.'
                  : 'Inventory remains disabled until a valid authenticated session exists.',
            ),
            if (state.walletsResponse != null) ...[
              const SizedBox(height: 16),
              Text(
                'Total ${state.walletsResponse!.total} · Returned ${state.walletsResponse!.returned} · Offset ${state.walletsResponse!.offset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (!isAuthenticated)
              const Text('Authenticate first to load the wallet inventory.')
            else if (state.isLoadingWallets && wallets.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (wallets.isEmpty)
              const Text('No wallets were returned for the current session.')
            else
              Column(
                children: [
                  for (final wallet in wallets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.address,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _Chip(label: 'Status', value: wallet.status),
                                _Chip(
                                  label: 'Primary',
                                  value: wallet.isPrimary ? 'yes' : 'no',
                                ),
                                _Chip(
                                  label: 'Can set primary',
                                  value: wallet.canSetPrimary ? 'yes' : 'no',
                                ),
                                _Chip(
                                  label: 'Can detach',
                                  value: wallet.canDetach ? 'yes' : 'no',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _Line(label: 'Wallet ID', value: wallet.id),
                            _Line(label: 'User ID', value: wallet.userId ?? ''),
                            _Line(
                              label: 'Linked At',
                              value: wallet.linkedAt?.toIso8601String() ?? '',
                            ),
                            _Line(
                              label: 'Detached At',
                              value: wallet.detachedAt?.toIso8601String() ?? '',
                            ),
                            if (wallet.detachBlockReasons.isNotEmpty)
                              _Line(
                                label: 'Detach block reasons',
                                value: wallet.detachBlockReasons.join(', '),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
