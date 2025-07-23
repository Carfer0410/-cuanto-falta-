import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';
import 'reminder_tracker.dart';
import 'milestone_notification_service.dart';

class ChallengeNotificationService {
  static Timer? _timer;
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
    
    // TIMER MEJORADO: Verificaciones más frecuentes para mejor cobertura
    // Programar verificaciones según la frecuencia configurada
    _timer = Timer.periodic(Duration(hours: frequency), (timer) {
      _checkChallengesNow();
    });
    
    // NUEVO: Timer adicional cada 30 minutos para motivación activa
    Timer.periodic(Duration(minutes: 30), (timer) {
      _checkActiveMotivation();
    });
    _timer = Timer.periodic(Duration(hours: frequency), (timer) {
      _checkChallengesNow();
    });
  }

  /// Detiene el sistema de verificación
  static void stopChecking() {
    _timer?.cancel();
    _timer = null;
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
