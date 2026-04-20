import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/repositories/patient_repository.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final PacienteRepository _repository = PacienteRepository();
  List<dynamic> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final data = await _repository.getMisCitas();
    if (mounted) {
      setState(() {
        _allAppointments = data;
        _isLoading = false;
      });
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Mis Citas',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Próximas'),
              Tab(text: 'Historial'),
              Tab(text: 'Canceladas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // PRÓXIMAS: Pendiente o Confirmada
            _buildAppointmentList(_allAppointments
                .where((apt) =>
                    apt['estado'] == 'Pendiente' ||
                    apt['estado'] == 'Confirmada')
                .toList()),
            // HISTORIAL: Atendido (o Completada)
            _buildAppointmentList(_allAppointments
                .where((apt) => apt['estado'] == 'Atendida')
                .toList()),
            // CANCELADAS: Cancelada
            _buildAppointmentList(_allAppointments
                .where((apt) => apt['estado'] == 'Cancelada')
                .toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List appointments) {
    if (appointments.isEmpty) {
      return const Center(
          child: Text("No tienes citas en esta categoría",
              style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];

          // Quitamos el 'margin' de CustomCard y usamos Padding
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${apt['fecha']} - ${apt['hora']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      StatusBadge(status: apt['estado']),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary)),
                    title: Text(apt['psicologo'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(apt['servicio']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
