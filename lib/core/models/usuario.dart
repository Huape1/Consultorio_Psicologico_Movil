class Usuario {
  final int numero;
  final String nombrePila;
  final String primerApellido;
  final String segundoApellido;
  final String correo;
  final String genero;
  final String? fotoPerfil;
  final int tipoUsuario; // El ID del tipo

  Usuario({
    required this.numero,
    required this.nombrePila,
    required this.primerApellido,
    required this.segundoApellido,
    required this.correo,
    required this.genero,
    this.fotoPerfil,
    required this.tipoUsuario,
  });

  // El nombre completo que usaremos en la UI
  String get nombreCompleto => "$nombrePila $primerApellido $segundoApellido";

  // Constructor para convertir de JSON (Django) a Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      numero: json['numero'],
      nombrePila: json['nombrePila'],
      primerApellido: json['primerApellido'],
      segundoApellido: json['segundoApellido'],
      correo: json['correo'],
      genero: json['genero'],
      fotoPerfil: json['fotoPerfil'],
      tipoUsuario: json['tipoUsuario'],
    );
  }
}