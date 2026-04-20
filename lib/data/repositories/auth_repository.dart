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
        isPublic: true, // El login es público
      );

      print("Respuesta cruda de Django: $data");

      if (data == null || data is! Map<String, dynamic>) {
        return null;
      }

      return AuthResponse.fromJson(data);
    } catch (e) {
      print("Error en AuthRepository (Login): $e");
      return null;
    }
  }

  // MÉTODO PARA REGISTRO DE PACIENTE
  Future<String?> registerPaciente({
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
      final response = await _apiService.postRequest(
        '/registro-api/',
        {
          'nombre': nombre,
          'primer_apellido': primerApellido,
          'segundo_apellido': segundoApellido,
          'telefono': telefono,
          'fecha_nacimiento': fechaNacimiento,
          'correo': correo,
          'password': password,
          'confirm_password': confirmPassword,
          'genero': genero,
        },
        isPublic: true, // ¡ESTO ES LO MÁS IMPORTANTE! Evita el error 403
      );

      if (response != null) {
        return null; // Éxito
      }
      
      return "Respuesta inesperada del servidor";
    } catch (e) {
      print("Error en AuthRepository (Register): $e");
      // Limpiamos el mensaje de "Exception: " para el usuario
      return e.toString().replaceAll("Exception: ", "");
    }
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      // El perfil SÍ requiere token, por eso no mandamos isPublic
      final data = await _apiService.getRequest('/paciente/perfil/');
      return data;
    } catch (e) {
      print("Error cargando perfil: $e");
      return null;
    }
  }
}