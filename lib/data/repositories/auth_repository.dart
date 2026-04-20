import '../../core/api/api_service.dart';
import '../../core/models/auth_response.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // MÉTODO PARA LOGIN
  Future<AuthResponse?> login(String correo, String password) async {
    try {
      final data = await _apiService.postRequest(
        '/login/',
        {
          'correo': correo,
          'password': password,
        },
      );

      // ESTO ES CLAVE: Mira tu consola de debug en VS Code / Android Studio
      print("Respuesta cruda de Django: $data");

      if (data == null || data is! Map<String, dynamic>) {
        print("Error: La respuesta no es un Mapa válido");
        return null;
      }

      return AuthResponse.fromJson(data);
    } catch (e) {
      print("Error en AuthRepository (Login): $e");
      return null;
    }
  }

  // MÉTODO PARA REGISTRO DE PACIENTE
  Future<bool> registerPaciente({
    required String nombre,
    required String primerApellido,
    required String segundoApellido,
    required String telefono,
    required String fechaNacimiento,
    required String correo,
    required String password,
    required String confirmPassword,
    required String genero,
  }) async {
    try {
      // 1. Quitamos /api/ del path porque el ApiService ya tiene baseUrl con /api
      await _apiService.postRequest('/registro/', {
        'nombre': nombre,
        'primer_apellido': primerApellido,
        'segundo_apellido': segundoApellido,
        'telefono': telefono,
        'fecha_nacimiento': fechaNacimiento,
        'correo': correo,
        'password': password,
        'confirm_password': confirmPassword,
        'genero': genero,
      });

      // 2. Si no hubo excepción, el registro fue exitoso (201)
      return true;
    } catch (e) {
      print("Error en AuthRepository (Register): $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      // El ApiService ya debería estar mandando el Token que guardamos en el login
      final data = await _apiService.getRequest('/paciente/perfil/');
      return data;
    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }
}
