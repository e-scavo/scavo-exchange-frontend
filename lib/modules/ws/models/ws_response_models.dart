import 'package:scavo_exchange_frontend/core/errors/app_error.dart';

import 'ws_envelope.dart';

class WsResponse {
  const WsResponse({
    required this.id,
    required this.action,
    this.data,
    this.error,
  });

  final String id;
  final String action;
  final Map<String, dynamic>? data;
  final AppError? error;

  factory WsResponse.fromEnvelope(WsEnvelope envelope) {
    return WsResponse(
      id: envelope.id,
      action: envelope.action,
      data: envelope.data,
      error:
          envelope.error == null
              ? null
              : AppError(
                message: envelope.error!.message,
                code: envelope.error!.code,
              ),
    );
  }
}
