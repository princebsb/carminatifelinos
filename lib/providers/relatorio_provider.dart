import 'package:flutter/material.dart';
import '../models/relatorio.dart';
import '../services/relatorio_service.dart';

class RelatorioProvider extends ChangeNotifier {
  final RelatorioService _service = RelatorioService();

  List<Relatorio> _relatorios = [];
  bool _isLoading = false;
  String? _error;

  List<Relatorio> get relatorios => _relatorios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarRelatorios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _relatorios = await _service.getRelatorios();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar relatorios: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  String getDownloadUrl(int id) {
    return _service.getDownloadUrl(id);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
