import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../data/repositories/psychologist_repository.dart';
import '../../../features/psychologist/screens/patient_record_screen.dart';

class PatientsScreen extends StatefulWidget {
  // Quitamos pacienteId, nombre e imageUrl de aquí porque esta es la LISTA GENERAL
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PsicologoRepository _repo = PsicologoRepository();
  List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final data = await _repo.getMisPacientes();
    if (mounted) {
      setState(() {
        _allPatients = data;
        _filteredPatients = data;
        _isLoading = false;
      });
    }
  }

  void _filterPatients(String v) {
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final name = p['nombre_completo'].toString().toLowerCase();
        return name.contains(v.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                      ? const Center(child: Text("No se encontraron pacientes"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: _filteredPatients.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildPatientItem(_filteredPatients[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Pacientes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: _fetchPatients, icon: const Icon(Icons.refresh)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _filterPatients,
        decoration: InputDecoration(
          hintText: "Buscar paciente...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildPatientItem(dynamic p) {
    // IMPORTANTE: Estos nombres deben coincidir con tu JSON de Django
    final String fullName = p['nombre_completo'] ?? "Sin nombre";
    final String email = p['correo'] ?? "Sin correo";
    final String phone = p['telefono'] ?? "Sin teléfono";
    String? photoUrl = p['foto_perfil'];

    // Lógica de URL base
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = "http://192.168.1.26:8000$photoUrl";
    }

    return CustomCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientRecordScreen(
                pacienteId: p['id'],
                nombre: fullName,
                imageUrl: photoUrl,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Avatar(name: fullName, imageUrl: photoUrl, size: 'medium'),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    _buildIconText(Icons.email_outlined, email),
                    _buildIconText(Icons.phone_outlined, phone),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
