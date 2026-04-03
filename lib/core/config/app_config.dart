class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.apiBaseUrl,
    required this.wsUrl,
  });

  final String appName;
  final String environment;
  final String apiBaseUrl;
  final String wsUrl;

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment(
      'SCAVO_API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

    const wsUrl = String.fromEnvironment(
      'SCAVO_WS_URL',
      defaultValue: 'ws://localhost:8080/ws',
    );

    const environment = String.fromEnvironment(
      'SCAVO_APP_ENV',
      defaultValue: 'local',
    );

    const appName = String.fromEnvironment(
      'SCAVO_APP_NAME',
      defaultValue: 'SCAVO Exchange',
    );

    return const AppConfig(
      appName: appName,
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      wsUrl: wsUrl,
    );
  }
}
