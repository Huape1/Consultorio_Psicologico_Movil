import 'usuario.dart';

class PsicologoModel { // Cambiamos nombre para no chocar con la clase de UI
  final int numero;
  final String cedula;
  final int especialidadId;
  final Usuario usuario; // Aquí viene el objeto Usuario anidado

  PsicologoModel({
    required this.numero,
    required this.cedula,
    required this.especialidadId,
    required this.usuario,
  });

  factory PsicologoModel.fromJson(Map<String, dynamic> json) {
    return PsicologoModel(
      numero: json['numero'],
      cedula: json['cedula'],
      especialidadId: json['especialidad'],
      usuario: Usuario.fromJson(json['usuario_data']), // Django DRF suele mandarlo así
    );
  }
}