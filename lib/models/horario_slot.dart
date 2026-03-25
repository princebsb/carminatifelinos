class HorarioSlot {
  final String horario;
  final bool ocupado;
  final bool passado;

  HorarioSlot({
    required this.horario,
    required this.ocupado,
    required this.passado,
  });

  factory HorarioSlot.fromJson(Map<String, dynamic> json) {
    return HorarioSlot(
      horario: json['horario'] ?? '',
      ocupado: json['ocupado'] == true,
      passado: json['passado'] == true,
    );
  }

  bool get disponivel => !ocupado && !passado;
}

class PacienteSimples {
  final int id;
  final String nome;

  PacienteSimples({
    required this.id,
    required this.nome,
  });

  factory PacienteSimples.fromJson(Map<String, dynamic> json) {
    return PacienteSimples(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PacienteSimples && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
