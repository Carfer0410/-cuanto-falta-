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
    
    // 🆕 INICIALIZAR CENTRO DE NOTIFICACIONES
    await NotificationCenterService.instance.init();
    
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
    print('  🌙 VERIFICACIÓN NOCTURNA AUTOMÁTICA:');
    print('     🕐 Verificación principal: 00:25-00:35');
    print('     🔄 Verificación de respaldo: cada 30 min después de 00:30');
    print('     📱 Verificación al abrir app: si faltó verificación nocturna');
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
          // 🆕 NUEVO: Crear payload para navegación a configuración de estilo
          final payload = NotificationNavigationService.createPlanningStylePayload();
          
          await NotificationService.instance.showImmediateNotification(
            id: 99998,
            title: title,
            body: body,
            payload: payload,  // 🆕 NUEVO: Incluir payload de navegación
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
    
    // 🆕 MEJORADO: SISTEMA SIMPLIFICADO DE VERIFICACIÓN NOCTURNA
    // Un solo timer cada 15 minutos para mayor robustez
    Timer.periodic(Duration(minutes: 15), (timer) async {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si necesita ejecutar verificación nocturna
      bool shouldExecute = false;
      String reason = '';
      
      // Condición 1: Es la ventana principal (00:15 - 01:00)
      if ((now.hour == 0 && now.minute >= 15) || (now.hour == 1 && now.minute == 0)) {
        // Verificar si ya se ejecutó hoy
        final lastVerificationStr = prefs.getString('last_night_verification');
        final today = DateTime(now.year, now.month, now.day);
        
        bool alreadyExecutedToday = false;
        if (lastVerificationStr != null) {
          final lastVerification = DateTime.parse(lastVerificationStr);
          final lastVerificationDate = DateTime(lastVerification.year, lastVerification.month, lastVerification.day);
          alreadyExecutedToday = !lastVerificationDate.isBefore(today);
        }
        
        if (!alreadyExecutedToday) {
          shouldExecute = true;
          reason = 'Ventana principal de verificación (${now.hour}:${now.minute.toString().padLeft(2, '0')})';
        }
      }
      
      // Condición 2: Verificación de recuperación (después de las 01:00 si no se ejecutó)
      else if (now.hour >= 1) {
        final lastVerificationStr = prefs.getString('last_night_verification');
        final today = DateTime(now.year, now.month, now.day);
        
        bool needsRecovery = true;
        if (lastVerificationStr != null) {
          final lastVerification = DateTime.parse(lastVerificationStr);
          final lastVerificationDate = DateTime(lastVerification.year, lastVerification.month, lastVerification.day);
          needsRecovery = lastVerificationDate.isBefore(today);
        }
        
        if (needsRecovery) {
          shouldExecute = true;
          reason = 'Verificación de recuperación (${now.hour}:${now.minute.toString().padLeft(2, '0')})';
        }
      }
      
      if (shouldExecute) {
        print('🌙 === VERIFICACIÓN NOCTURNA AUTOMÁTICA ===');
        print('📅 Razón: $reason');
        
        await _checkMissedConfirmationsAndApplyConsequences();
        
        // Marcar como ejecutada
        final today = DateTime(now.year, now.month, now.day);
        await prefs.setString('last_night_verification', today.toIso8601String());
        
        print('🔧 Verificación marcada como ejecutada para hoy');
      }
    });
    
    // 2. 🔧 VERIFICACIÓN AL INICIAR LA APP (para casos donde app estuvo cerrada)
    Timer(Duration(seconds: 5), () async {
      await _checkPendingNightVerification();
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
        // 🆕 NUEVO: Crear payload para navegación a configuración
        final payload = NotificationNavigationService.createSettingsPayload();
        
        await NotificationService.instance.showImmediateNotification(
          id: 99999,
          title: '💡 Tip: Para mejores notificaciones',
          body: 'Mantén la app minimizada (no cerrada) para recibir todos los recordatorios. ¡Funciona perfectamente en segundo plano! 🚀',
          payload: payload,  // 🆕 NUEVO: Incluir payload de navegación
        );
        
        // Marcar como mostrado
        await prefs.setBool('has_shown_usage_hint', true);
        print('💡 Hint de uso óptimo mostrado al usuario');
      });
    }
  }

  /// 🔧 MEJORADO: Verificar múltiples días de verificaciones pendientes
  /// Se ejecuta al iniciar la app para capturar verificaciones perdidas de varios días
  Future<void> _checkPendingNightVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      print('🔍 === VERIFICACIÓN DE DÍAS PENDIENTES ===');
      
      // Obtener la fecha de la última verificación nocturna ejecutada
      final lastNightCheckStr = prefs.getString('last_night_verification');
      final today = DateTime(now.year, now.month, now.day);
      
      DateTime? lastNightCheck;
      if (lastNightCheckStr != null) {
        lastNightCheck = DateTime.parse(lastNightCheckStr);
      }
      
      // Determinar cuántos días han pasado sin verificación
      List<DateTime> daysMissed = [];
      
      if (lastNightCheck == null) {
        // Primera vez - verificar últimos 3 días por seguridad
        for (int i = 1; i <= 3; i++) {
          daysMissed.add(today.subtract(Duration(days: i)));
        }
        print('📅 Primera verificación - revisando últimos 3 días');
      } else {
        final lastCheckDate = DateTime(lastNightCheck.year, lastNightCheck.month, lastNightCheck.day);
        
        // Verificar cada día desde la última verificación
        DateTime checkDate = lastCheckDate.add(Duration(days: 1));
        while (checkDate.isBefore(today) || checkDate.isAtSameMomentAs(today)) {
          daysMissed.add(checkDate);
          checkDate = checkDate.add(Duration(days: 1));
        }
        
        if (daysMissed.isNotEmpty) {
          print('📅 Días sin verificar desde ${lastCheckDate.day}/${lastCheckDate.month}: ${daysMissed.length}');
        }
      }
      
      if (daysMissed.isNotEmpty) {
        print('🌙 ⚡ EJECUTANDO VERIFICACIONES PENDIENTES');
        print('� Total de días a verificar: ${daysMissed.length}');
        
        for (final missedDay in daysMissed) {
          print('�️ Verificando día: ${missedDay.day}/${missedDay.month}/${missedDay.year}');
          
          await _checkMissedConfirmationsForSpecificDate(missedDay);
          
          // Pequeña pausa para evitar sobrecarga
          await Future.delayed(Duration(milliseconds: 100));
        }
        
        // Marcar como ejecutada para HOY
        await prefs.setString('last_night_verification', today.toIso8601String());
        
        print('✅ Todas las verificaciones pendientes completadas');
        
        // Notificación resumen
        await NotificationService.instance.showImmediateNotification(
          id: 99998,
          title: '🌙 Verificación de recuperación',
          body: 'Se procesaron ${daysMissed.length} días pendientes. Revisa el centro de notificaciones para más detalles.',
          payload: '{"action":"recovery_summary","days":${daysMissed.length}}',
        );
        
      } else {
        print('✅ No hay verificaciones pendientes');
      }
      
    } catch (e) {
      print('❌ Error verificando verificaciones pendientes: $e');
    }
  }
  
  /// 🆕 NUEVA FUNCIÓN: Verificar confirmaciones para una fecha específica
  Future<void> _checkMissedConfirmationsForSpecificDate(DateTime targetDate) async {
    try {
      print('🔍 Verificando confirmaciones para: ${targetDate.day}/${targetDate.month}/${targetDate.year}');
      
      // Obtener todos los retos individuales
      final streakService = IndividualStreakService.instance;
      final allStreaks = streakService.streaks;
      
      if (allStreaks.isEmpty) {
        print('📝 No hay retos registrados para esta fecha');
        return;
      }
      
      int retosVerificados = 0;
      int retosConFallo = 0;
      
      // Verificar cada reto individualmente
      for (final entry in allStreaks.entries) {
        final challengeId = entry.key;
        final streak = entry.value;
        
        retosVerificados++;
        
        // Verificar si fue confirmado en la fecha objetivo
        final wasConfirmedOnDate = _wasConfirmedOnDate(streak, targetDate);
        
        if (!wasConfirmedOnDate) {
          retosConFallo++;
          print('   ❌ "${streak.challengeTitle}" no confirmado el ${targetDate.day}/${targetDate.month}');
          
          await _applyMissedConfirmationPenalty(
            challengeId, 
            streak.challengeTitle,
            targetDate
          );
        } else {
          print('   ✅ "${streak.challengeTitle}" confirmado correctamente');
        }
      }
      
      print('📊 Resumen ${targetDate.day}/${targetDate.month}: $retosVerificados verificados, $retosConFallo fallos');
      
    } catch (e) {
      print('❌ Error verificando fecha ${targetDate.day}/${targetDate.month}: $e');
    }
  }

  /// 🆕 NUEVO: SISTEMA AUTOMÁTICO DE VERIFICACIÓN NOCTURNA
  /// Verifica retos no confirmados el día anterior y aplica consecuencias automáticas
  Future<void> _checkMissedConfirmationsAndApplyConsequences() async {
    final prefs = await SharedPreferences.getInstance();
    final executionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      final now = DateTime.now();
      print('🔍 === INICIANDO VERIFICACIÓN NOCTURNA ===');
      print('🆔 ID de ejecución: $executionId');
      print('🕐 Hora actual: ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');
      print('📅 Fecha actual: ${now.day}/${now.month}/${now.year}');
      
      // 🔧 REGISTRO DETALLADO: Guardar inicio de verificación
      await prefs.setString('last_verification_start_$executionId', now.toIso8601String());
      await prefs.setString('current_verification_status', 'INICIANDO');
      
      // Calcular el día de ayer usando subtract() para evitar errores de fecha
      final yesterday = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
      
      print('🗓️ Verificando confirmaciones del día: ${yesterday.day}/${yesterday.month}/${yesterday.year}');
      
      // 🔧 REGISTRO: Guardar día verificado
      await prefs.setString('last_verified_date', yesterday.toIso8601String());
      
      // Obtener todos los retos individuales
      final streakService = IndividualStreakService.instance;
      final allStreaks = streakService.streaks;
      
      if (allStreaks.isEmpty) {
        print('📝 No hay retos registrados, saliendo...');
        await prefs.setString('current_verification_status', 'COMPLETADO_SIN_RETOS');
        return;
      }
      
      print('📊 Total de retos encontrados: ${allStreaks.length}');
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
        
        // 🔧 REGISTRO: Estado inicial del reto
        print('🔍 "${streak.challengeTitle}":');
        print('   📊 Fichas antes: ${streak.forgivenessTokens}');
        print('   📊 Racha antes: ${streak.currentStreak}');
        
        // Verificar si fue confirmado ayer
        final wasConfirmedYesterday = _wasConfirmedOnDate(streak, yesterday);
        
        print('   ¿Confirmado ayer? ${wasConfirmedYesterday ? "SÍ ✅" : "NO ❌"}');
        
        // 🔧 REGISTRO DETALLADO: Guardar estado de cada reto
        await prefs.setString('challenge_${challengeId}_status_$executionId', 
          'confirmed:$wasConfirmedYesterday,tokens:${streak.forgivenessTokens},streak:${streak.currentStreak}');
        
        if (!wasConfirmedYesterday) {
          // No fue confirmado ayer - aplicar consecuencias
          retosConFallo++;
          print('   ⚡ Aplicando consecuencias...');
          
          await _applyMissedConfirmationPenalty(
            challengeId, 
            streak.challengeTitle,
            yesterday
          );
          
          // Verificar si se usó ficha o se perdió racha
          final updatedStreak = streakService.getStreak(challengeId);
          if (updatedStreak != null) {
            print('   📊 Fichas después: ${updatedStreak.forgivenessTokens}');
            print('   📊 Racha después: ${updatedStreak.currentStreak}');
            
            // Si las fichas disminuyeron, se usó una ficha
            if (updatedStreak.forgivenessTokens < streak.forgivenessTokens) {
              fichasUsadas++;
              print('   🛡️ FICHA USADA');
            }
            // Si la racha se reseteó, se perdió
            if (updatedStreak.currentStreak == 0 && streak.currentStreak > 0) {
              rachasPerdidas++;
              print('   💔 RACHA PERDIDA');
            }
            
            // 🔧 REGISTRO FINAL: Estado después del procesamiento
            await prefs.setString('challenge_${challengeId}_result_$executionId', 
              'tokens_used:${streak.forgivenessTokens - updatedStreak.forgivenessTokens},streak_lost:${updatedStreak.currentStreak == 0 && streak.currentStreak > 0}');
          }
        } else {
          print('   ✅ Reto confirmado correctamente');
        }
      }
      
      // Resumen final
      print('📊 === RESUMEN VERIFICACIÓN NOCTURNA ===');
      print('🔍 Retos verificados: $retosVerificados');
      print('❌ Retos con fallo: $retosConFallo');
      print('🛡️ Fichas de perdón usadas: $fichasUsadas');
      print('💔 Rachas perdidas: $rachasPerdidas');
      print('✅ Verificación nocturna completada');
      
      // 🔧 REGISTRO FINAL: Marcar verificación como completada
      await prefs.setString('current_verification_status', 'COMPLETADO');
      await prefs.setString('last_verification_end_$executionId', DateTime.now().toIso8601String());
      
      // Guardar estadísticas de la verificación 
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await prefs.setInt('night_check_verified_$dateKey', retosVerificados);
      await prefs.setInt('night_check_failed_$dateKey', retosConFallo);
      await prefs.setInt('night_check_tokens_used_$dateKey', fichasUsadas);
      await prefs.setInt('night_check_streaks_lost_$dateKey', rachasPerdidas);
      
      // 🚨 NOTIFICACIÓN DE CONFIRMACIÓN (para debugging)
      if (retosConFallo > 0) {
        await NotificationService.instance.showImmediateNotification(
          id: 99999,
          title: '🌙 Verificación nocturna ejecutada',
          body: 'Procesados $retosVerificados retos. $retosConFallo fallos detectados. Fichas usadas: $fichasUsadas. Rachas perdidas: $rachasPerdidas.',
          payload: '{"action":"verification_summary","date":"${yesterday.day}/${yesterday.month}"}',
        );
      }
      
    } catch (e) {
      print('❌ Error en verificación nocturna: $e');
    }
  }

  /// Verificar si un reto fue confirmado en una fecha específica
  bool _wasConfirmedOnDate(ChallengeStreak streak, DateTime targetDate) {
    final targetNormalized = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    return streak.confirmationHistory.any((confirmation) {
      final confirmNormalized = DateTime(confirmation.year, confirmation.month, confirmation.day);
      return confirmNormalized.isAtSameMomentAs(targetNormalized);
    });
  }

  /// Aplicar penalización por confirmación perdida (usar ficha de perdón o resetear racha)
  Future<void> _applyMissedConfirmationPenalty(String challengeId, String challengeTitle, DateTime missedDate) async {
    final streakService = IndividualStreakService.instance;
    final streak = streakService.getStreak(challengeId);
    
    if (streak == null) {
      print('⚠️ No se encontró racha para $challengeId');
      return;
    }
    
    print('⚡ Aplicando consecuencia a "${challengeTitle}"...');
    
    // Verificar si puede usar ficha de perdón
    if (streak.forgivenessTokens > 0) {
      // USAR FICHA DE PERDÓN AUTOMÁTICAMENTE
      print('🛡️ Usando ficha de perdón automáticamente');
      
      final success = await streakService.failChallenge(
        challengeId, 
        challengeTitle, 
        useForgiveness: true
      );
      
      if (success) {
        // Crear payload para navegación al reto específico
        final payload = NotificationNavigationService.createChallengeConfirmationPayload(
          challengeName: challengeTitle,
        );
        
        // Notificación informativa con navegación
        await NotificationService.instance.showImmediateNotification(
          id: 77700 + challengeId.hashCode.abs() % 1000,
          title: '🛡️ Ficha de perdón usada',
          body: 'Ficha usada para "$challengeTitle" (${missedDate.day}/${missedDate.month}). Racha preservada.',
          payload: payload,
        );
        
        print('✅ Ficha de perdón usada exitosamente');
      } else {
        print('❌ Error al usar ficha de perdón');
      }
      
    } else {
      // NO HAY FICHAS - RESETEAR RACHA
      print('💔 No hay fichas de perdón disponibles, reseteando racha');
      
      await streakService.failChallenge(challengeId, challengeTitle, useForgiveness: false);
      
      // Crear payload para navegación al reto específico
      final payload = NotificationNavigationService.createChallengeConfirmationPayload(
        challengeName: challengeTitle,
      );
      
      // Notificación de racha perdida con navegación
      await NotificationService.instance.showImmediateNotification(
        id: 77800 + challengeId.hashCode.abs() % 1000,
        title: '💔 Racha perdida',
        body: 'No confirmaste "$challengeTitle" ayer (${missedDate.day}/${missedDate.month}). Racha reseteada.',
        payload: payload,
      );
      
      print('💔 Racha reseteada por falta de confirmación');
    }
  }

  /// 🧪 FUNCIÓN DE PRUEBA: Ejecutar verificación nocturna manualmente
  /// Útil para probar el sistema sin esperar a las 00:30
  /// Para usar: descomenta y llama _MyAppState.testNightVerification()
  /*
  static Future<void> testNightVerification() async {
    print('🧪 === PRUEBA MANUAL DE VERIFICACIÓN NOCTURNA ===');
    
    // Crear instancia temporal para acceder al método
    final appState = _MyAppState();
    await appState._checkMissedConfirmationsAndApplyConsequences();
    
    print('🧪 === PRUEBA COMPLETADA ===');
  }
  */

  /// 🧪 FUNCIÓN DE PRUEBA: Forzar verificación de día específico
  /// Útil para probar con fechas personalizadas
  /// Para usar: descomenta y llama _MyAppState.testNightVerificationForDate(DateTime(2025, 7, 31))
  /*
  static Future<void> testNightVerificationForDate(DateTime targetDate) async {
    print('🧪 === PRUEBA CON FECHA ESPECÍFICA: ${targetDate.day}/${targetDate.month}/${targetDate.year} ===');
    
    try {
      // Obtener todos los retos individuales
      final streakService = IndividualStreakService.instance;
      final allStreaks = streakService.streaks;
      
      if (allStreaks.isEmpty) {
        print('📝 No hay retos registrados');
        return;
      }
      
      print('📊 Verificando ${allStreaks.length} retos para fecha ${targetDate.day}/${targetDate.month}');
      
      // Verificar cada reto
      for (final entry in allStreaks.entries) {
        final streak = entry.value;
        
        // Verificar si fue confirmado en la fecha objetivo
        final wasConfirmed = streak.confirmationHistory.any((confirmation) {
          final confirmDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
          final targetNormalized = DateTime(targetDate.year, targetDate.month, targetDate.day);
          return confirmDate.isAtSameMomentAs(targetNormalized);
        });
        
        print('🔍 "${streak.challengeTitle}": ${wasConfirmed ? "CONFIRMADO ✅" : "NO CONFIRMADO ❌"}');
        
        if (!wasConfirmed) {
          print('   📊 Racha actual: ${streak.currentStreak}');
          print('   🛡️ Fichas disponibles: ${streak.forgivenessTokens}');
          
          if (streak.forgivenessTokens > 0) {
            print('   💡 Se usaría ficha de perdón');
          } else {
            print('   💔 Se resetearía la racha');
          }
        }
      }
      
    } catch (e) {
      print('❌ Error en prueba: $e');
    }
    
    print('🧪 === PRUEBA COMPLETADA ===');
  }
  */

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
    // 🆕 NUEVO: Configurar contexto global para navegación desde notificaciones
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
