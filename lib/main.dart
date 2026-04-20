import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importes de constantes y estilos
import 'core/constants/color.dart';

// Importa tus pantallas de Auth
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

// Importa tus pantallas de Paciente
import 'features/patient/screens/home_screen.dart';
import 'features/patient/screens/appointments_screen.dart';
import 'features/patient/screens/messages_screen.dart';
import 'features/patient/screens/profile_screen.dart';
import 'features/patient/screens/schedule_screen.dart';
import 'features/patient/screens/edit-profile.dart';
import 'features/patient/screens/change-password.dart';

// Importa tus pantallas de Psicólogo
import 'features/psychologist/screens/home_screen.dart';
import 'features/psychologist/screens/patients_screen.dart';
import 'features/psychologist/screens/agenda_screen.dart';
import 'features/psychologist/screens/chat_screen.dart';
import 'features/psychologist/screens/psychologist_profile_screen.dart';

// Importa tus pantallas de ADMIN
import 'features/admin/screens/home_screen.dart';
import 'features/admin/screens/psychologists_screen.dart';
import 'features/admin/screens/schedules_screen.dart';
import 'features/admin/screens/admins_screen.dart';
import 'features/admin/screens/reports_screen.dart';
import 'features/admin/screens/profile_screen.dart';

import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FYM App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/patient': (context) => const PatientMainLayout(),
        '/psychologist': (context) =>
            const PsychologistMainLayout(), // Actualizado a Layout
        '/admin': (context) => const AdminMainLayout(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}

// --- LAYOUT DE PACIENTE ---
class PatientMainLayout extends StatefulWidget {
  const PatientMainLayout({super.key});

  @override
  State<PatientMainLayout> createState() => _PatientMainLayoutState();
}

class _PatientMainLayoutState extends State<PatientMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PatientHomeScreen(),
    const ScheduleScreen(),
    const AppointmentsScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Citas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Mensajes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- LAYOUT DE PSICÓLOGO ---
class PsychologistMainLayout extends StatefulWidget {
  const PsychologistMainLayout({super.key});

  @override
  State<PsychologistMainLayout> createState() => _PsychologistMainLayoutState();
}

class _PsychologistMainLayoutState extends State<PsychologistMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PsychologistHomeScreen(),
    const PatientsScreen(),
    const AgendaScreen(),
    const PsychologistChatScreen(),
    const PsychologistProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Pacientes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Agenda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- LAYOUT DE ADMINISTRADOR ---
class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;
  // 1. Declaramos la lista, pero no la inicializamos aquí
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 2. La inicializamos en el initState donde 'this' ya es accesible
    _screens = [
      AdminHomeScreen(onTapChange: (index) => onTapManual(index)),
      const PsychologistsManagementScreen(),
      const SchedulesScreen(),
      const AdminsScreen(),
      const ReportsScreen(),
      const AdminProfileScreen(),
    ];
  }

  // 3. Este método debe ser público (sin guion bajo)
  void onTapManual(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos la lista ya inicializada
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTapManual, // También usamos el método aquí
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Psicólogos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Horarios'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Admins'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
