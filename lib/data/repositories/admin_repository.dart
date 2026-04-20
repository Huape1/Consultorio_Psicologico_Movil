import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/api/api_service.dart';

class AdminRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      return await _apiService.getRequest('/auth/profile/');
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    try {
      final token = await _apiService.getToken();
      var uri = Uri.parse('${ApiService.baseUrl}/auth/profile/update/');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Token $token';
      
      // Agregar campos de texto
      request.fields.addAll(fields);
      
      // Agregar imagen si existe
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }
      
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}