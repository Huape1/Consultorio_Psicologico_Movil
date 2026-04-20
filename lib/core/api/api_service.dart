import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.26:8000/api";

  // Función privada para obtener los headers con el Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token =
        prefs.getString('token'); // Recuperamos el token guardado

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Importante: Si usas el sistema básico de Django es 'Token $token'
      // Si usas JWT es 'Bearer $token'
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final headers = await _getHeaders(); // Obtenemos headers con token
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<dynamic> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: jsonEncode(data),
        headers: headers,
      );
      return _processResponse(response); // Procesamos igual que el GET
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Sesión expirada o no autorizada");
    } else {
      throw Exception("Error del servidor: ${response.statusCode}");
    }
  }
}
