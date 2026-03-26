import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cliente.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _emailKey = 'biometric_email';
  static const String _senhaKey = 'biometric_senha';
  static const String _biometricEnabledKey = 'biometric_enabled';

  Cliente? _cliente;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  bool _canUseBiometrics = false;
  bool _biometricEnabled = false;

  Cliente? get cliente => _cliente;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  String get clienteNome => _cliente?.nome ?? '';
  String? get clienteEmail => _cliente?.email;
  bool get canUseBiometrics => _canUseBiometrics;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> init() async {
    try {
      await _apiService.init();
    } catch (e) {
      debugPrint('Erro ao inicializar ApiService: $e');
    }

    try {
      await _checkBiometricAvailability();
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      _canUseBiometrics = false;
    }

    try {
      await _checkBiometricEnabled();
    } catch (e) {
      debugPrint('Erro ao verificar biometria habilitada: $e');
      _biometricEnabled = false;
    }

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        final clienteData = await _authService.getClienteData();
        if (clienteData['id'] != null) {
          _cliente = Cliente(
            id: int.parse(clienteData['id']!),
            codigo: '',
            nome: clienteData['nome'] ?? '',
            email: clienteData['email'] ?? '',
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar login: $e');
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      _canUseBiometrics = canAuthenticate;
    } on PlatformException {
      _canUseBiometrics = false;
    }
  }

  Future<void> _checkBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      _biometricEnabled = enabled == 'true';
    } catch (e) {
      debugPrint('Erro ao ler secure storage: $e');
      _biometricEnabled = false;
    }
  }

  Future<bool> hasSavedCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final senha = await _secureStorage.read(key: _senhaKey);
    return email != null && senha != null && _biometricEnabled;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_canUseBiometrics || !_biometricEnabled) {
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        final email = await _secureStorage.read(key: _emailKey);
        final senha = await _secureStorage.read(key: _senhaKey);

        if (email != null && senha != null) {
          return await login(email, senha, saveBiometric: false);
        }
      }
      return false;
    } on PlatformException catch (e) {
      _error = 'Erro na biometria: ${e.message}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String senha, {bool saveBiometric = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, senha);

      if (result['success'] == true) {
        _cliente = result['cliente'];
        _isLoggedIn = true;
        _isLoading = false;

        // Salva credenciais se biometria estiver habilitada
        if (saveBiometric && _biometricEnabled) {
          await _saveCredentials(email, senha);
        }

        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Erro ao fazer login';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: \$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveCredentials(String email, String senha) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _senhaKey, value: senha);
  }

  Future<void> enableBiometric(String email, String senha) async {
    await _saveCredentials(email, senha);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
    _biometricEnabled = true;
    notifyListeners();
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _senhaKey);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
    _biometricEnabled = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignora erros de logout
    }

    _cliente = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> alterarSenha(
    String senhaAtual,
    String novaSenha,
    String confirmarSenha,
  ) async {
    return await _authService.alterarSenha(senhaAtual, novaSenha, confirmarSenha);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
