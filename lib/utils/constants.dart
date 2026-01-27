class AppConstants {
  static const String baseUrl = 'https://carminatifelinos.com.br';
  static const String apiPrefix = '/api/portal';

  // Endpoints da API
  static const String apiLogin = '/api/portal/login';
  static const String apiLogout = '/api/portal/logout';
  static const String apiDashboard = '/api/portal/dashboard';
  static const String apiPacientes = '/api/portal/pacientes';
  static const String apiAgendamentos = '/api/portal/agendamentos';
  static const String apiHistorico = '/api/portal/historico';
  static const String apiAlterarSenha = '/api/portal/alterar-senha';
  static const String apiRelatorios = '/api/portal/relatorios';

  // Cores do tema
  static const int primaryColorValue = 0xFF8C1414; // Vermelho escuro
  static const int secondaryColorValue = 0xFFB01C1C; // Vermelho medio
  static const int successColorValue = 0xFF28A745;
  static const int dangerColorValue = 0xFFDC3545;
  static const int warningColorValue = 0xFFFFC107;
  static const int infoColorValue = 0xFFA52A2A; // Vermelho info

  // Textos
  static const String appName = 'Carminati';
  static const String appSubtitle = 'Portal do Cliente';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String clienteIdKey = 'cliente_id';
  static const String clienteNomeKey = 'cliente_nome';
  static const String clienteEmailKey = 'cliente_email';
}
