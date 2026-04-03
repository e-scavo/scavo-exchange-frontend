class VersionResponse {
  const VersionResponse({
    required this.version,
    required this.commit,
    required this.environment,
  });

  final String version;
  final String commit;
  final String environment;

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(
      version: json['version']?.toString() ?? '',
      commit: json['commit']?.toString() ?? '',
      environment: json['env']?.toString() ?? '',
    );
  }
}
