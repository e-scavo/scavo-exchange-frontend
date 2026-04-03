import 'dart:math';

import 'ws_envelope.dart';

class WsRequest {
  const WsRequest({required this.id, required this.action, this.data});

  final String id;
  final String action;
  final Map<String, dynamic>? data;

  WsEnvelope toEnvelope() {
    return WsEnvelope(id: id, type: 'req', action: action, data: data);
  }

  factory WsRequest.action(String action, {Map<String, dynamic>? data}) {
    return WsRequest(id: _generateRequestId(), action: action, data: data);
  }
}

String _generateRequestId() {
  final random = Random();
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final salt = random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
  return '$micros$salt';
}
