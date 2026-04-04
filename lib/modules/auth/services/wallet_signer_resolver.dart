import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

import 'wallet_signer_internal_contract.dart';
import 'wallet_signer_service.dart';
import 'wallet_signer_stub.dart'
    if (dart.library.html) 'wallet_signer_web.dart' as external_signer;

class WalletSignerResolver {
  WalletSignerResolver({
    WalletSignerService? externalSigner,
    WalletSignerService? internalSigner,
  }) : _externalSigner = externalSigner ?? external_signer.createExternalWalletSigner(),
       _internalSigner = internalSigner ?? const InternalWalletSignerContract();

  final WalletSignerService _externalSigner;
  final WalletSignerService _internalSigner;

  WalletSignerService get externalSigner => _externalSigner;
  WalletSignerService get internalSigner => _internalSigner;

  Future<WalletSignerState> resolvePreferredState() async {
    final externalState = await _externalSigner.getState();
    if (externalState.isAvailable) {
      return externalState;
    }

    final internalState = await _internalSigner.getState();
    if (internalState.isAvailable) {
      return internalState;
    }

    return externalState;
  }

  Future<WalletSignerService?> resolvePreferredSigner() async {
    final externalState = await _externalSigner.getState();
    if (externalState.isAvailable) {
      return _externalSigner;
    }

    final internalState = await _internalSigner.getState();
    if (internalState.isAvailable) {
      return _internalSigner;
    }

    return null;
  }
}
