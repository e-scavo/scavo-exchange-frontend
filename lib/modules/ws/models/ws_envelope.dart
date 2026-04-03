class WsEnvelope {
  const WsEnvelope({
    required this.id,
    required this.type,
    required this.action,
    this.data,
    this.error,
  });

  final String id;
  final String type;
  final String action;
  final Map<String, dynamic>? data;
  final WsErrorPayload? error;

  factory WsEnvelope.fromJson(Map<String, dynamic> json) {
    return WsEnvelope(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      data:
          json['data'] is Map<String, dynamic>
              ? json['data'] as Map<String, dynamic>
              : null,
      error:
          json['error'] is Map<String, dynamic>
              ? WsErrorPayload.fromJson(json['error'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'action': action,
      if (data != null) 'data': data,
      if (error != null) 'error': error!.toJson(),
    };
  }
}

class WsErrorPayload {
  const WsErrorPayload({required this.code, required this.message});

  final String code;
  final String message;

  factory WsErrorPayload.fromJson(Map<String, dynamic> json) {
    return WsErrorPayload(
      code: json['code']?.toString() ?? '',
      message: json['msg']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'msg': message};
  }
}
