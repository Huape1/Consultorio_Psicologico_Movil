import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/repositories/patient_repository.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // 1. INSTANCIA DEL REPOSITORIO
  final PacienteRepository _repository = PacienteRepository();

  // 2. VARIABLES DE ESTADO (Aquí es donde se definen para que no den error)
  bool _isLoading = true;
  String userName = "Cargando...";
  String userGender = "---";
  String userAge = "--";

  String diaCita = "--";
  String mesCita = "--";
  String horaCita = "--:--";
  String tipoServicio = "Sin citas próximas";
  String nombrePsicologo = "---";
  String estadoCita = "Pendiente";

  int sesionesAtendidas = 0;
  List<dynamic> ultimosMensajes = []; // <--- ESTA ES LA QUE TE DABA ERROR

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final data = await _repository.getDashboardData();

      if (data != null && mounted) {
        setState(() {
          // Datos del Perfil
          userName = data['nombre'] ?? "Usuario";
          userGender = data['genero'] ?? "---";
          userAge = data['edad'].toString();
          sesionesAtendidas = data['sesiones'] ?? 0;
          ultimosMensajes = data['mensajes'] ?? [];

          // Datos de la Cita
          if (data['proxima_cita'] != null) {
            var cita = data['proxima_cita'];
            DateTime fecha = DateTime.parse(cita['fecha']);
            diaCita = fecha.day.toString();
            mesCita = _obtenerNombreMes(fecha.month);
            horaCita = cita['hora'];
            tipoServicio = cita['servicio_nombre'];
            nombrePsicologo = "Psic. ${cita['psicologo_nombre']}";
            estadoCita = cita['estado_nombre'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return meses[mes - 1];
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const Text("Bienvenido de nuevo",
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              Text(userName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildNextAppointmentCard(),
              const SizedBox(height: 16),
              _buildPatientInfoCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildLastMessages(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Text("FYM",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.notifications_none, size: 28),
      ],
    );
  }

  Widget _buildNextAppointmentCard() {
    return CustomCard(
      variant: 'elevated',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Próxima cita",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              StatusBadge(status: estadoCita, isSmall: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text(diaCita,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text(mesCita,
                        style: const TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(horaCita,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(tipoServicio,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    Text(nombrePsicologo, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Avatar(name: userName, size: 'large'),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Información Personal",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Datos vinculados a tu cuenta",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              )
            ],
          ),
          const Divider(height: 32),
          _infoRow("Sexo", userGender),
          _infoRow("Edad", "$userAge años"),
          _infoRow("Estado", "Activo"),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text("$sesionesAtendidas",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text("Sesiones"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastMessages() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Últimos mensajes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (ultimosMensajes.isEmpty)
            const Text("No hay mensajes nuevos",
                style: TextStyle(color: AppColors.textSecondary)),
          ...ultimosMensajes
              .map((m) => Column(
                    children: [
                      _messageItem(m['remitente'] ?? 'Sistema',
                          m['contenido'] ?? '', m['hora'] ?? ''),
                      const Divider(),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _messageItem(String title, String sub, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: Text(time,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    );
  }
}
