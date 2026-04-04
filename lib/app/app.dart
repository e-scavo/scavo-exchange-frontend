import 'package:flutter/material.dart';
import 'package:scavo_exchange_frontend/core/config/app_config.dart';
import 'package:scavo_exchange_frontend/core/network/api_client.dart';
import 'package:scavo_exchange_frontend/core/network/ws_client.dart';
import 'package:scavo_exchange_frontend/core/storage/session_storage.dart';
import 'package:scavo_exchange_frontend/modules/auth/controllers/auth_session_controller.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/auth_api.dart';
import 'package:scavo_exchange_frontend/modules/auth/services/wallet_signer_resolver.dart';
import 'package:scavo_exchange_frontend/modules/system/services/system_api.dart';
import 'package:scavo_exchange_frontend/modules/ws/services/auth_ws_service.dart';

import 'router.dart';
import 'theme.dart';

class AppServices {
  AppServices({
    required this.config,
    required this.sessionStorage,
    required this.apiClient,
    required this.wsClient,
    required this.systemApi,
    required this.authApi,
    required this.authWsService,
    required this.walletSignerResolver,
    required this.authSessionController,
  });

  final AppConfig config;
  final SessionStorage sessionStorage;
  final ApiClient apiClient;
  final WsClient wsClient;
  final SystemApi systemApi;
  final AuthApi authApi;
  final AuthWsService authWsService;
  final WalletSignerResolver walletSignerResolver;
  final AuthSessionController authSessionController;
}

class ScavoExchangeApp extends StatefulWidget {
  const ScavoExchangeApp({super.key});

  @override
  State<ScavoExchangeApp> createState() => _ScavoExchangeAppState();
}

class _ScavoExchangeAppState extends State<ScavoExchangeApp> {
  late final AppServices _services;

  @override
  void initState() {
    super.initState();
    final config = AppConfig.fromEnvironment();
    final sessionStorage = SessionStorage();
    final apiClient = ApiClient(
      baseUrl: config.apiBaseUrl,
      tokenProvider: sessionStorage.readToken,
    );
    final wsClient = WsClient(config.wsUrl);
    final authApi = AuthApi(apiClient);
    final authWsService = AuthWsService(wsClient);
    final walletSignerResolver = WalletSignerResolver();
    final authSessionController = AuthSessionController(
      sessionStorage: sessionStorage,
      authApi: authApi,
      authWsService: authWsService,
    );

    _services = AppServices(
      config: config,
      sessionStorage: sessionStorage,
      apiClient: apiClient,
      wsClient: wsClient,
      systemApi: SystemApi(apiClient),
      authApi: authApi,
      authWsService: authWsService,
      walletSignerResolver: walletSignerResolver,
      authSessionController: authSessionController,
    );

    _services.authSessionController.bootstrap();
  }

  @override
  void dispose() {
    _services.authSessionController.dispose();
    _services.apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: _services,
      child: AuthSessionScope(
        notifier: _services.authSessionController,
        child: MaterialApp(
          title: _services.config.appName,
          debugShowCheckedModeBanner: false,
          theme: buildScavoExchangeTheme(),
          initialRoute: AppRouter.bootstrap,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    required this.services,
    required super.child,
    super.key,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<AppServicesScope>();
    final scope = element?.widget as AppServicesScope?;
    assert(scope != null, 'AppServicesScope is not available in this context.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return identical(services, oldWidget.services) == false;
  }
}

class AuthSessionScope extends InheritedNotifier<AuthSessionController> {
  const AuthSessionScope({
    required AuthSessionController notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static AuthSessionController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AuthSessionScope>();
    assert(scope?.notifier != null, 'AuthSessionScope is not available.');
    return scope!.notifier!;
  }
}
