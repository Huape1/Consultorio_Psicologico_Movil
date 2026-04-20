import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/mock_data.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/api/api_service.dart';


class AdminHomeScreen extends StatefulWidget {
  final Function(int) onTapChange;
  const AdminHomeScreen({super.key, required this.onTapChange});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}
class _AdminHomeScreenState extends State<AdminHomeScreen> {
  
  // Función para cambiar de pestaña en el Layout Principal
  void _goToTab(int index) {
    widget.onTapChange(index);
  }
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Estructura para datos reales
  Map<String, dynamic> stats = {
    'psychologists': 0,
    'patients': 0,
    'messages': 0,
    'appointments': 0
  };
  List<dynamic> recentMessages = [];
  List<dynamic> adminList = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getRequest('/admin/stats/');

      setState(() {
        // Asignamos cantidades
        stats = {
          'psychologists': data['activePsychologists'],
          'patients': data['registeredPatients'],
          'messages': data['pendingMessages'],
          'appointments': data['todayAppointments'],
        };
        // ASIGNAMOS LISTAS REALES
        recentMessages = data['recentMessages'] ?? [];
        adminList = data['adminList'] ?? [];

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildActivitySection(),
                const SizedBox(height: 20),
                _buildAdminsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text("FYM",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            const Text("Panel Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        // Aquí podrías usar el nombre real del admin logueado
        const Avatar(name: "Admin", size: 'medium'),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard("Psicólogos", stats['psychologists'].toString(),
            Icons.people, AppColors.primary, AppColors.primaryLight,
            growth: mockDashboardStats.monthlyGrowth),
        _buildStatCard("Pacientes", stats['patients'].toString(), Icons.person,
            AppColors.success, AppColors.successLight,
            growth: mockDashboardStats.patientGrowth),
        _buildStatCard(
            "Mensajes",
            stats['messages'].toString(),
            Icons.chat_bubble_outline,
            AppColors.warning,
            AppColors.warningLight,
            growth: "Sin leer",
            isWarning: true),
        _buildStatCard("Citas Hoy", stats['appointments'].toString(),
            Icons.calendar_today, AppColors.secondary, AppColors.secondaryLight,
            growth: "En curso"),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, Color bgColor,
      {String? growth, bool isWarning = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return SizedBox(
          width: width,
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (growth != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(growth,
                        style: TextStyle(
                            fontSize: 11,
                            color: isWarning
                                ? AppColors.warning
                                : AppColors.success,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INDICE 4: Reportes / Mensajes
          _buildSectionHeader(
              "Mensajes Recientes", "Ver todos", () => _goToTab(4)),
          if (recentMessages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No hay mensajes nuevos")),
            )
          else
            ...recentMessages.map((msg) => _buildMessageItem(msg)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic msg) {
    bool isHigh = msg['isHigh'] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          Icon(isHigh ? Icons.mark_chat_unread : Icons.chat_bubble_outline,
              color: isHigh ? AppColors.warning : AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(msg['user'] ?? 'Desconocido',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(msg['content'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ])),
          Text(msg['timestamp'] ?? '',
              style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
        ],
      ),
    );
  }

  // MODIFICACIÓN EN SECCIÓN DE ADMINISTRADORES
  Widget _buildAdminsSection() {
    return CustomCard(
      child: Column(
        children: [
          _buildSectionHeader(
              "Administradores", "Gestionar", () => _goToTab(3)),
          if (adminList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Cargando administradores..."),
            )
          else
            ...adminList.map((admin) => ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: // En home_screen.dart, dentro del .map
                          Avatar(
                        name: admin['fullName'],
                        imageUrl: admin[
                            'photo'], // <--- Verifica que diga 'photo' y no 'imageUrl' o 'foto'
                        size: 'small',
                        showOnlineStatus: true,
                        isOnline: admin['status'] == 'Activo',
                      )
                  ),
                  title: Text(admin['fullName'] ?? 'Sin nombre'),
                  subtitle: Text(admin['role'] ?? 'Admin',
                      style: const TextStyle(fontSize: 12)),
                  trailing: StatusBadge(status: admin['status'], isSmall: true),
                  onTap: () => _goToTab(3),
                )),
        ],
      ),
    );
  }

  // Modifica el método para que reciba una función callback
  Widget _buildSectionHeader(
      String title, String action, VoidCallback onActionTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
            onPressed: onActionTap,
            child:
                Text(action, style: const TextStyle(color: AppColors.primary))),
      ],
    );
  }
}
