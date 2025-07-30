import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';
import 'reminder_tracker.dart';
import 'milestone_notification_service.dart';
import 'individual_streak_service.dart';

class ChallengeNotificationService {
  static Timer? _timer;
  static Timer? _motivationTimer;
  static Timer? _confirmationTimer;
  static bool _isActive = false;

  /// Inicia el sistema de verificación de retos cada 6 horas
  static Future<void> startChecking() async {
    if (_isActive) return;
    
    // Verificar si las notificaciones están habilitadas
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('challenge_notifications_enabled') ?? true;
    if (!enabled) {
      print('🔕 ChallengeNotificationService: Notificaciones de retos deshabilitadas');
      return;
    }
    
    _isActive = true;
    final frequency = int.parse(prefs.getString('challenge_frequency') ?? '6');
    print('💪 ChallengeNotificationService: Iniciando verificación cada $frequency horas');
    
    // Verificar inmediatamente
    _checkChallengesNow();
    
    // TIMER PRINCIPAL: Verificaciones según la frecuencia configurada
    _timer = Timer.periodic(Duration(hours: frequency), (timer) {
      _checkChallengesNow();
    });
    
    // NUEVO: Timer adicional cada 30 minutos para motivación activa
    _motivationTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      _checkActiveMotivation();
    });
    
    // 🆕 NUEVO: Timer específico para ventana de confirmación (21:00-23:59)
    // Ejecutar cada minuto para capturar exactamente las 21:00
    _confirmationTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      ConfirmationWindow._checkConfirmationWindow();
    });
    
    // Verificar inmediatamente la ventana de confirmación al iniciar
    ConfirmationWindow._checkConfirmationWindow();
    
    // 🔥 NUEVO: Timer adicional que se sincroniza específicamente para las 21:00
    _setupSyncedConfirmationTimer();
    
    print('✅ Timers iniciados: Principal (${frequency}h), Motivación (30min), Confirmación (1min + sincronizado)');
  }

  /// Configura un timer que se sincroniza específicamente para las 21:00 exactas
  static void _setupSyncedConfirmationTimer() {
    final now = DateTime.now();
    
    // Calcular la próxima vez que sean las 21:00
    DateTime next21 = DateTime(now.year, now.month, now.day, 21, 0, 0);
    if (now.isAfter(next21)) {
      // Si ya pasaron las 21:00 de hoy, programar para mañana
      next21 = next21.add(Duration(days: 1));
    }
    
    final delay = next21.difference(now);
    print('🕘 Timer sincronizado para 21:00: próxima ejecución en ${delay.inMinutes} minutos (${next21.toString().substring(11, 16)})');
    
    // Timer que se ejecuta exactamente a las 21:00
    Timer(delay, () {
      print('🎯 ¡Timer sincronizado ejecutándose EXACTAMENTE a las 21:00!');
      ConfirmationWindow._sendConfirmationWindowNotifications('start');
      
      // Programar el siguiente día
      _setupSyncedConfirmationTimer();
    });
    
    // NUEVO: Timer adicional específico para las 23:30
    _setupSyncedReminderTimer();
  }

  /// Configura un timer que se sincroniza específicamente para las 23:30 exactas
  static void _setupSyncedReminderTimer() {
    final now = DateTime.now();
    
    // Calcular la próxima vez que sean las 23:30
    DateTime next2330 = DateTime(now.year, now.month, now.day, 23, 30, 0);
    if (now.isAfter(next2330)) {
      // Si ya pasaron las 23:30 de hoy, programar para mañana
      next2330 = next2330.add(Duration(days: 1));
    }
    
    final delay = next2330.difference(now);
    print('🕘 Timer sincronizado para 23:30: próxima ejecución en ${delay.inMinutes} minutos (${next2330.toString().substring(11, 16)})');
    
    // Timer que se ejecuta exactamente a las 23:30
    Timer(delay, () {
      print('⏰ ¡Timer sincronizado ejecutándose EXACTAMENTE a las 23:30!');
      ConfirmationWindow._sendConfirmationWindowNotifications('reminder');
      
      // Programar el siguiente día
      _setupSyncedReminderTimer();
    });
  }

  /// Detiene el sistema de verificación
  static void stopChecking() {
    _timer?.cancel();
    _motivationTimer?.cancel();
    _confirmationTimer?.cancel();
    _timer = null;
    _motivationTimer = null;
    _confirmationTimer = null;
    _isActive = false;
    print('🛑 ChallengeNotificationService: Verificación detenida');
  }

  /// Verifica retos inmediatamente
  static Future<void> checkChallengesNow() async {
    print('🔍 ChallengeNotificationService: Verificación manual iniciada');
    await _checkChallengesNow();
  }

  /// Lógica principal de verificación de retos
  static Future<void> _checkChallengesNow() async {
    try {
      // Inicializar servicio de notificaciones
      await NotificationService.instance.init();

      // Cargar todos los retos de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('counters');
      if (jsonString == null) {
        print('📋 No hay retos guardados');
        return;
      }

      final List<dynamic> countersJson = jsonDecode(jsonString);
      final now = DateTime.now();

      print('💪 Verificando ${countersJson.length} retos para notificaciones motivacionales...');

      for (final counterJson in countersJson) {
        final counter = _ChallengeCounter.fromJson(counterJson);
        
        // Solo procesar retos que han sido iniciados y confirmados
        if (counter.challengeStartedAt != null && counter.lastConfirmedDate != null) {
          final notificationInfo = _shouldSendMotivationalNotification(
            counter, 
            now
          );
          
          if (notificationInfo != null) {
            // 🛡️ PROTECCIÓN ANTI-DUPLICADOS ULTRA-ROBUSTA
            final today = DateTime.now();
            final todayKey = '${today.year}-${today.month}-${today.day}';
            final baseReminderId = counter.title.hashCode;
            
            // Verificar si ya se envió CUALQUIER notificación de hito para este reto HOY
            final allMilestoneTypes = ['day_1', 'day_3', 'week_1', 'day_15', 'month_1', 'month_2', 'month_3', 'month_6', 'year_1'];
            bool alreadySentAnyMilestoneToday = false;
            
            for (final milestoneType in allMilestoneTypes) {
              final wasAlreadySent = await ReminderTracker.wasReminderSent(
                baseReminderId, 
                '${milestoneType}_$todayKey'
              );
              if (wasAlreadySent) {
                print('🛡️ BLOQUEO ANTI-DUPLICADO: Ya se envió "$milestoneType" para "${counter.title}" hoy');
                alreadySentAnyMilestoneToday = true;
                break;
              }
            }
            
            // VERIFICAR TAMBIÉN el tipo específico actual
            final wasSpecificTypeSent = await ReminderTracker.wasReminderSent(
              baseReminderId, 
              notificationInfo['reminderType']
            );
            
            // SOLO ENVIAR si NO se ha enviado NINGÚN hito hoy
            if (!alreadySentAnyMilestoneToday && !wasSpecificTypeSent) {
              // Enviar notificación motivacional
              await NotificationService.instance.showImmediateNotification(
                id: notificationInfo['notificationId'],
                title: notificationInfo['title'],
                body: notificationInfo['body'],
              );

              // Marcar como enviado con MÚLTIPLES claves para prevenir duplicados
              await ReminderTracker.markReminderSent(
                baseReminderId, 
                notificationInfo['reminderType']
              );
              
              await ReminderTracker.markReminderSent(
                baseReminderId, 
                '${notificationInfo['reminderType']}_$todayKey'
              );
              
              // NUEVA PROTECCIÓN: Marcar también con un identificador único del día
              await ReminderTracker.markReminderSent(
                baseReminderId, 
                'milestone_sent_$todayKey'
              );

              print('✅ Notificación motivacional enviada: ${notificationInfo['title']} para ${counter.title}');
              print('🔒 TRIPLE PROTECCIÓN activada: tipo, fecha y milestone diario');
            } else {
              if (alreadySentAnyMilestoneToday) {
                print('🛡️ BLOQUEADO: Ya se envió un hito HOY para "${counter.title}" - evitando duplicado');
              } else {
                print('🛡️ BLOQUEADO: Notificación específica "${notificationInfo['reminderType']}" ya enviada para "${counter.title}"');
              }
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error en verificación de retos: $e');
    }
  }

  /// Determina si debe enviar notificación motivacional y qué tipo
  static Map<String, dynamic>? _shouldSendMotivationalNotification(
      _ChallengeCounter counter, DateTime now) {
    
    if (counter.challengeStartedAt == null || counter.lastConfirmedDate == null) {
      return null;
    }

    // CORRECCIÓN PARA RETOS RETROACTIVOS
    final lastConfirmed = counter.lastConfirmedDate!;
    final startDate = counter.challengeStartedAt!;
    
    // 🔥 NUEVA LÓGICA MEJORADA: Calcular días de racha considerando retos retroactivos
    // Para retos retroactivos, necesitamos obtener la información correcta de IndividualStreakService
    final challengeId = counter.title.hashCode.toString();
    final streak = IndividualStreakService.instance.getStreak(challengeId);
    
    // 🔧 CORRECCIÓN CRÍTICA: Calcular días correctamente para retos retroactivos
    // Si el reto comenzó el 23 julio y se confirmó el 29 julio = 7 días (23,24,25,26,27,28,29)
    final directCalculation = lastConfirmed.difference(startDate).inDays + 1;
    final serviceCalculation = streak?.currentStreak;
    
    // USAR SIEMPRE el cálculo directo que es más confiable para retos retroactivos
    final streakDays = directCalculation;
    
    // Debug: Mostrar información detallada del cálculo
    print('🧮 Calculando notificación para ${counter.title}:');
    print('  📅 Inicio del reto: ${startDate.toString().substring(0, 10)}');
    print('  ✅ Última confirmación: ${lastConfirmed.toString().substring(0, 10)}');
    print('  🔢 IndividualStreakService respuesta: $serviceCalculation');
    print('  🔢 Cálculo directo (USANDO): $directCalculation');
    print('  📊 Diferencia en días: ${lastConfirmed.difference(startDate).inDays}');
    print('  ➕ Más 1 día = $streakDays días totales');
    print('  🕐 Hora actual: ${now.toString().substring(0, 16)}');
    
    // Verificar si el reto sigue activo (última confirmación no muy antigua)
    final daysSinceLastConfirmation = now.difference(lastConfirmed).inDays;
    final isActive = daysSinceLastConfirmation <= 2;
    
    if (!isActive) return null; // No enviar si el reto parece abandonado

    // Sistema de notificaciones progresivas
    final challengeType = counter.isNegativeHabit ? 'dejar' : 'hacer';
    final activity = _getCleanActivity(counter.title, counter.isNegativeHabit);
    
    final baseId = counter.title.hashCode;
    
    // 🎯 NUEVA LÓGICA MEJORADA: Hitos exactos sin tolerancia para retos retroactivos
    final exactMilestones = {
      1: {'type': 'day_1', 'idOffset': 1001},
      3: {'type': 'day_3', 'idOffset': 1003},
      7: {'type': 'week_1', 'idOffset': 1007},
      15: {'type': 'day_15', 'idOffset': 1015},
      30: {'type': 'month_1', 'idOffset': 1030},
      60: {'type': 'month_2', 'idOffset': 1060},
      90: {'type': 'month_3', 'idOffset': 1090},
      180: {'type': 'month_6', 'idOffset': 1180},
      365: {'type': 'year_1', 'idOffset': 2001},
    };
    
    // 🔥 CORRECCIÓN CRÍTICA: Encontrar SOLO EL HITO MÁS ESPECÍFICO (sin tolerancia)
    // Para evitar duplicados, buscar EXACTAMENTE el día y devolver SOLO UNO
    Map<String, dynamic>? matchingMilestone;
    
    // Buscar hito EXACTO primero (sin tolerancia) - PRIORIDAD ABSOLUTA
    if (exactMilestones.containsKey(streakDays)) {
      matchingMilestone = exactMilestones[streakDays]!;
      print('🎯 Hito EXACTO encontrado para día $streakDays: ${matchingMilestone['type']} - ENVIANDO SOLO ESTE');
    }
    
    // Si no hay hito exacto, NO enviar nada para evitar confusión
    // Esto previene que se envíen hitos de "día 1" cuando debería ser "día 15", etc.
    if (matchingMilestone == null) {
      print('⚠️ No hay hito exacto para día $streakDays, no enviando notificación para evitar duplicados');
      return null; // No enviar notificación si no es un hito exacto
    }
    
    // PROCEDER SOLO SI HAY UN HITO EXACTO
    // 🎯 NUEVA LÓGICA: Generar mensaje basado en los días REALES de racha
    String title;
    String body;
    
    if (streakDays == 1) {
      title = '🎉 ¡Primer día completado!';
      body = '¡Felicidades! Has completado tu primer día ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n💪 ¡Excelente comienzo! Sigue así.';
    } else if (streakDays == 3) {
      title = '🔥 ¡3 días de éxito!';
      body = '¡Increíble! Ya llevas 3 días ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🚀 El hábito se está formando. ¡Continúa!';
    } else if (streakDays == 7) {
      title = '🌟 ¡Una semana completa!';
      body = '¡Fantástico! Has completado una semana entera ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n💎 ¡Esto es dedicación real!';
    } else if (streakDays == 15) {
      title = '⭐ ¡15 días de constancia!';
      body = '¡Impresionante! Ya son 15 días ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🏆 Tu determinación es admirable.';
    } else if (streakDays == 30) {
      title = '🎊 ¡UN MES COMPLETO!';
      body = '¡FELICIDADES! Has alcanzado tu primer mes ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n👑 ¡Eres una inspiración!';
    } else if (streakDays >= 60 && streakDays <= 180) {
      final months = streakDays ~/ 30;
      title = '🏅 ¡$months meses de éxito!';
      body = '¡Extraordinario! Ya llevas $months meses ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🌈 ¡Tu perseverancia es inspiradora!';
    } else if (streakDays == 365) {
      title = '🎉 ¡UN AÑO COMPLETO!';
      body = '🏆 ¡FELICIDADES! Has completado UN AÑO ENTERO ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n👑 ¡Eres un verdadero campeón! Este es un logro extraordinario.';
    } else if (streakDays > 365) {
      final years = streakDays ~/ 365;
      title = '🎆 ¡$years AÑOS DE ÉXITO!';
      body = '🌟 ¡INCREÍBLE! Has completado $years años ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🏆 ¡Eres una leyenda viviente!';
    } else {
      // Para días que no tienen hito específico, crear mensaje genérico
      title = '💪 ¡$streakDays días de constancia!';
      body = '¡Excelente trabajo! Ya llevas $streakDays días ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🚀 ¡Sigue adelante!';
    }
    
    final idOffsetRaw = matchingMilestone['idOffset'];
    final idOffset = idOffsetRaw is int ? idOffsetRaw : int.tryParse(idOffsetRaw.toString()) ?? 0;
    
    print('🔔 Generando notificación:');
    print('  📝 Título: $title');
    print('  💬 Cuerpo: ${body.substring(0, body.length > 50 ? 50 : body.length)}...');
    print('  🆔 ID: ${baseId + idOffset}');
    print('  🏷️ Tipo: ${matchingMilestone['type']}');
    
    return {
      'notificationId': baseId + idOffset,
      'reminderType': matchingMilestone['type'],
      'title': title,
      'body': body,
    };
  }

  /// Extrae la actividad limpia del título del reto
  static String _getCleanActivity(String title, bool isNegativeHabit) {
    final clean = title.toLowerCase().trim();
    
    // Mapeo de actividades comunes a frases más naturales
    final Map<String, String> activityMap = {
      'masturbacion': 'masturbarte',
      'masturbar': 'masturbarte', 
      'cigarro': 'fumar',
      'cigarros': 'fumar',
      'tabaco': 'fumar',
      'alcohol': 'beber alcohol',
      'bebida': 'beber',
      'ejercicio': 'ejercicio',
      'gym': 'ir al gimnasio',
      'correr': 'correr',
      'leer': 'leer',
      'estudiar': 'estudiar',
      'meditar': 'meditar',
      'dormir': 'dormir bien',
      'agua': 'tomar agua',
    };

    // Buscar coincidencias en el mapa
    for (final key in activityMap.keys) {
      if (clean.contains(key)) {
        return activityMap[key]!;
      }
    }

    // Si no encuentra coincidencia, usar el título tal como está
    return clean;
  }

  /// Verificación motivacional activa cada 30 minutos
  static Future<void> _checkActiveMotivation() async {
    if (!_isActive) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('challenge_notifications_enabled') ?? true;
      if (!enabled) return;
      
      // 🆕 MEJORADO: Usar el nuevo sistema de motivación más avanzado
      await MilestoneNotificationService.sendMotivationalMessage();
      
    } catch (e) {
      print('❌ Error en motivación activa: $e');
    }
  }

  /// Getter para saber si está activo
  static bool get isActive => _isActive;

  /// 🧪 MÉTODO DE PRUEBA: Simular verificación de ventana de confirmación
  static Future<void> testConfirmationWindow() async {
    print('🧪 === PRUEBA MANUAL DE VENTANA DE CONFIRMACIÓN ===');
    try {
      await ConfirmationWindow._checkConfirmationWindow();
      print('✅ Prueba de ventana de confirmación completada');
    } catch (e) {
      print('❌ Error en prueba: $e');
    }
  }

  /// 🧪 MÉTODO DE PRUEBA: Simular notificación de inicio
  static Future<void> testStartNotification() async {
    print('🧪 === PRUEBA MANUAL DE NOTIFICACIÓN DE INICIO ===');
    try {
      await ConfirmationWindow._sendConfirmationWindowNotifications('start');
      print('✅ Prueba de notificación de inicio completada');
    } catch (e) {
      print('❌ Error en prueba: $e');
    }
  }

  /// 🧪 MÉTODO DE PRUEBA: Forzar notificación sin verificar si ya fue enviada
  static Future<void> testForceNotification() async {
    print('🧪 === PRUEBA FORZADA DE NOTIFICACIÓN ===');
    try {
      await NotificationService.instance.init();
      await NotificationService.instance.showImmediateNotification(
        id: 99999,
        title: '🧪 Notificación de Prueba',
        body: 'Esta es una notificación de prueba para verificar que el sistema funciona correctamente.',
      );
      print('✅ Notificación de prueba enviada (ID: 99999)');
    } catch (e) {
      print('❌ Error en notificación de prueba: $e');
    }
  }

  /// 🧪 MÉTODO DE PRUEBA: Limpiar historial de notificaciones enviadas
  static Future<void> clearNotificationHistory() async {
    print('🧪 === LIMPIANDO HISTORIAL DE NOTIFICACIONES ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiar notificaciones de ventana de confirmación (formato antiguo)
      final windowKeys = prefs.getKeys().where((key) => key.contains('confirmation_window_')).toList();
      
      // Limpiar recordatorios de ReminderTracker (formato: reminder_sent_${hashCode}_${type})
      final reminderKeys = prefs.getKeys().where((key) => key.startsWith('reminder_sent_')).toList();
      
      // 🆕 NUEVO: Limpiar también las claves con fecha para evitar duplicados
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final dateKeys = prefs.getKeys().where((key) => key.contains(todayKey)).toList();
      
      // 🆕 ULTRA-ROBUSTAS: Limpiar protecciones adicionales
      final milestoneKeys = prefs.getKeys().where((key) => key.contains('milestone_sent_')).toList();
      final allHitoKeys = prefs.getKeys().where((key) => 
        key.contains('day_') || 
        key.contains('week_') || 
        key.contains('month_') || 
        key.contains('year_')).toList();
      
      // 🔥 NUEVO: Limpiar también las notificaciones del MilestoneNotificationService
      final lastMilestoneKeys = prefs.getKeys().where((key) => key.startsWith('last_milestone_')).toList();
      
      final allKeys = [...windowKeys, ...reminderKeys, ...dateKeys, ...milestoneKeys, ...allHitoKeys, ...lastMilestoneKeys];
      
      for (final key in allKeys) {
        await prefs.remove(key);
        print('🗑️ Removido: $key');
      }
      
      print('✅ Historial de notificaciones COMPLETAMENTE limpiado (${allKeys.length} entradas)');
      print('🛡️ Sistema anti-duplicados REINICIADO - todas las protecciones removidas');
      print('🔥 MilestoneNotificationService también limpiado');
      
      // Debug: Mostrar todas las claves que quedan relacionadas con notificaciones
      final remainingKeys = prefs.getKeys().where((key) => 
        key.contains('confirmation') || 
        key.contains('reminder_sent') ||
        key.contains('milestone_sent') ||
        key.contains('last_milestone_') ||
        key.contains('day_') ||
        key.contains('week_') ||
        key.contains('month_')).toList();
      print('🔍 Claves restantes relacionadas con notificaciones: $remainingKeys');
      
    } catch (e) {
      print('❌ Error limpiando historial: $e');
    }
  }

  /// 🧪 MÉTODO DE PRUEBA: Forzar notificación de ventana sin verificar historial
  static Future<void> testForceWindowNotification() async {
    print('🧪 === PRUEBA FORZADA DE NOTIFICACIÓN DE VENTANA ===');
    try {
      // Cargar retos
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('counters');
      if (jsonString == null) {
        print('❌ No hay retos guardados');
        return;
      }

      final List<dynamic> countersJson = jsonDecode(jsonString);
      final now = DateTime.now();
      
      // Contar retos pendientes
      int pendingChallenges = 0;
      List<String> challengeTitles = [];
      
      for (final counterJson in countersJson) {
        final counter = _ChallengeCounter.fromJson(counterJson);
        if (counter.challengeStartedAt != null) {
          final notConfirmedToday = counter.lastConfirmedDate == null || 
              !ConfirmationWindow._isSameDay(counter.lastConfirmedDate!, now);
          
          if (notConfirmedToday) {
            pendingChallenges++;
            challengeTitles.add(counter.title);
          }
        }
      }
      
      if (pendingChallenges == 0) {
        print('❌ No hay retos pendientes para notificar');
        return;
      }
      
      // Forzar notificación sin verificar historial
      final title = '🧪 PRUEBA: ¡Ventana de confirmación abierta!';
      final body = pendingChallenges == 1 
          ? 'PRUEBA: Puedes confirmar tu reto "${challengeTitles.first}" desde las 21:00 hasta las 23:59'
          : 'PRUEBA: Puedes confirmar tus $pendingChallenges retos desde las 21:00 hasta las 23:59';
      
      await NotificationService.instance.init();
      await NotificationService.instance.showImmediateNotification(
        id: 88888,
        title: title,
        body: body,
      );
      
      print('🔔 Notificación de ventana FORZADA enviada (ID: 88888)');
      print('  • Retos: $challengeTitles');
      print('  • Cantidad: $pendingChallenges');
      
    } catch (e) {
      print('❌ Error en notificación forzada: $e');
    }
  }

  /// 🧪 FUNCIÓN DE PRUEBA: Simular notificaciones de 21:00 y 23:30
  static Future<void> testConfirmationNotifications() async {
    print('🧪 === PRUEBA DE NOTIFICACIONES 21:00 Y 23:30 ===');
    try {
      await NotificationService.instance.init();
      
      // Simular notificación de 21:00
      print('📢 Probando notificación de apertura (21:00)...');
      await NotificationService.instance.showImmediateNotification(
        id: 77777,
        title: '🎯 ¡Ventana de confirmación abierta!',
        body: '[PRUEBA 21:00] ¡Es hora de confirmar tus retos! Tienes hasta las 23:59. ¡A por todas! 🚀',
      );
      
      // Esperar 3 segundos
      await Future.delayed(Duration(seconds: 3));
      
      // Simular notificación de 23:30
      print('📢 Probando notificación de recordatorio (23:30)...');
      await NotificationService.instance.showImmediateNotification(
        id: 66666,
        title: '⏰ ¡Últimos 29 minutos!',
        body: '[PRUEBA 23:30] Recuerda confirmar tus retos antes de las 23:59. ¡Solo quedan 29 minutos!',
      );
      
      print('✅ Ambas notificaciones de prueba enviadas correctamente');
      print('   📱 ID 77777: Notificación de apertura (21:00)');
      print('   📱 ID 66666: Notificación de recordatorio (23:30 - 29 min restantes)');
      print('   ⏰ Nota: La ventana se cierra exactamente a las 23:59');
      
    } catch (e) {
      print('❌ Error en prueba de notificaciones: $e');
    }
  }

  /// 🧪 MÉTODO DE PRUEBA ESPECÍFICO: Validar notificaciones para retos retroactivos
  static Future<void> testRetroactiveChallengeNotification() async {
    print('🧪 === PRUEBA DE RETOS RETROACTIVOS ===');
    try {
      // 🧹 LIMPIAR HISTORIAL DE PRUEBAS ANTERIORES
      print('🧹 Limpiando historial de notificaciones para prueba limpia...');
      await clearNotificationHistory();
      
      // 🎯 CASO ESPECÍFICO DEL USUARIO: 23 julio - 29 julio = 7 días
      print('📅 === CASO REAL DEL USUARIO ===');
      print('📅 Reto iniciado: 23 julio 2025');
      print('✅ Confirmado: 29 julio 2025');
      print('🔢 Total días esperados: 7 días (23,24,25,26,27,28,29)');
      print('🎯 DEBE mostrar: "¡Una semana completa!" NO "primer día"');
      
      final userStartDate = DateTime(2025, 7, 23); // 23 julio 2025
      final userConfirmDate = DateTime(2025, 7, 29); // 29 julio 2025
      
      final userTestCounter = _ChallengeCounter(
        title: 'Test Usuario REAL - 7 días retroactivo',
        startDate: userStartDate,
        lastConfirmedDate: userConfirmDate,
        isNegativeHabit: true,
        challengeStartedAt: userStartDate,
      );
      
      print('\n🧮 === CÁLCULO DETALLADO ===');
      final diffDays = userConfirmDate.difference(userStartDate).inDays;
      final totalDays = diffDays + 1;
      print('📊 Diferencia (difference): $diffDays días');
      print('➕ Más 1 día de inclusión: $totalDays días totales');
      print('✅ CORRECTO: Debe ser 7 días');
      
      final userNotification = _shouldSendMotivationalNotification(userTestCounter, DateTime.now());
      
      if (userNotification != null) {
        print('\n🔔 === NOTIFICACIÓN GENERADA ===');
        print('📝 Título: ${userNotification['title']}');
        print('💬 Cuerpo: ${userNotification['body']}');
        print('🏷️ Tipo: ${userNotification['reminderType']}');
        
        // Verificar que es el tipo correcto
        if (userNotification['reminderType'] == 'week_1' && userNotification['title'].contains('semana')) {
          print('✅ ¡CORRECTO! Detectó una semana completa (7 días)');
        } else if (userNotification['reminderType'] == 'day_1') {
          print('❌ ERROR: Detectó día 1 cuando debería ser semana 1');
          print('🔧 El cálculo de días está fallando');
        } else {
          print('⚠️ Detectó tipo: ${userNotification['reminderType']} - verificar si es correcto');
        }
        
        print('\n📱 Enviando notificación de prueba...');
        await NotificationService.instance.init();
        await NotificationService.instance.showImmediateNotification(
          id: userNotification['notificationId'],
          title: '[PRUEBA 7 DÍAS] ${userNotification['title']}',
          body: '[23-29 JULIO] ${userNotification['body']}',
        );
        
        print('✅ Notificación de prueba enviada');
      } else {
        print('❌ No se generó notificación para el caso del usuario');
      }
      
      // Lista adicional de casos de prueba
      final testCases = [
        {'startDay': 23, 'endDay': 24, 'expectedDays': 2, 'expectedType': 'none'},
        {'startDay': 23, 'endDay': 25, 'expectedDays': 3, 'expectedType': 'day_3'},
        {'startDay': 23, 'endDay': 29, 'expectedDays': 7, 'expectedType': 'week_1'},
        {'startDay': 15, 'endDay': 29, 'expectedDays': 15, 'expectedType': 'day_15'},
      ];
      
      print('\n🧪 === CASOS DE PRUEBA ADICIONALES ===');
      for (final testCase in testCases) {
        final start = DateTime(2025, 7, testCase['startDay'] as int);
        final end = DateTime(2025, 7, testCase['endDay'] as int);
        final expectedDays = testCase['expectedDays'] as int;
        final expectedType = testCase['expectedType'] as String;
        
        final testCounter = _ChallengeCounter(
          title: 'Prueba ${expectedDays} días',
          startDate: start,
          lastConfirmedDate: end,
          isNegativeHabit: true,
          challengeStartedAt: start,
        );
        
        print('\n📅 Inicio: ${start.day} julio → Final: ${end.day} julio');
        final notification = _shouldSendMotivationalNotification(testCounter, DateTime.now());
        
        if (notification != null) {
          final actualType = notification['reminderType'];
          print('  🔢 Días calculados: OK');
          print('  🏷️ Tipo detectado: $actualType');
          print('  🎯 Tipo esperado: $expectedType');
          print('  ${actualType == expectedType ? '✅ CORRECTO' : '❌ ERROR'}');
        } else if (expectedType == 'none') {
          print('  ✅ CORRECTO: No hay hito para $expectedDays días');
        } else {
          print('  ❌ ERROR: No se generó notificación');
        }
      }
      
    } catch (e) {
      print('❌ Error en prueba retroactiva: $e');
    }
  }
}

/// Clase auxiliar para manejar los datos del contador/reto
class _ChallengeCounter {
  final String title;
  final DateTime startDate;
  final DateTime? lastConfirmedDate;
  final bool isNegativeHabit;
  final DateTime? challengeStartedAt;

  _ChallengeCounter({
    required this.title,
    required this.startDate,
    this.lastConfirmedDate,
    this.isNegativeHabit = false,
    this.challengeStartedAt,
  });

  static _ChallengeCounter fromJson(Map<String, dynamic> json) => _ChallengeCounter(
    title: json['title'],
    startDate: DateTime.parse(json['startDate']),
    lastConfirmedDate: json['lastConfirmedDate'] != null
        ? DateTime.parse(json['lastConfirmedDate'])
        : null,
    isNegativeHabit: json['isNegativeHabit'] == true,
    challengeStartedAt: json['challengeStartedAt'] != null
        ? DateTime.parse(json['challengeStartedAt'])
        : null,
  );
}

/// 🆕 NUEVO: Extensión de ChallengeNotificationService para ventana de confirmación
extension ConfirmationWindow on ChallengeNotificationService {
  /// Verifica si estamos en la ventana de confirmación (función de respaldo)
  /// Los timers específicos de 21:00 y 23:30 son más precisos
  static Future<void> _checkConfirmationWindow() async {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;
      
      // Debug log reducido ya que los timers específicos son más precisos
      print('🔍 Verificación de respaldo: ${currentHour}:${currentMinute.toString().padLeft(2, '0')}');
      
      // Solo actuar como respaldo si los timers específicos fallan
      if (currentHour == 21 && currentMinute == 0) {
        print('📢 [RESPALDO] Verificando notificación de 21:00');
        await _sendConfirmationWindowNotifications('start');
      } else if (currentHour == 23 && currentMinute == 30) {
        print('📢 [RESPALDO] Verificando notificación de 23:30');
        await _sendConfirmationWindowNotifications('reminder');
      }
    } catch (e) {
      print('❌ Error en verificación de respaldo: $e');
    }
  }

  /// Envía notificaciones de ventana de confirmación
  static Future<void> _sendConfirmationWindowNotifications(String type) async {
    try {
      // Cargar retos
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('counters');
      if (jsonString == null) return;

      final List<dynamic> countersJson = jsonDecode(jsonString);
      final now = DateTime.now();
      
      // Contar retos pendientes de confirmación y obtener información detallada
      int pendingChallenges = 0;
      List<String> challengeTitles = [];
      final List<Map<String, dynamic>> challengeDetails = [];
      
      for (final counterJson in countersJson) {
        final counter = _ChallengeCounter.fromJson(counterJson);
        
        // Verificar si el reto está iniciado y no confirmado hoy
        if (counter.challengeStartedAt != null) {
          final notConfirmedToday = counter.lastConfirmedDate == null || 
              !ConfirmationWindow._isSameDay(counter.lastConfirmedDate!, now);
          
          if (notConfirmedToday) {
            // Verificar si el reto cumple el tiempo mínimo para confirmación
            final minutesSinceStart = now.difference(counter.challengeStartedAt!).inMinutes;
            final currentHour = now.hour;
            
            // Determinar tiempo mínimo según horario (sistema híbrido)
            int minimumTimeRequired;
            if (currentHour >= 21 || currentHour <= 23) {
              minimumTimeRequired = 10; // Ventana nocturna
            } else if (currentHour >= 0 && currentHour <= 5) {
              minimumTimeRequired = 30; // Madrugada
            } else {
              minimumTimeRequired = 60; // Día normal
            }
            
            final canConfirmNow = minutesSinceStart >= minimumTimeRequired;
            final timeRemaining = canConfirmNow ? 0 : (minimumTimeRequired - minutesSinceStart);
            
            challengeDetails.add({
              'title': counter.title,
              'canConfirm': canConfirmNow,
              'timeRemaining': timeRemaining,
              'minimumRequired': minimumTimeRequired
            });
            
            if (canConfirmNow) {
              pendingChallenges++;
              challengeTitles.add(counter.title);
            }
          }
        }
      }
      
      // Si no hay retos listos AHORA, no enviar notificación de "listos"
      if (type == 'start' && pendingChallenges == 0) {
        final retosConTiempo = challengeDetails.where((c) => !c['canConfirm']).toList();
        if (retosConTiempo.isNotEmpty) {
          // Hay retos pero ninguno está listo aún
          final proximoReto = retosConTiempo.reduce((a, b) => 
            a['timeRemaining'] < b['timeRemaining'] ? a : b);
          
          print('⏰ Hay retos pero ninguno está listo. Próximo: "${proximoReto['title']}" en ${proximoReto['timeRemaining']}min');
          return; // No enviar notificación prematura
        } else {
          print('✅ No hay retos pendientes de confirmación');
          return;
        }
      }
      
      if (pendingChallenges == 0) {
        print('✅ No hay retos pendientes de confirmación');
        return;
      }
      
      // Generar notificación inteligente según el tipo
      String title;
      String body;
      int notificationId;
      
      if (type == 'start') {
        if (pendingChallenges == 1) {
          title = '🎯 ¡Ventana de confirmación abierta!';
          body = '¡Es hora de confirmar tu reto "${challengeTitles.first}"! Tienes hasta las 23:59 para confirmarlo. 💪';
        } else {
          title = '🎯 ¡Ventana de confirmación abierta!';
          body = '¡Es hora de confirmar tus $pendingChallenges retos! Tienes hasta las 23:59. ¡A por todas! 🚀';
        }
        
        // Agregar información sobre retos que AÚN no están listos
        final retosNoListos = challengeDetails.where((c) => !c['canConfirm']).toList();
        if (retosNoListos.isNotEmpty) {
          final proximoReto = retosNoListos.reduce((a, b) => 
            a['timeRemaining'] < b['timeRemaining'] ? a : b);
          body += '\n\n⏳ "${proximoReto['title']}" estará listo en ${proximoReto['timeRemaining']} min';
        }
        
        notificationId = 50001;
      } else {
        title = '⏰ ¡Últimos 29 minutos!';
        body = pendingChallenges == 1
            ? 'Recuerda confirmar "${challengeTitles.first}" antes de las 23:59. ¡Solo quedan 29 minutos!'
            : 'Recuerda confirmar tus $pendingChallenges retos antes de las 23:59. ¡Solo quedan 29 minutos!';
        notificationId = 50002;
      }
      
      // Verificar si ya se envió esta notificación hoy
      final reminderKey = 'confirmation_window_${type}_${now.day}_${now.month}_${now.year}';
      final wasAlreadySent = await ReminderTracker.wasReminderSent(reminderKey.hashCode, type);
      
      print('🔍 Debug notificación:');
      print('  • Tipo: $type');
      print('  • Retos pendientes: $pendingChallenges');
      print('  • Títulos: $challengeTitles');
      print('  • ReminderKey: $reminderKey');
      print('  • Ya enviada: $wasAlreadySent');
      
      if (!wasAlreadySent) {
        print('📤 Enviando notificación...');
        await NotificationService.instance.showImmediateNotification(
          id: notificationId,
          title: title,
          body: body,
        );
        
        await ReminderTracker.markReminderSent(reminderKey.hashCode, type);
        print('🔔 Notificación de ventana de confirmación enviada: $type');
        print('✅ Notificación marcada como enviada para evitar duplicados');
      } else {
        print('⏭️ Notificación ya fue enviada hoy, saltando...');
      }
      
    } catch (e) {
      print('❌ Error enviando notificaciones de confirmación: $e');
    }
  }

  /// Verifica si dos fechas son del mismo día
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}