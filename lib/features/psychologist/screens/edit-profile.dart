import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/psychologist_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _repo = PsicologoRepository();
  final _presentacionCtrl = TextEditingController();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() async {
    final data = await _repo.getPerfilData();
    if (data != null && mounted) {
      setState(() {
        _userData = data;
        _presentacionCtrl.text = data['presentacion'] ?? "";
        _isLoading = false;
      });
    }
  }

  void _handleUpdate() async {
    setState(() => _isLoading = true);
    final success = await _repo.updateProfile({
      "presentacion": _presentacionCtrl.text,
    });

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Presentación actualizada")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Información Personal", style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyField("Nombre Completo", _userData?['nombre_completo']),
                  _buildReadOnlyField("Género", _userData?['genero']),
                  _buildReadOnlyField("Cédula Profesional", _userData?['cedula']),
                  _buildReadOnlyField("Especialidad", _userData?['especialidad']),
                  const SizedBox(height: 20),
                  const Text("Presentación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _presentacionCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Escribe tu presentación profesional...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(title: "Guardar Cambios", onPress: _handleUpdate),
                ],
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value ?? "No disponible", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}