import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/api/api_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _apiService.getRequest('/admin/list-admins/');
      setState(() {
        _admins = data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar administradores: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAdminDialog([dynamic admin]) {
    final bool isEditing = admin != null;
    final formKey = GlobalKey<FormState>();

    String nombre = isEditing ? (admin['nombre'] ?? '') : '';
    String apellido1 = isEditing ? (admin['apellido1'] ?? '') : '';
    String apellido2 = isEditing ? (admin['apellido2'] ?? '') : '';
    String email = isEditing ? (admin['email'] ?? '') : '';
    String telefono = isEditing ? (admin['phone'] ?? '') : '';
    String genero = isEditing ? (admin['genero'] ?? 'Masculino') : 'Masculino';
    String status = isEditing ? (admin['status'] ?? 'Activo') : 'Activo';
    String password = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Editar Administrador" : "Nuevo Administrador"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nombre,
                  decoration: const InputDecoration(labelText: "Nombre(s)"),
                  onSaved: (val) => nombre = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                TextFormField(
                  initialValue: apellido1,
                  decoration:
                      const InputDecoration(labelText: "Primer Apellido"),
                  onSaved: (val) => apellido1 = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                TextFormField(
                  initialValue: apellido2,
                  decoration:
                      const InputDecoration(labelText: "Segundo Apellido"),
                  onSaved: (val) => apellido2 = val!,
                ),
                TextFormField(
                  initialValue: email,
                  decoration:
                      const InputDecoration(labelText: "Correo Electrónico"),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val!,
                  validator: (val) =>
                      !val!.contains('@') ? "Email inválido" : null,
                ),
                TextFormField(
                  initialValue: telefono,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => telefono = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                if (!isEditing)
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Contraseña"),
                    obscureText: true,
                    onSaved: (val) => password = val!,
                    validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                  ),
                DropdownButtonFormField<String>(
                  value: ["Masculino", "Femenino", "Otro"].contains(genero)
                      ? genero
                      : "Otro",
                  items: ["Masculino", "Femenino", "Otro"]
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => genero = val!,
                  decoration: const InputDecoration(labelText: "Género"),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ["Activo", "Inactivo"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => status = val!,
                  decoration: const InputDecoration(labelText: "Estado"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                String url = isEditing
                    ? '/admin/manage-admin/${admin['id']}/'
                    : '/admin/manage-admin/0/';

                await _apiService.postRequest(url, {
                  "nombre": nombre,
                  "apellido1": apellido1,
                  "apellido2": apellido2,
                  "email": email,
                  "telefono": telefono,
                  "genero": genero,
                  "status": status,
                  "password": password,
                });

                Navigator.pop(context);
                _fetchAdmins();
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Equipo Administrativo")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAdmins,
              child: _admins.isEmpty
                  ? const Center(child: Text("No hay datos"))
                  : ListView.builder(
                      itemCount: _admins.length,
                      itemBuilder: (context, index) {
                        final admin = _admins[index];
                        // Validamos nombre para evitar el RangeError
                        final String firstLetter = (admin['nombre'] != null &&
                                admin['nombre'].toString().isNotEmpty)
                            ? admin['nombre'][0].toUpperCase()
                            : '?';

                        return ListTile(
                          leading: CircleAvatar(
                            radius:
                                20, // Tamaño fijo para evitar el error de ancho
                            child: Text(firstLetter),
                          ),
                          title: Text(admin['fullName'] ?? "Sin nombre"),
                          subtitle: Text(admin['email'] ?? ""),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_admins", // <--- CORRIGE EL ERROR DE HERO
        onPressed: () => _showAdminDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
