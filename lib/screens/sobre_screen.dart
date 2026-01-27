import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../services/version_service.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _ligar(String telefone) async {
    final uri = Uri.parse('tel:$telefone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _enviarEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _abrirWhatsApp(String telefone) async {
    final numero = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/55$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo e nome do app
            Image.asset(
              'assets/images/logo_login.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'Carminati Felinos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const Text(
              'Portal do Tutor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Versão ${VersionService.currentVersion} (Build ${VersionService.currentBuild})',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Desenvolvido por
            _buildSection(
              context,
              icon: Icons.code,
              title: 'Desenvolvido por',
              child: Column(
                children: [
                  const Text(
                    'LS GLOBAL TECNOLOGIA LTDA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _enviarEmail('contato@lsglobaltecnologia.com.br'),
                    child: Text(
                      'contato@lsglobaltecnologia.com.br',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contato de suporte
            _buildSection(
              context,
              icon: Icons.support_agent,
              title: 'Contato de Suporte',
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.phone, color: AppTheme.primaryColor),
                    title: const Text('(61) 99817-0414'),
                    subtitle: const Text('Telefone'),
                    onTap: () => _ligar('61998170414'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Colors.green[600]),
                    title: const Text('(61) 99817-0414'),
                    subtitle: const Text('WhatsApp'),
                    onTap: () => _abrirWhatsApp('61998170414'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Termos e Política
            _buildSection(
              context,
              icon: Icons.description,
              title: 'Legal',
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
                    title: const Text('Política de Privacidade'),
                    onTap: () => _abrirUrl('https://carminatifelinos.com.br/politica-privacidade'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                  ),
                  ListTile(
                    leading: Icon(Icons.gavel, color: AppTheme.primaryColor),
                    title: const Text('Termos de Uso'),
                    onTap: () => _abrirUrl('https://carminatifelinos.com.br/termos-uso'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            Text(
              '© ${DateTime.now().year} Carminati Medicina Felina',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            Text(
              'Todos os direitos reservados',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}
