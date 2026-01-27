import '../models/relatorio.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class RelatorioService {
  final ApiService _api = ApiService();

  Future<List<Relatorio>> getRelatorios() async {
    final result = await _api.get(AppConstants.apiRelatorios);

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data is List) {
        return data.map((json) => Relatorio.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    }

    return [];
  }

  String getDownloadUrl(int id) {
    return '${AppConstants.baseUrl}${AppConstants.apiRelatorios}/download/$id';
  }
}
