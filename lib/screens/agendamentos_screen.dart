import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/agendamento_provider.dart';
import '../models/agendamento.dart';
import '../utils/app_theme.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendamentoProvider>().carregarAgendamentos();
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
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppTheme.secondaryColor,
              tabs: const [
                Tab(text: 'Próximos'),
                Tab(text: 'Todos'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AgendamentoProvider>(
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
                          onPressed: () => provider.carregarAgendamentos(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAgendamentosList(provider.proximosAgendamentos),
                    _buildAgendamentosList(provider.agendamentos),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentosList(List<Agendamento> agendamentos) {
    if (agendamentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento encontrado',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre em contato com a clínica\npara agendar uma consulta',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AgendamentoProvider>().carregarAgendamentos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: agendamentos.length,
        itemBuilder: (context, index) {
          final agendamento = agendamentos[index];
          return _AgendamentoCard(agendamento: agendamento);
        },
      ),
    );
  }
}

class _AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;

  const _AgendamentoCard({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('dd');
    final monthFormat = DateFormat('MMM', 'pt_BR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetalhes(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Data
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(agendamento.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      dayFormat.format(agendamento.dataAgendamento),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(agendamento.status),
                      ),
                    ),
                    Text(
                      monthFormat.format(agendamento.dataAgendamento).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(agendamento.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            agendamento.pacienteNome ?? 'Paciente',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          agendamento.horaInicio,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.medical_services, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          agendamento.tipoFormatado,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (agendamento.servicoNome != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.content_cut, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              agendamento.servicoNome!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (agendamento.veterinarioNome != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Dr(a). ${agendamento.veterinarioNome}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(agendamento.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      agendamento.statusFormatado,
                      style: TextStyle(
                        color: _getStatusColor(agendamento.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetalhes(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(agendamento.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event,
                    color: _getStatusColor(agendamento.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agendamento.tipoFormatado,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        agendamento.statusFormatado,
                        style: TextStyle(
                          color: _getStatusColor(agendamento.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildDetalheRow(Icons.pets, 'Paciente', agendamento.pacienteNome ?? '-'),
            _buildDetalheRow(
              Icons.calendar_today,
              'Data',
              dateFormat.format(agendamento.dataAgendamento),
            ),
            _buildDetalheRow(Icons.access_time, 'Horário', agendamento.horaInicio),
            if (agendamento.veterinarioNome != null)
              _buildDetalheRow(
                Icons.person,
                'Veterinário',
                'Dr(a). ${agendamento.veterinarioNome}',
              ),
            if (agendamento.servicoNome != null)
              _buildDetalheRow(Icons.medical_services, 'Serviço', agendamento.servicoNome!),
            if (agendamento.motivo != null)
              _buildDetalheRow(Icons.notes, 'Motivo', agendamento.motivo!),
            if (agendamento.observacoes != null)
              _buildDetalheRow(Icons.info, 'Observações', agendamento.observacoes!),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalheRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
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
      case 'faltou':
        return AppTheme.dangerColor;
      default:
        return Colors.grey;
    }
  }
}
