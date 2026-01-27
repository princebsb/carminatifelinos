import '../models/agendamento.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AgendamentoService {
  final ApiService _api = ApiService();

  Future<List<Agendamento>> getAgendamentos() async {
    final result = await _api.get(AppConstants.apiAgendamentos);

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data is List) {
        return data.map((json) => Agendamento.fromJson(json)).toList();
      } else if (data['agendamentos'] is List) {
        return (data['agendamentos'] as List)
            .map((json) => Agendamento.fromJson(json))
            .toList();
      }
    }

    return [];
  }

  Future<List<Agendamento>> getProximosAgendamentos() async {
    final agendamentos = await getAgendamentos();
    final hoje = DateTime.now();

    return agendamentos.where((a) {
      return a.dataAgendamento.isAfter(hoje.subtract(const Duration(days: 1))) &&
          a.status != 'cancelado' &&
          a.status != 'finalizado' &&
          a.status != 'concluido';
    }).toList()
      ..sort((a, b) => a.dataAgendamento.compareTo(b.dataAgendamento));
  }

  Future<Agendamento?> getAgendamento(int id) async {
    final result = await _api.get('${AppConstants.apiAgendamentos}/$id');

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data['agendamento'] != null) {
        return Agendamento.fromJson(data['agendamento']);
      }
      return Agendamento.fromJson(data);
    }

    return null;
  }
}
