import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../modules/auth/services/auth_api.dart';
import '../modules/system/services/system_api.dart';
import 'router.dart';
import 'theme.dart';

class AppServices {
  AppServices({
    required this.config,
    required this.sessionStorage,
    required this.apiClient,
    required this.systemApi,
    required this.authApi,
  });

  final AppConfig config;
  final SessionStorage sessionStorage;
  final ApiClient apiClient;
  final SystemApi systemApi;
  final AuthApi authApi;
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

    _services = AppServices(
      config: config,
      sessionStorage: sessionStorage,
      apiClient: apiClient,
      systemApi: SystemApi(apiClient),
      authApi: AuthApi(apiClient),
    );
  }

  @override
  void dispose() {
    _services.apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: _services,
      child: MaterialApp(
        title: _services.config.appName,
        debugShowCheckedModeBanner: false,
        theme: buildScavoExchangeTheme(),
        initialRoute: AppRouter.bootstrap,
        onGenerateRoute: AppRouter.onGenerateRoute,
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
    final element = context.getElementForInheritedWidgetOfExactType<AppServicesScope>();
    final scope = element?.widget as AppServicesScope?;
    assert(scope != null, 'AppServicesScope is not available in this context.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return identical(services, oldWidget.services) == false;
  }
}
