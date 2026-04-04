import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scavo_exchange_frontend/modules/auth/controllers/wallet_flow_controller.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_flow_state.dart';

class WalletChallengeCard extends StatefulWidget {
  const WalletChallengeCard({
    required this.controller,
    required this.state,
    super.key,
  });

  final WalletFlowController controller;
  final WalletFlowState state;

  @override
  State<WalletChallengeCard> createState() => _WalletChallengeCardState();
}

class _WalletChallengeCardState extends State<WalletChallengeCard> {
  late final TextEditingController _addressController;
  late final TextEditingController _chainController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.state.challengeAddress,
    );
    _chainController = TextEditingController(text: widget.state.challengeChain);
  }

  @override
  void didUpdateWidget(covariant WalletChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.challengeAddress != _addressController.text) {
      _addressController.text = widget.state.challengeAddress;
    }
    if (widget.state.challengeChain != _chainController.text) {
      _chainController.text = widget.state.challengeChain;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _chainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.state.challengeResponse?.challenge;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet challenge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Phase 0.4 keeps the backend-confirmed challenge contract while allowing automatic signing when a supported signer is available. Manual signing remains available as the fallback path.',
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Wallet address',
                      hintText: '0x...',
                    ),
                    onChanged:
                        (value) => widget.controller.updateDraft(
                          challengeAddress: value,
                        ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wallet address is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _chainController,
                    decoration: const InputDecoration(
                      labelText: 'Chain',
                      hintText: 'scavium',
                    ),
                    onChanged:
                        (value) => widget.controller.updateDraft(
                          challengeChain: value,
                        ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Chain is required.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed:
                      widget.state.isRequestingChallenge
                          ? null
                          : _requestChallenge,
                  icon:
                      widget.state.isRequestingChallenge
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.key_outlined),
                  label: Text(
                    widget.state.isRequestingChallenge
                        ? 'Requesting...'
                        : 'Request challenge',
                  ),
                ),
                if (challenge != null)
                  OutlinedButton.icon(
                    onPressed:
                        () => _copyToClipboard(
                          challenge.message,
                          'Challenge message copied.',
                        ),
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy message'),
                  ),
              ],
            ),
            if (challenge != null) ...[
              const SizedBox(height: 20),
              _ValueRow(label: 'Challenge ID', value: challenge.id),
              _ValueRow(label: 'Address', value: challenge.address),
              _ValueRow(label: 'Chain', value: challenge.chain),
              _ValueRow(label: 'Purpose', value: challenge.purpose ?? ''),
              _ValueRow(label: 'Statement', value: challenge.statement ?? ''),
              _ValueRow(label: 'Domain', value: challenge.domain ?? ''),
              _ValueRow(label: 'URI', value: challenge.uri ?? ''),
              _ValueRow(label: 'Nonce', value: challenge.nonce ?? ''),
              _ValueRow(
                label: 'Issued At',
                value: challenge.issuedAt?.toIso8601String() ?? '',
              ),
              _ValueRow(
                label: 'Expires At',
                value: challenge.expiresAt?.toIso8601String() ?? '',
              ),
              const SizedBox(height: 12),
              SelectableText(
                challenge.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _requestChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.controller.requestChallenge(
      address: _addressController.text.trim(),
      chain: _chainController.text.trim(),
    );
  }

  Future<void> _copyToClipboard(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
