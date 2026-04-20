import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/api/api_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    print("Intentando obtener horarios..."); // LOG DE CONTROL
    setState(() => _isLoading = true);

    try {
      // 1. Verifica que esta URL sea EXACTAMENTE la que tienes en urls.py de Django
      final data = await _apiService.getRequest('/admin/schedules/');

      print("Datos recibidos de Django: $data"); // MIRA TU CONSOLA DE DEBUG

      setState(() {
        _schedules = data;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR AL CARGAR HORARIOS: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showScheduleDialog([dynamic schedule]) {
    final bool isEditing = schedule != null;
    final formKey = GlobalKey<FormState>();

    final List<String> todosLosDias = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sabado",
      "Domingo"
    ];

    // INICIALIZACIÓN LIMPIA
    List<String> diasSeleccionados = [];

    if (isEditing &&
        schedule['days'] != null &&
        schedule['days'].toString().isNotEmpty) {
      // Usamos trim() y where para eliminar cualquier rastro de elementos vacíos o "fantasmas"
      diasSeleccionados = schedule['days']
          .toString()
          .split(',')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty && todosLosDias.contains(d))
          .toList();
    }

    String name = isEditing ? schedule['name'] : '';
    String hours = isEditing ? schedule['hours'] : '';
    String status = isEditing ? schedule['status'] : 'Activo';

    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar por error
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Editar Horario" : "Nuevo Horario"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration:
                        const InputDecoration(labelText: "Nombre del Turno"),
                    onSaved: (val) => name = val!,
                    validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("Días seleccionados:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: todosLosDias.map((dia) {
                      // Verificación exacta
                      final bool estaSeleccionado =
                          diasSeleccionados.contains(dia);

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (estaSeleccionado) {
                              diasSeleccionados.remove(dia);
                            } else {
                              diasSeleccionados.add(dia);
                            }
                          });
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: estaSeleccionado
                                ? AppColors.primary
                                : Colors.grey[200],
                            border: Border.all(
                              color: estaSeleccionado
                                  ? AppColors.primary
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dia.substring(0, 1),
                            style: TextStyle(
                              color: estaSeleccionado
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: hours,
                    decoration: const InputDecoration(
                        labelText: "Horas (Ej: 08:00 - 14:00)"),
                    onSaved: (val) => hours = val!,
                    validator: (val) => val!.isEmpty ? "Obligatorio" : null,
                  ),
                  // ... (Dropdown de status)
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar")),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                // VALIDACIÓN DE DÍAS
                if (diasSeleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Error: Selecciona al menos un día")),
                  );
                  return;
                }

                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  // ORDENAR LOS DÍAS antes de enviar (para que no queden desordenados)
                  diasSeleccionados.sort((a, b) => todosLosDias
                      .indexOf(a)
                      .compareTo(todosLosDias.indexOf(b)));

                  // UNIÓN LIMPIA
                  String diasParaDB = diasSeleccionados.join(', ');

                  String url = isEditing
                      ? '/admin/schedules/manage/${schedule['id']}/'
                      : '/admin/schedules/manage/';

                  await _apiService.postRequest(url, {
                    "name": name,
                    "days": diasParaDB,
                    "hours": hours,
                    "status": status,
                    "icon": "sun"
                  });

                  Navigator.pop(context);
                  _fetchSchedules();
                }
              },
              child:
                  const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Gestión de Horarios"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSchedules,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  // Verificación de seguridad para el índice
                  if (index >= _schedules.length)
                    return const SizedBox.shrink();

                  final item = _schedules[index];

                  // Verificación de nulidad para evitar el RangeError
                  final String name = item["name"]?.toString() ?? "Sin nombre";
                  final String days =
                      item["days"]?.toString() ?? "No especificado";
                  final String hours = item["hours"]?.toString() ?? "--:--";
                  final String status = item["status"]?.toString() ?? "Activo";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      child: InkWell(
                        onTap: () => _showScheduleDialog(item),
                        child: Padding(
                          // Agregamos un padding interno por si el CustomCard no lo tiene
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Evita que la columna intente ocupar infinito
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Usamos Flexible para que el texto no empuje el badge fuera de la pantalla
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: status),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                "Días: $days",
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text("Horario: $hours"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn_schedules_screen",
        backgroundColor: AppColors.primary,
        onPressed: () => _showScheduleDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
