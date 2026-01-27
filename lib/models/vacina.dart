class Vacina {
  final int id;
  final int pacienteId;
  final int? veterinarioId;
  final String nome;
  final String? fabricante;
  final String? lote;
  final DateTime dataAplicacao;
  final DateTime? proximaDose;
  final String? observacoes;
  final String? pacienteNome;
  final String? veterinarioNome;
  final DateTime? criadoEm;

  Vacina({
    required this.id,
    required this.pacienteId,
    this.veterinarioId,
    required this.nome,
    this.fabricante,
    this.lote,
    required this.dataAplicacao,
    this.proximaDose,
    this.observacoes,
    this.pacienteNome,
    this.veterinarioNome,
    this.criadoEm,
  });

  factory Vacina.fromJson(Map<String, dynamic> json) {
    return Vacina(
      id: int.parse(json['id'].toString()),
      pacienteId: int.parse(json['paciente_id'].toString()),
      veterinarioId: json['veterinario_id'] != null
          ? int.tryParse(json['veterinario_id'].toString())
          : null,
      nome: json['nome'] ?? '',
      fabricante: json['fabricante'],
      lote: json['lote'],
      dataAplicacao: DateTime.parse(json['data_aplicacao']),
      proximaDose: json['proxima_dose'] != null
          ? DateTime.tryParse(json['proxima_dose'])
          : null,
      observacoes: json['observacoes'],
      pacienteNome: json['paciente_nome'],
      veterinarioNome: json['veterinario_nome'],
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  bool get proximaDoseVencida {
    if (proximaDose == null) return false;
    return proximaDose!.isBefore(DateTime.now());
  }

  bool get proximaDoseProxima {
    if (proximaDose == null) return false;
    final diasRestantes = proximaDose!.difference(DateTime.now()).inDays;
    return diasRestantes >= 0 && diasRestantes <= 30;
  }
}
