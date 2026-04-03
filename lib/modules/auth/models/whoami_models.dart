class WhoAmIResponse {
  const WhoAmIResponse({
    required this.authenticated,
    required this.userId,
    this.email,
    this.walletId,
    this.walletAddress,
    this.authMethod,
    this.chain,
    this.subject,
    this.issuer,
    this.expiresAt,
  });

  final bool authenticated;
  final String userId;
  final String? email;
  final String? walletId;
  final String? walletAddress;
  final String? authMethod;
  final String? chain;
  final String? subject;
  final String? issuer;
  final DateTime? expiresAt;

  factory WhoAmIResponse.fromJson(Map<String, dynamic> json) {
    return WhoAmIResponse(
      authenticated: json['authenticated'] == true,
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      walletId: json['wallet_id']?.toString(),
      walletAddress: json['wallet_address']?.toString(),
      authMethod: json['auth_method']?.toString(),
      chain: json['chain']?.toString(),
      subject: json['subject']?.toString(),
      issuer: json['issuer']?.toString(),
      expiresAt: _parseDate(json['expires_at']),
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
