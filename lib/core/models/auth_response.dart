import 'usuario.dart';

class AuthResponse {
  final String token;
  final Usuario user;
  // Puedes agregar campo 'token' si usas JWT más adelante

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '', // Leemos el token de la raíz del JSON
      user: Usuario.fromJson(
          json['user']), // Leemos el usuario de la llave 'user'
    );
  }
}

class Usuario {
  final int numero;
  final String nombrePila;
  final int tipoUsuario; // <--- ESTE ES EL CAMPO CLAVE
  final String correo;

  Usuario({
    required this.numero,
    required this.nombrePila,
    required this.tipoUsuario,
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      numero: json['numero'],
      nombrePila: json['nombrePila'] ?? '',
      // Si Django manda el objeto TipoUsuario, extraemos la clave.
      // Si manda solo el ID, lo tomamos directo.
      tipoUsuario: json['tipoUsuario'] is Map
          ? json['tipoUsuario']['clave']
          : json['tipoUsuario'],
      correo: json['correo'],
    );
  }
}
