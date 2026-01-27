import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/paciente_service.dart';

class PacienteProvider extends ChangeNotifier {
  final PacienteService _service = PacienteService();

  List<Paciente> _pacientes = [];
  Paciente? _pacienteSelecionado;
  Map<String, dynamic>? _dadosCompletos;
  bool _isLoading = false;
  String? _error;

  List<Paciente> get pacientes => _pacientes;
  Paciente? get pacienteSelecionado => _pacienteSelecionado;
  Map<String, dynamic>? get dadosCompletos => _dadosCompletos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarPacientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pacientes = await _service.getPacientes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar pacientes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarPaciente(int id) async {
    _isLoading = true;
    _error = null;
    _pacienteSelecionado = null;
    _dadosCompletos = null;
    notifyListeners();

    try {
      // Faz apenas uma chamada para a API
      _dadosCompletos = await _service.getPacienteCompleto(id);
      
      if (_dadosCompletos != null && _dadosCompletos!['paciente'] != null) {
        _pacienteSelecionado = Paciente.fromJson(
          Map<String, dynamic>.from(_dadosCompletos!['paciente'])
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar paciente: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparPacienteSelecionado() {
    _pacienteSelecionado = null;
    _dadosCompletos = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
