import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cliente.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final result = await _api.post(AppConstants.apiLogin, {
      'email': email,
      'senha': senha,
    });

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      if (data['token'] != null) {
        await _api.setToken(data['token']);
      }
      if (data['cliente'] != null) {
        await _saveClienteData(data['cliente']);
        return {
          'success': true,
          'cliente': Cliente.fromJson(data['cliente']),
          'primeiro_acesso': data['primeiro_acesso'] ?? false,
        };
      }
    }

    return {
      'success': false,
      'message': result['message'] ?? 'E-mail ou senha incorretos.',
    };
  }

  Future<void> _saveClienteData(Map<String, dynamic> cliente) async {
    await _storage.write(
      key: AppConstants.clienteIdKey,
      value: cliente['id'].toString(),
    );
    await _storage.write(
      key: AppConstants.clienteNomeKey,
      value: cliente['nome'] ?? '',
    );
    await _storage.write(
      key: AppConstants.clienteEmailKey,
      value: cliente['email'] ?? '',
    );
  }

  Future<void> logout() async {
    await _api.post(AppConstants.apiLogout, {});
    await _api.clearToken();
    await _storage.delete(key: AppConstants.clienteIdKey);
    await _storage.delete(key: AppConstants.clienteNomeKey);
    await _storage.delete(key: AppConstants.clienteEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String?>> getClienteData() async {
    return {
      'id': await _storage.read(key: AppConstants.clienteIdKey),
      'nome': await _storage.read(key: AppConstants.clienteNomeKey),
      'email': await _storage.read(key: AppConstants.clienteEmailKey),
    };
  }

  Future<Map<String, dynamic>> alterarSenha(
    String senhaAtual,
    String novaSenha,
    String confirmarSenha,
  ) async {
    final result = await _api.post(AppConstants.apiAlterarSenha, {
      'senha_atual': senhaAtual,
      'nova_senha': novaSenha,
      'confirmar_senha': confirmarSenha,
    });

    return {
      'success': result['success'] ?? false,
      'message': result['message'] ?? 'Erro ao alterar senha.',
    };
  }
}
