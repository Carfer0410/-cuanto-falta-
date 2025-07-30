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
import 'event_dashboard_service.dart';
import 'theme_service.dart';
import 'root_page.dart';
import 'localization_service.dart';
import 'splash_screen.dart';

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
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(ThemeMode.light);

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
    
    // NUEVO: Verificar si necesita configurar estilo de planificación (sistema inteligente)
    _checkPlanningStyleSetup();
    
    print('🔄 Sistema Timer mejorado iniciado:');
    print('  ✅ Verificaciones frecuentes mientras app está activa');
    print('  ✅ Verificaciones críticas cada minuto para eventos urgentes');
    print('  ✅ Motivación activa cada 30 minutos para retos');
    print('  🔔 Notificaciones automáticas de ventana de confirmación:');
    print('     📱 21:00 - "¡Ventana de confirmación abierta!"');
    print('     📱 23:30 - "¡Últimos 29 minutos!" (cierre a las 23:59)');
    print('  ✅ Sistema de recuperación automática');
    print('  ✅ Recordatorios de personalización inteligentes y no invasivos');
    print('  ⚠️  Funciona solo con app abierta (solución más confiable)');
  }

  /// Verificar si necesita mostrar configuración de estilo de planificación
  /// Sistema inteligente que evita ser insistente
  Future<void> _checkPlanningStyleSetup() async {
    final planningService = PlanningStyleService.instance;
    final hasConfigured = await planningService.hasConfiguredStyle();
    
    if (!hasConfigured) {
      // Verificar si está en modo snooze
      if (await _isPersonalizationSnoozed()) {
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Controlar frecuencia y momentos apropiados
      final lastShown = prefs.getInt('last_planning_reminder') ?? 0;
      final reminderCount = prefs.getInt('planning_reminder_count') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final currentHour = DateTime.now().hour;
      
      // Solo mostrar en horarios apropiados (9 AM - 9 PM)
      if (currentHour < 9 || currentHour > 21) {
        print('🎨 Horario no apropiado para recordatorio de personalización');
        return;
      }
      
      // Escalamiento inteligente de frecuencia
      int minHoursBetweenReminders;
      if (reminderCount == 0) {
        minHoursBetweenReminders = 0; // Primera vez: inmediato
      } else if (reminderCount <= 2) {
        minHoursBetweenReminders = 24; // Primeras veces: cada día
      } else if (reminderCount <= 5) {
        minHoursBetweenReminders = 72; // Después: cada 3 días
      } else {
        minHoursBetweenReminders = 168; // Después de 5 veces: cada semana
      }
      
      final hoursSinceLastShown = (currentTime - lastShown) / (1000 * 60 * 60);
      
      if (hoursSinceLastShown >= minHoursBetweenReminders) {
        // Mensajes progresivamente más amigables
        String title, body;
        if (reminderCount == 0) {
          title = '🎨 ¡Bienvenido!';
          body = 'Personaliza tu experiencia configurando tu estilo de planificación. Configuración → Personalización';
        } else if (reminderCount <= 2) {
          title = '✨ Personalización disponible';
          body = 'Tu experiencia será mejor si configuras tu estilo de planificación. Es rápido y fácil 😊';
        } else if (reminderCount <= 5) {
          title = '🎯 Mejora tu experiencia';
          body = 'Los preparativos se adaptan mejor si configuras tu estilo personal. ¿Te animas?';
        } else {
          title = '💝 Recordatorio amigable';
          body = 'Cuando gustes, puedes personalizar tu estilo de planificación en Configuración';
        }
        
        // Esperar un momento apropiado para mostrar
        final delay = reminderCount == 0 ? 10 : 30; // Primera vez más rápido
        Timer(Duration(seconds: delay), () async {
          await NotificationService.instance.showImmediateNotification(
            id: 99998,
            title: title,
            body: body,
          );
          
          // Actualizar contadores
          await prefs.setInt('last_planning_reminder', currentTime);
          await prefs.setInt('planning_reminder_count', reminderCount + 1);
          
          print('🎨 Recordatorio de personalización enviado (vez ${reminderCount + 1})');
          print('   ⏰ Próximo recordatorio en ${minHoursBetweenReminders == 168 ? '1 semana' : '$minHoursBetweenReminders horas'}');
        });
      } else {
        final hoursUntilNext = minHoursBetweenReminders - hoursSinceLastShown;
        print('🎨 Recordatorio de personalización programado para ${hoursUntilNext.toStringAsFixed(1)} horas');
      }
    }
  }

  /// Función para que el usuario pueda posponer recordatorios de personalización
  /// Útil si el usuario accede a configuración pero no completa la personalización
  /// Uso desde cualquier parte de la app: _MyAppState.snoozePersonalizationReminders()
  /// ignore: unused_element
  static Future<void> snoozePersonalizationReminders({int hours = 48}) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = DateTime.now().add(Duration(hours: hours)).millisecondsSinceEpoch;
    await prefs.setInt('personalization_snooze_until', snoozeUntil);
    print('🎨 Recordatorios de personalización pospuestos por $hours horas');
  }

  /// Verificar si los recordatorios están en modo snooze
  Future<bool> _isPersonalizationSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = prefs.getInt('personalization_snooze_until') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (snoozeUntil > now) {
      final hoursLeft = (snoozeUntil - now) / (1000 * 60 * 60);
      print('🎨 Recordatorios en snooze por ${hoursLeft.toStringAsFixed(1)} horas más');
      return true;
    }
    return false;
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
      try {
        final mode = ThemeMode.values.firstWhere(
          (e) => e.toString() == modeString,
          orElse: () => ThemeMode.light,
        );
        if (mounted) {
          setState(() {
            _themeMode = mode;
          });
          _themeModeNotifier.value = mode;
        }
      } catch (e) {
        print('Error loading theme: $e');
        // Fallback a modo claro si hay error
        if (mounted) {
          setState(() {
            _themeMode = ThemeMode.light;
          });
          _themeModeNotifier.value = ThemeMode.light;
        }
      }
    } else {
      _themeModeNotifier.value = ThemeMode.light;
    }
  }

  Future<void> _onThemeChanged(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode.toString());
      
      if (mounted) {
        setState(() {
          _themeMode = mode;
        });
        _themeModeNotifier.value = mode;
      }
      
      print('🎨 Tema cambiado a: ${mode.toString()}');
    } catch (e) {
      print('Error saving theme: $e');
    }
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
        ChangeNotifierProvider.value(value: EventDashboardService.instance),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: localizationService.t('appTitle'),
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: _themeMode,
            home: SplashScreen(
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: _themeModeNotifier,
                builder: (context, themeMode, child) {
                  return RootPage(
                    themeMode: themeMode,
                    onThemeChanged: _onThemeChanged,
                  );
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
