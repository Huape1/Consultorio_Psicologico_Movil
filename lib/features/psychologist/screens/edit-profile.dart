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
  final _formKey = GlobalKey<FormState>();
  final _repo = PsicologoRepository();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

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
        // Usamos las llaves simples que definimos en la vista corregida
        _nombreCtrl.text = data['nombre'] ?? "";
        _apellidoCtrl.text = data['apellido'] ?? "";
        _emailCtrl.text = data['email'] ?? "";
        _telCtrl.text = data['telefono'] ?? "";
        _isLoading = false;
      });
    }
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // CORRECCIÓN: Se agregó .updateProfile y se usan llaves que coinciden con el backend
      final success = await _repo.updateProfile({
        "nombre": _nombreCtrl.text,
        "apellido": _apellidoCtrl.text,
        "email": _emailCtrl.text,
        "telefono": _telCtrl.text,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Perfil actualizado correctamente")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error al actualizar el perfil")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Editar Perfil",
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        "Nombre", _nombreCtrl, Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(
                        "Apellido", _apellidoCtrl, Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(
                        "Correo Electrónico", _emailCtrl, Icons.email_outlined,
                        isEmail: true),
                    const SizedBox(height: 16),
                    _buildTextField(
                        "Teléfono", _telCtrl, Icons.phone_android_outlined,
                        isPhone: true),
                    const SizedBox(height: 32),
                    CustomButton(
                      title: "Guardar Cambios",
                      onPress: _handleUpdate,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "Este campo es obligatorio" : null,
    );
  }
}
