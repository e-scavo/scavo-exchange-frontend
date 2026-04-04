import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signature_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

import 'wallet_signer_service.dart';

class InternalWalletSignerContract implements WalletSignerService {
  const InternalWalletSignerContract();

  @override
  WalletSignerType get signerType => WalletSignerType.internalPrepared;

  @override
  Future<WalletSignerState> getState() async {
    return const WalletSignerState.unavailable(
      signerType: WalletSignerType.internalPrepared,
      displayName: 'Internal SCAVIUM signer',
      description:
          'The internal signer contract is prepared, but the Exchange has not integrated SCAVIUM Wallet cryptographic flows yet.',
    );
  }

  @override
  Future<String?> getSelectedAddress() async => null;

  @override
  Future<String> signMessage(WalletSignatureRequest request) {
    throw AppError(
      message:
          'The internal SCAVIUM wallet signer is not implemented yet in this phase.',
      code: 'internal_wallet_signer_not_implemented',
    );
  }
}
