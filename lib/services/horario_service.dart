import 'api_service.dart';
import '../utils/constants.dart';
import '../models/profissional.dart';
import '../models/horario_slot.dart';

class HorarioService {
  final ApiService _api = ApiService();

  Future<List<Profissional>> getProfissionais() async {
    final response = await _api.get(AppConstants.apiHorariosProfissionais);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Profissional.fromJson(json)).toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> getHorarios({
    int? veterinarioId,
    String? data,
  }) async {
    String endpoint = AppConstants.apiHorarios;
    final params = <String>[];

    if (veterinarioId != null) {
      params.add('veterinario_id=$veterinarioId');
    }
    if (data != null) {
      params.add('data=$data');
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    final response = await _api.get(endpoint);

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];

      // Parsear profissionais
      List<Profissional> profissionais = [];
      if (data['profissionais'] != null) {
        profissionais = (data['profissionais'] as List)
            .map((json) => Profissional.fromJson(json))
            .toList();
      }

      // Parsear pacientes
      List<PacienteSimples> pacientes = [];
      if (data['pacientes'] != null) {
        pacientes = (data['pacientes'] as List)
            .map((json) => PacienteSimples.fromJson(json))
            .toList();
      }

      // Parsear horarios
      List<HorarioSlot> horarios = [];
      if (data['horarios'] != null) {
        horarios = (data['horarios'] as List)
            .map((json) => HorarioSlot.fromJson(json))
            .toList();
      }

      return {
        'profissionais': profissionais,
        'pacientes': pacientes,
        'veterinario_id': data['veterinario_id'],
        'data_selecionada': data['data_selecionada'],
        'horarios': horarios,
        'whatsapp': data['whatsapp'] ?? '',
      };
    }

    return {
      'profissionais': <Profissional>[],
      'pacientes': <PacienteSimples>[],
      'horarios': <HorarioSlot>[],
      'whatsapp': '',
    };
  }
}
