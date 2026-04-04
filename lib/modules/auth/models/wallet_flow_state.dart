import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

import 'wallet_models.dart';
import 'wallet_signature_models.dart';

class WalletFlowState {
  const WalletFlowState({
    this.challengeResponse,
    this.walletsResponse,
    this.lastVerifiedResponse,
    this.challengeAddress = '',
    this.challengeChain = 'scavium',
    this.verifyAddress = '',
    this.verifyChallengeId = '',
    this.signature = '',
    this.isRequestingChallenge = false,
    this.isVerifying = false,
    this.isLoadingWallets = false,
    this.isRefreshingSigner = false,
    this.isSigningChallenge = false,
    this.signerState = const WalletSignerState.unavailable(
      signerType: WalletSignerType.manualFallback,
      displayName: 'Manual signature fallback',
      description:
          'No automatic signer has been resolved yet. Manual signature entry remains available.',
    ),
    this.lastError,
    this.lastSuccessMessage,
  });

  const WalletFlowState.initial()
    : challengeResponse = null,
      walletsResponse = null,
      lastVerifiedResponse = null,
      challengeAddress = '',
      challengeChain = 'scavium',
      verifyAddress = '',
      verifyChallengeId = '',
      signature = '',
      isRequestingChallenge = false,
      isVerifying = false,
      isLoadingWallets = false,
      isRefreshingSigner = false,
      isSigningChallenge = false,
      signerState = const WalletSignerState.unavailable(
        signerType: WalletSignerType.manualFallback,
        displayName: 'Manual signature fallback',
        description:
            'No automatic signer has been resolved yet. Manual signature entry remains available.',
      ),
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
  final bool isRefreshingSigner;
  final bool isSigningChallenge;
  final WalletSignerState signerState;
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
    bool? isRefreshingSigner,
    bool? isSigningChallenge,
    WalletSignerState? signerState,
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
      isRefreshingSigner: isRefreshingSigner ?? this.isRefreshingSigner,
      isSigningChallenge: isSigningChallenge ?? this.isSigningChallenge,
      signerState: signerState ?? this.signerState,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastSuccessMessage:
          clearLastSuccessMessage
              ? null
              : (lastSuccessMessage ?? this.lastSuccessMessage),
    );
  }
}
