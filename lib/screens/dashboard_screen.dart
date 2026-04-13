import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/paciente_provider.dart';
import '../providers/agendamento_provider.dart';
import '../utils/app_theme.dart';
import 'paciente_detalhe_screen.dart';
import 'home_screen.dart';
import 'horarios_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final pacienteProvider = context.read<PacienteProvider>();
    final agendamentoProvider = context.read<AgendamentoProvider>();

    await Future.wait([
      pacienteProvider.carregarPacientes(),
      agendamentoProvider.carregarAgendamentos(),
    ]);
  }

  void _navigateToTab(int index) {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    homeState?.changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final nomeCompleto = authProvider.clienteNome;
    final primeiroNome = nomeCompleto.isNotEmpty ? nomeCompleto.split(' ').first : '';
    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              primeiroNome.isNotEmpty ? 'Olá, $primeiroNome!' : 'Olá!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe seus felinos e agendamentos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Cards de resumo
            Row(
              children: [
                Expanded(
                  child: Consumer<PacienteProvider>(
                    builder: (context, provider, _) {
                      return _buildSummaryCard(
                        onTap: () => _navigateToTab(1),
                        icon: Icons.pets,
                        title: 'Meus Gatos',
                        value: provider.pacientes.length.toString(),
                        color: AppTheme.primaryColor,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<AgendamentoProvider>(
                    builder: (context, provider, _) {
                      final proximos = provider.proximosAgendamentos.length;
                      return _buildSummaryCard(
                        onTap: () => _navigateToTab(2),
                        icon: Icons.calendar_today,
                        title: 'Agendamentos',
                        value: proximos.toString(),
                        color: AppTheme.infoColor,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Próximos agendamentos
            Text(
              'Próximos Agendamentos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Consumer<AgendamentoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.proximosAgendamentos.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum agendamento próximo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: provider.proximosAgendamentos
                      .take(3)
                      .map((agendamento) => _buildAgendamentoCard(agendamento))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Meus gatos
            Text(
              'Meus Gatos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Consumer<PacienteProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.pacientes.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum gato cadastrado',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: provider.pacientes
                      .take(3)
                      .map((paciente) => _buildPacienteCard(paciente))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Ver Horarios de Consulta
            _buildHorariosCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosCard() {
    return Card(
      color: AppTheme.primaryColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HorariosScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ver Horarios de Consulta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consulte a disponibilidade e agende uma consulta.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendamentoCard(dynamic agendamento) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToTab(2),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event, color: AppTheme.infoColor),
          ),
          title: Text(agendamento.pacienteNome ?? 'Paciente'),
          subtitle: Text(
            '${dateFormat.format(agendamento.dataAgendamento)} às ${agendamento.horaInicio}\n${agendamento.tipoFormatado}',
          ),
          isThreeLine: true,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(agendamento.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              agendamento.statusFormatado,
              style: TextStyle(
                color: _getStatusColor(agendamento.status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPacienteCard(dynamic paciente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PacienteDetalheScreen(pacienteId: paciente.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: paciente.fotoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      paciente.fotoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.pets,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : const Icon(Icons.pets, color: AppTheme.primaryColor),
          ),
          title: Text(paciente.nome),
          subtitle: Text(
            '${paciente.sexoFormatado} - ${paciente.idade}',
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
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
      case 'finalizado':
      case 'concluido':
        return AppTheme.successColor;
      case 'cancelado':
        return AppTheme.dangerColor;
      default:
        return Colors.grey;
    }
  }
}
