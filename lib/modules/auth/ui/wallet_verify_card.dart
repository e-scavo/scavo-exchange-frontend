import 'package:flutter/material.dart';
import 'package:scavo_exchange_frontend/modules/auth/controllers/wallet_flow_controller.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_flow_state.dart';

class WalletVerifyCard extends StatefulWidget {
  const WalletVerifyCard({
    required this.controller,
    required this.state,
    super.key,
  });

  final WalletFlowController controller;
  final WalletFlowState state;

  @override
  State<WalletVerifyCard> createState() => _WalletVerifyCardState();
}

class _WalletVerifyCardState extends State<WalletVerifyCard> {
  late final TextEditingController _challengeIdController;
  late final TextEditingController _addressController;
  late final TextEditingController _signatureController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _challengeIdController = TextEditingController(
      text: widget.state.verifyChallengeId,
    );
    _addressController = TextEditingController(
      text: widget.state.verifyAddress,
    );
    _signatureController = TextEditingController(text: widget.state.signature);
  }

  @override
  void didUpdateWidget(covariant WalletVerifyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.verifyChallengeId != _challengeIdController.text) {
      _challengeIdController.text = widget.state.verifyChallengeId;
    }
    if (widget.state.verifyAddress != _addressController.text) {
      _addressController.text = widget.state.verifyAddress;
    }
    if (widget.state.signature != _signatureController.text) {
      _signatureController.text = widget.state.signature;
    }
  }

  @override
  void dispose() {
    _challengeIdController.dispose();
    _addressController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verified = widget.state.lastVerifiedResponse;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet verify',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Paste the signed challenge manually. This keeps Phase 0.3 aligned with the backend while connector decisions remain intentionally deferred.',
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _challengeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Challenge ID',
                    ),
                    onChanged:
                        (value) => widget.controller.updateDraft(
                          verifyChallengeId: value,
                        ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Challenge ID is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Wallet address',
                    ),
                    onChanged:
                        (value) =>
                            widget.controller.updateDraft(verifyAddress: value),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wallet address is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _signatureController,
                    decoration: const InputDecoration(
                      labelText: 'Signature',
                      hintText: '0x...',
                      alignLabelWithHint: true,
                    ),
                    minLines: 4,
                    maxLines: 8,
                    onChanged:
                        (value) =>
                            widget.controller.updateDraft(signature: value),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Signature is required.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.state.isVerifying ? null : _verify,
              icon:
                  widget.state.isVerifying
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.verified_user_outlined),
              label: Text(
                widget.state.isVerifying ? 'Verifying...' : 'Verify wallet',
              ),
            ),
            if (verified != null) ...[
              const SizedBox(height: 20),
              _ValueRow(label: 'Auth Method', value: verified.authMethod),
              _ValueRow(label: 'User ID', value: verified.userId),
              _ValueRow(label: 'Wallet ID', value: verified.walletId ?? ''),
              _ValueRow(label: 'Wallet Address', value: verified.walletAddress),
              _ValueRow(label: 'Chain', value: verified.chain),
              _ValueRow(label: 'Token Type', value: verified.tokenType),
              _ValueRow(label: 'Expires In', value: '${verified.expiresIn}'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.controller.verifyWallet(
      challengeId: _challengeIdController.text.trim(),
      address: _addressController.text.trim(),
      signature: _signatureController.text.trim(),
    );
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
