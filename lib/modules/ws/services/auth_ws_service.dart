import 'dart:async';

import '../../../core/errors/app_error.dart';
import '../../../core/network/ws_client.dart';
import '../../auth/models/session_models.dart';
import '../../auth/models/whoami_models.dart';
import '../models/ws_request_models.dart';
import '../models/ws_response_models.dart';

class AuthWsService {
  AuthWsService(this._client);

  final WsClient _client;
  final Map<String, Completer<WsResponse>> _pending =
      <String, Completer<WsResponse>>{};
  StreamSubscription<dynamic>? _eventsSubscription;

  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(AppError error)? onError;

  bool _connected = false;
  bool get isConnected => _connected;

  Future<void> connect(String token) async {
    await close();

    await _client.connect(token: token);
    _connected = true;
    onConnected?.call();

    _eventsSubscription = _client.events.listen(
      (dynamic event) {
        final response = WsResponse.fromEnvelope(event);
        if (response.action == 'system.hello') {
          return;
        }

        final completer = _pending.remove(response.id);
        if (completer != null && !completer.isCompleted) {
          completer.complete(response);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        final appError =
            error is AppError
                ? error
                : AppError(message: error.toString(), code: 'ws_stream_error');
        onError?.call(appError);
      },
      onDone: () {
        _connected = false;
        onDisconnected?.call();
      },
      cancelOnError: false,
    );
  }

  Future<DateTime?> ping() async {
    final response = await _request('system.ping');
    final raw = response.data?['ts']?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toUtc();
  }

  Future<SessionResponse> fetchSession() async {
    final response = await _request('auth.session');
    final sessionJson = response.data?['session'];
    if (sessionJson is! Map<String, dynamic>) {
      throw AppError(
        message: 'WS session payload is invalid.',
        code: 'ws_invalid_payload',
      );
    }
    return SessionResponse.fromJson({'session': sessionJson});
  }

  Future<WhoAmIResponse> fetchWhoAmI() async {
    final response = await _request('auth.whoami');
    return WhoAmIResponse.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<WsResponse> _request(
    String action, {
    Map<String, dynamic>? data,
  }) async {
    if (!_connected) {
      throw AppError(
        message: 'WebSocket is not connected.',
        code: 'ws_not_connected',
      );
    }

    final request = WsRequest.action(action, data: data);
    final completer = Completer<WsResponse>();
    _pending[request.id] = completer;

    try {
      _client.send(request.toEnvelope());
      final response = await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          _pending.remove(request.id);
          throw AppError(
            message: 'WebSocket request timeout.',
            code: 'ws_timeout',
          );
        },
      );

      if (response.error != null) {
        throw response.error!;
      }

      return response;
    } catch (error) {
      _pending.remove(request.id);
      rethrow;
    }
  }

  Future<void> close() async {
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          AppError(
            message: 'WebSocket connection closed before response.',
            code: 'ws_closed',
          ),
        );
      }
    }
    _pending.clear();
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    _connected = false;
    await _client.close();
  }

  Future<void> dispose() async {
    await close();
  }
}
