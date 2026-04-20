import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/psychologist_repository.dart';
import '../../psychologist/screens/edit-profile.dart';
import '../../../shared/widgets/change_password_screen.dart';

class PsychologistProfileScreen extends StatefulWidget {
  const PsychologistProfileScreen({super.key});

  @override
  State<PsychologistProfileScreen> createState() => _PsychologistProfileScreenState();
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

  // Lógica para seleccionar imagen
  Future<void> _changePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      
      // Enviamos el archivo al servidor
      final success = await _repo.updateProfileWithImage(
        {}, // No enviamos textos aquí, solo la foto
        File(pickedFile.path)
      );

      if (success) {
        await _loadProfile(); // Recarga los datos y la URL de la imagen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto actualizada correctamente")),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir la foto")),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () { Navigator.pop(context); _changePhoto(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () { Navigator.pop(context); _changePhoto(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
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
            child: Stack(
              children: [
                Avatar(
                  name: name,
                  size: 'large',
                  imageUrl: _profileData?['foto_perfil'],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(especialidad, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 40),
          _buildOption(Icons.person_outline, "Información Personal", onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            _loadProfile(); // Recargar al volver
          }),
          _buildOption(Icons.lock_outline, "Seguridad y Privacidad", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()));
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(title: "Cerrar Sesión", variant: 'outline', onPress: _logout),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}