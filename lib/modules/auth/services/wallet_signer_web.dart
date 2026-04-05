import 'dart:js_interop';

import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signature_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_signer_state.dart';

import 'wallet_signer_service.dart';

@JS('window.ethereum')
external JSAny? get _ethereum;

@JS()
@anonymous
extension type _EthereumRequestArgs._(JSObject _) implements JSObject {
  external factory _EthereumRequestArgs({
    JSString method,
    JSArray<JSAny?>? params,
  });
}

extension type _EthereumProvider._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> request(_EthereumRequestArgs args);
}

class WalletSignerWebService implements WalletSignerService {
  const WalletSignerWebService();

  _EthereumProvider? get _provider {
    final ethereum = _ethereum;
    if (ethereum == null || ethereum is! JSObject) {
      return null;
    }

    return ethereum as _EthereumProvider;
  }

  @override
  WalletSignerType get signerType => WalletSignerType.metaMask;

  @override
  Future<WalletSignerState> getState() async {
    final provider = _provider;
    if (provider == null) {
      return const WalletSignerState.unavailable(
        signerType: WalletSignerType.metaMask,
        displayName: 'MetaMask web signer',
        description:
            'No injected web wallet provider was detected in this browser. Manual signature fallback remains available.',
      );
    }

    final address = await getSelectedAddress();

    return WalletSignerState.available(
      signerType: WalletSignerType.metaMask,
      displayName: 'MetaMask web signer',
      description:
          'An injected web wallet provider is available in this browser and can sign wallet authentication challenges.',
      address: address,
    );
  }

  @override
  Future<String?> getSelectedAddress() async {
    final provider = _provider;
    if (provider == null) {
      return null;
    }

    try {
      final result =
          await provider
              .request(_EthereumRequestArgs(method: 'eth_requestAccounts'.toJS))
              .toDart;

      if (result == null || result is! JSArray<JSAny?>) {
        return null;
      }

      final accounts = result.toDart;
      if (accounts.isEmpty) {
        return null;
      }

      final first = accounts.first;
      if (first == null) {
        return null;
      }

      if (first is JSString) {
        return first.toDart;
      }

      return first.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> signMessage(WalletSignatureRequest request) async {
    final provider = _provider;
    if (provider == null) {
      throw AppError(
        message:
            'No injected web wallet provider is available in this browser. Use the manual signature fallback.',
        code: 'wallet_signer_unavailable',
      );
    }

    final address = request.address.trim();
    final message = request.message;

    if (address.isEmpty) {
      throw AppError(
        message: 'The wallet address is required before signing the challenge.',
        code: 'wallet_signer_missing_address',
      );
    }

    if (message.trim().isEmpty) {
      throw AppError(
        message: 'The wallet challenge message is empty.',
        code: 'wallet_signer_missing_message',
      );
    }

    try {
      final result =
          await provider
              .request(
                _EthereumRequestArgs(
                  method: 'personal_sign'.toJS,
                  params: <JSAny?>[message.toJS, address.toJS].toJS,
                ),
              )
              .toDart;

      if (result == null) {
        throw AppError(
          message: 'The web wallet signer did not return a signature.',
          code: 'wallet_signer_empty_signature',
        );
      }

      if (result is JSString) {
        final signature = result.toDart;
        if (signature.trim().isEmpty) {
          throw AppError(
            message: 'The web wallet signer returned an empty signature.',
            code: 'wallet_signer_empty_signature',
          );
        }
        return signature;
      }

      final signature = result.toString();
      if (signature.trim().isEmpty) {
        throw AppError(
          message: 'The web wallet signer returned an empty signature.',
          code: 'wallet_signer_empty_signature',
        );
      }

      return signature;
    } catch (error) {
      if (error is AppError) {
        rethrow;
      }

      throw AppError(
        message: 'Web wallet signing failed: $error',
        code: 'wallet_signer_request_failed',
      );
    }
  }
}

WalletSignerService createExternalWalletSigner() =>
    const WalletSignerWebService();
