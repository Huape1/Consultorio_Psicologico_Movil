import 'dart:convert';
import 'dart:io';
import '../../core/api/api_service.dart';
import '../../core/models/psicologo.dart';
import 'package:http/http.dart' as http;

class PsicologoRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final response = await _apiService.getRequest('/psicologo/dashboard/');
      if (response != null) {
        return response;
      }
      return null;
    } catch (e) {
      print("Error en PsicologoRepository.getDashboardData: $e");
      return null;
    }
  }
  Future<List<dynamic>> getMisPacientes() async {
    try {
      final response = await _apiService.getRequest('/psicologo/pacientes/');
      return (response as List? ?? []);
    } catch (e) {
      print("Error al obtener pacientes: $e");
      return [];
    }
  }
  Future<List<dynamic>> getAgendaPorFecha(String fechaIso) async {
    try {
      // Ejemplo: /psicologo/agenda/?fecha=2024-10-24
      final response =
          await _apiService.getRequest('/psicologo/agenda/?fecha=$fechaIso');
      return (response as List? ?? []);
    } catch (e) {
      print("Error en agenda: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>?> getPerfilData() async {
    try {
      print("LLAMANDO A: /psicologo/perfil/"); // <--- Agrega esto para debug
      final response = await _apiService.getRequest('/psicologo/perfil/');
      return response;
    } catch (e) {
      print("Error en perfil psicologo: $e");
      return null;
    }
  }
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      // ESTA URL debe coincidir con la de la función de arriba (punto 2)
      final response =
          await _apiService.postRequest('/psicologo/actualizar-perfil/', data);
      return response != null && response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getExpedientePaciente(int pacienteId) async {
    try {
      final response = await _apiService
          .getRequest('/psicologo/expediente-api/?paciente_id=$pacienteId');
      return response;
    } catch (e) {
      print("Error al obtener expediente: $e");
      return null;
    }
  }
  Future<bool> updateProfileWithImage(Map<String, String> fields, File? imageFile) async {
  try {
    String? token = await _apiService.getToken(); 
    var uri = Uri.parse('${ApiService.baseUrl}/psicologo/actualizar-perfil/');
    
    var request = http.MultipartRequest('POST', uri);
    
    // IMPORTANTE: Usa 'Token' en lugar de 'Bearer' si así está en tu ApiService
    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }
    
    request.fields.addAll(fields);
    
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'foto_perfil', 
        imageFile.path,
      ));
    }
    
    var response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    print("Error: $e");
    return false;
  }
}
}