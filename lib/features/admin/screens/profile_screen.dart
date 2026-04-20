import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // --- LÓGICA DE BACKEND ---

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

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      // Endpoint sugerido para actualizar datos
      await _apiService.postRequest('/auth/profile/update/', data);
      await _fetchProfile(); // Recargamos datos frescos
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado con éxito")),
        );
      }
    } catch (e) {
      debugPrint("Error al actualizar: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    bool confirm = await _showLogoutDialog() ?? false;
    if (!confirm) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
    }
  }

  // --- INTERFAZ DE USUARIO (DIÁLOGOS) ---

  void _showInfoDialog() {
    final nameController = TextEditingController(text: _userData?['full_name']);
    final phoneController = TextEditingController(text: _userData?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Información"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Nombre completo")),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Teléfono")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              _updateProfile({
                'full_name': nameController.text,
                'phone': phoneController.text
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seguridad"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Correo electrónico:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(_userData?['email'] ?? "",
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Nueva Contraseña"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Actualizar")),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que quieres salir?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
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
              Avatar(name: name, imageUrl: photoUrl, size: 'xlarge'),
              const SizedBox(height: 16),
              Text(name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(email,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              CustomCard(
                child: Column(
                  children: [
                    _buildOption(Icons.person_outline, "Información Personal",
                        _showInfoDialog),
                    const Divider(),
                    _buildOption(Icons.security, "Seguridad y Contraseña",
                        _showSecurityDialog),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Cerrar Sesión",
                variant: 'outline',
                onPress: _handleLogout,
              ),
            ],
          ),
        ),
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
