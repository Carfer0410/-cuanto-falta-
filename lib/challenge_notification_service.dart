import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';
import 'reminder_tracker.dart';
import 'milestone_notification_service.dart';

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
    print('🕘 Timer sincronizado: próxima verificación exacta en ${delay.inMinutes} minutos (${next21.toString().substring(11, 16)})');
    
    // Timer que se ejecuta exactamente a las 21:00
    Timer(delay, () {
      print('🎯 ¡Timer sincronizado ejecutándose a las 21:00 exactas!');
      ConfirmationWindow._checkConfirmationWindow();
      
      // Programar el siguiente día
      _setupSyncedConfirmationTimer();
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
        
        // Solo procesar retos que han sido iniciados
        if (counter.challengeStartedAt != null) {
          final notificationInfo = _shouldSendMotivationalNotification(
            counter, 
            now
          );
          
          if (notificationInfo != null) {
            // Verificar si ya se envió esta notificación específica
            final wasAlreadySent = await ReminderTracker.wasReminderSent(
              counter.title.hashCode, 
              notificationInfo['reminderType']
            );
            
            if (!wasAlreadySent) {
              // Enviar notificación motivacional
              await NotificationService.instance.showImmediateNotification(
                id: notificationInfo['notificationId'],
                title: notificationInfo['title'],
                body: notificationInfo['body'],
              );

              // Marcar como enviado para evitar duplicados
              await ReminderTracker.markReminderSent(
                counter.title.hashCode, 
                notificationInfo['reminderType']
              );

              print('✅ Notificación motivacional enviada: ${notificationInfo['title']} para ${counter.title}');
            } else {
              print('⏭️ Notificación ya enviada: ${notificationInfo['reminderType']} para ${counter.title}');
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
    
    if (counter.challengeStartedAt == null) return null;

    final startDate = counter.challengeStartedAt!;
    final daysPassed = now.difference(startDate).inDays;
    final baseId = counter.title.hashCode;
    
    // Verificar si el reto sigue activo (última confirmación no muy antigua)
    final isActive = counter.lastConfirmedDate != null && 
                    now.difference(counter.lastConfirmedDate!).inDays <= 2;
    
    if (!isActive) return null; // No enviar si el reto parece abandonado

    // Sistema de notificaciones progresivas
    final challengeType = counter.isNegativeHabit ? 'dejar' : 'hacer';
    final activity = _getCleanActivity(counter.title, counter.isNegativeHabit);
    
    // DÍA 1: Primer día
    if (daysPassed == 1) {
      return {
        'notificationId': baseId + 1001,
        'reminderType': 'day_1',
        'title': '🎉 ¡Primer día completado!',
        'body': '¡Felicidades! Has completado tu primer día ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n💪 ¡Excelente comienzo! Sigue así.'
      };
    }

    // DÍA 3: Tercer día
    if (daysPassed == 3) {
      return {
        'notificationId': baseId + 1003,
        'reminderType': 'day_3',
        'title': '🔥 ¡3 días de éxito!',
        'body': '¡Increíble! Ya llevas 3 días ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🚀 El hábito se está formando. ¡Continúa!'
      };
    }

    // SEMANA 1: Una semana
    if (daysPassed == 7) {
      return {
        'notificationId': baseId + 1007,
        'reminderType': 'week_1',
        'title': '🌟 ¡Una semana completa!',
        'body': '¡Fantástico! Has completado una semana entera ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n💎 ¡Esto es dedicación real!'
      };
    }

    // 15 DÍAS: Dos semanas
    if (daysPassed == 15) {
      return {
        'notificationId': baseId + 1015,
        'reminderType': 'day_15',
        'title': '⭐ ¡15 días de constancia!',
        'body': '¡Impresionante! Ya son 15 días ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🏆 Tu determinación es admirable.'
      };
    }

    // MES 1: Un mes
    if (daysPassed == 30) {
      return {
        'notificationId': baseId + 1030,
        'reminderType': 'month_1',
        'title': '🎊 ¡UN MES COMPLETO!',
        'body': '¡FELICIDADES! Has alcanzado tu primer mes ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n👑 ¡Eres una inspiración!'
      };
    }

    // MESES SIGUIENTES: Cada mes hasta el año
    for (int month = 2; month <= 12; month++) {
      final targetDays = month * 30; // Aproximación
      if (daysPassed >= targetDays - 2 && daysPassed <= targetDays + 2) {
        return {
          'notificationId': baseId + 1000 + month * 100,
          'reminderType': 'month_$month',
          'title': '🏅 ¡$month meses de éxito!',
          'body': '¡Extraordinario! Ya llevas $month meses ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🌈 ¡Tu perseverancia es inspiradora!'
        };
      }
    }

    // AÑO 1: Un año completo
    if (daysPassed >= 363 && daysPassed <= 367) { // Rango de tolerancia
      return {
        'notificationId': baseId + 2001,
        'reminderType': 'year_1',
        'title': '🎉 ¡UN AÑO COMPLETO!',
        'body': '🏆 ¡FELICIDADES! Has completado UN AÑO ENTERO ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n👑 ¡Eres un verdadero campeón! Este es un logro extraordinario.'
      };
    }

    // AÑOS SIGUIENTES: Cada año
    final years = (daysPassed / 365).floor();
    if (years >= 2) {
      final yearTargetDays = years * 365;
      if (daysPassed >= yearTargetDays - 3 && daysPassed <= yearTargetDays + 3) {
        return {
          'notificationId': baseId + 2000 + years,
          'reminderType': 'year_$years',
          'title': '🎆 ¡$years AÑOS DE ÉXITO!',
          'body': '🌟 ¡INCREÍBLE! Has completado $years años ${challengeType == 'dejar' ? 'sin' : 'haciendo'} $activity.\n\n🏆 ¡Eres una leyenda viviente!'
        };
      }
    }

    return null; // No enviar notificación en este momento
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
      final reminderKeys = prefs.getKeys().where((key) => key.startsWith('reminder_sent_') && key.contains('_start')).toList();
      final reminderKeys2 = prefs.getKeys().where((key) => key.startsWith('reminder_sent_') && key.contains('_reminder')).toList();
      
      final allKeys = [...windowKeys, ...reminderKeys, ...reminderKeys2];
      
      for (final key in allKeys) {
        await prefs.remove(key);
        print('🗑️ Removido: $key');
      }
      
      print('✅ Historial de notificaciones limpiado (${allKeys.length} entradas)');
      
      // Debug: Mostrar todas las claves que quedan relacionadas con notificaciones
      final remainingKeys = prefs.getKeys().where((key) => 
        key.contains('confirmation') || 
        key.contains('reminder_sent')).toList();
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
  /// Verifica si estamos en la ventana de confirmación y envía notificaciones
  static Future<void> _checkConfirmationWindow() async {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;
      
      // Debug log para verificar que el timer está funcionando
      print('🔍 Verificando ventana de confirmación: ${currentHour}:${currentMinute.toString().padLeft(2, '0')}');
      
      // Solo actuar en momentos específicos o ventana de inicio
      if (currentHour == 21 && currentMinute >= 0 && currentMinute <= 2) {
        // 21:00-21:02 - Ventana de inicio (más flexible para capturar 21:00)
        print('📢 Enviando notificación de inicio de ventana (21:0${currentMinute})');
        await _sendConfirmationWindowNotifications('start');
      } else if (currentHour == 23 && currentMinute == 30) {
        // 23:30 exacto - Recordatorio de últimos 29 minutos
        print('📢 Enviando notificación de recordatorio (23:30 exacto)');
        await _sendConfirmationWindowNotifications('reminder');
      }
    } catch (e) {
      print('❌ Error en _checkConfirmationWindow: $e');
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
          title = '🎯 ¡Reto "${challengeTitles.first}" listo!';
          body = 'Tu reto ya cumplió el tiempo mínimo y puedes confirmarlo hasta las 23:59';
        } else {
          title = '🎯 ¡$pendingChallenges retos listos!';
          body = 'Los siguientes retos están disponibles para confirmar: ${challengeTitles.join(", ")}';
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
            ? 'No olvides confirmar "${challengeTitles.first}" antes de las 23:59'
            : 'No olvides confirmar tus $pendingChallenges retos antes de las 23:59';
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
