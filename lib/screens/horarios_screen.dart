import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/horario_provider.dart';
import '../providers/auth_provider.dart';
import '../models/profissional.dart';
import '../models/horario_slot.dart';
import '../utils/app_theme.dart';
import '../services/horario_service.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HorarioProvider>().carregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de Consulta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HorarioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profissionais.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.profissionais.isEmpty) {
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
                    onPressed: () => provider.carregarDados(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.carregarDados(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descricao
                  Text(
                    'Consulte a disponibilidade dos nossos profissionais',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filtros
                  _buildFiltros(context, provider),

                  const SizedBox(height: 24),

                  // Conteudo
                  if (provider.profissionalSelecionado == null)
                    _buildEstadoInicial()
                  else ...[
                    _buildInfoProfissional(provider),
                    const SizedBox(height: 16),
                    _buildGradeHorarios(context, provider),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, HorarioProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown Paciente
            DropdownButtonFormField<PacienteSimples>(
              decoration: InputDecoration(
                labelText: 'Paciente',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              value: provider.pacienteSelecionado,
              hint: const Text('Selecione o paciente'),
              items: provider.pacientes.map((paciente) {
                return DropdownMenuItem(
                  value: paciente,
                  child: Text(paciente.nome),
                );
              }).toList(),
              onChanged: (value) => provider.selecionarPaciente(value),
            ),
            const SizedBox(height: 16),

            // Dropdown Profissional
            DropdownButtonFormField<Profissional>(
              decoration: InputDecoration(
                labelText: 'Profissional',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              value: provider.profissionalSelecionado,
              hint: const Text('Selecione o profissional'),
              items: provider.profissionais.map((prof) {
                return DropdownMenuItem(
                  value: prof,
                  child: Text(prof.nome),
                );
              }).toList(),
              onChanged: (value) => provider.selecionarProfissional(value),
            ),
            const SizedBox(height: 16),

            // Seletor de Data
            InkWell(
              onTap: () => _selecionarData(context, provider),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(provider.dataSelecionada),
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isHoje(provider.dataSelecionada))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hoje',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoInicial() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                'Selecione um Profissional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha um profissional acima para visualizar\nos horarios disponiveis para consulta.',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoProfissional(HorarioProvider provider) {
    final prof = provider.profissionalSelecionado!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prof.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (prof.cargo != null && prof.cargo!.isNotEmpty)
                  Text(
                    prof.cargo!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                if (prof.crmv != null && prof.crmv!.isNotEmpty)
                  Text(
                    'CRMV: ${prof.crmv}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(provider.dataSelecionada),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (_isHoje(provider.dataSelecionada))
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Hoje',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeHorarios(BuildContext context, HorarioProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Grade de Horarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (provider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Legenda
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendaItem(AppTheme.successColor, 'Disponivel'),
                _buildLegendaItem(AppTheme.dangerColor, 'Ocupado'),
                _buildLegendaItem(Colors.grey, 'Encerrado'),
              ],
            ),
            const SizedBox(height: 16),

            // Aviso de paciente
            if (provider.pacienteSelecionado == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.warningColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Selecione um paciente acima para inclui-lo na mensagem de agendamento.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Grade de horarios
            if (provider.horarios.isEmpty)
              _buildSemHorarios()
            else ...[
              Text(
                'Clique em um horario disponivel para agendar',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: provider.horarios.length,
                itemBuilder: (context, index) {
                  final slot = provider.horarios[index];
                  return _buildHorarioSlot(context, slot, provider);
                },
              ),
              const SizedBox(height: 24),

              // Resumo
              _buildResumo(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSemHorarios() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum horario disponivel para esta data.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioSlot(BuildContext context, HorarioSlot slot, HorarioProvider provider) {
    Color cor;
    IconData icone;

    if (slot.passado) {
      cor = Colors.grey;
      icone = Icons.schedule;
    } else if (slot.ocupado) {
      cor = AppTheme.dangerColor;
      icone = Icons.close;
    } else {
      cor = AppTheme.successColor;
      icone = Icons.chat;
    }

    return Material(
      color: cor.withValues(alpha: slot.disponivel ? 1.0 : 0.7),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: slot.disponivel
            ? () => _abrirWhatsApp(context, slot.horario, provider)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              slot.horario,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo(HorarioProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem(
            provider.horariosDisponiveis.toString(),
            'Disponiveis',
            AppTheme.successColor,
          ),
          _buildResumoItem(
            provider.horariosOcupados.toString(),
            'Ocupados',
            AppTheme.dangerColor,
          ),
          if (provider.horariosPassados > 0)
            _buildResumoItem(
              provider.horariosPassados.toString(),
              'Encerrados',
              Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String valor, String label, Color cor) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarData(BuildContext context, HorarioProvider provider) async {
    final dataAtual = DateTime.now();
    final dataMaxima = dataAtual.add(const Duration(days: 60));

    // Garantir que initialDate seja >= firstDate
    DateTime initialDate = provider.dataSelecionada;
    if (initialDate.isBefore(dataAtual)) {
      initialDate = dataAtual;
    }

    // Se initialDate for domingo, avanca para segunda
    if (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dataAtual,
      lastDate: dataMaxima,
      selectableDayPredicate: (date) {
        // Bloquear domingos
        return date.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      provider.selecionarData(dataSelecionada);
    }
  }

  Future<void> _abrirWhatsApp(BuildContext context, String horario, HorarioProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    final prof = provider.profissionalSelecionado;
    final paciente = provider.pacienteSelecionado;
    final data = DateFormat('dd/MM/yyyy').format(provider.dataSelecionada);
    final dataApi = DateFormat('yyyy-MM-dd').format(provider.dataSelecionada);

    // Registrar clique de forma assincrona (nao bloqueia a abertura do WhatsApp)
    HorarioService().registrarClique(
      horario: horario,
      data: dataApi,
      pacienteId: paciente?.id,
      veterinarioId: prof?.id,
    );

    String mensagem = 'Ola! Meu nome e ${authProvider.clienteNome}';

    if (paciente != null) {
      mensagem += ', tutor(a) do(a) ${paciente.nome}';
    }

    mensagem += '. Gostaria de agendar uma consulta';

    if (paciente != null) {
      mensagem += ' para ${paciente.nome}';
    }

    if (prof != null) {
      mensagem += ' com ${prof.nome}';
    }

    mensagem += ' no dia $data as $horario.';

    // Formatar numero de WhatsApp
    String numero = provider.whatsapp.replaceAll(RegExp(r'\D'), '');
    if (numero.isNotEmpty && !numero.startsWith('55')) {
      numero = '55$numero';
    }

    final url = 'https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nao foi possivel abrir o WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isHoje(DateTime date) {
    final hoje = DateTime.now();
    return date.year == hoje.year &&
        date.month == hoje.month &&
        date.day == hoje.day;
  }
}
