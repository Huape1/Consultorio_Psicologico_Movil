import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/admin_repository.dart';

class EditAdminProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditAdminProfileScreen({super.key, required this.userData});

  @override
  State<EditAdminProfileScreen> createState() => _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState extends State<EditAdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminRepository _repository = AdminRepository();
  
  late TextEditingController _nameCtrl, _ap1Ctrl, _ap2Ctrl, _emailCtrl, _phoneCtrl;
  String? _selectedGenero;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userData['nombre']);
    _ap1Ctrl = TextEditingController(text: widget.userData['apellido1']);
    _ap2Ctrl = TextEditingController(text: widget.userData['apellido2']);
    _emailCtrl = TextEditingController(text: widget.userData['email']);
    _phoneCtrl = TextEditingController(text: widget.userData['phone']);
    
    // VALIDACIÓN AQUÍ:
    // Si el género no es M, F o O, lo ponemos como null para que no rompa
    final genre = widget.userData['genero'];
_selectedGenero = (genre == 'M' || genre == 'F' || genre == 'O') ? genre : null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final fields = {
      'nombre': _nameCtrl.text,
      'apellido1': _ap1Ctrl.text,
      'apellido2': _ap2Ctrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text,
      'genero': _selectedGenero ?? '',
    };

    bool success = await _repository.updateProfile(fields: fields, imageFile: _imageFile);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Información Personal"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Quitamos el _buildPhotoPicker de aquí
              const SizedBox(height: 10),
              _buildTextField("Nombre", _nameCtrl, Icons.person),
              _buildTextField("Primer Apellido", _ap1Ctrl, Icons.person_outline),
              _buildTextField("Segundo Apellido", _ap2Ctrl, Icons.person_outline),
              _buildTextField("Correo", _emailCtrl, Icons.email, isEmail: true),
              _buildTextField("Teléfono", _phoneCtrl, Icons.phone),
              _buildDropdownGenero(),
              const SizedBox(height: 40),
              CustomButton(
                title: _isSaving ? "Guardando..." : "Guardar Cambios",
                onPress: _isSaving ? () {} : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: _imageFile != null 
                ? FileImage(_imageFile!) 
                : (widget.userData['photo'] != null ? NetworkImage(widget.userData['photo']) : null) as ImageProvider?,
            child: (_imageFile == null && widget.userData['photo'] == null) 
                ? const Icon(Icons.person, size: 60, color: AppColors.primary) 
                : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildDropdownGenero() {
    return DropdownButtonFormField<String>(
      value: _selectedGenero,
      hint: const Text("Seleccione género"),
      decoration: InputDecoration(
        labelText: "Género",
        prefixIcon: const Icon(Icons.wc, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text("Masculino")),
        DropdownMenuItem(value: 'F', child: Text("Femenino")),
        DropdownMenuItem(value: 'O', child: Text("Otro")),
      ],
      onChanged: (val) => setState(() => _selectedGenero = val),
    );
  }
}