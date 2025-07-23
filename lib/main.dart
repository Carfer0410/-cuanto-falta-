import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'notification_service.dart';
import 'simple_event_checker.dart';
import 'challenge_notification_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'data_migration_service.dart';
import 'preparation_service.dart';
import 'planning_style_service.dart';
import 'challenge_strategy_service.dart';
import 'individual_streak_service.dart';
import 'milestone_notification_service.dart';
import 'root_page.dart';
import 'localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones
  await NotificationService.instance.init();
  
  // Cargar el idioma guardado
  await LocalizationService.instance.loadLanguage();
  
  // Cargar el estilo de planificación del usuario
  await PlanningStyleService.instance.loadPlanningStyle();
  
  // Inicializar servicios de estadísticas y logros
  await StatisticsService.instance.loadStatistics();
  await AchievementService.instance.loadAchievements();
  
  // Inicializar nuevo sistema de rachas individuales
  await IndividualStreakService.instance.loadStreaks();
  
  // Ejecutar migración de datos existentes (solo una vez)
  await DataMigrationService.runInitialDataMigration();
  
  // Migrar al nuevo sistema de rachas individuales
  await DataMigrationService.migrateToIndividualStreaks();
  
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

  // Remover _loadLanguage() ya que se carga en main()

  Future<void> _initializeNotificationSystems() async {
    await NotificationService.instance.init();
    
    // Sistema Timer MEJORADO - Más frecuente y resistente a suspensión
    await SimpleEventChecker.startChecking();
    await ChallengeNotificationService.startChecking();
    
    // NUEVO: Sistema de recuperación automática
    _setupTimerRecovery();
    
    // NUEVO: Verificar si necesita configurar estilo de planificación
    _checkPlanningStyleSetup();
    
    print('🔄 Sistema Timer mejorado iniciado:');
    print('  ✅ Verificaciones frecuentes mientras app está activa');
    print('  ✅ Verificaciones críticas cada minuto para eventos urgentes');
    print('  ✅ Motivación activa cada 30 minutos para retos');
    print('  ✅ Sistema de recuperación automática');
    print('  ⚠️  Funciona solo con app abierta (solución más confiable)');
  }

  /// Verificar si necesita mostrar configuración de estilo de planificación
  Future<void> _checkPlanningStyleSetup() async {
    final planningService = PlanningStyleService.instance;
    final hasConfigured = await planningService.hasConfiguredStyle();
    
    if (!hasConfigured) {
      // Esperar 5 segundos para que la app se cargue completamente
      Timer(Duration(seconds: 5), () async {
        await NotificationService.instance.showImmediateNotification(
          id: 99998,
          title: '🎨 ¡Personaliza tu experiencia!',
          body: 'Configura tu estilo de planificación para que los preparativos se adapten a ti. Ve a Configuración → Personalización',
        );
        
        print('🎨 Recordatorio para configurar estilo de planificación enviado');
      });
    }
  }

  /// Sistema de recuperación automática del Timer
  void _setupTimerRecovery() {
    // Verificar y reactivar timers cada 5 minutos si se detuvieron
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (!SimpleEventChecker.isActive) {
        print('🔄 Recuperando SimpleEventChecker...');
        await SimpleEventChecker.startChecking();
      }
      
      if (!ChallengeNotificationService.isActive) {
        print('🔄 Recuperando ChallengeNotificationService...');
        await ChallengeNotificationService.startChecking();
      }
    });
    
    // Regenerar fichas de perdón semanalmente
    Timer.periodic(Duration(hours: 24), (timer) async {
      await IndividualStreakService.instance.regenerateForgivenessTokens();
    });
    
    // 🆕 NUEVO: Timer adicional para mensajes motivacionales aleatorios
    Timer.periodic(Duration(hours: 3), (timer) async {
      await MilestoneNotificationService.sendMotivationalMessage();
    });
    
    // NUEVO: Notificación educativa para el usuario (una sola vez)
    _showOptimalUsageHint();
  }

  /// Muestra hint sobre uso óptimo (solo la primera vez)
  Future<void> _showOptimalUsageHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownHint = prefs.getBool('has_shown_usage_hint') ?? false;
    
    if (!hasShownHint) {
      // Esperar 30 segundos para que el usuario explore la app
      Timer(Duration(seconds: 30), () async {
        await NotificationService.instance.showImmediateNotification(
          id: 99999,
          title: '💡 Tip: Para mejores notificaciones',
          body: 'Mantén la app minimizada (no cerrada) para recibir todos los recordatorios. ¡Funciona perfectamente en segundo plano! 🚀',
        );
        
        // Marcar como mostrado
        await prefs.setBool('has_shown_usage_hint', true);
        print('💡 Hint de uso óptimo mostrado al usuario');
      });
    }
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LocalizationService.instance),
        ChangeNotifierProvider.value(value: StatisticsService.instance),
        ChangeNotifierProvider.value(value: AchievementService.instance),
        ChangeNotifierProvider.value(value: PreparationService.instance),
        ChangeNotifierProvider.value(value: PlanningStyleService.instance),
        ChangeNotifierProvider.value(value: ChallengeStrategyService.instance),
        ChangeNotifierProvider.value(value: IndividualStreakService.instance),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: localizationService.t('appTitle'),
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
        },
      ),
    );
  }
}
