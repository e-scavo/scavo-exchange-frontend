import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signature_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

abstract class WalletSignerService {
  WalletSignerType get signerType;

  Future<WalletSignerState> getState();

  Future<String?> getSelectedAddress();

  Future<String> signMessage(WalletSignatureRequest request);
}
