import 'package:scavo_exchange_frontend/core/errors/app_error.dart';

import 'wallet_models.dart';

class WalletFlowState {
  const WalletFlowState({
    this.challengeResponse,
    this.walletsResponse,
    this.lastVerifiedResponse,
    this.challengeAddress = '',
    this.challengeChain = 'ethereum',
    this.verifyAddress = '',
    this.verifyChallengeId = '',
    this.signature = '',
    this.isRequestingChallenge = false,
    this.isVerifying = false,
    this.isLoadingWallets = false,
    this.lastError,
    this.lastSuccessMessage,
  });

  const WalletFlowState.initial()
    : challengeResponse = null,
      walletsResponse = null,
      lastVerifiedResponse = null,
      challengeAddress = '',
      challengeChain = 'ethereum',
      verifyAddress = '',
      verifyChallengeId = '',
      signature = '',
      isRequestingChallenge = false,
      isVerifying = false,
      isLoadingWallets = false,
      lastError = null,
      lastSuccessMessage = null;

  final WalletChallengeResponse? challengeResponse;
  final WalletsResponse? walletsResponse;
  final WalletVerifyResponse? lastVerifiedResponse;
  final String challengeAddress;
  final String challengeChain;
  final String verifyAddress;
  final String verifyChallengeId;
  final String signature;
  final bool isRequestingChallenge;
  final bool isVerifying;
  final bool isLoadingWallets;
  final AppError? lastError;
  final String? lastSuccessMessage;

  WalletFlowState copyWith({
    WalletChallengeResponse? challengeResponse,
    bool clearChallengeResponse = false,
    WalletsResponse? walletsResponse,
    bool clearWalletsResponse = false,
    WalletVerifyResponse? lastVerifiedResponse,
    bool clearLastVerifiedResponse = false,
    String? challengeAddress,
    String? challengeChain,
    String? verifyAddress,
    String? verifyChallengeId,
    String? signature,
    bool? isRequestingChallenge,
    bool? isVerifying,
    bool? isLoadingWallets,
    AppError? lastError,
    bool clearLastError = false,
    String? lastSuccessMessage,
    bool clearLastSuccessMessage = false,
  }) {
    return WalletFlowState(
      challengeResponse:
          clearChallengeResponse
              ? null
              : (challengeResponse ?? this.challengeResponse),
      walletsResponse:
          clearWalletsResponse
              ? null
              : (walletsResponse ?? this.walletsResponse),
      lastVerifiedResponse:
          clearLastVerifiedResponse
              ? null
              : (lastVerifiedResponse ?? this.lastVerifiedResponse),
      challengeAddress: challengeAddress ?? this.challengeAddress,
      challengeChain: challengeChain ?? this.challengeChain,
      verifyAddress: verifyAddress ?? this.verifyAddress,
      verifyChallengeId: verifyChallengeId ?? this.verifyChallengeId,
      signature: signature ?? this.signature,
      isRequestingChallenge:
          isRequestingChallenge ?? this.isRequestingChallenge,
      isVerifying: isVerifying ?? this.isVerifying,
      isLoadingWallets: isLoadingWallets ?? this.isLoadingWallets,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastSuccessMessage:
          clearLastSuccessMessage
              ? null
              : (lastSuccessMessage ?? this.lastSuccessMessage),
    );
  }
}
