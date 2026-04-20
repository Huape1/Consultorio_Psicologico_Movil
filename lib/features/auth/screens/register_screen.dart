import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controladores
  final _nameController = TextEditingController();
  final _paternoController = TextEditingController();
  final _maternoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController(); // Para mostrar la fecha seleccionada
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 2. Variables de estado
  DateTime? selectedDate;
  String selectedGender = 'Seleccionar género';
  bool acceptTerms = false;
  bool _isLoading = false;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 3. Selector de Fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"), // Asegúrate de configurar el soporte de idiomas
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // 4. Lógica de Registro
  void _handleRegister() async {
    // 1. Validaciones previas de UI
    if (!acceptTerms) {
      _showSnackBar('Debes aceptar los términos y condiciones');
      return;
    }

    if (selectedDate == null) {
      _showSnackBar('Por favor, selecciona tu fecha de nacimiento');
      return;
    }

    if (_nameController.text.trim().isEmpty || 
        _paternoController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty) {
      _showSnackBar('Por favor, llena todos los campos obligatorios (*)');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showSnackBar('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Las contraseñas no coinciden');
      return;
    }

    if (selectedGender == 'Seleccionar género') {
      _showSnackBar('Por favor, selecciona tu género');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Formatear fecha para Django (YYYY-MM-DD)
      String formattedDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      // Llamada al repositorio
      final String? errorMessage = await _authRepository.registerPaciente(
        nombre: _nameController.text.trim(),
        primerApellido: _paternoController.text.trim(),
        segundoApellido: _maternoController.text.trim(),
        telefono: _phoneController.text.trim(),
        fechaNacimiento: formattedDate,
        correo: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        genero: selectedGender,
      );

      if (errorMessage == null) {
        // REGISTRO EXITOSO
        if (!mounted) return;
        _showSnackBar('¡Registro exitoso! Ya puedes iniciar sesión.', isError: false);
        
        // Esperamos un segundo para que el usuario vea el mensaje verde y redirigimos
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // REGISTRO FALLIDO: Mostramos el error que nos dio el servidor
        // Limpiamos un poco el mensaje si viene con códigos HTTP
        String friendlyError = errorMessage;
        if (errorMessage.contains('400')) friendlyError = "El correo o teléfono ya están registrados";
        
        _showSnackBar(friendlyError);
      }
    } catch (e) {
      _showSnackBar('Error de conexión: No se pudo contactar al servidor');
      print("Error detallado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registro de Paciente', 
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crear cuenta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Ingresa tus datos personales para continuar.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            
            _buildInput("Nombre(s) *", "Ej. Andrea", _nameController),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildInput("Ap. Paterno *", "Ej. Lopez", _paternoController)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput("Ap. Materno", "Ej. Perez", _maternoController)),
              ],
            ),
            const SizedBox(height: 16),

            _buildInput("Teléfono *", "10 dígitos", _phoneController, icon: Icons.phone, isPhone: true),
            const SizedBox(height: 16),

            // Campo de Fecha de Nacimiento (Solo lectura, se abre el Picker)
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildInput("Fecha de Nacimiento *", "Seleccionar fecha", _dateController, icon: Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),

            _buildInput("Correo electrónico *", "nombre@correo.com", _emailController, icon: Icons.mail_outline, isEmail: true),
            const SizedBox(height: 16),

            _buildGenderDropdown(),
            const SizedBox(height: 16),

            _buildInput("Contraseña *", "Mínimo 8 caracteres", _passwordController, icon: Icons.lock_outline, isPass: true),
            const SizedBox(height: 16),

            _buildInput("Confirmar contraseña *", "Repite tu contraseña", _confirmPasswordController, icon: Icons.lock_outline, isPass: true),
            const SizedBox(height: 24),

            _buildTermsCheckbox(),
            const SizedBox(height: 32),

            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SOPORTE ---

  Widget _buildInput(String label, String hint, TextEditingController controller, {IconData? icon, bool isPass = false, bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppColors.textLight) : null,
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Género", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(selectedGender, style: TextStyle(color: selectedGender.contains('Seleccionar') ? AppColors.textLight : AppColors.textPrimary)),
              items: ['Masculino', 'Femenino', 'Otro'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => setState(() => selectedGender = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: (v) => setState(() => acceptTerms = v!),
          activeColor: AppColors.primary,
        ),
        const Expanded(child: Text('Acepto los términos y condiciones y el manejo de datos.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading || !acceptTerms ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppColors.textLight,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('Registrarse', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}