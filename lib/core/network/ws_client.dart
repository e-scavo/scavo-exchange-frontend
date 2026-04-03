import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../modules/ws/models/ws_envelope.dart';

class WsClient {
  WsClient(this.url);

  final String url;
  WebSocketChannel? _channel;

  Stream<WsEnvelope> connect() {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    _channel = channel;

    return channel.stream.map((dynamic event) {
      if (event is String) {
        return WsEnvelope.fromJson(jsonDecode(event) as Map<String, dynamic>);
      }
      throw FormatException('Unsupported WS event payload type: ${event.runtimeType}');
    });
  }

  void send(WsEnvelope envelope) {
    final channel = _channel;
    if (channel == null) {
      throw StateError('WebSocket connection is not open.');
    }
    channel.sink.add(jsonEncode(envelope.toJson()));
  }

  Future<void> close() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
