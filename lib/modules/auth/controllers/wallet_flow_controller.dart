import 'package:flutter/foundation.dart';
import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_flow_state.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/auth_api.dart';

import 'auth_session_controller.dart';

class WalletFlowController extends ChangeNotifier {
  WalletFlowController({
    required AuthApi authApi,
    required AuthSessionController authSessionController,
  }) : _authApi = authApi,
       _authSessionController = authSessionController;

  final AuthApi _authApi;
  final AuthSessionController _authSessionController;

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

  void _emit(WalletFlowState next) {
    _state = next;
    notifyListeners();
  }
}
