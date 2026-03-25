class Profissional {
  final int id;
  final String nome;
  final String? cargo;
  final String? crmv;

  Profissional({
    required this.id,
    required this.nome,
    this.cargo,
    this.crmv,
  });

  factory Profissional.fromJson(Map<String, dynamic> json) {
    return Profissional(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      cargo: json['cargo'],
      crmv: json['crmv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cargo': cargo,
      'crmv': crmv,
    };
  }

  String get nomeFormatado {
    if (cargo != null && cargo!.isNotEmpty) {
      return '$nome - $cargo';
    }
    return nome;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profissional && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
