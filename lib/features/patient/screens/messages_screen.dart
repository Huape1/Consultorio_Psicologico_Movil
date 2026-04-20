import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/api/api_service.dart';
import '../../../shared/widgets/avatar.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService _apiService = ApiService();
  String searchQuery = "";
  List<dynamic> _contactos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContactos();
  }

  // Carga los psicólogos con los que el paciente tiene relación (citas)
  Future<void> _fetchContactos() async {
    try {
      setState(() => _isLoading = true);
      // Endpoint que definimos en pacientes_movil.py
      final data = await _apiService.getRequest('/paciente/contactos/');
      if (data != null && data is List) {
        setState(() {
          _contactos = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error cargando contactos: $e");
      setState(() => _isLoading = false);
    }
  }

  // Filtra la lista según la búsqueda del usuario
  List<dynamic> get _filteredContactos {
    if (searchQuery.isEmpty) return _contactos;
    return _contactos.where((c) {
      final name = c['nombre'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: AppColors.textPrimary, 
            fontWeight: FontWeight.bold
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchContactos,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchContactos(), // <--- ESTA ES LA LÍNEA CLAVE
                    child: ListView(
                      // physics permite que el scroll funcione aunque haya pocos elementos
                      physics: const AlwaysScrollableScrollPhysics(), 
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildSupportTile(),
                        const SizedBox(height: 20),
                        const Text(
                          "Tus Psicólogos",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_filteredContactos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text("No se encontraron contactos.")),
                          )
                        else
                          ..._filteredContactos.map((contacto) => 
                            _buildChatItem(
                              contacto['id'], 
                              contacto['nombre'], 
                              contacto['ultimo_msg'] ?? "Toca para chatear"
                            )
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "Buscar psicólogo...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSupportTile() {
    return _buildCardWrapper(
      child: ListTile(
        onTap: () => _navigateToChat(0, "Soporte Técnico"), // ID 0 para todos los admins
        leading: const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.support_agent, color: Colors.white),
        ),
        title: const Text(
          "Soporte Técnico", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: const Text("Atención directa con administración"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildChatItem(int id, String nombre, String ultimoMsg) {
    return _buildCardWrapper(
      child: ListTile(
        onTap: () => _navigateToChat(id, nombre),
        leading: Avatar(name: nombre, size: 'medium'),
        title: Text(
          nombre, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Text(
          ultimoMsg, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis
        ),
        trailing: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: child,
    );
  }

  void _navigateToChat(int id, String nombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(receptorId: id, nombre: nombre)
      ),
    );
  }
}