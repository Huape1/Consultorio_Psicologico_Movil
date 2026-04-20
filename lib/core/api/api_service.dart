import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.100.4:8000/api";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders({bool isPublic = false}) async {
    final String? token = isPublic ? null : await getToken(); 
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    
    return headers;
  }

  Future<dynamic> getRequest(String endpoint, {bool isPublic = false}) async {
    try {
      final headers = await _getHeaders(isPublic: isPublic);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data, {bool isPublic = false}) async {
    try {
      final headers = await _getHeaders(isPublic: isPublic);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: jsonEncode(data),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  // --- MÉTODO RECUPERADO PARA CAMBIAR CONTRASEÑA ---
  Future<bool> updatePassword(String newPassword) async {
    try {
      // Este método requiere token, por eso no usamos isPublic
      final response = await postRequest('/psicologo/cambiar-password/', {
        "password": newPassword,
      });
      return response != null && (response['status'] == 'success' || response['message'] != null);
    } catch (e) {
      print("Error en ApiService.updatePassword: $e");
      return false;
    }
  }

    dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    } 
    
    // Si es 401 o 403, intentamos ver si el servidor mandó un mensaje de error útil
    if (response.statusCode == 401 || response.statusCode == 403) {
      dynamic errorData;
      try {
        errorData = json.decode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      // Si el servidor mandó un mensaje específico (ej: "Correo ya existe"), lo lanzamos
      if (errorData != null && errorData is Map && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      }
      
      // Solo si no hay mensaje detallado, lanzamos el genérico de sesión
      throw Exception("Sesión expirada o no autorizada");
    } else {
      throw Exception("Error del servidor: ${response.statusCode}");
    }
  }
}