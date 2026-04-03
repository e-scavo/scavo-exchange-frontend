import 'package:scavo_exchange_frontend/core/network/api_client.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/login_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/session_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/wallet_models.dart';

class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: request.toJson(),
    );
    return LoginResponse.fromJson(response.body);
  }

  Future<MeResponse> getMe() async {
    final response = await _apiClient.get('/auth/me', authenticated: true);
    return MeResponse.fromJson(response.body);
  }

  Future<SessionResponse> getSession() async {
    final response = await _apiClient.get('/auth/session', authenticated: true);
    return SessionResponse.fromJson(response.body);
  }

  Future<WalletChallengeResponse> createWalletChallenge(
    WalletChallengeRequest request,
  ) async {
    final response = await _apiClient.post(
      '/auth/wallet/challenge',
      body: request.toJson(),
    );
    return WalletChallengeResponse.fromJson(response.body);
  }

  Future<WalletVerifyResponse> verifyWallet(WalletVerifyRequest request) async {
    final response = await _apiClient.post(
      '/auth/wallet/verify',
      body: request.toJson(),
    );
    return WalletVerifyResponse.fromJson(response.body);
  }

  Future<WalletsResponse> getWallets() async {
    final response = await _apiClient.get('/auth/wallets', authenticated: true);
    return WalletsResponse.fromJson(response.body);
  }
}
