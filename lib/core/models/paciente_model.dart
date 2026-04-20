class PacienteData {
  final int numero;
  final String nombre;
  final String apellido;
  final String genero;
  final DateTime fechaNacimiento;
  final String correo;
  final int sesionesCompletadas;

  PacienteData({
    required this.numero,
    required this.nombre,
    required this.apellido,
    required this.genero,
    required this.fechaNacimiento,
    required this.correo,
    this.sesionesCompletadas = 0,
  });

  // Cálculo de edad
  int get edad {
    final today = DateTime.now();
    int age = today.year - fechaNacimiento.year;
    if (today.month < fechaNacimiento.month ||
        (today.month == fechaNacimiento.month &&
            today.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  factory PacienteData.fromJson(Map<String, dynamic> json) {
    return PacienteData(
      numero: json['numero'],
      nombre: json['usuario']['nombrePila'],
      apellido: json['usuario']['primerApellido'],
      genero: json['usuario']['genero'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      correo: json['usuario']['correo'],
      sesionesCompletadas: json['total_sesiones'] ?? 0,
    );
  }
}
