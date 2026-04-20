import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/patient_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final PacienteRepository _repository = PacienteRepository();
  int currentStep = 1;
  bool _isLoading = true;

  // Listas de BD
  List<dynamic> dbPsychologists = [];
  List<dynamic> dbServices = [];

  // Selección del usuario
  Map<String, dynamic>? selectedService;
  String? selectedModality;
  Map<String, dynamic>? selectedSpecialist;
  String? selectedReason;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> reasons = [
    'Ansiedad o estrés',
    'Problemas de pareja',
    'Depresión',
    'Autoestima',
    'Duelo',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final data = await _repository.getSetupAgendar();
    if (data != null && mounted) {
      setState(() {
        dbPsychologists = data['psicologos'];
        dbServices = data['servicios'];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final success = await _repository.postAgendarCita({
      "psicologo_id": selectedSpecialist!['id'],
      "servicio_id": selectedService!['id'],
      "fecha":
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      "hora":
          "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}",
      "modalidad": selectedModality,
      "motivo": selectedReason,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error al agendar la cita. Intenta de nuevo.")));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Cita Agendada!'),
        content: const Text('Tu cita ha sido registrada exitosamente.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => currentStep > 1
              ? setState(() => currentStep--)
              : Navigator.pop(context),
        ),
        title: const Text('Agendar Cita',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _renderStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderStepContent() {
    switch (currentStep) {
      case 1:
        return _renderStep1();
      case 2:
        return _renderStep2();
      case 3:
        return _renderStep3();
      case 4:
        return _renderStep4();
      default:
        return Container();
    }
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(
            4,
            (i) => Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: (i + 1) <= currentStep
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
      ),
    );
  }

  // --- PASO 1: SERVICIO Y MODALIDAD ---
  Widget _renderStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("¿Qué tipo de terapia buscas?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...dbServices.map((s) => RadioListTile(
              title: Text(s['nombre']),
              value: s,
              groupValue: selectedService,
              activeColor: AppColors.primary,
              onChanged: (val) =>
                  setState(() => selectedService = val as Map<String, dynamic>),
            )),
        const Divider(height: 40),
        const Text("Modalidad",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: ['Presencial', 'En línea']
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CustomButton(
                        title: m,
                        variant: selectedModality == m ? 'primary' : 'outline',
                        onPress: () => setState(() => selectedModality = m),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 30),
        CustomButton(
          title: "Continuar",
          disabled: selectedService == null || selectedModality == null,
          onPress: () => setState(() => currentStep = 2),
        )
      ],
    );
  }

  // --- PASO 2: ESPECIALISTA ---
  Widget _renderStep2() {
    return Column(
      children: [
        const Text("Selecciona un especialista",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...dbPsychologists.map((p) => GestureDetector(
              onTap: () => setState(() => selectedSpecialist = p),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: selectedSpecialist?['id'] == p['id']
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2),
                  ),
                  child: CustomCard(
                    child: Row(
                      children: [
                        Avatar(name: p['nombre'], size: 'large'),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['nombre'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(p['especialidad'],
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        )),
                        if (selectedSpecialist?['id'] == p['id'])
                          const Icon(Icons.check_circle,
                              color: AppColors.primary)
                      ],
                    ),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 20),
        _navigationButtons(
            prev: 1, next: 3, canContinue: selectedSpecialist != null),
      ],
    );
  }

  // --- PASO 3: MOTIVO ---
  Widget _renderStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Motivo de la consulta",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: reasons
              .map((r) => ChoiceChip(
                    label: Text(r),
                    selected: selectedReason == r,
                    onSelected: (_) => setState(() => selectedReason = r),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: selectedReason == r
                            ? Colors.white
                            : AppColors.textPrimary),
                  ))
              .toList(),
        ),
        const SizedBox(height: 30),
        _navigationButtons(
            prev: 2, next: 4, canContinue: selectedReason != null),
      ],
    );
  }

  // --- PASO 4: FECHA, HORA Y RESUMEN ---
  Widget _renderStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha y Hora",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(
          title: Text(
              "Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
          trailing: const Icon(Icons.calendar_month, color: AppColors.primary),
          onTap: () async {
            final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 180)));
            if (picked != null) setState(() => selectedDate = picked);
          },
        ),
        ListTile(
          title: Text("Hora: ${selectedTime.format(context)}"),
          trailing: const Icon(Icons.access_time, color: AppColors.primary),
          onTap: () async {
            final picked = await showTimePicker(
                context: context, initialTime: selectedTime);
            if (picked != null) setState(() => selectedTime = picked);
          },
        ),
        const Divider(height: 40),
        const Text("Resumen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CustomCard(
          child: Column(
            children: [
              _summaryRow("Especialista", selectedSpecialist?['nombre'] ?? ""),
              _summaryRow("Servicio", selectedService?['nombre'] ?? ""),
              _summaryRow("Modalidad", selectedModality ?? ""),
              const Divider(),
              _summaryRow(
                  "Costo Total", "\$${selectedService?['precio'] ?? '0'} MXN"),
            ],
          ),
        ),
        const SizedBox(height: 30),
        CustomButton(title: "Confirmar y Agendar", onPress: _handleConfirm),
        const SizedBox(height: 10),
        CustomButton(
            title: "Anterior",
            variant: 'outline',
            onPress: () => setState(() => currentStep = 3)),
      ],
    );
  }

  Widget _navigationButtons(
      {required int prev, required int next, required bool canContinue}) {
    return Row(
      children: [
        Expanded(
            child: CustomButton(
                title: "Anterior",
                variant: 'outline',
                onPress: () => setState(() => currentStep = prev))),
        const SizedBox(width: 12),
        Expanded(
            child: CustomButton(
                title: "Continuar",
                disabled: !canContinue,
                onPress: () => setState(() => currentStep = next))),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
