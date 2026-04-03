import 'session_models.dart';

class WalletChallengeRequest {
  const WalletChallengeRequest({required this.address, this.chain});

  final String address;
  final String? chain;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      if (chain != null && chain!.trim().isNotEmpty) 'chain': chain,
    };
  }
}

class WalletChallengeResponse {
  const WalletChallengeResponse({required this.challenge});

  final WalletChallenge challenge;

  factory WalletChallengeResponse.fromJson(Map<String, dynamic> json) {
    return WalletChallengeResponse(
      challenge: WalletChallenge.fromJson(json['challenge'] as Map<String, dynamic>),
    );
  }
}

class WalletChallenge {
  const WalletChallenge({
    required this.id,
    required this.address,
    required this.chain,
    required this.message,
    this.purpose,
    this.statement,
    this.domain,
    this.uri,
    this.nonce,
    this.issuedAt,
    this.expiresAt,
  });

  final String id;
  final String address;
  final String chain;
  final String message;
  final String? purpose;
  final String? statement;
  final String? domain;
  final String? uri;
  final String? nonce;
  final DateTime? issuedAt;
  final DateTime? expiresAt;

  factory WalletChallenge.fromJson(Map<String, dynamic> json) {
    return WalletChallenge(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      chain: json['chain']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      purpose: json['purpose']?.toString(),
      statement: json['statement']?.toString(),
      domain: json['domain']?.toString(),
      uri: json['uri']?.toString(),
      nonce: json['nonce']?.toString(),
      issuedAt: _parseDate(json['issued_at']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }
}

class WalletVerifyRequest {
  const WalletVerifyRequest({
    required this.challengeId,
    required this.address,
    required this.signature,
  });

  final String challengeId;
  final String address;
  final String signature;

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'address': address,
      'signature': signature,
    };
  }
}

class WalletVerifyResponse {
  const WalletVerifyResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.walletAddress,
    required this.chain,
    required this.authMethod,
    this.walletId,
    this.user,
    this.challenge,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String walletAddress;
  final String chain;
  final String authMethod;
  final String? walletId;
  final UserView? user;
  final WalletChallenge? challenge;

  factory WalletVerifyResponse.fromJson(Map<String, dynamic> json) {
    return WalletVerifyResponse(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? '',
      walletAddress: json['wallet_address']?.toString() ?? '',
      chain: json['chain']?.toString() ?? '',
      authMethod: json['auth_method']?.toString() ?? '',
      walletId: json['wallet_id']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? UserView.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      challenge: json['challenge'] is Map<String, dynamic>
          ? WalletChallenge.fromJson(json['challenge'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WalletReadModel {
  const WalletReadModel({
    required this.id,
    required this.address,
    required this.isPrimary,
    required this.status,
    required this.canSetPrimary,
    required this.canDetach,
    required this.detachBlockReasons,
    this.userId,
    this.linkedAt,
    this.detachedAt,
  });

  final String id;
  final String address;
  final bool isPrimary;
  final String status;
  final bool canSetPrimary;
  final bool canDetach;
  final List<String> detachBlockReasons;
  final String? userId;
  final DateTime? linkedAt;
  final DateTime? detachedAt;

  factory WalletReadModel.fromJson(Map<String, dynamic> json) {
    return WalletReadModel(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
      status: json['status']?.toString() ?? '',
      canSetPrimary: json['can_set_primary'] == true,
      canDetach: json['can_detach'] == true,
      detachBlockReasons: (json['detach_block_reasons'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
      userId: json['user_id']?.toString(),
      linkedAt: _parseDate(json['linked_at']),
      detachedAt: _parseDate(json['detached_at']),
    );
  }
}

class WalletsResponse {
  const WalletsResponse({
    required this.wallets,
    required this.total,
    required this.limit,
    required this.offset,
    required this.returned,
    required this.hasMore,
    this.nextOffset,
    this.previousOffset,
  });

  final List<WalletReadModel> wallets;
  final int total;
  final int limit;
  final int offset;
  final int returned;
  final bool hasMore;
  final int? nextOffset;
  final int? previousOffset;

  factory WalletsResponse.fromJson(Map<String, dynamic> json) {
    return WalletsResponse(
      wallets: (json['wallets'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(WalletReadModel.fromJson)
          .toList(growable: false),
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      returned: (json['returned'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] == true,
      nextOffset: (json['next_offset'] as num?)?.toInt(),
      previousOffset: (json['previous_offset'] as num?)?.toInt(),
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
