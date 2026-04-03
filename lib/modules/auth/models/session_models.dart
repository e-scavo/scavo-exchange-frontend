class UserView {
  const UserView({
    required this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserView.fromJson(Map<String, dynamic> json) {
    return UserView(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

class MeResponse {
  const MeResponse({required this.user});

  final UserView user;

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      user: UserView.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class SessionResponse {
  const SessionResponse({required this.session});

  final SessionView session;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      session: SessionView.fromJson(json['session'] as Map<String, dynamic>),
    );
  }
}

class SessionView {
  const SessionView({
    required this.authenticated,
    required this.tokenType,
    required this.userId,
    required this.authMethod,
    this.email,
    this.walletId,
    this.walletAddress,
    this.chain,
    this.subject,
    this.issuer,
    this.expiresAt,
    this.user,
  });

  final bool authenticated;
  final String tokenType;
  final String userId;
  final String authMethod;
  final String? email;
  final String? walletId;
  final String? walletAddress;
  final String? chain;
  final String? subject;
  final String? issuer;
  final DateTime? expiresAt;
  final UserView? user;

  factory SessionView.fromJson(Map<String, dynamic> json) {
    return SessionView(
      authenticated: json['authenticated'] == true,
      tokenType: json['token_type']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      authMethod: json['auth_method']?.toString() ?? '',
      email: json['email']?.toString(),
      walletId: json['wallet_id']?.toString(),
      walletAddress: json['wallet_address']?.toString(),
      chain: json['chain']?.toString(),
      subject: json['subject']?.toString(),
      issuer: json['issuer']?.toString(),
      expiresAt: _parseDate(json['expires_at']),
      user: json['user'] is Map<String, dynamic>
          ? UserView.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  final raw = value.toString().trim();
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}
