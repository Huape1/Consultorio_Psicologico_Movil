import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/api/api_service.dart'; // <--- Importante: Importa tu ApiService

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  
  // SOLUCIÓN AL ERROR: Definimos e inicializamos el servicio
  final ApiService _apiService = ApiService(); 
  
  bool _isLoading = false;

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // SOLUCIÓN: Usamos el servicio que acabamos de definir arriba
      final success = await _apiService.updatePassword(_passCtrl.text);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contraseña actualizada con éxito"))
          );
          Navigator.pop(context); // Regresa al perfil
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al actualizar la contraseña"))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Seguridad", style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_outline, size: 60, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                "Nueva Contraseña", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Ingresa tu nueva clave",
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? "Campo requerido" : null,
              ),
              const SizedBox(height: 40),
              _isLoading 
                ? const CircularProgressIndicator()
                : CustomButton(title: "Guardar Cambios", onPress: _handleUpdate),
            ],
          ),
        ),
      ),
    );
  }
}