// psychologist_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/api/api_service.dart'; // Importa tu servicio

class PsychologistsManagementScreen extends StatefulWidget {
  const PsychologistsManagementScreen({super.key});

  @override
  State<PsychologistsManagementScreen> createState() =>
      _PsychologistsManagementScreenState();
}

class _PsychologistsManagementScreenState
    extends State<PsychologistsManagementScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _psychologists = [];
  List<dynamic> _specialties = []; // Nueva lista para especialidades
  bool _isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Cargamos ambas cosas al iniciar
  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchPsychologists(),
      _fetchSpecialties(),
    ]);
  }

  Future<void> _fetchSpecialties() async {
    try {
      // Asumiendo que crearas este endpoint en Django
      final data = await _apiService.getRequest('/admin/specialties/');
      setState(() => _specialties = data);
    } catch (e) {
      debugPrint("Error cargando especialidades: $e");
    }
  }

  Future<void> _fetchPsychologists() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getRequest('/admin/psychologists/');
      setState(() {
        _psychologists = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

void _showAddPsychologistDialog() {
    final _formKey = GlobalKey<FormState>();
    // Nuevas variables para password y teléfono
    String nombre = '',
        apellido1 = '',
        apellido2 = '',
        email = '',
        cedula = '',
        genero = 'Otro',
        password = '',
        telefono = '';

    int? especialidadId =
        _specialties.isNotEmpty ? _specialties[0]['clave'] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Psicólogo"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Nombre(s)"),
                  onSaved: (val) => nombre = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Primer Apellido"),
                  onSaved: (val) => apellido1 = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Segundo Apellido"),
                  onSaved: (val) => apellido2 = val!,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Correo Electrónico"),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val!,
                  validator: (val) =>
                      !val!.contains("@") ? "Email inválido" : null,
                ),
                // CAMPO DE TELÉFONO
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Teléfono de Contacto"),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => telefono = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                // CAMPO DE CONTRASEÑA
                TextFormField(
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  obscureText: true, // Ocultar texto
                  onSaved: (val) => password = val!,
                  validator: (val) =>
                      val!.length < 6 ? "Mínimo 6 caracteres" : null,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Cédula Profesional"),
                  onSaved: (val) => cedula = val!,
                  validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                ),
                DropdownButtonFormField<int>(
                  value: especialidadId,
                  decoration: const InputDecoration(labelText: "Especialidad"),
                  items: _specialties
                      .map((s) => DropdownMenuItem<int>(
                            value: s['clave'],
                            child: Text(s['nombre']),
                          ))
                      .toList(),
                  onChanged: (val) => especialidadId = val,
                ),
                DropdownButtonFormField<String>(
                  value: genero,
                  items: ["Masculino", "Femenino", "Otro"]
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => genero = val!,
                  decoration: const InputDecoration(labelText: "Género"),
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                await _apiService.postRequest('/admin/psychologists/create/', {
                  "nombre": nombre,
                  "apellido1": apellido1,
                  "apellido2": apellido2,
                  "email": email,
                  "password": password, // Enviamos contraseña
                  "telefono": telefono, // Enviamos teléfono
                  "cedula": cedula,
                  "genero": genero,
                  "especialidad_id": especialidadId,
                });

                Navigator.pop(context);
                _fetchPsychologists();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Psicólogo registrado correctamente")),
                );
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPsychologistDialog(dynamic psy) {
    final _formKey = GlobalKey<FormState>();

    // Pre-rellenamos las variables con los datos que ya tenemos
    // Nota: Asegúrate que los nombres coincidan con los que envía tu GET inicial
    String nombre = psy['fullName'].split(' ')[0];
    String apellido1 = psy['fullName'].split(' ').length > 1
        ? psy['fullName'].split(' ')[1]
        : '';
    String apellido2 =
        ''; // Podrías manejar mejor el split o enviarlo separado desde Django
    String email = psy['email'] ?? '';
    String telefono = psy['phone'] ?? '';
    String cedula = psy['license'] ?? '';
    String genero = 'Masculino'; // O el valor que traiga de la DB
    String password = ''; // Se deja vacío a menos que se quiera cambiar
    int? especialidadId = _specialties.firstWhere(
        (s) => s['nombre'] == psy['specialty'],
        orElse: () => _specialties[0])['clave'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar: ${psy['fullName']}"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nombre,
                  decoration: const InputDecoration(labelText: "Nombre(s)"),
                  onSaved: (val) => nombre = val!,
                ),
                TextFormField(
                  initialValue: apellido1,
                  decoration:
                      const InputDecoration(labelText: "Primer Apellido"),
                  onSaved: (val) => apellido1 = val!,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: "Correo"),
                  onSaved: (val) => email = val!,
                ),
                TextFormField(
                  initialValue: telefono,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  onSaved: (val) => telefono = val!,
                ),
                TextFormField(
                  initialValue: cedula,
                  decoration: const InputDecoration(labelText: "Cédula"),
                  onSaved: (val) => cedula = val!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText:
                          "Nueva Contraseña (dejar vacío para no cambiar)",
                      hintText: "******"),
                  obscureText: true,
                  onSaved: (val) => password = val!,
                ),
                DropdownButtonFormField<int>(
                  value: especialidadId,
                  items: _specialties
                      .map((s) => DropdownMenuItem<int>(
                          value: s['clave'], child: Text(s['nombre'])))
                      .toList(),
                  onChanged: (val) => especialidadId = val,
                  decoration: const InputDecoration(labelText: "Especialidad"),
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Enviamos el ID en la URL
                await _apiService
                    .postRequest('/admin/psychologists/update/${psy['id']}/', {
                  "nombre": nombre,
                  "apellido1": apellido1,
                  "apellido2": apellido2,
                  "email": email,
                  "telefono": telefono,
                  "cedula": cedula,
                  "password": password,
                  "genero": genero,
                  "especialidad_id": especialidadId,
                });

                Navigator.pop(context);
                _fetchPsychologists(); // Refrescar lista
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  // Cargar datos desde Django

  @override
  Widget build(BuildContext context) {
    // Filtrado en tiempo real
    final filteredPsychologists = _psychologists.where((psy) {
      final query = searchQuery.toLowerCase();
      final name = (psy["fullName"] ?? "").toLowerCase();
      final specialty = (psy["specialty"] ?? "").toLowerCase();
      return name.contains(query) || specialty.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _fetchPsychologists,
                    child: filteredPsychologists.isEmpty
                        ? const Center(child: Text("No se encontraron psicólogos"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredPsychologists.length,
                            itemBuilder: (context, index) =>
                                _buildPsychologistCard(filteredPsychologists[index]),
                          ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Tus métodos _buildHeader y _buildSearchBar se quedan igual) ...

Widget _buildPsychologistCard(dynamic psy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: InkWell(
          onTap: () => _showEditPsychologistDialog(psy),
          child: Column(
            children: [
              Row(
                children: [
                  // Cambiamos o envolvemos el Avatar
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: psy["photo"] != null
                        ? NetworkImage(psy["photo"])
                        : null,
                    child: psy["photo"] == null
                        ? Text(psy["fullName"][0],
                            style: const TextStyle(color: AppColors.primary))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(psy["fullName"] ?? "Sin nombre",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(psy["specialty"] ?? "General",
                            style: const TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLight)
                ],
              ),
              // ... resto de tu código (Divider y Rows de email/license)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Buscar psicólogo...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: () {
              // Aquí abrirías un formulario en blanco
              _showAddPsychologistDialog();
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Gestión",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Psicólogos", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
