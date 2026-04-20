import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../data/repositories/auth_repository.dart'; // Ajusta según tu ruta real
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
  final AuthRepository _authRepository = AuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- EL MÉTODO QUE FALTABA ---
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- LÓGICA DE LOGIN CON REDIRECCIÓN POR ROL ---
void _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authResponse = await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (authResponse != null) {
        // --- PASO VITAL: GUARDAR EL TOKEN EN EL DISCO ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authResponse.token);
        // -----------------------------------------------

        final user = authResponse.user;
        if (!mounted) return;

        // REDIRECCIÓN POR ROLES
        switch (user.tipoUsuario) {
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
            _showError('Rol no reconocido: ${user.tipoUsuario}');
        }
      } else {
        _showError('Credenciales incorrectas');
      }
    } catch (e) {
      print("Error en login: $e"); // Para que veas qué pasa en consola
      _showError('Error de conexión con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tu Logo o Icono aquí
              const Icon(Icons.lock_person, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido a FYM",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Campo Correo
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              // Botón Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Iniciar Sesión",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              // Botón Registro
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("¿No tienes cuenta? Regístrate aquí"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
