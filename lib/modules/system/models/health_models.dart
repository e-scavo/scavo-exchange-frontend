class HealthResponse {
  const HealthResponse({required this.ok});

  final bool ok;

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(ok: json['ok'] == true);
  }
}
