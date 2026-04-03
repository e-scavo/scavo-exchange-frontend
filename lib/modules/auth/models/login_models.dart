import 'session_models.dart';

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.authMethod,
    this.user,
    this.walletId,
    this.walletAddress,
    this.chain,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String authMethod;
  final UserView? user;
  final String? walletId;
  final String? walletAddress;
  final String? chain;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      authMethod: json['auth_method']?.toString() ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserView.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      walletId: json['wallet_id']?.toString(),
      walletAddress: json['wallet_address']?.toString(),
      chain: json['chain']?.toString(),
    );
  }
}
