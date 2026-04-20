import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart'; 
import '../../../core/constants/color.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  final LocalAuthentication auth = LocalAuthentication();
  final AuthRepository _authRepository = AuthRepository();

  @override
void initState() {
  super.initState();
  // Esperamos un momento a que la pantalla cargue y lanzamos la huella
  Future.delayed(Duration(milliseconds: 500), () {
    _checkSavedSessionAndAuth();
  });
}

Future<void> _checkSavedSessionAndAuth() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('token') && prefs.containsKey('tipoUsuario')) {
    // Si ya hay datos, disparamos la huella automáticamente
    _authenticateWithBiometrics();
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN DE REDIRECCIÓN ÚNICA ---
  void _redirectToRole(int role) {
    if (!mounted) return;
    switch (role) {
      case 1:
        Navigator.pushReplacementNamed(context, '/patient');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/psychologist');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      default:
        _showError('Rol no reconocido: $role');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- LÓGICA DE LOGIN MANUAL ---
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor, llena todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await _authRepository.login(email, password);

      if (authResponse != null) {
        final prefs = await SharedPreferences.getInstance();
        
        // --- AQUÍ ESTÁ EL CAMBIO CRÍTICO ---
        // Forzamos el guardado y esperamos a que termine con 'await'
        bool s1 = await prefs.setString('token', authResponse.token);
        bool s2 = await prefs.setInt('tipoUsuario', authResponse.user.tipoUsuario);

        print("¿Token guardado?: $s1");
        print("¿Rol guardado?: $s2 (Valor: ${authResponse.user.tipoUsuario})");

        if (!mounted) return;
        _redirectToRole(authResponse.user.tipoUsuario);
      } else {
        _showError('Credenciales incorrectas');
      }
    } catch (e) {
      print("Error en login: $e");
      _showError('Error de conexión con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE HUELLA ---
  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showError('Biometría no disponible');
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Inicia sesión de forma segura en FYM',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Identifícate', 
            cancelButton: 'Cancelar',
            // Se eliminó biometricHint porque causaba el error
          ),
          IOSAuthMessages(cancelButton: 'Cancelar'),
        ],
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        final String? savedToken = prefs.getString('token');
        final int? savedRole = prefs.getInt('tipoUsuario');

        // ESTO TE DIRÁ EL ERROR EN LA CONSOLA DE VS CODE
        print("DEBUG HUELLA: Token existe -> ${savedToken != null}");
        print("DEBUG HUELLA: Rol existe -> ${savedRole != null} (Valor: $savedRole)");

        if (savedToken != null && savedRole != null) {
          _redirectToRole(savedRole); 
        } else {
          _showError('Debes iniciar sesión con contraseña una vez primero');
        }
      }
    } catch (e) {
      _showError('Error al autenticar con biometría');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                _buildLogoSection(),
                const SizedBox(height: 48),
                _buildInput("Correo electrónico", "ejemplo@correo.com", _emailController, Icons.mail_outline),
                const SizedBox(height: 20),
                _buildInput("Contraseña", "••••••••", _passwordController, Icons.lock_outline, isPassword: true),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: _buildLoginButton()),
                    const SizedBox(width: 12),
                    _buildBiometricButton(),
                  ],
                ),
                const SizedBox(height: 32),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin, 
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Ingresar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      height: 56, width: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: IconButton(
        icon: const Icon(Icons.fingerprint, color: AppColors.primary, size: 30),
        onPressed: _authenticateWithBiometrics,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('FYM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 24),
        const Text('Bienvenido de nuevo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const Text('Atención emocional segura', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), 
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)
                ) : null,
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("¿Aún no tienes cuenta? ", style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text("Regístrate", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}