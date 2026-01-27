import '../models/paciente.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PacienteService {
  final ApiService _api = ApiService();

  Future<List<Paciente>> getPacientes() async {
    final result = await _api.get(AppConstants.apiPacientes);

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data is List) {
        return data.map((json) => Paciente.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    }

    return [];
  }

  Future<Paciente?> getPaciente(int id) async {
    final dados = await getPacienteCompleto(id);
    if (dados.isNotEmpty && dados['paciente'] != null) {
      return Paciente.fromJson(Map<String, dynamic>.from(dados['paciente']));
    }
    return null;
  }

  Future<Map<String, dynamic>> getPacienteCompleto(int id) async {
    final result = await _api.get('${AppConstants.apiPacientes}/$id');

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }

    return {};
  }
}
