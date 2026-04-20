import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../data/repositories/psychologist_repository.dart';

class PatientRecordScreen extends StatefulWidget {
  final int pacienteId;
  final String nombre;
  final String? imageUrl;

  const PatientRecordScreen({
    super.key,
    required this.pacienteId,
    required this.nombre,
    this.imageUrl,
  });

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  final PsicologoRepository _repo = PsicologoRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _record;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final data = await _repo.getExpedientePaciente(widget.pacienteId);
    if (mounted) {
      setState(() {
        _record = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Expediente Clínico"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Información General"),
                  _buildGeneralInfo(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Antecedentes"),
                  _buildAntecedents(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Evoluciones Recientes"),
                  _buildEvolutions(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Avatar(name: widget.nombre, imageUrl: widget.imageUrl, size: 'large'),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.nombre,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  "${_record?['edad'] ?? '--'} años • ${_record?['ocupacion'] ?? 'No definida'}",
                  style: const TextStyle(color: AppColors.textSecondary)),
              Text("Estado Civil: ${_record?['estado_civil'] ?? '--'}",
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfo() {
    return CustomCard(
      child: Column(
        children: [
          _buildInfoRow(Icons.warning_amber_rounded, "Riesgos",
              _record?['riesgos'], Colors.orange),
          const Divider(),
          _buildInfoRow(
              Icons
                  .psychology_outlined, // <--- Cambiado de 'P' mayúscula a 'p' minúscula
              "Traumas",
              _record?['traumas'],
              Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildAntecedents() {
    return Column(
      children: [
        _buildExpandableInfo("Personales", _record?['ant_personales']),
        _buildExpandableInfo("Familiares", _record?['ant_familiares']),
        _buildExpandableInfo("Psicológicos", _record?['ant_psicologicos']),
      ],
    );
  }

  Widget _buildEvolutions() {
    List evoluciones = _record?['evoluciones'] ?? [];
    if (evoluciones.isEmpty)
      return const Text("No hay evoluciones registradas.");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evoluciones.length,
      itemBuilder: (context, index) {
        final evo = evoluciones[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evo['fecha'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(evo['notas'] ?? "Sin notas"),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String? value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(value ?? "Ninguno detectado",
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInfo(String title, String? content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content ?? "Sin registros"),
          )
        ],
      ),
    );
  }
}
