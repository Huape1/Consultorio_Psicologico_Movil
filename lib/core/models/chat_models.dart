class ChatPreview {
  final int receptorId;
  final String nombre;
  final String ultimoMensaje;
  final String hora;
  final int noLeidos;

  ChatPreview({
    required this.receptorId,
    required this.nombre,
    required this.ultimoMensaje,
    required this.hora,
    this.noLeidos = 0,
  });
}

class MessageModel {
  final String texto;
  final String tipo; 
  final String hora;
  final String fechaCompleta; // Nuevo: Para agrupar (ej: "2026-04-15")
  final String diaStr;        // Nuevo: Para mostrar (ej: "15 de Abril, 2026")
  final bool leido;

  MessageModel({
    required this.texto, 
    required this.tipo, 
    required this.hora, 
    required this.fechaCompleta,
    required this.diaStr,
    required this.leido
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      texto: json['texto'],
      tipo: json['tipo'],
      hora: json['hora'],
      fechaCompleta: json['fecha_completa'] ?? "",
      diaStr: json['dia_str'] ?? "",
      leido: json['leido'] ?? false,
    );
  }
}