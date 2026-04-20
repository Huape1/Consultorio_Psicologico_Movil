import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/psychologist_repository.dart';

class PsychologistHomeScreen extends StatefulWidget {
  const PsychologistHomeScreen({super.key});

  @override
  State<PsychologistHomeScreen> createState() => _PsychologistHomeScreenState();
}

class _PsychologistHomeScreenState extends State<PsychologistHomeScreen> {
  final PsicologoRepository _repository = PsicologoRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _repository.getDashboardData();
    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

@override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stats = _dashboardData?['stats'];
    final proximaCita = _dashboardData?['proxima_cita'];
    final citasSiguientes = _dashboardData?['citas_siguientes'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header con foto real
                _buildHeader(
                  _dashboardData?['nombre_psicologo'] ?? "",
                  _dashboardData?['foto_psicologo'],
                ),
                const SizedBox(height: 24),

                // 2. Stats (Cambiado a Mensajes no leídos)
                Row(
                  children: [
                    _buildStatCard(stats?['total_hoy']?.toString() ?? "0", "Citas Hoy"),
                    const SizedBox(width: 12),
                    _buildStatCard(stats?['mensajes_no_leidos']?.toString() ?? "0", "Mensajes"),
                    const SizedBox(width: 12),
                    _buildStatCard(stats?['pacientes_activos']?.toString() ?? "0", "Pacientes"),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Próxima Cita (Con fecha y hora)
                if (proximaCita != null) ...[
                  const Text("Próxima Cita",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildNextAppointment(proximaCita),
                ],

                const SizedBox(height: 24),

                // 4. Citas siguientes con botón a Agenda
                _buildSectionHeader("Siguientes Citas", () {
                   // Aquí navegas a tu pantalla de agenda
                   Navigator.pushNamed(context, '/agenda'); 
                }),
                const SizedBox(height: 12),
                
                citasSiguientes.isEmpty
                    ? const Center(child: Text("No hay más citas programadas"))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: citasSiguientes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _buildAppointmentListItem(citasSiguientes[index]),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER ACTUALIZADO: Usa la URL de la foto
  Widget _buildHeader(String name, String? photoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Buenos días,",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            Text(name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Avatar(
          name: name, 
          size: 'medium',
          imageUrl: photoUrl, // Pasa la URL que viene del backend
        ),
      ],
    );
  }

  // PRÓXIMA CITA ACTUALIZADA: Muestra fecha y hora
  Widget _buildNextAppointment(dynamic apt) {
    return CustomCard(
      variant: 'elevated',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${apt['fecha']}", 
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(apt['hora'],
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
              StatusBadge(status: apt['estado'], isSmall: true),
            ],
          ),
          const Divider(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(
              name: apt['paciente_nombre'], 
              imageUrl: apt['foto_paciente']
            ),
            title: Text(apt['paciente_nombre'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(apt['tipo']),
          ),
          const SizedBox(height: 8),
          CustomButton(
              title: "Ver Expediente",
              size: 'small',
              onPress: () => print("Navegar a expediente del paciente")),
        ],
      ),
    );
  }

  // HEADER DE SECCIÓN ACTUALIZADO: Recibe una función para el botón
  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
            onPressed: onSeeAll,
            child: const Text("Ver Agenda",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
      ],
    );
  }

  // LISTA DE CITAS ACTUALIZADA: Incluye la fecha
  Widget _buildAppointmentListItem(dynamic apt) {
    return CustomCard(
      child: Row(
        children: [
          Column(
            children: [
              Text(apt['hora'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(apt['fecha'], style: const TextStyle(fontSize: 10)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(apt['paciente_nombre'],
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          StatusBadge(status: apt['estado'], isSmall: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: CustomCard(
        child: Column(
          children: [
            Text(number,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}