import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/version_service.dart';
import '../widgets/update_dialog.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _senhaController = TextEditingController();
    bool _obscurePassword = true;
    bool _showBiometricButton = false;

    @override
    void initState() {
      super.initState();
      _checkBiometric();
    }

    Future<void> _checkBiometric() async {
      final authProvider = context.read<AuthProvider>();
      final hasSaved = await authProvider.hasSavedCredentials();
      if (mounted) {
        setState(() {
          _showBiometricButton = authProvider.canUseBiometrics && hasSaved;
        });
        if (_showBiometricButton) {
          _loginWithBiometric();
        }
      }
    }

    Future<void> _loginWithBiometric() async {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.authenticateWithBiometrics();
      if (success && mounted) {
        await _checkForUpdates();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    }

    Future<void> _checkForUpdates() async {
      final versionService = VersionService();
      final versionInfo = await versionService.checkVersion();

      if (versionInfo != null && mounted) {
        if (versionService.needsMandatoryUpdate(versionInfo)) {
          await UpdateDialog.show(context, versionInfo, mandatory: true);
        } else if (versionService.needsUpdate(versionInfo)) {
          await UpdateDialog.show(context, versionInfo);
        }
      }
    }

    @override
    void dispose() {
      _emailController.dispose();
      _senhaController.dispose();
      super.dispose();
    }

    Future<void> _login() async {
      if (!_formKey.currentState!.validate()) return;

      final authProvider = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final senha = _senhaController.text;

      final success = await authProvider.login(email, senha);

      if (success && mounted) {
        if (authProvider.canUseBiometrics && !authProvider.biometricEnabled) {
          final enableBio = await _showEnableBiometricDialog();
          if (enableBio == true) {
            await authProvider.enableBiometric(email, senha);
          }
        }

        if (mounted) {
          await _checkForUpdates();
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else if (mounted && authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }

    Future<bool?> _showEnableBiometricDialog() {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ativar Biometria'),
          content: const Text(
            'Deseja usar sua biometria para fazer login mais rápido nas próximas vezes?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sim'),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo_login.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Portal do Tutor',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        if (!value.contains('@')) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _login,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                        );
                      },
                    ),
                    if (_showBiometricButton) ...[
                      const SizedBox(height: 16),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return OutlinedButton.icon(
                            onPressed: authProvider.isLoading ? null : _loginWithBiometric,
                            icon: const Icon(Icons.fingerprint, size: 28),
                            label: const Text(
                              'Entrar com Biometria',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.primaryColor),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Acesse com o e-mail e senha cadastrados na clínica',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }