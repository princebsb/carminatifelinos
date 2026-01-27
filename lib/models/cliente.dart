class Cliente {
  final int id;
  final String codigo;
  final String nome;
  final String email;
  final String? cpf;
  final String? telefone;
  final String? celular;
  final String? endereco;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final bool ativo;
  final DateTime? ultimoAcesso;
  final DateTime? criadoEm;

  Cliente({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.email,
    this.cpf,
    this.telefone,
    this.celular,
    this.endereco,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.ativo = true,
    this.ultimoAcesso,
    this.criadoEm,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: int.parse(json['id'].toString()),
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'],
      telefone: json['telefone'],
      celular: json['celular'],
      endereco: json['endereco'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      ativo: json['ativo'] == 1 || json['ativo'] == '1' || json['ativo'] == true,
      ultimoAcesso: json['ultimo_acesso'] != null
          ? DateTime.tryParse(json['ultimo_acesso'])
          : null,
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'celular': celular,
      'endereco': endereco,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'ativo': ativo,
    };
  }

  String get enderecoCompleto {
    final partes = <String>[];
    if (endereco != null && endereco!.isNotEmpty) partes.add(endereco!);
    if (numero != null && numero!.isNotEmpty) partes.add(numero!);
    if (complemento != null && complemento!.isNotEmpty) partes.add(complemento!);
    if (bairro != null && bairro!.isNotEmpty) partes.add(bairro!);
    if (cidade != null && cidade!.isNotEmpty) {
      if (estado != null && estado!.isNotEmpty) {
        partes.add('$cidade - $estado');
      } else {
        partes.add(cidade!);
      }
    }
    if (cep != null && cep!.isNotEmpty) partes.add('CEP: $cep');
    return partes.join(', ');
  }
}
