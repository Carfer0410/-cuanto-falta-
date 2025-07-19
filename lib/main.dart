import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'simple_event_checker.dart';
import 'challenge_notification_service.dart';
import 'root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones
  await NotificationService.instance.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _initializeNotificationSystems();
  }

  Future<void> _initializeNotificationSystems() async {
    await NotificationService.instance.init();
    
    // Iniciar el sistema de verificación simple para eventos
    await SimpleEventChecker.startChecking();
    
    // Iniciar el sistema de notificaciones motivacionales para retos
    await ChallengeNotificationService.startChecking();
  }


  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString('themeMode');
    if (modeString != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.light,
      );
      setState(() {
        _themeMode = mode;
      });
    }
  }

  Future<void> _onThemeChanged(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¿Cuánto Falta?',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: RootPage(
        themeMode: _themeMode,
        onThemeChanged: _onThemeChanged,
        // Forzar color naranja en el botón flotante desde aquí si el tema no lo respeta
        // (esto requiere que RootPage/FAB acepte parámetros, si no, el tema global lo debe forzar)
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
