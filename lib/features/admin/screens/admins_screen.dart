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
  List<dynamic> _allAdmins = []; // Lista original
  List<dynamic> _filteredAdmins = []; // Lista para la búsqueda
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredAdmins = _allAdmins.where((admin) {
        final name = admin['fullName'].toString().toLowerCase();
        final email = admin['email'].toString().toLowerCase();
        final query = _searchController.text.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getRequest('/admin/list-admins/');
      setState(() {
        _allAdmins = data ?? [];
        _filteredAdmins = _allAdmins;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Equipo Administrativo"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre o correo...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchAdmins,
                    child: _filteredAdmins.isEmpty
                        ? const Center(child: Text("No se encontraron resultados"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredAdmins.length,
                            itemBuilder: (context, index) {
                              final admin = _filteredAdmins[index];
                              return _buildAdminCard(admin);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_admins",
        backgroundColor: AppColors.primary,
        onPressed: () => _showAdminDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAdminCard(dynamic admin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: admin['photo'] != null 
              ? NetworkImage(admin['photo']) 
              : null,
          child: admin['photo'] == null
              ? Text(
                  admin['nombre'][0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              : null,
        ),
        title: Text(
          admin['fullName'] ?? "Sin nombre",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(admin['email'] ?? "", style: const TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(admin['phone'] ?? "Sin teléfono", style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            // Reutilizamos tu StatusBadge
            StatusBadge(status: admin['status'] ?? 'Inactivo'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          onPressed: () => _showAdminDialog(admin),
        ),
      ),
    );
  }

  // --- El diálogo _showAdminDialog se mantiene casi igual, 
  // --- pero asegúrate de que use las llaves correctas ('phone' en lugar de 'telefono' si es necesario)
  void _showAdminDialog([dynamic admin]) {
    final bool isEditing = admin != null;
    final formKey = GlobalKey<FormState>();

    // Inicialización de variables (Mantenemos tu lógica de mapeo)
    String nombre = isEditing ? (admin['nombre'] ?? '') : '';
    String apellido1 = isEditing ? (admin['apellido1'] ?? '') : '';
    String apellido2 = isEditing ? (admin['apellido2'] ?? '') : '';
    String email = isEditing ? (admin['email'] ?? '') : '';
    String telefono = isEditing ? (admin['phone'] ?? '') : '';
    String genero = isEditing ? (admin['genero'] ?? 'M') : 'M';
    String status = isEditing ? (admin['status'] ?? 'Activo') : 'Activo';
    String password = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? "Editar Administrador" : "Nuevo Administrador"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nombre,
                  decoration: const InputDecoration(labelText: "Nombre(s)", prefixIcon: Icon(Icons.person)),
                  onSaved: (val) => nombre = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: apellido1,
                  decoration: const InputDecoration(labelText: "Primer Apellido"),
                  onSaved: (val) => apellido1 = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: "Correo", prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val!,
                  validator: (val) => !val!.contains('@') ? "Email inválido" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: telefono,
                  decoration: const InputDecoration(labelText: "Teléfono", prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => telefono = val!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['M', 'F', 'O'].contains(genero) ? genero : 'M',
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text("Masculino")),
                    DropdownMenuItem(value: 'F', child: Text("Femenino")),
                    DropdownMenuItem(value: 'O', child: Text("Otro")),
                  ],
                  onChanged: (val) => genero = val!,
                  decoration: const InputDecoration(labelText: "Género", prefixIcon: Icon(Icons.wc)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final url = isEditing ? '/admin/manage-admin/${admin['id']}/' : '/admin/manage-admin/0/';
                
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
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}