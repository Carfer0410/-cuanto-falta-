import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'notification_service.dart';
import 'notification_navigation_service.dart';
import 'notification_center_service.dart';
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
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _initializeNotificationSystems();
  }

  Future<void> _initializeNotificationSystems() async {
    await NotificationService.instance.init();

    // INICIALIZAR CENTRO DE NOTIFICACIONES
    await NotificationCenterService.instance.init();

    // Sistema Timer MEJORADO - Más frecuente y resistente a suspensión
    await SimpleEventChecker.startChecking();
    await ChallengeNotificationService.startChecking();

    // Sistema de recuperación automática
    _setupTimerRecovery();

    // Verificar si necesita configurar estilo de planificación (sistema inteligente)
    _checkPlanningStyleSetup();
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
          body =
              'Personaliza tu experiencia configurando tu estilo de planificación. Configuración → Personalización';
        } else if (reminderCount <= 2) {
          title = '✨ Personalización disponible';
          body =
              'Tu experiencia será mejor si configuras tu estilo de planificación. Es rápido y fácil 😊';
        } else if (reminderCount <= 5) {
          title = '🎯 Mejora tu experiencia';
          body =
              'Los preparativos se adaptan mejor si configuras tu estilo personal. ¿Te animas?';
        } else {
          title = '💝 Recordatorio amigable';
          body =
              'Cuando gustes, puedes personalizar tu estilo de planificación en Configuración';
        }

        // Esperar un momento apropiado para mostrar
        final delay = reminderCount == 0 ? 10 : 30; // Primera vez más rápido
        Timer(Duration(seconds: delay), () async {
          // Crear payload para navegación a configuración de estilo
          final payload =
              NotificationNavigationService.createPlanningStylePayload();

          await NotificationService.instance.showImmediateNotification(
            id: 99998,
            title: title,
            body: body,
            payload: payload,
          );

          // Actualizar contadores
          await prefs.setInt('last_planning_reminder', currentTime);
          await prefs.setInt('planning_reminder_count', reminderCount + 1);
        });
      }
    }
  }

  /// Función para que el usuario pueda posponer recordatorios de personalización
  /// Útil si el usuario accede a configuración pero no completa la personalización
  /// ignore: unused_element
  static Future<void> snoozePersonalizationReminders({int hours = 48}) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil =
        DateTime.now().add(Duration(hours: hours)).millisecondsSinceEpoch;
    await prefs.setInt('personalization_snooze_until', snoozeUntil);
  }

  /// Verificar si los recordatorios están en modo snooze
  Future<bool> _isPersonalizationSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = prefs.getInt('personalization_snooze_until') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (snoozeUntil > now) {
      return true;
    }
    return false;
  }

  /// Sistema de recuperación automática del Timer
  void _setupTimerRecovery() {
    // Verificar y reactivar timers cada 5 minutos si se detuvieron
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (!SimpleEventChecker.isActive) {
        await SimpleEventChecker.startChecking();
      }

      if (!ChallengeNotificationService.isActive) {
        await ChallengeNotificationService.startChecking();
      }
    });

    // CORREGIDO: SISTEMA DE VERIFICACIÓN NOCTURNA SOLO DESPUÉS DE MEDIANOCHE
    // Un solo timer cada 15 minutos, pero SOLO verifica después de las 00:00
    Timer.periodic(Duration(minutes: 15), (timer) async {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      // CORRECCIÓN CRÍTICA TOTAL: SOLO ejecutar entre 00:00 y 02:00
      // ABSOLUTAMENTE PROHIBIDO ejecutar durante el día (02:01-23:59)
      if (now.hour > 2) {
        // BLOQUEAR COMPLETAMENTE durante TODO EL DÍA
        return;
      }

      // Verificar si necesita ejecutar verificación nocturna
      bool shouldExecute = false;
      String reason = '';

      // CONDICIÓN ULTRA ESTRICTA: Solo entre 00:15 y 01:30
      if (now.hour == 0 && now.minute >= 15) {
        // Verificar si ya se ejecutó hoy
        final lastVerificationStr = prefs.getString('last_night_verification');
        final today = DateTime(now.year, now.month, now.day);

        bool alreadyExecutedToday = false;
        if (lastVerificationStr != null) {
          final lastVerification = DateTime.parse(lastVerificationStr);
          final lastVerificationDate = DateTime(
            lastVerification.year,
            lastVerification.month,
            lastVerification.day,
          );
          alreadyExecutedToday = !lastVerificationDate.isBefore(today);
        }

        if (!alreadyExecutedToday) {
          shouldExecute = true;
          reason =
              'Ventana NOCTURNA ESTRICTA (${now.hour}:${now.minute.toString().padLeft(2, '0')})';
        }
      }
      // Solo recuperación nocturna entre 01:30 y 02:00
      else if (now.hour == 1 && now.minute >= 30) {
        final lastVerificationStr = prefs.getString('last_night_verification');
        final today = DateTime(now.year, now.month, now.day);

        bool needsRecovery = true;
        if (lastVerificationStr != null) {
          final lastVerification = DateTime.parse(lastVerificationStr);
          final lastVerificationDate = DateTime(
            lastVerification.year,
            lastVerification.month,
            lastVerification.day,
          );
          needsRecovery = lastVerificationDate.isBefore(today);
        }

        if (needsRecovery) {
          shouldExecute = true;
          reason =
              'Recuperación NOCTURNA TARDÍA (${now.hour}:${now.minute.toString().padLeft(2, '0')})';
        }
      }

      if (shouldExecute) {
        await _checkMissedConfirmationsAndApplyConsequences();

        // Marcar como ejecutada
        final today = DateTime(now.year, now.month, now.day);
        await prefs.setString(
          'last_night_verification',
          today.toIso8601String(),
        );
      }
    });

    // Timer adicional para mensajes motivacionales aleatorios
    Timer.periodic(Duration(hours: 3), (timer) async {
      await MilestoneNotificationService.sendMotivationalMessage();
    });

    // Notificación educativa para el usuario (una sola vez)
    _showOptimalUsageHint();
  }

  /// Muestra hint sobre uso óptimo (solo la primera vez)
  Future<void> _showOptimalUsageHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownHint = prefs.getBool('has_shown_usage_hint') ?? false;

    if (!hasShownHint) {
      // Esperar 30 segundos para que el usuario explore la app
      Timer(Duration(seconds: 30), () async {
        // Crear payload para navegación a configuración
        final payload = NotificationNavigationService.createSettingsPayload();

        await NotificationService.instance.showImmediateNotification(
          id: 99999,
          title: '💡 Tip: Para mejores notificaciones',
          body:
              'Mantén la app minimizada (no cerrada) para recibir todos los recordatorios. ¡Funciona perfectamente en segundo plano! 🚀',
          payload: payload,
        );

        // Marcar como mostrado
        await prefs.setBool('has_shown_usage_hint', true);
      });
    }
  }

  /// NUEVO: SISTEMA AUTOMÁTICO DE VERIFICACIÓN NOCTURNA
  /// Verifica retos no confirmados el día anterior y aplica consecuencias automáticas
  Future<void> _checkMissedConfirmationsAndApplyConsequences() async {
    final prefs = await SharedPreferences.getInstance();
    final executionId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final now = DateTime.now();

      // Registro detallado: Guardar inicio de verificación
      await prefs.setString(
        'last_verification_start_$executionId',
        now.toIso8601String(),
      );
      await prefs.setString('current_verification_status', 'INICIANDO');

      // Calcular el día de ayer usando subtract() para evitar errores de fecha
      final yesterday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 1));

      // Registro: Guardar día verificado
      await prefs.setString('last_verified_date', yesterday.toIso8601String());

      // Obtener todos los retos individuales
      final streakService = IndividualStreakService.instance;
      final allStreaks = streakService.streaks;

      if (allStreaks.isEmpty) {
        await prefs.setString(
          'current_verification_status',
          'COMPLETADO_SIN_RETOS',
        );
        return;
      }

      await prefs.setString('current_verification_status', 'PROCESANDO_RETOS');
      await prefs.setInt('total_challenges_found', allStreaks.length);

      int retosVerificados = 0;
      int retosConFallo = 0;
      int fichasUsadas = 0;
      int rachasPerdidas = 0;

      // Verificar cada reto individualmente
      for (final entry in allStreaks.entries) {
        final challengeId = entry.key;
        final streak = entry.value;

        retosVerificados++;

        // Verificar si fue confirmado ayer
        final wasConfirmedYesterday = _wasConfirmedOnDate(streak, yesterday);

        // CORRECCIÓN CRÍTICA: Verificar si el usuario YA interactuó con el reto ayer
        // (ya sea confirmando éxito o usando ficha de perdón en ventana de confirmación)
        final userAlreadyInteracted = await _didUserInteractWithChallengeOnDate(
          challengeId,
          yesterday,
        );

        // Registro detallado: Guardar estado de cada reto
        await prefs.setString(
          'challenge_${challengeId}_status_$executionId',
          'confirmed:$wasConfirmedYesterday,interacted:$userAlreadyInteracted,tokens:${streak.forgivenessTokens},streak:${streak.currentStreak}',
        );

        // LÓGICA CORREGIDA: Solo aplicar consecuencias si el usuario NO interactuó
        if (!wasConfirmedYesterday && !userAlreadyInteracted) {
          // No fue confirmado ayer Y el usuario no interactuó - aplicar consecuencias
          retosConFallo++;

          await _applyMissedConfirmationPenalty(
            challengeId,
            streak.challengeTitle,
            yesterday,
          );

          // Verificar si se usó ficha o se perdió racha
          final updatedStreak = streakService.getStreak(challengeId);
          if (updatedStreak != null) {
            // Si las fichas disminuyeron, se usó una ficha
            if (updatedStreak.forgivenessTokens < streak.forgivenessTokens) {
              fichasUsadas++;
            }
            // Si la racha se reseteó, se perdió
            if (updatedStreak.currentStreak == 0 && streak.currentStreak > 0) {
              rachasPerdidas++;
            }

            // Registro final: Estado después del procesamiento
            await prefs.setString(
              'challenge_${challengeId}_result_$executionId',
              'tokens_used:${streak.forgivenessTokens - updatedStreak.forgivenessTokens},streak_lost:${updatedStreak.currentStreak == 0 && streak.currentStreak > 0}',
            );
          }
        } else if (!wasConfirmedYesterday && userAlreadyInteracted) {
          // El usuario ya interactuó (usó ficha de perdón) - no aplicar consecuencias adicionales
          continue; // Saltar al siguiente reto
        } else {
          continue; // Saltar al siguiente reto
        }
      }

      // Registro final: Marcar verificación como completada
      await prefs.setString('current_verification_status', 'COMPLETADO');
      await prefs.setString(
        'last_verification_end_$executionId',
        DateTime.now().toIso8601String(),
      );

      // Guardar estadísticas de la verificación
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await prefs.setInt('night_check_verified_$dateKey', retosVerificados);
      await prefs.setInt('night_check_failed_$dateKey', retosConFallo);
      await prefs.setInt('night_check_tokens_used_$dateKey', fichasUsadas);
      await prefs.setInt('night_check_streaks_lost_$dateKey', rachasPerdidas);

      // Notificación de confirmación (para debugging)
      if (retosConFallo > 0) {
        await NotificationService.instance.showImmediateNotification(
          id: 99999,
          title: '🌙 Verificación nocturna ejecutada',
          body:
              'Procesados $retosVerificados retos. $retosConFallo fallos detectados. Fichas usadas: $fichasUsadas. Rachas perdidas: $rachasPerdidas.',
          payload:
              '{"action":"verification_summary","date":"${yesterday.day}/${yesterday.month}"}',
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  /// Verificar si un reto fue confirmado en una fecha específica
  bool _wasConfirmedOnDate(ChallengeStreak streak, DateTime targetDate) {
    final targetNormalized = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    return streak.confirmationHistory.any((confirmation) {
      final confirmNormalized = DateTime(
        confirmation.year,
        confirmation.month,
        confirmation.day,
      );
      return confirmNormalized.isAtSameMomentAs(targetNormalized);
    });
  }

  /// NUEVA FUNCIÓN: Verificar si el usuario ya interactuó con un reto en una fecha específica
  /// (ya sea confirmando éxito o usando ficha de perdón en ventana de confirmación)
  Future<bool> _didUserInteractWithChallengeOnDate(
    String challengeId,
    DateTime targetDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey =
        '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

    // Verificar si hay registro de interacción del usuario para esta fecha
    // Esto se marca cuando el usuario usa ficha de perdón en ventana de confirmación
    final interactionKey = 'user_interacted_${challengeId}_$dateKey';
    final didInteract = prefs.getBool(interactionKey) ?? false;

    return didInteract;
  }

  /// NUEVA FUNCIÓN: Marcar que el usuario interactuó con un reto en una fecha específica
  /// Esta función debe ser llamada desde counters_page.dart cuando el usuario usa ficha de perdón
  static Future<void> markUserInteractionWithChallenge(
    String challengeId,
    DateTime date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final interactionKey = 'user_interacted_${challengeId}_$dateKey';

    await prefs.setBool(interactionKey, true);
  }

  /// Aplicar penalización por confirmación perdida (usar ficha de perdón o resetear racha)
  Future<void> _applyMissedConfirmationPenalty(
    String challengeId,
    String challengeTitle,
    DateTime missedDate,
  ) async {
    final streakService = IndividualStreakService.instance;
    final streak = streakService.getStreak(challengeId);

    if (streak == null) {
      return;
    }

    // Verificar si puede usar ficha de perdón
    if (streak.forgivenessTokens > 0) {
      // USAR FICHA DE PERDÓN AUTOMÁTICAMENTE
      final success = await streakService.failChallenge(
        challengeId,
        challengeTitle,
        useForgiveness: true,
      );

      if (success) {
        // Crear payload para navegación al reto específico
        final payload =
            NotificationNavigationService.createChallengeConfirmationPayload(
              challengeName: challengeTitle,
            );

        // Notificación informativa con navegación
        await NotificationService.instance.showImmediateNotification(
          id: 77700 + challengeId.hashCode.abs() % 1000,
          title: '🛡️ Ficha de perdón usada',
          body:
              'Ficha usada para "$challengeTitle" (${missedDate.day}/${missedDate.month}). Racha preservada.',
          payload: payload,
        );
      }
    } else {
      // NO HAY FICHAS - RESETEAR RACHA
      await streakService.failChallenge(
        challengeId,
        challengeTitle,
        useForgiveness: false,
      );

      // Crear payload para navegación al reto específico
      final payload =
          NotificationNavigationService.createChallengeConfirmationPayload(
            challengeName: challengeTitle,
          );

      // Notificación de racha perdida con navegación
      await NotificationService.instance.showImmediateNotification(
        id: 77800 + challengeId.hashCode.abs() % 1000,
        title: '💔 Racha perdida',
        body:
            'No confirmaste "$challengeTitle" ayer (${missedDate.day}/${missedDate.month}). Racha reseteada.',
        payload: payload,
      );
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
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    // Configurar contexto global para navegación desde notificaciones
    NotificationNavigationService.setGlobalContext(context);

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
        ChangeNotifierProvider.value(value: NotificationCenterService.instance),
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

/// FUNCIÓN GLOBAL: Marcar interacción del usuario para evitar doble penalización
/// Accesible desde cualquier archivo que importe main.dart
Future<void> markUserInteractionWithChallenge(
  String challengeId,
  DateTime date,
) async {
  await _MyAppState.markUserInteractionWithChallenge(challengeId, date);
}

/// NUEVA FUNCIÓN: Recuperar fichas de perdón gastadas por error
/// Útil para casos donde el verificador nocturno aplicó penalizaciones incorrectas
Future<void> recoverIncorrectlyUsedTokens() async {
  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    // Obtener todos los retos
    final streakService = IndividualStreakService.instance;
    final allStreaks = streakService.streaks;

    if (allStreaks.isEmpty) {
      return;
    }

    List<String> retosAfectados = [];
    int fichasRecuperadas = 0;

    for (final entry in allStreaks.entries) {
      final challengeId = entry.key;
      final streak = entry.value;

      // Verificar si fue confirmado ayer usando el método existente
      final wasConfirmedYesterday = streak.confirmationHistory.any((
        confirmation,
      ) {
        final confirmNormalized = DateTime(
          confirmation.year,
          confirmation.month,
          confirmation.day,
        );
        final yesterdayNormalized = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        return confirmNormalized.isAtSameMomentAs(yesterdayNormalized);
      });

      // Verificar si se usó ficha de perdón ayer
      final lastForgivenessUsed = streak.lastForgivenessUsed;
      bool tokenUsedYesterday = false;

      if (lastForgivenessUsed != null) {
        final forgivenessDate = DateTime(
          lastForgivenessUsed.year,
          lastForgivenessUsed.month,
          lastForgivenessUsed.day,
        );
        final yesterdayNormalized = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        tokenUsedYesterday = forgivenessDate.isAtSameMomentAs(
          yesterdayNormalized,
        );
      }

      // Si fue confirmado correctamente pero también se usó una ficha el mismo día, es un error
      if (wasConfirmedYesterday && tokenUsedYesterday) {
        retosAfectados.add(streak.challengeTitle);
        fichasRecuperadas++;

        // Usar el sistema de emergencia para restaurar fichas
        await streakService.registerChallenge(
          challengeId,
          streak.challengeTitle,
        );

        // Notificar al usuario sobre la recuperación
        await NotificationService.instance.showImmediateNotification(
          id: 88800 + challengeId.hashCode.abs() % 1000,
          title: '🛡️ Error detectado y corregido',
          body:
              'Se detectó un error en "${streak.challengeTitle}" donde se usó incorrectamente una ficha de perdón. Contacta al soporte si esto se repite.',
          payload:
              '{"action":"token_recovery","challenge":"${streak.challengeTitle}"}',
        );
      }
    }

    if (retosAfectados.isNotEmpty) {
      // Notificación resumen
      await NotificationService.instance.showImmediateNotification(
        id: 88888,
        title: '🔧 Diagnóstico completado',
        body:
            'Se detectaron $fichasRecuperadas posibles errores en el sistema. Se han aplicado correcciones preventivas.',
        payload:
            '{"action":"diagnostic_summary","recovered":$fichasRecuperadas}',
      );
    }
  } catch (e) {
    // Error handling
  }
}
