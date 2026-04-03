import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:scavo_exchange_frontend/core/errors/app_error.dart';
import 'package:scavo_exchange_frontend/core/storage/session_storage.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/auth_state.dart';
import 'package:scavo_exchange_frontend/modules/auth/models/login_models.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/auth_api.dart';
import 'package:scavo_exchange_frontend/modules/ws/services/auth_ws_service.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    required SessionStorage sessionStorage,
    required AuthApi authApi,
    required AuthWsService authWsService,
  }) : _sessionStorage = sessionStorage,
       _authApi = authApi,
       _authWsService = authWsService {
    _authWsService.onConnected = _handleWsConnected;
    _authWsService.onDisconnected = _handleWsDisconnected;
    _authWsService.onError = _handleWsError;
  }

  final SessionStorage _sessionStorage;
  final AuthApi _authApi;
  final AuthWsService _authWsService;

  AuthState _state = const AuthState.initial();
  AuthState get state => _state;

  bool _bootstrapStarted = false;

  Future<void> bootstrap() async {
    if (_bootstrapStarted &&
        _state.bootstrapStatus != AuthBootstrapStatus.idle) {
      return;
    }
    _bootstrapStarted = true;

    final token = await _sessionStorage.readToken();
    _emit(
      _state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.bootstrapping,
        token: token,
        clearLastError: true,
        clearWsError: true,
      ),
    );

    if (token == null || token.trim().isEmpty) {
      await _setAnonymousReady();
      return;
    }

    await _restoreAuthenticatedState(token);
  }

  Future<void> login({required String email, required String password}) async {
    _emit(_state.copyWith(isSubmittingLogin: true, clearLastError: true));

    try {
      final response = await _authApi.login(
        LoginRequest(email: email, password: password),
      );
      await _sessionStorage.writeToken(response.accessToken);

      _emit(
        _state.copyWith(token: response.accessToken, isSubmittingLogin: false),
      );

      await _restoreAuthenticatedState(response.accessToken);
    } on AppError catch (error) {
      _emit(_state.copyWith(isSubmittingLogin: false, lastError: error));
    } catch (error) {
      _emit(
        _state.copyWith(
          isSubmittingLogin: false,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_login_error',
          ),
        ),
      );
    }
  }

  Future<void> authenticateWithExternalToken(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      _emit(
        _state.copyWith(
          lastError: AppError(
            message: 'External authentication returned an empty access token.',
            code: 'empty_external_token',
          ),
        ),
      );
      return;
    }

    await _sessionStorage.writeToken(normalized);
    _emit(
      _state.copyWith(
        token: normalized,
        isSubmittingLogin: false,
        clearLastError: true,
      ),
    );
    await _restoreAuthenticatedState(normalized);
  }

  Future<void> refreshAuthenticatedState() async {
    final token = _state.token ?? await _sessionStorage.readToken();
    if (token == null || token.trim().isEmpty) {
      await _setAnonymousReady();
      return;
    }

    await _restoreAuthenticatedState(token);
  }

  Future<void> logout() async {
    await _authWsService.close();
    await _sessionStorage.clearToken();
    _emit(
      const AuthState.initial().copyWith(
        bootstrapStatus: AuthBootstrapStatus.ready,
      ),
    );
  }

  void clearVisibleErrors() {
    _emit(_state.copyWith(clearLastError: true, clearWsError: true));
  }

  Future<void> _restoreAuthenticatedState(String token) async {
    _emit(
      _state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.bootstrapping,
        token: token,
        wsStatus: WsConnectionStatus.connecting,
        clearLastError: true,
        clearWsError: true,
      ),
    );

    try {
      final session = await _authApi.getSession();
      final me = await _authApi.getMe();

      _emit(
        _state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.bootstrapping,
          token: token,
          isAuthenticated: session.session.authenticated,
          session: session.session,
          user: me.user,
          clearLastError: true,
        ),
      );

      await _connectWs(token);

      _emit(
        _state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.ready,
          isAuthenticated: true,
        ),
      );
    } on AppError catch (error) {
      final shouldInvalidate =
          error.statusCode == 401 ||
          error.code == 'unauthorized' ||
          error.code == 'missing_token';
      if (shouldInvalidate) {
        await _authWsService.close();
        await _sessionStorage.clearToken();
        _emit(
          AuthState.initial().copyWith(
            bootstrapStatus: AuthBootstrapStatus.ready,
            lastError: error,
          ),
        );
        return;
      }

      _emit(
        _state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.ready,
          isAuthenticated: _state.session?.authenticated == true,
          lastError: error,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.ready,
          lastError: AppError(
            message: error.toString(),
            code: 'unexpected_bootstrap_error',
          ),
        ),
      );
    }
  }

  Future<void> _connectWs(String token) async {
    try {
      _emit(_state.copyWith(wsStatus: WsConnectionStatus.connecting));
      await _authWsService.connect(token);
      final wsPingAt = await _authWsService.ping();
      final wsSession = await _authWsService.fetchSession();
      final whoAmI = await _authWsService.fetchWhoAmI();

      _emit(
        _state.copyWith(
          wsStatus: WsConnectionStatus.connected,
          session: wsSession.session,
          whoAmI: whoAmI,
          wsPingAt: wsPingAt,
          clearWsError: true,
        ),
      );
    } on AppError catch (error) {
      _emit(
        _state.copyWith(wsStatus: WsConnectionStatus.degraded, wsError: error),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          wsStatus: WsConnectionStatus.degraded,
          wsError: AppError(
            message: error.toString(),
            code: 'unexpected_ws_error',
          ),
        ),
      );
    }
  }

  Future<void> _setAnonymousReady() async {
    await _authWsService.close();
    _emit(
      const AuthState.initial().copyWith(
        bootstrapStatus: AuthBootstrapStatus.ready,
      ),
    );
  }

  void _handleWsConnected() {
    _emit(
      _state.copyWith(
        wsStatus: WsConnectionStatus.connected,
        clearWsError: true,
      ),
    );
  }

  void _handleWsDisconnected() {
    _emit(
      _state.copyWith(
        wsStatus:
            _state.isAuthenticated
                ? WsConnectionStatus.degraded
                : WsConnectionStatus.disconnected,
      ),
    );
  }

  void _handleWsError(AppError error) {
    _emit(
      _state.copyWith(wsStatus: WsConnectionStatus.degraded, wsError: error),
    );
  }

  void _emit(AuthState next) {
    _state = next;
    notifyListeners();
  }
}
