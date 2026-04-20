import '../models/paciente_model.dart';

// 1. RE-DEFINE LA CLASE (Para que los otros archivos no exploten)
class Patient {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String memberSince;
  final String plan;
  final int sessionsCompleted;

  Patient({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.memberSince,
    required this.plan,
    required this.sessionsCompleted,
  });
}

// 2. CORRIGE EL OBJETO GLOBAL
final mockPatient = Patient(
  id: "1",
  name: "Andrea",
  lastName: "López",
  email: "andrea@test.com",
  memberSince: "2023",
  plan: "Premium",
  sessionsCompleted: 12,
);

// 3. CORRIGE LA LISTA (Para chat_screen y patients_screen)
final List<Patient> mockPatients = [
  mockPatient,
  Patient(
      id: "2",
      name: "Juan",
      lastName: "Pérez",
      email: "juan@test.com",
      memberSince: "2024",
      plan: "Básico",
      sessionsCompleted: 4),
  Patient(
      id: "3",
      name: "María",
      lastName: "García",
      email: "maria@test.com",
      memberSince: "2023",
      plan: "Estándar",
      sessionsCompleted: 8),
];

// ... (El resto de tus mocks como nextAppointment deben seguir igual abajo)

class MockAppointment {
  final String status;
  final String time;
  final String type;
  final String psychologistName;

  MockAppointment({
    required this.status,
    required this.time,
    required this.type,
    required this.psychologistName,
  });
}

final nextAppointment = MockAppointment(
  status: "Confirmada",
  time: "04:30",
  type: "Sesión de seguimiento",
  psychologistName: "Dr. Roberto Silva",
);

// 1. Definimos un modelo rápido para las citas si aún no lo tienes
class Appointment {
  final String id;
  final String status;
  final String time;
  final String type;
  final String modality;
  final String? location;
  final Patient patient;
  final String psychologistName;

  Appointment({
    required this.id,
    required this.status,
    required this.time,
    required this.type,
    required this.modality,
    this.location,
    required this.patient,
    required this.psychologistName,
  });
}

// 2. Datos de prueba del Psicólogo
class Psychologist {
  final String fullName;
  final String specialty;
  final String experience;

  Psychologist({required this.fullName, required this.specialty, required this.experience});
}

final mockPsychologist = Psychologist(
  fullName: "Dr. Roberto Silva",
  specialty: "Psicólogo Clínico",
  experience: "12 años",
);

// 3. Lista de Pacientes de prueba

// 4. LA VARIABLE QUE TE FALTA: mockAppointments
final List<Appointment> mockAppointments = [
  Appointment(
    id: "apt-001",
    status: "Confirmada",
    time: "09:00 AM",
    type: "Terapia Individual",
    modality: "Presencial",
    location: "Consultorio 204",
    patient: mockPatients[0],
    psychologistName: "Dr. Roberto Silva",
  ),
  Appointment(
    id: "apt-002",
    status: "Pendiente",
    time: "11:30 AM",
    type: "Sesión de Seguimiento",
    modality: "En línea",
    patient: mockPatients[1],
    psychologistName: "Dr. Roberto Silva",
  ),
  Appointment(
    id: "apt-003",
    status: "Confirmada",
    time: "04:00 PM",
    type: "Terapia de Pareja",
    modality: "Presencial",
    location: "Consultorio 105",
    patient: mockPatients[2],
    psychologistName: "Dr. Roberto Silva",
  ),
];

// Estadísticas del Dashboard
class DashboardStats {
  final int activePsychologists;
  final int registeredPatients;
  final int pendingReports;
  final int todayAppointments;
  final String monthlyGrowth;
  final String patientGrowth;

  DashboardStats({
    required this.activePsychologists,
    required this.registeredPatients,
    required this.pendingReports,
    required this.todayAppointments,
    required this.monthlyGrowth,
    required this.patientGrowth,
  });
}

final mockDashboardStats = DashboardStats(
  activePsychologists: 24,
  registeredPatients: 156,
  pendingReports: 3,
  todayAppointments: 18,
  monthlyGrowth: "+12% este mes",
  patientGrowth: "+5% este mes",
);

// Reportes/Actividad
class AdminReport {
  final String id;
  final String user;
  final String lastMessage;
  final String priority;
  final String timestamp;
  final int unreadCount;

  AdminReport({required this.id, required this.user, required this.lastMessage, required this.priority, required this.timestamp, required this.unreadCount});
}

final List<AdminReport> mockReports = [
  AdminReport(id: "1", user: "Soporte Técnico", lastMessage: "Error en pasarela de pagos", priority: "high", timestamp: "10:25 AM", unreadCount: 2),
  AdminReport(id: "2", user: "Dra. Elena Ramos", lastMessage: "Solicitud de cambio de horario", priority: "low", timestamp: "09:15 AM", unreadCount: 0),
];

// Administradores
class AdminUser {
  final String id;
  final String fullName;
  final String role;
  final String status;

  AdminUser({required this.id, required this.fullName, required this.role, required this.status});
}

final List<AdminUser> mockAdmins = [
  AdminUser(id: "1", fullName: "Admin Principal", role: "Super Admin", status: "Activo"),
  AdminUser(id: "2", fullName: "Carlos Méndez", role: "Moderador", status: "Activo"),
];


