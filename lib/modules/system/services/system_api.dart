import '../../../core/network/api_client.dart';
import '../models/health_models.dart';
import '../models/version_models.dart';

class SystemApi {
  SystemApi(this._apiClient);

  final ApiClient _apiClient;

  Future<HealthResponse> getHealth() async {
    final response = await _apiClient.get('/health');
    return HealthResponse.fromJson(response.body);
  }

  Future<VersionResponse> getVersion() async {
    final response = await _apiClient.get('/version');
    return VersionResponse.fromJson(response.body);
  }
}
