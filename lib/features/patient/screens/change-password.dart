import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nueva Contraseña",
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingresa la contraseña";
                  // Aquí quitamos la validación de 6 caracteres como pediste
                  return null; 
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                title: "Actualizar Contraseña",
                onPress: () {
                  if (_formKey.currentState!.validate()) {
                    // Lógica para llamar a tu API de cambio de contraseña
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}