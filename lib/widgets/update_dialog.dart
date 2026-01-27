import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/version_service.dart';
import '../utils/app_theme.dart';

class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final bool isMandatory;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('Atualizacao Disponivel'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(versionInfo.mensagem),
          const SizedBox(height: 16),
          Text(
            'Versao disponivel: ${versionInfo.versaoAtual}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Sua versao: ${VersionService.currentVersion}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        if (!isMandatory)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Depois'),
          ),
        ElevatedButton(
          onPressed: () async {
            final url = Uri.parse(versionInfo.urlAtualizacao);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Atualizar Agora'),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, VersionInfo info, {bool mandatory = false}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) => UpdateDialog(
        versionInfo: info,
        isMandatory: mandatory,
      ),
    );
  }
}
