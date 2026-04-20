import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/repositories/psychologist_repository.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

// ... tus imports se mantienen igual

class _AgendaScreenState extends State<AgendaScreen> {
  final PsicologoRepository _repo = PsicologoRepository();
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    // Generamos la semana inicial basada en hoy
    _generateWeek(_selectedDate);
    _fetchAgenda();
  }

  // Nueva función para generar los 7 días de la semana según la fecha elegida
  void _generateWeek(DateTime baseDate) {
    // Calculamos el lunes de esa semana (opcional, aquí empezamos desde el día elegido)
    // Para que siempre empiece en el día seleccionado y muestre los 6 siguientes:
    setState(() {
      _weekDays =
          List.generate(7, (index) => baseDate.add(Duration(days: index)));
    });
  }

  // Función para abrir el calendario de Flutter
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale(
          'es', 'ES'), // Asegúrate de tener configurado el soporte de idiomas
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Color del encabezado
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _generateWeek(picked); // Actualizamos la tira de la semana
      _fetchAgenda(); // Cargamos las citas del nuevo día
    }
  }

  Future<void> _fetchAgenda() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final data = await _repo.getAgendaPorFecha(dateStr);

    if (mounted) {
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekStrip(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? const Center(child: Text("No hay citas programadas"))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _appointments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) =>
                              _buildAgendaItem(_appointments[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Mi Agenda",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                DateFormat('MMMM, yyyy', 'es').format(_selectedDate),
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              // Botón del calendario
              IconButton(
                onPressed: () => _selectDate(context),
                icon:
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                tooltip: "Seleccionar fecha",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final date = _weekDays[index];
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _fetchAgenda();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE', 'es').format(date).toUpperCase(),
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(date.day.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgendaItem(dynamic apt) {
    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(apt['hora'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                  width: 2,
                  height: 40,
                  color: AppColors.primary.withOpacity(0.2)),
              const SizedBox(height: 4),
              Text(apt['duracion'] ?? "45 min",
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(apt['tipo'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    StatusBadge(status: apt['status'], isSmall: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Avatar(name: apt['paciente_nombre'], size: 'small'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(apt['paciente_nombre'],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(apt['modalidad'],
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
