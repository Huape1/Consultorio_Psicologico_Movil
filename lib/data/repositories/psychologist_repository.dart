import 'dart:convert';
import '../../core/api/api_service.dart';
import '../../core/models/psicologo.dart';

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
}