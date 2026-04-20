class Usuario {
  final int numero;
  final String nombre;
  final String correo;

  Usuario({required this.numero, required this.nombre, required this.correo});

  // Este "fábrica" convierte el JSON de Django en un objeto de Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      numero: json['numero'],
      nombre: json['nombrePila'],
      correo: json['correo'],
    );
  }
}