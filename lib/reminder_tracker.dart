import 'package:shared_preferences/shared_preferences.dart';

class ReminderTracker {
  static const String _keyPrefix = 'reminder_sent_';

  /// Verifica si ya se envió un recordatorio específico
  static Future<bool> wasReminderSent(int eventId, String reminderType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${eventId}_$reminderType';
    return prefs.getBool(key) ?? false;
  }

  /// Marca un recordatorio como enviado
  static Future<void> markReminderSent(int eventId, String reminderType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${eventId}_$reminderType';
    await prefs.setBool(key, true);
    print('📝 Recordatorio marcado como enviado: $reminderType para evento $eventId');
  }

  /// Limpia recordatorios de eventos pasados (opcional, para mantener limpia la memoria)
  static Future<void> cleanOldReminders(List<int> activeEventIds) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    
    for (final key in keys) {
      // Extraer ID del evento de la clave
      final parts = key.replaceFirst(_keyPrefix, '').split('_');
      if (parts.isNotEmpty) {
        final eventId = int.tryParse(parts[0]);
        if (eventId != null && !activeEventIds.contains(eventId)) {
          await prefs.remove(key);
          print('🧹 Recordatorio limpiado para evento eliminado: $eventId');
        }
      }
    }
  }

  /// Obtiene tipos de recordatorio disponibles
  static List<String> get reminderTypes => [
    '1month',
    '2weeks', 
    '1week',
    '3days',
    '1day',
    'today'
  ];
}
