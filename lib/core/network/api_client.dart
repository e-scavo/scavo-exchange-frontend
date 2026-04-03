import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_error.dart';

class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final Map<String, dynamic> body;
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenProvider,
    http.Client? client,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  final String baseUrl;
  final Future<String?> Function() tokenProvider;
  final http.Client _client;
  final Duration _timeout;

  Future<ApiResponse> get(String path, {bool authenticated = false}) {
    return _send(
      method: 'GET',
      path: path,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) {
    return _send(
      method: 'POST',
      path: path,
      authenticated: authenticated,
      body: body,
    );
  }

  Future<ApiResponse> _send({
    required String method,
    required String path,
    required bool authenticated,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(_normalizeUrl(path));
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await tokenProvider();
      if (token == null || token.trim().isEmpty) {
        throw AppError(message: 'Missing bearer token.', code: 'missing_token');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? <String, dynamic>{}))
              .timeout(_timeout);
          break;
        default:
          throw AppError(message: 'Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw AppError(message: 'Request timeout.', code: 'timeout');
    } on http.ClientException catch (error) {
      throw AppError(message: error.message, code: 'client_exception');
    }

    final decoded = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppError(
        message: _extractErrorMessage(decoded) ?? 'Request failed.',
        code: decoded['error']?.toString(),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(statusCode: response.statusCode, body: decoded);
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  String? _extractErrorMessage(Map<String, dynamic> decoded) {
    final error = decoded['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    return null;
  }

  String _normalizeUrl(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }

  void close() {
    _client.close();
  }
}
