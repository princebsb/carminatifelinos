import 'package:flutter/foundation.dart';
import '../services/horario_service.dart';
import '../models/profissional.dart';
import '../models/horario_slot.dart';

class HorarioProvider extends ChangeNotifier {
  final HorarioService _service = HorarioService();

  List<Profissional> _profissionais = [];
  List<PacienteSimples> _pacientes = [];
  List<HorarioSlot> _horarios = [];
  Profissional? _profissionalSelecionado;
  PacienteSimples? _pacienteSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  String _whatsapp = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Profissional> get profissionais => _profissionais;
  List<PacienteSimples> get pacientes => _pacientes;
  List<HorarioSlot> get horarios => _horarios;
  Profissional? get profissionalSelecionado => _profissionalSelecionado;
  PacienteSimples? get pacienteSelecionado => _pacienteSelecionado;
  DateTime get dataSelecionada => _dataSelecionada;
  String get whatsapp => _whatsapp;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get horariosDisponiveis => _horarios.where((h) => h.disponivel).length;
  int get horariosOcupados => _horarios.where((h) => h.ocupado).length;
  int get horariosPassados => _horarios.where((h) => h.passado).length;

  Future<void> carregarDados({int? veterinarioId, String? data}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.getHorarios(
        veterinarioId: veterinarioId ?? _profissionalSelecionado?.id,
        data: data ?? _formatDate(_dataSelecionada),
      );

      _profissionais = resultado['profissionais'] as List<Profissional>;
      _pacientes = resultado['pacientes'] as List<PacienteSimples>;
      _horarios = resultado['horarios'] as List<HorarioSlot>;
      _whatsapp = resultado['whatsapp'] as String;

      // Manter a selecao do profissional na nova lista
      if (_profissionalSelecionado != null) {
        final profEncontrado = _profissionais.where((p) => p.id == _profissionalSelecionado!.id).firstOrNull;
        _profissionalSelecionado = profEncontrado;
      }

      // Manter a selecao do paciente na nova lista
      if (_pacienteSelecionado != null) {
        final pacEncontrado = _pacientes.where((p) => p.id == _pacienteSelecionado!.id).firstOrNull;
        _pacienteSelecionado = pacEncontrado;
      }

      if (resultado['data_selecionada'] != null) {
        _dataSelecionada = DateTime.parse(resultado['data_selecionada']);
      }
    } catch (e) {
      _error = 'Erro ao carregar horarios: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void selecionarProfissional(Profissional? profissional) {
    _profissionalSelecionado = profissional;
    _horarios = [];
    notifyListeners();

    if (profissional != null) {
      carregarDados(veterinarioId: profissional.id);
    }
  }

  void selecionarPaciente(PacienteSimples? paciente) {
    _pacienteSelecionado = paciente;
    notifyListeners();
  }

  void selecionarData(DateTime data) {
    _dataSelecionada = data;
    notifyListeners();

    if (_profissionalSelecionado != null) {
      carregarDados(
        veterinarioId: _profissionalSelecionado!.id,
        data: _formatDate(data),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void limpar() {
    _profissionalSelecionado = null;
    _pacienteSelecionado = null;
    _horarios = [];
    _dataSelecionada = DateTime.now();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
