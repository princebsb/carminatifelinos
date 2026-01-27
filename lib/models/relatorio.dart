class Relatorio {
  final int id;
  final int pacienteId;
  final String? titulo;
  final String? tipo;
  final String? observacoes;
  final String? pacienteNome;
  final DateTime? criadoEm;

  Relatorio({
    required this.id,
    required this.pacienteId,
    this.titulo,
    this.tipo,
    this.observacoes,
    this.pacienteNome,
    this.criadoEm,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    return Relatorio(
      id: int.parse(json['id'].toString()),
      pacienteId: int.parse(json['paciente_id'].toString()),
      titulo: json['titulo'],
      tipo: json['tipo'],
      observacoes: json['observacoes'],
      pacienteNome: json['paciente_nome'],
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  String get tipoFormatado {
    if (tipo == null || tipo!.isEmpty) return 'Relatório';
    switch (tipo) {
      case 'relatorio_clinico':
        return 'Relatório Clínico';
      case 'exame':
        return 'Exame';
      case 'receita':
        return 'Receita';
      case 'atestado':
        return 'Atestado';
      default:
        return tipo!;
    }
  }

  String get tituloFormatado {
    if (titulo == null || titulo!.isEmpty) return 'Relatório Clínico';

    // Se o titulo for no formato "relatorio_XX.pdf" ou "relatorio_XX_XXXXX.pdf", mostra nome amigavel
    if (titulo!.startsWith('relatorio_')) {
      if (pacienteNome != null && pacienteNome!.isNotEmpty) {
        return 'Relatório de $pacienteNome';
      }
      return 'Relatório Clínico';
    }

    return titulo!;
  }
}
