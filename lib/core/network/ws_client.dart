import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../modules/ws/models/ws_envelope.dart';

class WsClient {
  WsClient(this.baseUrl);

  final String baseUrl;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  final StreamController<WsEnvelope> _eventsController =
      StreamController<WsEnvelope>.broadcast();

  Stream<WsEnvelope> get events => _eventsController.stream;

  Future<void> connect({String? token}) async {
    await close();

    final uri = _buildUri(token: token);
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    _subscription = channel.stream.listen(
      (dynamic event) {
        if (event is! String) {
          _eventsController.addError(
            FormatException(
              'Unsupported WS event payload type: ${event.runtimeType}',
            ),
          );
          return;
        }

        final decoded = jsonDecode(event);
        if (decoded is! Map<String, dynamic>) {
          _eventsController.addError(
            const FormatException('Unexpected WS payload shape.'),
          );
          return;
        }

        _eventsController.add(WsEnvelope.fromJson(decoded));
      },
      onError: _eventsController.addError,
      onDone: () {
        _channel = null;
      },
      cancelOnError: false,
    );
  }

  void send(WsEnvelope envelope) {
    final channel = _channel;
    if (channel == null) {
      throw StateError('WebSocket connection is not open.');
    }
    channel.sink.add(jsonEncode(envelope.toJson()));
  }

  Uri _buildUri({String? token}) {
    final uri = Uri.parse(baseUrl);
    if (token == null || token.trim().isEmpty) {
      return uri;
    }

    final query = Map<String, String>.from(uri.queryParameters);
    query['token'] = token.trim();
    return uri.replace(queryParameters: query);
  }

  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await close();
    await _eventsController.close();
  }
}
