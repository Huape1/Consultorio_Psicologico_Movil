import '../../core/api/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PacienteRepository {
  // Instanciamos el ApiService que ya tienes para hacer las peticiones
  final ApiService _apiService = ApiService();

  /// Obtiene toda la información necesaria para el Dashboard del Paciente
  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      // Esta ruta debe coincidir con la que pusiste en el urls.py de Django
      // El ApiService ya debería incluir el Token de autenticación automáticamente
      final response = await _apiService.getRequest('/paciente/dashboard/');

      if (response != null) {
        return response;
      }
      return null;
    } catch (e) {
      // Si hay un error (error de red, 404, 500), lo imprimimos en consola
      print("Error en PacienteRepository.getDashboardData: $e");
      return null;
    }
  }

  Future<List<dynamic>> getMisCitas() async {
    try {
      final response = await _apiService.getRequest('/paciente/citas/');
      return (response != null) ? response as List : [];
    } catch (e) {
      print("Error al obtener citas: $e");
      return [];
    }
  }

  /// Obtiene psicólogos y servicios disponibles
  Future<Map<String, dynamic>?> getSetupAgendar() async {
    try {
      final response = await _apiService.getRequest('/paciente/setup-agendar/');
      return response;
    } catch (e) {
      print("Error en setup agendar: $e");
      return null;
    }
  }

  /// Envía la nueva cita al servidor
  Future<bool> postAgendarCita(Map<String, dynamic> citaData) async {
    try {
      // Asumiendo que tu ApiService tiene un método postRequest
      final response =
          await _apiService.postRequest('/paciente/agendar/', citaData);
      return response != null && response['status'] == 'success';
    } catch (e) {
      print("Error al agendar: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPerfilCompleto() async {
    try {
      // Esta ruta debe devolver: nombre, correo, teléfono, foto, etc.
      final response = await _apiService.getRequest('/paciente/perfils/');
      return response;
    } catch (e) {
      print("Error al obtener perfil: $e");
      return null;
    }
  }

  /// Actualiza los datos del perfil (Nombre, Correo, Teléfono)
  Future<bool> actualizarPerfil(Map<String, dynamic> datos) async {
    try {
      final response = await _apiService.postRequest(
          '/paciente/actualizar-perfil-api/', datos);
      return response != null && response['status'] == 'success';
    } catch (e) {
      print("Error al actualizar perfil: $e");
      return false;
    }
  }

  Future<bool> changePassword(String oldPwd, String newPwd) async {
    try {
      final response =
          await _apiService.postRequest('/paciente/cambiar-password/', {
        "old_password": oldPwd,
        "new_password": newPwd,
      });
      // Verificamos si Django respondió con éxito
      return response != null &&
          (response['status'] == 'success' || response.containsKey('message'));
    } catch (e) {
      print("Error al cambiar contraseña: $e");
      return false;
    }
  }

  /// Actualiza los datos generales (para edit_profile_screen)
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.postRequest('/paciente/actualizar-perfil/', data);
      return response != null && (response['status'] == 'success');
    } catch (e) {
      print("Error al actualizar perfil: $e");
      return false;
    }
  }

  Future<bool> updateProfileWithImage(Map<String, String> fields, File? imageFile) async {
  try {
    String? token = await _apiService.getToken(); 
    var uri = Uri.parse('${ApiService.baseUrl}/paciente/actualizar-perfil/'); // Ajusta tu ruta
    
    var request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Token $token';
    
    request.fields.addAll(fields);
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_perfil', imageFile.path));
    }
    
    var response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}
