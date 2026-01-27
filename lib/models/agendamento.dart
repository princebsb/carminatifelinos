class Agendamento {
  final int id;
  final int pacienteId;
  final int clienteId;
  final int? veterinarioId;
  final int? servicoId;
  final String tipo;
  final DateTime dataAgendamento;
  final String horaInicio;
  final String? horaFim;
  final String status;
  final String? motivo;
  final String? observacoes;
  final double? valorPrevisto;
  final DateTime? confirmadoEm;
  final String? confirmadoPor;
  final DateTime? canceladoEm;
  final String? motivoCancelamento;
  final bool lembreteEnviado;
  final String? pacienteNome;
  final String? clienteNome;
  final String? clienteCelular;
  final String? veterinarioNome;
  final String? servicoNome;
  final DateTime? criadoEm;

  Agendamento({
    required this.id,
    required this.pacienteId,
    required this.clienteId,
    this.veterinarioId,
    this.servicoId,
    required this.tipo,
    required this.dataAgendamento,
    required this.horaInicio,
    this.horaFim,
    this.status = 'agendado',
    this.motivo,
    this.observacoes,
    this.valorPrevisto,
    this.confirmadoEm,
    this.confirmadoPor,
    this.canceladoEm,
    this.motivoCancelamento,
    this.lembreteEnviado = false,
    this.pacienteNome,
    this.clienteNome,
    this.clienteCelular,
    this.veterinarioNome,
    this.servicoNome,
    this.criadoEm,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: int.parse(json['id'].toString()),
      pacienteId: int.parse(json['paciente_id'].toString()),
      clienteId: int.parse(json['cliente_id'].toString()),
      veterinarioId: json['veterinario_id'] != null
          ? int.tryParse(json['veterinario_id'].toString())
          : null,
      servicoId: json['servico_id'] != null
          ? int.tryParse(json['servico_id'].toString())
          : null,
      tipo: json['tipo'] ?? 'consulta',
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horaInicio: json['hora_inicio'] ?? '00:00',
      horaFim: json['hora_fim'],
      status: json['status'] ?? 'agendado',
      motivo: json['motivo'],
      observacoes: json['observacoes'],
      valorPrevisto: json['valor_previsto'] != null
          ? double.tryParse(json['valor_previsto'].toString())
          : null,
      confirmadoEm: json['confirmado_em'] != null
          ? DateTime.tryParse(json['confirmado_em'])
          : null,
      confirmadoPor: json['confirmado_por'],
      canceladoEm: json['cancelado_em'] != null
          ? DateTime.tryParse(json['cancelado_em'])
          : null,
      motivoCancelamento: json['motivo_cancelamento'],
      lembreteEnviado: json['lembrete_enviado'] == 1 ||
          json['lembrete_enviado'] == '1' ||
          json['lembrete_enviado'] == true,
      pacienteNome: json['paciente_nome'],
      clienteNome: json['cliente_nome'],
      clienteCelular: json['cliente_celular'],
      veterinarioNome: json['veterinario_nome'],
      servicoNome: json['servico_nome'],
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'cliente_id': clienteId,
      'veterinario_id': veterinarioId,
      'servico_id': servicoId,
      'tipo': tipo,
      'data_agendamento': dataAgendamento.toIso8601String().split('T').first,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'status': status,
      'motivo': motivo,
      'observacoes': observacoes,
      'valor_previsto': valorPrevisto,
    };
  }

  String get tipoFormatado {
    switch (tipo) {
      case 'consulta':
        return 'Consulta';
      case 'retorno':
        return 'Retorno';
      case 'exame':
        return 'Exame';
      case 'cirurgia':
        return 'Cirurgia';
      case 'vacina':
        return 'Vacina';
      case 'procedimento':
        return 'Procedimento';
      default:
        return tipo;
    }
  }

  String get statusFormatado {
    switch (status) {
      case 'agendado':
        return 'Agendado';
      case 'confirmado':
        return 'Confirmado';
      case 'em_atendimento':
        return 'Em Atendimento';
      case 'finalizado':
        return 'Finalizado';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      case 'faltou':
        return 'Faltou';
      default:
        return status;
    }
  }

  bool get isHoje {
    final hoje = DateTime.now();
    return dataAgendamento.year == hoje.year &&
        dataAgendamento.month == hoje.month &&
        dataAgendamento.day == hoje.day;
  }

  bool get isFuturo {
    return dataAgendamento.isAfter(DateTime.now());
  }

  bool get isPassado {
    return dataAgendamento.isBefore(DateTime.now()) && !isHoje;
  }
}
