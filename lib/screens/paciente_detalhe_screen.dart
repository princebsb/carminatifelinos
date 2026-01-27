import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/paciente_provider.dart';
import '../utils/app_theme.dart';

class PacienteDetalheScreen extends StatefulWidget {
  final int pacienteId;

  const PacienteDetalheScreen({super.key, required this.pacienteId});

  @override
  State<PacienteDetalheScreen> createState() => _PacienteDetalheScreenState();
}

class _PacienteDetalheScreenState extends State<PacienteDetalheScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PacienteProvider>().carregarPaciente(widget.pacienteId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.secondaryColor,
          tabs: const [
            Tab(text: 'Dados'),
            Tab(text: 'Saúde'),
            Tab(text: 'Consultas'),
            Tab(text: 'Agenda'),
          ],
        ),
      ),
      body: Consumer<PacienteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final paciente = provider.pacienteSelecionado;
          if (paciente == null) {
            return const Center(child: Text('Paciente não encontrado'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDadosTab(paciente),
              _buildSaudeTab(paciente),
              _buildConsultasTab(provider.dadosCompletos),
              _buildAgendaTab(provider.dadosCompletos),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDadosTab(dynamic paciente) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header com foto
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: paciente.fotoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      paciente.fotoUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.pets,
                        size: 56,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.pets,
                    size: 56,
                    color: AppTheme.primaryColor,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            paciente.nome,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            paciente.codigo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Informações
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Sexo', paciente.sexoFormatado),
                  _buildInfoRow('Idade', paciente.idade),
                  if (paciente.dataNascimento != null)
                    _buildInfoRow(
                      'Nascimento',
                      dateFormat.format(paciente.dataNascimento!),
                    ),
                  _buildInfoRow('Raça', paciente.racaNome ?? 'Não informada'),
                  if (paciente.corPelagem != null)
                    _buildInfoRow('Pelagem', paciente.corPelagem!),
                  if (paciente.peso != null)
                    _buildInfoRow('Peso', '${paciente.peso} kg'),
                  _buildInfoRow(
                    'Castrado',
                    paciente.castrado ? 'Sim' : 'Não',
                  ),
                  if (paciente.castrado && paciente.dataCastracao != null)
                    _buildInfoRow(
                      'Data Castração',
                      dateFormat.format(paciente.dataCastracao!),
                    ),
                  if (paciente.microchip != null)
                    _buildInfoRow('Microchip', paciente.microchip!),
                  _buildInfoRow('Status', paciente.statusFormatado),
                ],
              ),
            ),
          ),

          if (paciente.temperamento != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperamento',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(paciente.temperamento!),
                  ],
                ),
              ),
            ),
          ],

          if (paciente.observacoes != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observações',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(paciente.observacoes!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaudeTab(dynamic paciente) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alergias
          _buildSectionCard(
            title: 'Alergias',
            icon: Icons.warning_amber,
            color: AppTheme.dangerColor,
            content: paciente.alergias ?? 'Nenhuma alergia registrada',
            isEmpty: paciente.alergias == null,
          ),

          const SizedBox(height: 16),

          // Doencas Cronicas
          _buildSectionCard(
            title: 'Doencas Cronicas',
            icon: Icons.medical_information,
            color: AppTheme.warningColor,
            content: paciente.doencasCronicas ?? 'Nenhuma doenca cronica registrada',
            isEmpty: paciente.doencasCronicas == null,
          ),

          const SizedBox(height: 16),

          // Medicamentos
          _buildSectionCard(
            title: 'Medicamentos de Uso Continuo',
            icon: Icons.medication,
            color: AppTheme.infoColor,
            content: paciente.medicamentosUsoContinuo ?? 'Nenhum medicamento registrado',
            isEmpty: paciente.medicamentosUsoContinuo == null,
          ),

          const SizedBox(height: 16),

          // Alimentação
          _buildSectionCard(
            title: 'Tipo de Alimentação',
            icon: Icons.restaurant,
            color: AppTheme.successColor,
            content: paciente.tipoAlimentacao ?? 'Não informado',
            isEmpty: paciente.tipoAlimentacao == null,
          ),
        ],
      ),
    );
  }

  Widget _buildConsultasTab(Map<String, dynamic>? dados) {
    if (dados == null) {
      return const Center(child: Text('Carregando...'));
    }

    final prontuarios = dados['prontuarios'] as List? ?? [];
    final vacinas = dados['vacinas'] as List? ?? [];
    final agendamentos = dados['agendamentos'] as List? ?? [];
    
    // Filtrar apenas agendamentos finalizados
    final historicoAgendamentos = agendamentos
        .where((a) => a['status'] == 'finalizado' || a['status'] == 'concluido')
        .toList();
    
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Histórico de Consultas (Agendamentos finalizados)
          Text(
            'Historico de Consultas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (historicoAgendamentos.isEmpty && prontuarios.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma consulta finalizada',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            ...historicoAgendamentos.map((a) {
              final data = DateTime.tryParse(a['data'] ?? '');
              final hora = a['hora'] ?? '';
              final tipo = a['tipo'] ?? 'Consulta';
              final veterinario = a['veterinario_nome'];
              final servico = a['servico_nome'];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle, color: AppTheme.successColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getTipoFormatado(tipo), style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (data != null) Text('${dateFormat.format(data)}${hora.isNotEmpty ? " as $hora" : ""}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            if (veterinario != null) Text('Dr(a). $veterinario', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            if (servico != null) Text(servico, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            ...prontuarios.map((p) => _buildProntuarioCard(p)),
          ],

          const SizedBox(height: 24),

          // Vacinas
          Text(
            'Vacinas Aplicadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (vacinas.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.vaccines, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma vacina registrada',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...vacinas.map((v) => _buildVacinaCard(v)),
        ],
      ),
    );
  }
  
  String _getTipoFormatado(String tipo) {
    switch (tipo) {
      case 'consulta':
        return 'Consulta';
      case 'retorno':
        return 'Retorno';
      case 'exame':
        return 'Exame';
      case 'vacina':
        return 'Vacina';
      case 'cirurgia':
        return 'Cirurgia';
      case 'emergencia':
        return 'Emergencia';
      case 'internacao':
        return 'Internacao';
      default:
        return tipo;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required bool isEmpty,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: isEmpty ? Colors.grey[500] : null,
                fontStyle: isEmpty ? FontStyle.italic : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProntuarioCard(Map<String, dynamic> prontuario) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final data = DateTime.tryParse(prontuario['data_atendimento'] ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showProntuarioDetalhes(prontuario),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getTipoFormatado(prontuario['tipo'] ?? 'consulta'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (data != null) Text(dateFormat.format(data), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    if (prontuario['veterinario_nome'] != null) Text('Dr(a). ${prontuario['veterinario_nome']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    if (prontuario['queixa_principal'] != null) Text(prontuario['queixa_principal'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showProntuarioDetalhes(Map<String, dynamic> prontuario) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final data = DateTime.tryParse(prontuario['data_atendimento'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              Text(_getTipoFormatado(prontuario['tipo'] ?? 'consulta'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (data != null) Text(dateFormat.format(data), style: TextStyle(color: Colors.grey[600])),
              const Divider(height: 24),
              if (prontuario['veterinario_nome'] != null) _buildDetalheConsulta('Veterinario', 'Dr(a). ${prontuario['veterinario_nome']}'),
              if (prontuario['peso'] != null) _buildDetalheConsulta('Peso', '${prontuario['peso']} kg'),
              if (prontuario['temperatura'] != null) _buildDetalheConsulta('Temperatura', '${prontuario['temperatura']} C'),
              if (prontuario['queixa_principal'] != null) _buildDetalheConsulta('Queixa Principal', prontuario['queixa_principal']),
              if (prontuario['historico'] != null) _buildDetalheConsulta('Historico', prontuario['historico']),
              if (prontuario['exame_fisico'] != null) _buildDetalheConsulta('Exame Fisico', prontuario['exame_fisico']),
              if (prontuario['hipotese_diagnostica'] != null) _buildDetalheConsulta('Hipotese Diagnostica', prontuario['hipotese_diagnostica']),
              if (prontuario['diagnostico'] != null) _buildDetalheConsulta('Diagnostico', prontuario['diagnostico']),
              if (prontuario['tratamento'] != null) _buildDetalheConsulta('Tratamento', prontuario['tratamento']),
              if (prontuario['orientacoes'] != null) _buildDetalheConsulta('Orientacoes', prontuario['orientacoes']),
              if (prontuario['retorno'] != null) _buildDetalheConsulta('Retorno', prontuario['retorno']),
              if (prontuario['observacoes'] != null) _buildDetalheConsulta('Observacoes', prontuario['observacoes']),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalheConsulta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildVacinaCard(Map<String, dynamic> vacina) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dataAplicacao = DateTime.tryParse(vacina['data_aplicacao'] ?? '');
    final proximaDose = DateTime.tryParse(vacina['proxima_dose'] ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.vaccines, color: AppTheme.successColor),
        ),
        title: Text(vacina['nome'] ?? 'Vacina'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dataAplicacao != null)
              Text('Aplicada em: ${dateFormat.format(dataAplicacao)}'),
            if (proximaDose != null)
              Text(
                'Próxima dose: ${dateFormat.format(proximaDose)}',
                style: TextStyle(
                  color: proximaDose.isBefore(DateTime.now())
                      ? AppTheme.dangerColor
                      : null,
                ),
              ),
          ],
        ),
        isThreeLine: proximaDose != null,
      ),
    );
  }

  Widget _buildAgendaTab(Map<String, dynamic>? dados) {
    if (dados == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final agendamentos = dados['agendamentos'] as List? ?? [];
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agendamentos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (agendamentos.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum agendamento registrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...agendamentos.map((a) {
              final data = DateTime.tryParse(a['data'] ?? '');
              final hora = a['hora'] ?? '';
              final tipo = a['tipo'] ?? 'Consulta';
              final status = a['status'] ?? 'agendado';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event, color: _getStatusColor(status)),
                  ),
                  title: Text(tipo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data != null) Text('${dateFormat.format(data)} às $hora'),
                      Text(_getStatusText(status)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'agendado':
        return AppTheme.infoColor;
      case 'confirmado':
        return AppTheme.successColor;
      case 'em_atendimento':
        return AppTheme.warningColor;
      case 'concluido':
        return AppTheme.successColor;
      case 'cancelado':
        return AppTheme.dangerColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'agendado':
        return 'Agendado';
      case 'confirmado':
        return 'Confirmado';
      case 'em_atendimento':
        return 'Em Atendimento';
      case 'concluido':
        return 'Concluido';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
