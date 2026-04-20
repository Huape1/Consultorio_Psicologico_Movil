import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/psychologist_repository.dart';

class PsychologistProfileScreen extends StatefulWidget {
  const PsychologistProfileScreen({super.key});

  @override
  State<PsychologistProfileScreen> createState() =>
      _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState extends State<PsychologistProfileScreen> {
  final PsicologoRepository _repo = PsicologoRepository();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _repo.getPerfilData();
    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    // Aquí limpiarías el token (SharedPreferences/SecureStorage)
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = _profileData?['nombre_completo'] ?? "Sin nombre";
    final String especialidad = _profileData?['especialidad'] ?? "Especialista";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Center(
              child: Avatar(
            name: name,
            size: 'large',
            // image: _profileData?['foto_perfil'], // Si tu widget Avatar soporta URL
          )),
          const SizedBox(height: 16),
          Text(name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(especialidad,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              _profileData?['tipo_usuario'] ?? "PSICÓLOGO",
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
          _buildOption(Icons.person_outline, "Información Personal",
              onTap: () => Navigator.pushNamed(context, '/edit-profile')),
          _buildOption(Icons.lock_outline, "Seguridad y Privacidad",
              onTap: () => Navigator.pushNamed(context, '/change-password')),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              title: "Cerrar Sesión",
              variant: 'outline',
              onPress: _logout,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title,
      {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}
