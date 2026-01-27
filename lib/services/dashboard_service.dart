import '../utils/constants.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardData() async {
    final result = await _api.get(AppConstants.apiDashboard);

    if (result['success'] == true && result['data'] != null) {
      return result['data'];
    }

    return {};
  }
}
