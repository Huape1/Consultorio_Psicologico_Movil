import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/patient_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _telCtrl = TextEditingController();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  final PacienteRepository _repo = PacienteRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _repo.getPerfilCompleto();
    if (data != null && mounted) {
      setState(() {
        _data = data;
        _telCtrl.text = data['telefono'] ?? "";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Datos Personales")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _readOnlyField("Nombre", "${_data?['nombre']} ${_data?['apellido']} ${_data?['segundo_apellido']}"),
                _readOnlyField("Género", _data?['genero']),
                _readOnlyField("Correo", _data?['email']),
                _readOnlyField("Fecha de Cumpleaños", _data?['fecha_nacimiento']),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                TextField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Teléfono (Editable)",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  title: "Guardar Teléfono",
                  onPress: () async {
                    setState(() => _isLoading = true);
                    final success = await _repo.updateProfile({"telefono": _telCtrl.text});
                    if (success) Navigator.pop(context);
                    else setState(() => _isLoading = false);
                  },
                )
              ],
            ),
          ),
    );
  }

  Widget _readOnlyField(String label, String? value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value ?? "No disponible", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}