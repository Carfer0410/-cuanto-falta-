import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'notification_service.dart';
import 'reminder_tracker.dart';

class SimpleEventChecker {
  static Timer? _timer;
  static bool _isActive = false;

  /// Inicia el sistema de verificación simple con Timer
  static Future<void> startChecking() async {
    if (_isActive) return;
    
    // Verificar si las notificaciones están habilitadas
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('event_notifications_enabled') ?? true;
    if (!enabled) {
      print('🔕 SimpleEventChecker: Notificaciones de eventos deshabilitadas');
      return;
    }
    
    _isActive = true;
    final frequency = int.parse(prefs.getString('event_frequency') ?? '5');
    print('🔄 SimpleEventChecker: Iniciando verificación cada $frequency minutos');
    
    // Verificar inmediatamente
    _checkEventsNow();
    
    // Programar verificaciones según la frecuencia configurada
    _timer = Timer.periodic(Duration(minutes: frequency), (timer) {
      _checkEventsNow();
    });
  }

  /// Detiene el sistema de verificación
  static void stopChecking() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    print('🛑 SimpleEventChecker: Verificación detenida');
  }

  /// Verifica eventos inmediatamente
  static Future<void> checkEventsNow() async {
    print('🔍 SimpleEventChecker: Verificación manual iniciada');
    await _checkEventsNow();
  }

  /// Lógica principal de verificación
  static Future<void> _checkEventsNow() async {
    try {
      // Inicializar servicio de notificaciones
      await NotificationService.instance.init();

      // Cargar todos los eventos de la base de datos
      final events = await DatabaseHelper.instance.getEvents();
      final now = DateTime.now();

      print('🔍 Verificando ${events.length} eventos para recordatorios...');

      for (final event in events) {
        final reminderInfo = _shouldSendReminder(event.targetDate, now, event.id, event.title);
        
        if (reminderInfo != null) {
          // Verificar si ya se envió este recordatorio
          final wasAlreadySent = await ReminderTracker.wasReminderSent(
            event.id ?? 0, 
            reminderInfo['reminderType']
          );
          
          if (!wasAlreadySent) {
            // Crear notificación con mensaje personalizado según el tiempo restante
            await NotificationService.instance.showImmediateNotification(
              id: reminderInfo['notificationId'],
              title: reminderInfo['title'],
              body: reminderInfo['body'],
            );

            // Marcar como enviado para evitar duplicados
            await ReminderTracker.markReminderSent(
              event.id ?? 0, 
              reminderInfo['reminderType']
            );

            print('✅ Recordatorio enviado: ${reminderInfo['title']} para ${event.title}');
          } else {
            print('⏭️ Recordatorio ya enviado: ${reminderInfo['reminderType']} para ${event.title}');
          }
        }
      }
    } catch (e) {
      print('❌ Error en verificación de eventos: $e');
    }
  }

  /// Determina si debe enviar recordatorio y qué tipo
  static Map<String, dynamic>? _shouldSendReminder(DateTime eventDate, DateTime now, int? eventId, String eventTitle) {
    final difference = eventDate.difference(now).inDays;
    
    // ID único para cada tipo de recordatorio
    final baseId = eventId ?? eventDate.millisecondsSinceEpoch ~/ 1000;
    
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    if (difference >= 28 && difference <= 32) {
      return {
        'notificationId': baseId + 1000,
        'reminderType': '1month',
        'title': '📅 $eventTitle - 1 Mes',
        'body': '¡Tu evento "$eventTitle" se acerca!\nFaltan aproximadamente 30 días.\n\n📝 Es buen momento para empezar a planificar.'
      };
    } else if (difference >= 13 && difference <= 17) {
      return {
        'notificationId': baseId + 2000,
        'reminderType': '2weeks',
        'title': '📅 $eventTitle - 2 Semanas',
        'body': '⏰ Faltan 2 semanas para "$eventTitle".\n\n🎯 ¡Ya es hora de preparar los detalles!'
      };
    } else if (difference >= 6 && difference <= 8) {
      return {
        'notificationId': baseId + 3000,
        'reminderType': '1week',
        'title': '📅 $eventTitle - 1 Semana',
        'body': '🚨 ¡Solo falta 1 semana para "$eventTitle"!\n\n✅ Revisa que todo esté listo.'
      };
    } else if (difference >= 2 && difference <= 4) {
      return {
        'notificationId': baseId + 4000,
        'reminderType': '3days',
        'title': '📅 $eventTitle - 3 Días',
        'body': '⚡ ¡Faltan solo 3 días para "$eventTitle"!\n\n🎯 Los últimos preparativos.'
      };
    } else if (difference == 1) {
      return {
        'notificationId': baseId + 5000,
        'reminderType': '1day',
        'title': '📅 ¡Mañana es "$eventTitle"!',
        'body': '🎉 Tu evento "$eventTitle" es MAÑANA.\n\n💫 ¡Todo listo para disfrutar!'
      };
    } else if (difference == 0 && today == eventDay) {
      return {
        'notificationId': baseId + 6000,
        'reminderType': 'today',
        'title': '🎯 ¡HOY es "$eventTitle"!',
        'body': '🎊 ¡El día que esperabas ha llegado!\n\n🚀 ¡Disfruta "$eventTitle" al máximo!'
      };
    }
    
    return null;
  }

  /// Getter para saber si está activo
  static bool get isActive => _isActive;
}
