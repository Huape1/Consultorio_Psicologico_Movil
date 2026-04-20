// lib/core/models/cita_model.dart
class CitaModel {
  final int numero;
  final DateTime fecha;
  final String hora;
  final String motivo;
  final int psicologoId;
  final int pacienteId;
  final String modalidad; // Nombre de la modalidad
  final String estado;    // Nombre del estado

  CitaModel({
    required this.numero,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.psicologoId,
    required this.pacienteId,
    required this.modalidad,
    required this.estado,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      numero: json['numero'],
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'],
      motivo: json['motivo'],
      psicologoId: json['psicologo'],
      pacienteId: json['paciente'],
      modalidad: json['modalidad_nombre'], // Django debería enviar el nombre, no solo el ID
      estado: json['estado_nombre'],
    );
  }
}