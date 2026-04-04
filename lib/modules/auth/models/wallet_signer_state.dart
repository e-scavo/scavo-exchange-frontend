import 'wallet_signature_models.dart';

class WalletSignerState {
  const WalletSignerState({
    required this.signerType,
    required this.isAvailable,
    required this.displayName,
    required this.description,
    this.address,
  });

  const WalletSignerState.unavailable({
    required WalletSignerType signerType,
    required String displayName,
    required String description,
  }) : this(
         signerType: signerType,
         isAvailable: false,
         displayName: displayName,
         description: description,
       );

  const WalletSignerState.available({
    required WalletSignerType signerType,
    required String displayName,
    required String description,
    String? address,
  }) : this(
         signerType: signerType,
         isAvailable: true,
         displayName: displayName,
         description: description,
         address: address,
       );

  final WalletSignerType signerType;
  final bool isAvailable;
  final String displayName;
  final String description;
  final String? address;
}
