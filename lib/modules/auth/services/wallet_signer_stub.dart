import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signature_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

import 'wallet_signer_service.dart';

class WalletSignerStubService implements WalletSignerService {
  const WalletSignerStubService();

  @override
  WalletSignerType get signerType => WalletSignerType.manualFallback;

  @override
  Future<WalletSignerState> getState() async {
    return const WalletSignerState.unavailable(
      signerType: WalletSignerType.manualFallback,
      displayName: 'Manual signature fallback',
      description:
          'No automatic signer is available on this platform, so manual signature entry remains active.',
    );
  }

  @override
  Future<String?> getSelectedAddress() async => null;

  @override
  Future<String> signMessage(WalletSignatureRequest request) {
    throw AppError(
      message:
          'No automatic signer is available on this platform. Use the manual signature fallback.',
      code: 'wallet_signer_unavailable',
    );
  }
}

WalletSignerService createExternalWalletSigner() => const WalletSignerStubService();
