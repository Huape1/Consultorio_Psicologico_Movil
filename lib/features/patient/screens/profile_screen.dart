import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../shared/widgets/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PacienteRepository _repository = PacienteRepository();
  bool _isLoading = true;

  // Datos del perfil
  String fullName = "Cargando...";
  String email = "...";
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Reutilizamos getDashboardData o puedes crear uno específico getPerfil en el repo
    final data = await _repository.getDashboardData();
    if (data != null && mounted) {
      setState(() {
        fullName = data['nombre'] ?? "Usuario";
        // Si tu API de dashboard no envía el email, asegúrate de añadirlo en el view de Django
        email = data['email'] ?? "correo@ejemplo.com";
        fotoUrl =
            data['foto_perfil']; // Asegúrate de mandar esta URL desde Django
        _isLoading = false;
      });
    }
  }

  // Función para llamar por teléfono
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('No se pudo realizar la llamada');
    }
  }

  void _handleLogout() {
    // Aquí deberías limpiar el token (SharedPreferences/SecureStorage)
    // Por ahora, redirigimos al inicio (Login)
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
Future<void> _changePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      final success = await _repository.updateProfileWithImage({}, File(pickedFile.path));
      if (success) _loadProfileData();
      else setState(() => _isLoading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galería'), onTap: () { Navigator.pop(context); _changePhoto(ImageSource.gallery); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Cámara'), onTap: () { Navigator.pop(context); _changePhoto(ImageSource.camera); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Stack(
                children: [
                  Avatar(name: fullName, size: 'large', imageUrl: fotoUrl),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _profileOption(Icons.person_outline, "Datos Personales",
                      onTap: () =>
                          Navigator.pushNamed(context, '/edit-profile')),
                  _profileOption(Icons.security, "Seguridad y Contraseña",
                      onTap:  () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()));
                      }),
                  _profileOption(Icons.help_outline, "Ayuda y Soporte",
                      onTap: () => _makePhoneCall("6648088464")),
                  const SizedBox(height: 20),
                  const Divider(),
                  _profileOption(
                    Icons.logout,
                    "Cerrar Sesión",
                    isDestructive: true,
                    onTap: () => _confirmLogout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title,
      {required VoidCallback onTap, bool isDestructive = false}) {
    Color color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color, size: 20),
      onTap: onTap,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que deseas salir?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: _handleLogout,
              child: const Text("Salir",
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
