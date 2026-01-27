class Prontuario {
  final int id;
  final int pacienteId;
  final int? agendamentoId;
  final int? veterinarioId;
  final String tipo;
  final DateTime dataAtendimento;
  final String? queixaPrincipal;
  final String? historicoDoenca;
  final String? exameClinico;
  final double? temperatura;
  final int? frequenciaCardiaca;
  final int? frequenciaRespiratoria;
  final double? peso;
  final String? mucosas;
  final String? hidratacao;
  final String? linfondos;
  final String? tpc;
  final String? diagnostico;
  final String? tratamento;
  final String? prescricao;
  final String? observacoes;
  final String? retorno;
  final String? pacienteNome;
  final String? veterinarioNome;
  final DateTime? criadoEm;

  Prontuario({
    required this.id,
    required this.pacienteId,
    this.agendamentoId,
    this.veterinarioId,
    required this.tipo,
    required this.dataAtendimento,
    this.queixaPrincipal,
    this.historicoDoenca,
    this.exameClinico,
    this.temperatura,
    this.frequenciaCardiaca,
    this.frequenciaRespiratoria,
    this.peso,
    this.mucosas,
    this.hidratacao,
    this.linfondos,
    this.tpc,
    this.diagnostico,
    this.tratamento,
    this.prescricao,
    this.observacoes,
    this.retorno,
    this.pacienteNome,
    this.veterinarioNome,
    this.criadoEm,
  });

  factory Prontuario.fromJson(Map<String, dynamic> json) {
    return Prontuario(
      id: int.parse(json['id'].toString()),
      pacienteId: int.parse(json['paciente_id'].toString()),
      agendamentoId: json['agendamento_id'] != null
          ? int.tryParse(json['agendamento_id'].toString())
          : null,
      veterinarioId: json['veterinario_id'] != null
          ? int.tryParse(json['veterinario_id'].toString())
          : null,
      tipo: json['tipo'] ?? 'consulta',
      dataAtendimento: DateTime.parse(json['data_atendimento']),
      queixaPrincipal: json['queixa_principal'],
      historicoDoenca: json['historico_doenca'],
      exameClinico: json['exame_clinico'],
      temperatura: json['temperatura'] != null
          ? double.tryParse(json['temperatura'].toString())
          : null,
      frequenciaCardiaca: json['frequencia_cardiaca'] != null
          ? int.tryParse(json['frequencia_cardiaca'].toString())
          : null,
      frequenciaRespiratoria: json['frequencia_respiratoria'] != null
          ? int.tryParse(json['frequencia_respiratoria'].toString())
          : null,
      peso: json['peso'] != null
          ? double.tryParse(json['peso'].toString())
          : null,
      mucosas: json['mucosas'],
      hidratacao: json['hidratacao'],
      linfondos: json['linfondos'],
      tpc: json['tpc'],
      diagnostico: json['diagnostico'],
      tratamento: json['tratamento'],
      prescricao: json['prescricao'],
      observacoes: json['observacoes'],
      retorno: json['retorno'],
      pacienteNome: json['paciente_nome'],
      veterinarioNome: json['veterinario_nome'],
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  String get tipoFormatado {
    switch (tipo) {
      case 'consulta':
        return 'Consulta';
      case 'retorno':
        return 'Retorno';
      case 'emergencia':
        return 'Emergência';
      case 'internacao':
        return 'Internação';
      default:
        return tipo;
    }
  }
}
