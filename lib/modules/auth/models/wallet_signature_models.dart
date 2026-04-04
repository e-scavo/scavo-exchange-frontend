enum WalletSignerType { manualFallback, metaMask, internalPrepared }

class WalletSignatureRequest {
  const WalletSignatureRequest({
    required this.address,
    required this.message,
    required this.chain,
  });

  final String address;
  final String message;
  final String chain;
}
