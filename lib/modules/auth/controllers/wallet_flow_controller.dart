import 'package:flutter/foundation.dart';
import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_flow_state.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signature_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/auth_api.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/wallet_signer_resolver.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/wallet_signer_service.dart';

import 'auth_session_controller.dart';
import '../models/wallet_models.dart';

class WalletFlowController extends ChangeNotifier {
  WalletFlowController({
    required AuthApi authApi,
    required AuthSessionController authSessionController,
    required WalletSignerResolver walletSignerResolver,
  }) : _authApi = authApi,
       _authSessionController = authSessionController,
       _walletSignerResolver = walletSignerResolver;

  final AuthApi _authApi;
  final AuthSessionController _authSessionController;
  final WalletSignerResolver _walletSignerResolver;

  WalletFlowState _state = const WalletFlowState.initial();
  WalletFlowState get state => _state;

  void updateDraft({
    String? challengeAddress,
    String? challengeChain,
    String? verifyAddress,
    String? verifyChallengeId,
    String? signature,
  }) {
    _emit(
      _state.copyWith(
        challengeAddress: challengeAddress,
        challengeChain: challengeChain,
        verifyAddress: verifyAddress,
        verifyChallengeId: verifyChallengeId,
        signature: signature,
      ),
    );
  }

  Future<void> refreshSignerState() async {
    _emit(
      _state.copyWith(
        isRefreshingSigner: true,
        clearLastError: true,
        clearLastSuccessMessage: true,
      ),
    );

    try {
      final signerState = await _walletSignerResolver.resolvePreferredState();
      _emit(
        _state.copyWith(
          isRefreshingSigner: false,
          signerState: signerState,
          challengeAddress:
              _state.challengeAddress.isNotEmpty
                  ? _state.challengeAddress
                  : (signerState.address ?? _state.challengeAddress),
          verifyAddress:
              _state.verifyAddress.isNotEmpty
                  ? _state.verifyAddress
                  : (signerState.address ?? _state.verifyAddress),
          lastSuccessMessage: 'Wallet signer status refreshed successfully.',
        ),
      );
    } on AppError catch (error) {
      _emit(_state.copyWith(isRefreshingSigner: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isRefreshingSigner: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_wallet_signer_refresh_error',
          ),
        ),
      );
    }
  }

  Future<void> requestChallenge({
    required String address,
    required String chain,
  }) async {
    _emit(
      _state.copyWith(
        isRequestingChallenge: true,
        clearLastError: true,
        clearLastSuccessMessage: true,
      ),
    );

    try {
      final response = await _authApi.createWalletChallenge(
        WalletChallengeRequest(address: address, chain: chain),
      );
      _emit(
        _state.copyWith(
          isRequestingChallenge: false,
          challengeResponse: response,
          challengeAddress: address,
          challengeChain: chain,
          verifyAddress: response.challenge.address,
          verifyChallengeId: response.challenge.id,
          signature: '',
          lastSuccessMessage: 'Wallet challenge created successfully.',
        ),
      );
    } on AppError catch (error) {
      _emit(_state.copyWith(isRequestingChallenge: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isRequestingChallenge: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_wallet_challenge_error',
          ),
        ),
      );
    }
  }

  Future<void> signChallengeWithPreferredSigner() async {
    final challenge = _state.challengeResponse?.challenge;
    if (challenge == null) {
      _emit(
        _state.copyWith(
          lastError: AppError(
            message:
                'Request a wallet challenge before attempting automatic signing.',
            code: 'wallet_signer_missing_challenge',
          ),
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        isSigningChallenge: true,
        clearLastError: true,
        clearLastSuccessMessage: true,
      ),
    );

    try {
      final signer = await _resolvePreferredSigner();
      if (signer == null) {
        throw AppError(
          message:
              'No automatic wallet signer is available. Keep using the manual signature fallback.',
          code: 'wallet_signer_unavailable',
        );
      }

      final signature = await signer.signMessage(
        WalletSignatureRequest(
          address: challenge.address,
          message: challenge.message,
          chain: challenge.chain,
        ),
      );

      final refreshedSignerState =
          await _walletSignerResolver.resolvePreferredState();
      _emit(
        _state.copyWith(
          isSigningChallenge: false,
          signerState: refreshedSignerState,
          signature: signature,
          verifyAddress: challenge.address,
          verifyChallengeId: challenge.id,
          lastSuccessMessage:
              '${refreshedSignerState.displayName} signed the wallet challenge successfully.',
        ),
      );
    } on AppError catch (error) {
      _emit(_state.copyWith(isSigningChallenge: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isSigningChallenge: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_wallet_sign_error',
          ),
        ),
      );
    }
  }

  Future<void> signAndVerifyWithPreferredSigner() async {
    await signChallengeWithPreferredSigner();
    if (_state.lastError != null || _state.signature.trim().isEmpty) {
      return;
    }

    await verifyWallet(
      challengeId: _state.verifyChallengeId,
      address: _state.verifyAddress,
      signature: _state.signature,
    );
  }

  Future<void> verifyWallet({
    required String challengeId,
    required String address,
    required String signature,
  }) async {
    _emit(
      _state.copyWith(
        isVerifying: true,
        clearLastError: true,
        clearLastSuccessMessage: true,
      ),
    );

    try {
      final response = await _authApi.verifyWallet(
        WalletVerifyRequest(
          challengeId: challengeId,
          address: address,
          signature: signature,
        ),
      );
      await _authSessionController.authenticateWithExternalToken(
        response.accessToken,
      );
      await loadWalletInventory();
      _emit(
        _state.copyWith(
          isVerifying: false,
          lastVerifiedResponse: response,
          lastSuccessMessage:
              'Wallet verification completed and the session was refreshed.',
        ),
      );
    } on AppError catch (error) {
      _emit(_state.copyWith(isVerifying: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isVerifying: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_wallet_verify_error',
          ),
        ),
      );
    }
  }

  Future<void> loadWalletInventory() async {
    if (!_authSessionController.state.isAuthenticated) {
      _emit(
        _state.copyWith(
          clearWalletsResponse: true,
          lastError: AppError(
            message: 'Wallet inventory requires an authenticated session.',
            code: 'wallet_inventory_requires_auth',
          ),
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        isLoadingWallets: true,
        clearLastError: true,
        clearLastSuccessMessage: true,
      ),
    );

    try {
      final response = await _authApi.getWallets();
      _emit(
        _state.copyWith(
          isLoadingWallets: false,
          walletsResponse: response,
          lastSuccessMessage: 'Wallet inventory refreshed successfully.',
        ),
      );
    } on AppError catch (error) {
      _emit(_state.copyWith(isLoadingWallets: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isLoadingWallets: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_wallet_inventory_error',
          ),
        ),
      );
    }
  }

  void clearMessages() {
    _emit(_state.copyWith(clearLastError: true, clearLastSuccessMessage: true));
  }

  Future<WalletSignerService?> _resolvePreferredSigner() async {
    return _walletSignerResolver.resolvePreferredSigner();
  }

  void _emit(WalletFlowState next) {
    _state = next;
    notifyListeners();
  }
}
