class Paciente {
  final int id;
  final int clienteId;
  final int? racaId;
  final String codigo;
  final String nome;
  final String? foto;
  final String sexo;
  final DateTime? dataNascimento;
  final String? idadeAproximada;
  final double? peso;
  final String? corPelagem;
  final bool castrado;
  final DateTime? dataCastracao;
  final String? microchip;
  final String? alergias;
  final String? doencasCronicas;
  final String? medicamentosUsoContinuo;
  final String? tipoAlimentacao;
  final String? temperamento;
  final String? observacoes;
  final String status;
  final DateTime? dataObito;
  final String? causaObito;
  final String? tutorNome;
  final String? tutorCelular;
  final String? racaNome;
  final DateTime? criadoEm;

  Paciente({
    required this.id,
    required this.clienteId,
    this.racaId,
    required this.codigo,
    required this.nome,
    this.foto,
    required this.sexo,
    this.dataNascimento,
    this.idadeAproximada,
    this.peso,
    this.corPelagem,
    this.castrado = false,
    this.dataCastracao,
    this.microchip,
    this.alergias,
    this.doencasCronicas,
    this.medicamentosUsoContinuo,
    this.tipoAlimentacao,
    this.temperamento,
    this.observacoes,
    this.status = 'ativo',
    this.dataObito,
    this.causaObito,
    this.tutorNome,
    this.tutorCelular,
    this.racaNome,
    this.criadoEm,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: int.parse(json['id'].toString()),
      clienteId: int.parse(json['cliente_id'].toString()),
      racaId: json['raca_id'] != null ? int.tryParse(json['raca_id'].toString()) : null,
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      foto: json['foto'],
      sexo: json['sexo'] ?? 'macho',
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.tryParse(json['data_nascimento'])
          : null,
      idadeAproximada: json['idade_aproximada'],
      peso: json['peso'] != null ? double.tryParse(json['peso'].toString()) : null,
      corPelagem: json['cor_pelagem'],
      castrado: json['castrado'] == 1 || json['castrado'] == '1' || json['castrado'] == true,
      dataCastracao: json['data_castracao'] != null
          ? DateTime.tryParse(json['data_castracao'])
          : null,
      microchip: json['microchip'],
      alergias: json['alergias'],
      doencasCronicas: json['doencas_cronicas'],
      medicamentosUsoContinuo: json['medicamentos_uso_continuo'],
      tipoAlimentacao: json['tipo_alimentacao'],
      temperamento: json['temperamento'],
      observacoes: json['observacoes'],
      status: json['status'] ?? 'ativo',
      dataObito: json['data_obito'] != null
          ? DateTime.tryParse(json['data_obito'])
          : null,
      causaObito: json['causa_obito'],
      tutorNome: json['tutor_nome'],
      tutorCelular: json['tutor_celular'],
      racaNome: json['raca_nome'],
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'raca_id': racaId,
      'codigo': codigo,
      'nome': nome,
      'foto': foto,
      'sexo': sexo,
      'data_nascimento': dataNascimento?.toIso8601String().split('T').first,
      'idade_aproximada': idadeAproximada,
      'peso': peso,
      'cor_pelagem': corPelagem,
      'castrado': castrado,
      'data_castracao': dataCastracao?.toIso8601String().split('T').first,
      'microchip': microchip,
      'alergias': alergias,
      'doencas_cronicas': doencasCronicas,
      'medicamentos_uso_continuo': medicamentosUsoContinuo,
      'tipo_alimentacao': tipoAlimentacao,
      'temperamento': temperamento,
      'observacoes': observacoes,
      'status': status,
    };
  }

  String get idade {
    if (dataNascimento == null) {
      return idadeAproximada ?? 'Idade desconhecida';
    }

    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento!.year;
    int meses = hoje.month - dataNascimento!.month;
    int dias = hoje.day - dataNascimento!.day;

    // Ajusta se os dias forem negativos
    if (dias < 0) {
      meses--;
      final mesAnterior = DateTime(hoje.year, hoje.month, 0);
      dias += mesAnterior.day;
    }

    // Ajusta se os meses forem negativos
    if (meses < 0) {
      anos--;
      meses += 12;
    }

    final partes = <String>[];
    if (anos > 0) {
      partes.add('$anos ano${anos > 1 ? "s" : ""}');
    }
    if (meses > 0) {
      partes.add('$meses ${meses > 1 ? "meses" : "mês"}');
    }
    if (dias > 0) {
      partes.add('$dias dia${dias > 1 ? "s" : ""}');
    }

    if (partes.isEmpty) {
      return 'Recém-nascido';
    }

    return partes.join(', ');
  }

  String get sexoFormatado => sexo == 'macho' ? 'Macho' : 'Fêmea';

  String? get fotoUrl {
    if (foto == null || foto!.isEmpty) return null;
    if (foto!.startsWith('http')) return foto;
    return 'https://carminatifelinos.com.br$foto';
  }

  String get statusFormatado {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'internado':
        return 'Internado';
      case 'obito':
        return 'Óbito';
      default:
        return status;
    }
  }
}
