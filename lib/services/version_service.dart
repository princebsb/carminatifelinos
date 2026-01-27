import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class VersionInfo {
  final String versaoAtual;
  final int buildAtual;
  final String versaoMinima;
  final int buildMinimo;
  final String urlAtualizacao;
  final bool obrigatoria;
  final String mensagem;

  VersionInfo({
    required this.versaoAtual,
    required this.buildAtual,
    required this.versaoMinima,
    required this.buildMinimo,
    required this.urlAtualizacao,
    required this.obrigatoria,
    required this.mensagem,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      versaoAtual: json['versao_atual'] ?? '1.0.0',
      buildAtual: json['build_atual'] ?? 1,
      versaoMinima: json['versao_minima'] ?? '1.0.0',
      buildMinimo: json['build_minimo'] ?? 1,
      urlAtualizacao: json['url_atualizacao'] ?? '',
      obrigatoria: json['obrigatoria'] ?? false,
      mensagem: json['mensagem'] ?? 'Uma nova versao esta disponivel.',
    );
  }
}

class VersionService {
  static const int currentBuild = 22;
  static const String currentVersion = '1.0.0';

  Future<VersionInfo?> checkVersion() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/versao'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VersionInfo.fromJson(data);
      }
    } catch (e) {
      // Silently fail - don't block the user
    }
    return null;
  }

  bool needsUpdate(VersionInfo info) {
    return info.buildAtual > currentBuild;
  }

  bool needsMandatoryUpdate(VersionInfo info) {
    return info.obrigatoria && info.buildMinimo > currentBuild;
  }
}
