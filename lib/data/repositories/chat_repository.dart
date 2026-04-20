import '../../core/api/api_service.dart';
import '../../core/models/chat_models.dart';

class ChatRepository {
  final ApiService _apiService = ApiService();

  // Obtiene la lista de mensajes con un psicólogo específico
  Future<List<MessageModel>> getMensajes(int receptorId) async {
    try {
      // Usamos el endpoint que ya tienes en Django
      final response = await _apiService.getRequest('/obtener-mensajes-paciente/?psicologo_id=$receptorId');
      
      if (response is List) {
        return response.map((m) => MessageModel.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print("Error en ChatRepository (getMensajes): $e");
      return [];
    }
  }

  // Envía un mensaje nuevo
  Future<bool> enviarMensaje(int receptorId, String contenido) async {
    try {
      final response = await _apiService.postRequest('/enviar-mensaje-paciente/', {
        'receptor_id': receptorId.toString(),
        'contenido': contenido,
      });

      return response != null && response['status'] == 'ok';
    } catch (e) {
      print("Error en ChatRepository (enviarMensaje): $e");
      return false;
    }
  }
}