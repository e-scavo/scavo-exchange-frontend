import '../../../core/errors/app_error.dart';
import 'session_models.dart';
import 'whoami_models.dart';

enum AuthBootstrapStatus { idle, bootstrapping, ready }

enum WsConnectionStatus { disconnected, connecting, connected, degraded }

class AuthState {
  const AuthState({
    required this.bootstrapStatus,
    required this.wsStatus,
    required this.isAuthenticated,
    required this.isSubmittingLogin,
    this.token,
    this.session,
    this.user,
    this.whoAmI,
    this.wsPingAt,
    this.lastError,
    this.wsError,
  });

  const AuthState.initial()
    : bootstrapStatus = AuthBootstrapStatus.idle,
      wsStatus = WsConnectionStatus.disconnected,
      isAuthenticated = false,
      isSubmittingLogin = false,
      token = null,
      session = null,
      user = null,
      whoAmI = null,
      wsPingAt = null,
      lastError = null,
      wsError = null;

  final AuthBootstrapStatus bootstrapStatus;
  final WsConnectionStatus wsStatus;
  final bool isAuthenticated;
  final bool isSubmittingLogin;
  final String? token;
  final SessionView? session;
  final UserView? user;
  final WhoAmIResponse? whoAmI;
  final DateTime? wsPingAt;
  final AppError? lastError;
  final AppError? wsError;

  bool get hasToken => token != null && token!.trim().isNotEmpty;
  bool get isBootstrapping =>
      bootstrapStatus == AuthBootstrapStatus.bootstrapping;
  bool get canOpenProtectedViews => isAuthenticated;

  AuthState copyWith({
    AuthBootstrapStatus? bootstrapStatus,
    WsConnectionStatus? wsStatus,
    bool? isAuthenticated,
    bool? isSubmittingLogin,
    String? token,
    bool clearToken = false,
    SessionView? session,
    bool clearSession = false,
    UserView? user,
    bool clearUser = false,
    WhoAmIResponse? whoAmI,
    bool clearWhoAmI = false,
    DateTime? wsPingAt,
    bool clearWsPingAt = false,
    AppError? lastError,
    bool clearLastError = false,
    AppError? wsError,
    bool clearWsError = false,
  }) {
    return AuthState(
      bootstrapStatus: bootstrapStatus ?? this.bootstrapStatus,
      wsStatus: wsStatus ?? this.wsStatus,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmittingLogin: isSubmittingLogin ?? this.isSubmittingLogin,
      token: clearToken ? null : (token ?? this.token),
      session: clearSession ? null : (session ?? this.session),
      user: clearUser ? null : (user ?? this.user),
      whoAmI: clearWhoAmI ? null : (whoAmI ?? this.whoAmI),
      wsPingAt: clearWsPingAt ? null : (wsPingAt ?? this.wsPingAt),
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      wsError: clearWsError ? null : (wsError ?? this.wsError),
    );
  }
}
