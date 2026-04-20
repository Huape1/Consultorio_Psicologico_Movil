import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/avatar.dart'; // Importamos el Avatar que ya usamos
import '../../../data/repositories/patient_repository.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final PacienteRepository _repository = PacienteRepository();
  List<dynamic> _allAppointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = true;

  // Controladores para filtros
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadAppointments() async {
    final data = await _repository.getMisCitas();
    if (mounted) {
      setState(() {
        _allAppointments = data;
        _filteredAppointments = data;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAppointments = _allAppointments.where((apt) {
        final query = _searchController.text.toLowerCase();
        final nombrePsicologo = apt['psicologo'].toString().toLowerCase();
        
        bool matchesName = nombrePsicologo.contains(query);
        bool matchesDate = true;

        if (_selectedDate != null) {
          // Asumiendo que apt['fecha'] viene como "DD/MM/YYYY"
          String fechaSeleccionada = DateFormat('dd/MM/yyyy').format(_selectedDate!);
          matchesDate = apt['fecha'] == fechaSeleccionada;
        }

        return matchesName && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear(); // Borra el texto del buscador
      _selectedDate = null;      // Borra la fecha seleccionada
      _filteredAppointments = List.from(_allAppointments); // Restaura la lista original
    });
    // Cerramos el teclado si está abierto
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Mis Citas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110), // Aumentamos espacio para el buscador
            child: Column(
              children: [
                _buildSearchBar(),
                const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Próximas'),
                    Tab(text: 'Historial'),
                    Tab(text: 'Canceladas'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(_filteredAppointments.where((apt) => apt['estado'] == 'Pendiente' || apt['estado'] == 'Confirmada').toList()),
            _buildAppointmentList(_filteredAppointments.where((apt) => apt['estado'] == 'Atendida' || apt['estado'] == 'Atendido').toList()),
            _buildAppointmentList(_filteredAppointments.where((apt) => apt['estado'] == 'Cancelada').toList()),
          ],
        ),
      ),
    );
  }

    Widget _buildSearchBar() {
    bool hasFilters = _searchController.text.isNotEmpty || _selectedDate != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilters(), // Filtra mientras escribes
                    decoration: InputDecoration(
                      hintText: "Buscar psicólogo...",
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Botón de Calendario
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedDate != null ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: _selectedDate != null ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          // BOTÓN DE RESETEAR (Solo aparece si hay filtros)
          if (hasFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: _clearFilters,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text(
                      "Mostrar todas las citas",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List appointments) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (appointments.isEmpty) {
      return const Center(child: Text("Sin resultados", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${apt['fecha']} - ${apt['hora']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      StatusBadge(status: apt['estado']),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Avatar(
                      name: apt['psicologo'],
                      imageUrl: apt['psicologo_foto'],
                      size: 'small',
                    ),
                    title: Text(apt['psicologo'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(apt['servicio']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}