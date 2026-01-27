import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';

class AgendamentoProvider extends ChangeNotifier {
  final AgendamentoService _service = AgendamentoService();

  List<Agendamento> _agendamentos = [];
  List<Agendamento> _proximosAgendamentos = [];
  Agendamento? _agendamentoSelecionado;
  bool _isLoading = false;
  String? _error;

  List<Agendamento> get agendamentos => _agendamentos;
  List<Agendamento> get proximosAgendamentos => _proximosAgendamentos;
  Agendamento? get agendamentoSelecionado => _agendamentoSelecionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarAgendamentos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agendamentos = await _service.getAgendamentos();
      _proximosAgendamentos = await _service.getProximosAgendamentos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar agendamentos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarAgendamento(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agendamentoSelecionado = await _service.getAgendamento(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar agendamento: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparAgendamentoSelecionado() {
    _agendamentoSelecionado = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
