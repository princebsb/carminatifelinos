import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/relatorio_provider.dart';
import '../models/relatorio.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelatorioProvider>().carregarRelatorios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      body: Consumer<RelatorioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.carregarRelatorios(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.relatorios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum relatório disponível',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.carregarRelatorios(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.relatorios.length,
              itemBuilder: (context, index) {
                final relatorio = provider.relatorios[index];
                return _RelatorioCard(relatorio: relatorio);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RelatorioCard extends StatelessWidget {
  final Relatorio relatorio;

  const _RelatorioCard({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icone PDF
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Informacoes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          relatorio.pacienteNome ?? 'Paciente',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (relatorio.tipo != null && relatorio.tipo!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            relatorio.tipoFormatado,
                            style: TextStyle(
                              color: AppTheme.infoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relatorio.tituloFormatado,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (relatorio.criadoEm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(relatorio.criadoEm!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (relatorio.observacoes != null && relatorio.observacoes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      relatorio.observacoes!.length > 100
                          ? '${relatorio.observacoes!.substring(0, 100)}...'
                          : relatorio.observacoes!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _baixarPdf(context),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Baixar PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _baixarPdf(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);

    final url = '${AppConstants.baseUrl}${AppConstants.apiRelatorios}/download/${relatorio.id}';

    // Mostrar loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Baixando PDF...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      // Buscar URL do PDF
      final uri = Uri.parse(url).replace(queryParameters: {'token': token ?? ''});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['url'] != null) {
          // Baixar o PDF
          final pdfUrl = data['url'] as String;
          final pdfResponse = await http.get(Uri.parse(pdfUrl));

          if (pdfResponse.statusCode == 200) {
            // Salvar no dispositivo
            final directory = await getApplicationDocumentsDirectory();
            final fileName = 'relatorio_${relatorio.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
            final filePath = '${directory.path}/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(pdfResponse.bodyBytes);

            // Fechar snackbar de loading
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }

            // Abrir o PDF no app padrão
            final result = await OpenFilex.open(filePath);

            if (result.type != ResultType.done) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Não foi possível abrir o PDF: ${result.message}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            throw Exception('Erro ao baixar o arquivo PDF');
          }
        } else {
          throw Exception('URL do PDF não encontrada');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['messages']?['error'] ?? 'Erro ao preparar download');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir o arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
