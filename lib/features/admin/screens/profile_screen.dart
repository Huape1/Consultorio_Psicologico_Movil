import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/change_password_screen.dart';
import '../../../core/api/api_service.dart';
import '../../../data/repositories/admin_repository.dart';
import '../screens/edit_admin_profile_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ApiService _apiService = ApiService();
  final AdminRepository _repository = AdminRepository();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _apiService.getRequest('/auth/profile/');
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar perfil: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE FOTO (TU CÓDIGO RECUPERADO) ---

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _changePhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _changePhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source, 
      imageQuality: 50
    );

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      // Usamos el repositorio de Admin para subir la foto
      final success = await _repository.updateProfile(
        fields: {}, // No enviamos textos, solo la foto
        imageFile: File(pickedFile.path),
      );
      
      if (success) {
        _fetchProfile(); // Recargamos para ver la nueva foto
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al subir la foto"))
          );
        }
      }
    }
  }

  // --- NAVEGACIÓN Y CIERRE DE SESIÓN ---

  void _goToEditProfile() async {
    if (_userData == null) return;

    // Mapeo preventivo para que EditAdminProfileScreen no reciba nulos inesperados
    final Map<String, dynamic> mappedData = {
      'nombre': _userData!['nombre'] ?? _userData!['full_name']?.split(' ')[0] ?? '',
      'apellido1': _userData!['apellido1'] ?? '',
      'apellido2': _userData!['apellido2'] ?? '',
      'email': _userData!['email'] ?? '',
      'phone': _userData!['phone'] ?? '',
      'genero': _userData!['genero'] ?? 'M', // Valor por defecto seguro
      'photo': _userData!['photo'],
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditAdminProfileScreen(userData: mappedData)),
    );
    if (result == true) _fetchProfile();
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary))
      );
    }

    final String name = _userData?['full_name'] ?? "Administrador";
    final String email = _userData?['email'] ?? "sin-correo@fym.com";
    final String? photoUrl = _userData?['photo'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // AVATAR CON TU STACK DE CÁMARA
              Center(
                child: Stack(
                  children: [
                    Avatar(name: name, imageUrl: photoUrl, size: 'xlarge'),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showPickerOptions, // Tu función de opciones
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary, 
                            shape: BoxShape.circle
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
              Text(email, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              CustomCard(
                child: Column(
                  children: [
                    _buildOption(Icons.person_outline, "Información Personal", _goToEditProfile),
                    const Divider(),
                    _buildOption(Icons.security, "Seguridad y Contraseña", () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Cerrar Sesión",
                variant: 'outline',
                onPress: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que deseas salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: _handleLogout, 
            child: const Text("Salir", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}